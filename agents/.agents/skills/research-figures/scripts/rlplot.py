"""Publication plotting helpers for RL/MARL results.

Tidy input: a pandas DataFrame with one row per (method, seed, x) observation.
Requires matplotlib, numpy, pandas. Run inside the project's environment, e.g.
`pixi run python fig_script.py` or `uv run --with matplotlib --with pandas fig_script.py`.
"""

from __future__ import annotations

import argparse
from pathlib import Path

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# Okabe-Ito colour-blind safe palette
PALETTE = ["#0072B2", "#E69F00", "#009E73", "#D55E00", "#CC79A7", "#56B4E9", "#F0E442", "#000000"]
LINESTYLES = ["-", "--", "-.", ":", (0, (5, 1)), (0, (3, 1, 1, 1))]
MARKERS = ["o", "s", "^", "D", "v", "P", "X", "*"]


def setup(width_in: float = 3.33, aspect: float = 0.62, usetex: bool = False, fontsize: float = 8) -> None:
    """Set rcParams so figures match a LaTeX paper at the given width (inches)."""
    mpl.rcParams.update(
        {
            "figure.figsize": (width_in, width_in * aspect),
            "font.family": "serif",
            "font.size": fontsize,
            "axes.labelsize": fontsize,
            "axes.titlesize": fontsize,
            "legend.fontsize": fontsize - 1,
            "xtick.labelsize": fontsize - 1,
            "ytick.labelsize": fontsize - 1,
            "axes.prop_cycle": mpl.cycler(color=PALETTE),
            "axes.spines.top": False,
            "axes.spines.right": False,
            "axes.grid": True,
            "grid.alpha": 0.25,
            "lines.linewidth": 1.2,
            "legend.frameon": False,
            "savefig.bbox": "tight",
            "savefig.pad_inches": 0.01,
            "pdf.fonttype": 42,
            "ps.fonttype": 42,
            "text.usetex": usetex,
        }
    )


def style_for(methods: list[str], highlight: str | None = None) -> dict[str, dict]:
    """Stable colour/linestyle/marker per method; the highlighted method is drawn on top and thicker."""
    styles = {}
    for i, m in enumerate(methods):
        styles[m] = {
            "color": PALETTE[i % len(PALETTE)],
            "linestyle": LINESTYLES[i % len(LINESTYLES)],
            "marker": MARKERS[i % len(MARKERS)],
            "zorder": 3 if m == highlight else 2,
            "linewidth": 1.8 if m == highlight else 1.2,
        }
    return styles


def _bootstrap_ci(values: np.ndarray, stat=np.mean, n_boot: int = 2000, alpha: float = 0.05, rng=None):
    rng = rng or np.random.default_rng(0)
    values = np.asarray(values)
    if len(values) < 2:
        v = stat(values)
        return v, v
    idx = rng.integers(0, len(values), size=(n_boot, len(values)))
    boots = np.array([stat(values[i]) for i in idx])
    return np.quantile(boots, alpha / 2), np.quantile(boots, 1 - alpha / 2)


def iqm(values: np.ndarray) -> float:
    """Interquartile mean: mean of the middle 50% (Agarwal et al., 2021)."""
    v = np.sort(np.asarray(values))
    n = len(v)
    lo, hi = int(np.floor(0.25 * n)), int(np.ceil(0.75 * n))
    return float(v[lo:hi].mean()) if hi > lo else float(v.mean())


def learning_curves(df, x="step", y="return", hue="algo", seed="seed", ci="std", smooth: int = 1,
                    highlight=None, ax=None, order=None):
    """Mean over seeds with shaded band. ci: 'std' (mean +/- std) or 'bootstrap' (95% CI of the mean)."""
    if ax is None:
        fig, ax = plt.subplots()
    else:
        fig = ax.figure
    methods = order or list(dict.fromkeys(df[hue]))
    styles = style_for(methods, highlight)
    for m in methods:
        sub = df[df[hue] == m].sort_values(x)
        piv = sub.pivot_table(index=x, columns=seed, values=y)
        if smooth > 1:
            piv = piv.rolling(smooth, min_periods=1).mean()
        mean = piv.mean(axis=1)
        if ci == "bootstrap":
            bounds = np.array([_bootstrap_ci(r.dropna().values) for _, r in piv.iterrows()])
            lo, hi = bounds[:, 0], bounds[:, 1]
        else:
            sd = piv.std(axis=1).fillna(0)
            lo, hi = mean - sd, mean + sd
        st = styles[m]
        ax.plot(mean.index, mean.values, label=f"{m}", color=st["color"], linestyle=st["linestyle"],
                linewidth=st["linewidth"], zorder=st["zorder"])
        ax.fill_between(mean.index, lo, hi, color=st["color"], alpha=0.18, linewidth=0, zorder=st["zorder"] - 1)
    if df[x].max() >= 1e4:  # 20M instead of a "1e7" offset label
        ax.xaxis.set_major_formatter(mpl.ticker.EngFormatter(sep=""))
    ax.set_xlabel(x.replace("_", " ").capitalize())
    ax.set_ylabel(y.replace("_", " ").capitalize())
    ax.legend(loc="lower right")
    return fig, ax


