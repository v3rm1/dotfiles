---
name: research-figures
description: Produce publication-quality figures for papers, theses and talks from experiment data — RL/MARL learning curves over seeds, IQM/confidence-interval comparisons, scaling and ablation plots, heatmaps — plus architecture diagrams in TikZ, sized exactly to the LaTeX column width and colour-blind safe. Use whenever the user asks to plot results, make or fix a figure, "turn this table into a chart", regenerate figures after new runs, match figures to a paper template, or when a paper/slide needs a diagram of a system or algorithm, even if they just say "visualise this".
---

# Research figures

Adapted from Orchestra Research's `academic-plotting`, rewritten for RL/MARL results and LaTeX-native output (no AI image generation: diagrams in TikZ stay editable and match the paper's fonts).

## Principles

- **Size to the document.** A figure designed at 3.3 in and included at 3.3 in has text the same size as the paper; one shrunk from 10 in does not. Measure the target width (below) and build at that width.
- **Fonts match the paper**: serif text via `text.usetex` or a matching font, labels 7–9 pt at final size.
- **Colour-blind safe palette** (Okabe–Ito) and redundant encoding (line style or marker) so the figure survives greyscale printing. Give the proposed method a consistent colour across every figure in the paper.
- **Show uncertainty.** RL results without seed variation are not evidence: shade mean ± std or a 95% bootstrap CI and state n seeds in the caption.
- **Vector output** (`.pdf`) for plots; never JPEG for line art.
- **Reproducible**: every figure comes from a script in the repo (`figures/scripts/fig_<name>.py`) that reads the raw results (CSV or MLflow) and writes `figures/fig_<name>.pdf`. Never hand-edit numbers into a plot.

## Measure the target width

Add temporarily to the document body, compile, and read the log:

```latex
\typeout{COLWIDTH=\the\columnwidth}\typeout{TEXTWIDTH=\the\textwidth}
```

Convert pt to inches (÷ 72.27). Single-column figures use `\columnwidth`, full-width (`figure*`) use `\textwidth`. Remove the lines afterwards.

## Data plots

Use the bundled helper, which sets the style and implements the common RL plots:

```bash
python ~/.agents/skills/research-figures/scripts/rlplot.py --help
```

Or import it in a figure script:

```python
import sys; sys.path.insert(0, str(Path.home() / ".agents/skills/research-figures/scripts"))
import rlplot
rlplot.setup(width_in=3.33)              # width from the measurement above
fig, ax = rlplot.learning_curves(df, x="step", y="return", hue="algo", seed="seed", ci="bootstrap")
rlplot.save(fig, "figures/fig_learning_curves.pdf")
```

`df` is a tidy table (one row per algo × seed × step). Pull it from MLflow with the project's env, or from `results/<suite>.csv` written by the `uni-server-sweep` skill.

Choosing the chart:

| Data | Chart |
|---|---|
| Metric over training steps | Learning curves, shaded CI, optional smoothing (state window in caption) |
| Final performance, many algos × tasks | IQM / mean with bootstrap CI as horizontal intervals (`rlplot.interval_estimates`), or grouped bars with error bars |
| Performance vs team size / parameter | Line with markers and error bars (`rlplot.scaling`) |
| Component removed vs full | Ablation bars sorted by effect, full method as reference line |
| Grid of settings | Heatmap with annotated cells, perceptually uniform colormap (viridis/cividis) |

Avoid: 3D plots, pie charts, dual y-axes, legends covering data (put the legend above the axes or label lines directly), more than ~6 series in one panel.

## Diagrams

Architecture, hierarchy (e.g. Macro/Meso/Micro holarchy), and pipeline diagrams: TikZ in `figures/tikz/<name>.tex`, compiled standalone (`\documentclass[tikz]{standalone}`) to PDF so it can be reused in slides. Use the same palette as the plots, `node distance` and `positioning` for layout, and the paper's exact terminology on labels. Keep under ~10 top-level nodes; group the rest.

## Check before handing over

Open the PDF at 100% zoom alongside the compiled paper page: text legible and same size as captions, nothing clipped, colours distinguishable, legend not covering data, axis labels with units, caption states what is plotted, n seeds and the uncertainty measure.
