---
name: research-talks
description: Turn a paper, report or set of results into a talk — conference oral/spotlight, PhD supervisory meeting update, course lecture or seminar — as Quarto revealjs (default), Beamer, or editable PPTX, with a timed slide plan, speaker notes and a backup/Q&A section. Use whenever the user mentions slides, a deck, a presentation, a talk, a supervisor meeting, a lecture, a defence, a poster pitch, or "present these results", even if they do not name a format.
---

# Research talks

Adapted from Orchestra Research's `presenting-conference-talks`, extended for this user's recurring formats: AAMAS/ACM conference talks, PhD supervisory meetings (`~/Documents/uia-documents/phd-latex-files/presentations`), coursework presentations (Quarto revealjs, e.g. IKT727) and teaching decks (PPTX, e.g. IKT465). British English.

## 1. Pin down the talk

Decide (ask only if not inferable): audience, duration, format, and the **one sentence** the audience should remember. Then size it:

| Talk | Duration | Slides | Depth |
|---|---|---|---|
| Spotlight / poster pitch | 3–8 min | 5–10 | Problem, key insight, one headline result |
| Conference oral | 12–20 min | 12–20 | Full story, 2–3 strongest results, one ablation |
| Supervisory meeting | 15–30 min | 8–15 | Progress since last meeting, results with honest caveats, decisions needed, next steps and timeline |
| Seminar / invited | 30–45 min | 25–40 | Context, method in depth, broader implications |
| Lecture (teaching) | 45–90 min | 1 per 2–3 min plus activities | Learning objectives, worked examples, interaction breaks |

Roughly one slide per minute for research talks.

## 2. Slide plan before slides

Write the plan as a list of slide headlines first. Each headline is a full-sentence claim ("Holonic teams close the gap to MAPPO as teams grow"), not a topic label ("Scaling results"). Read the headlines alone: they should tell the whole story. Show the plan to the user for a long talk before building.

Supervisory meetings add: a "decisions needed" slide early (not buried at the end), a status table per manuscript/experiment, risks and timeline. Pull state from agent memory (`_INDEX.md` → `erls_marl/erls-supervisory-meetings` and the paper nodes) rather than re-deriving it.

## 3. Build

**Quarto revealjs (default)**: one `.qmd` per talk, `format: revealjs`, slides as `##` headings, speaker notes in `::: {.notes}` blocks, columns with `:::: {.columns}`, incremental reveal with `. . .`. Render with `quarto render talk.qmd` (Quarto is installed as a cask); export PDF with `decktape` via `npx -y decktape reveal talk.html talk.pdf` if a PDF is needed.

**Beamer**: when the venue or co-authors want LaTeX; `metropolis` theme, 16:9 (`aspectratio=169`), notes via `\note{}`. Reuse the paper's macros and TikZ diagrams.

**PPTX**: for teaching decks or when others will edit; use the `pptx` skill (python-pptx), real speaker notes in the notes pane.

Content rules: one idea per slide; figures over bullets; at most ~6 short lines of text; reuse the paper's figures re-rendered at slide size with larger fonts (`research-figures`, `rlplot.setup(width_in=10, fontsize=16)`); state the takeaway before showing the plot; numbers on slides must match the paper (run `paper-claims-check` logic if unsure).

## 4. Speaker notes

Per slide: `[~mm:ss cumulative] key point · what to point at on the figure · transition sentence`. Add a full script only when asked (e.g. for a recorded talk or non-native-language rehearsal), at ~130 words per minute.

## 5. Backup and Q&A

After the closing slide, add hidden/appendix slides for likely questions: baseline tuning, seed counts and variance, compute cost, failure cases, the strongest related work and how this differs. For a supervisory meeting, add the detailed tables behind each summary slide.

## Check

Total timing within ±10% of the slot; every figure legible from the back of a room (labels ≥ 16 pt on slides); no slide without a headline claim; final slide shows the one-sentence takeaway and contact/paper link (QR code optional).