def interval_estimates(df, y="return", hue="algo", task=None, stat="iqm", highlight=None, ax=None, order=None):
    """Point estimate (IQM or mean over seeds[, tasks]) with 95% bootstrap CI, one row per method."""
    if ax is None:
        fig, ax = plt.subplots()
    else:
        fig = ax.figure
    f = iqm if stat == "iqm" else np.mean
    methods = order or list(dict.fromkeys(df[hue]))
    styles = style_for(methods, highlight)
    for i, m in enumerate(methods):
        vals = df[df[hue] == m][y].to_numpy()
        point = f(vals)
        lo, hi = _bootstrap_ci(vals, stat=f)
        c = styles[m]["color"]
        ax.barh(i, hi - lo, left=lo, height=0.6, color=c, alpha=0.35)
        ax.plot([point, point], [i - 0.3, i + 0.3], color=c, linewidth=2)
    ax.set_yticks(range(len(methods)), methods)
    ax.invert_yaxis()
    ax.set_xlabel(f"{'IQM' if stat == 'iqm' else 'Mean'} {y.replace('_', ' ')}")
    ax.grid(axis="y", visible=False)
    return fig, ax


def scaling(df, x="n_agents", y="return", hue="algo", seed="seed", highlight=None, ax=None, order=None):
    """Metric vs a scaling variable: mean +/- std across seeds with markers."""
    if ax is None:
        fig, ax = plt.subplots()
    else:
        fig = ax.figure
    methods = order or list(dict.fromkeys(df[hue]))
    styles = style_for(methods, highlight)
    for m in methods:
        g = df[df[hue] == m].groupby(x)[y]
        mean, sd = g.mean(), g.std().fillna(0)
        st = styles[m]
        ax.errorbar(mean.index, mean.values, yerr=sd.values, label=m, color=st["color"], marker=st["marker"],
                    linestyle=st["linestyle"], linewidth=st["linewidth"], markersize=3.5, capsize=2,
                    zorder=st["zorder"])
    ax.set_xlabel(x.replace("_", " ").capitalize())
    ax.set_ylabel(y.replace("_", " ").capitalize())
    ax.legend()
    return fig, ax


def save(fig, path: str | Path) -> Path:
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(path)
    plt.close(fig)
    return path


def _main() -> None:
    p = argparse.ArgumentParser(description="Quick RL plots from a tidy CSV.")
    p.add_argument("csv")
    p.add_argument("kind", choices=["curves", "intervals", "scaling"])
    p.add_argument("-o", "--out", required=True, help="output .pdf")
    p.add_argument("--x", default="step")
    p.add_argument("--y", default="return")
    p.add_argument("--hue", default="algo")
    p.add_argument("--seed", default="seed")
    p.add_argument("--width", type=float, default=3.33, help="figure width in inches (measure \\columnwidth)")
    p.add_argument("--highlight", default=None, help="method to emphasise (the paper's own)")
    p.add_argument("--ci", default="std", choices=["std", "bootstrap"])
    p.add_argument("--smooth", type=int, default=1)
    a = p.parse_args()
    setup(width_in=a.width)
    df = pd.read_csv(a.csv)
    if a.kind == "curves":
        fig, _ = learning_curves(df, a.x, a.y, a.hue, a.seed, ci=a.ci, smooth=a.smooth, highlight=a.highlight)
    elif a.kind == "intervals":
        fig, _ = interval_estimates(df, a.y, a.hue, highlight=a.highlight)
    else:
        fig, _ = scaling(df, a.x, a.y, a.hue, a.seed, highlight=a.highlight)
    print(save(fig, a.out))


if __name__ == "__main__":
    _main()
