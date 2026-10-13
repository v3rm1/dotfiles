---
name: paper-claims-check
description: Cross-check every quantitative and comparative claim in a LaTeX paper (abstract, introduction, results tables, discussion, conclusion) against the actual experiment results in MLflow, result CSVs/JSONs, or an agent-memory "authoritative claims" section, and report mismatches before submission. Use whenever the user is finalising, revising or submitting a paper (AAMAS, TOMACS, CSUR, Springer or any venue), asks "does the paper match the results", "check the numbers", "are the claims supported", mentions new experiment runs that might change the story, or is close to a deadline — even if they only say "proofread the results section".
---

# Paper claims check

A paper drifts away from its data: abstracts get written before the final sweeps finish, tables get pasted from an old run, and "outperforms" survives after the numbers stopped supporting it. This skill finds those gaps. It produces a report; it does not silently rewrite the paper, because the author decides how to reframe a claim that no longer holds.

## 1. Establish the source of truth

Look for evidence in this order and record which sources you actually used:

1. **Agent memory claims sections.** Check `~/Documents/obsidian-files/obsidian-dashboard/agent_memory/_INDEX.md` for the project, then the node file. A heading like `AUTHORITATIVE PAPER CLAIMS (<date>)` supersedes every earlier statement in that note. Treat it as the spec the paper must satisfy, but still spot-check its numbers against raw data when that data is reachable.
2. **MLflow.** Local `mlruns/` in the experiment repo (e.g. `~/Documents/projects/erls/mlruns`), or the university tracking server through the `uni-mlflow-tunnel` SSH alias (forwards `localhost:43210`). Query runs with the `mlflow` Python client inside the project's pixi environment (`pixi run python ...`, or `direnv exec <dir>` if the repo uses direnv). Aggregate across seeds yourself: mean ± std (state which, and n seeds).
3. **Result files** in the experiment repo: `results/`, `runs/`, `outputs/`, CSV/JSON/parquet, plus notes such as `EXPERIMENTS.md` or `*_findings.md`.

If the tunnel is down or data is missing, say so and continue with what is available; mark affected claims as `UNVERIFIABLE` rather than guessing.

## 2. Extract claims from the paper

Find the main file (`main.tex`, or whichever file has `\documentclass`) and follow `\input`/`\include`. Collect:

- **Numbers in prose**: scores, percentages, ratios ("2.1×"), p-values, seed counts, step counts, team sizes.
- **Comparatives and superlatives**: "outperforms", "best on all", "significantly", "consistently", "scales better", "robust to", "no degradation".
- **Table and figure contents**: every cell in results tables; captions that state a takeaway.
- **Abstract and conclusion statements**, which readers trust most and which drift most often.
- **Setup claims**: number of seeds, training steps, scenarios, baselines. These must match the configs that produced the data.

## 3. Compare and classify

For each claim, assign one status:

| Status | Meaning |
|---|---|
| `OK` | Matches the source within rounding. |
| `MISMATCH` | Number differs (give paper value vs source value). |
| `UNSUPPORTED` | Qualitative claim the data does not back (e.g. "outperforms" where the CIs overlap, or the baseline wins). |
| `STALE` | Matches an older run but not the latest authoritative one. |
| `UNVERIFIABLE` | No reachable source. |

Be strict about comparatives: "outperforms" needs a consistent gap beyond seed variance; "parity" or "comparable" is the honest word when the intervals overlap. Check that the same claim is stated identically in the abstract, introduction and conclusion.

## 4. Report

Write the report to `claims-check-<YYYY-MM-DD>.md` in the paper repo root (tell the user where it is, and leave it out of commits unless they ask, since Overleaf would sync it into the project). Use this structure:

```markdown
# Claims check: <paper> (<date>)
Sources used: <memory note + date / MLflow experiment name / files>

## Summary
<n> claims checked: <ok> OK, <m> MISMATCH, <u> UNSUPPORTED, <s> STALE, <v> UNVERIFIABLE

## Problems (most severe first)
| # | Location (file:line) | Paper says | Evidence says | Status | Suggested fix |

## Verified
<compact list of OK claims, so the author can see coverage>
```

Then summarise the top problems in chat. Offer to apply the suggested fixes; when the user agrees, edit the `.tex` files, recompile (see the `overleaf-paper-sync` skill), and re-run the check on the edited sections.

## Notes

- Never "fix" a number by rounding toward the claim. If the data says 68.2 vs 68.9, the claim is parity, not a win.
- Rounding: match the paper's precision; flag inconsistent precision across tables.
- If the paper reports mean ± std but the source has fewer seeds than stated, that is a `MISMATCH` on the setup claim.
- After the check, append a dated entry to the project's agent-memory node noting the result (see global CLAUDE.md for the memory format).
