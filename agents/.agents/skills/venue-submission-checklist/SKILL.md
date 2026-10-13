---
name: venue-submission-checklist
description: Run a pre-submission compliance check of a LaTeX paper against its target venue's rules — anonymity, page limits, template and class options, ACM CCS concepts/keywords/rights block, Springer Nature declarations, PRISMA 2020 reporting for systematic reviews, references and supplementary material. Use whenever the user mentions submitting, camera-ready, resubmitting to another venue, a deadline, "is it ready", "check formatting", "does it fit the page limit", "anonymise", or names AAMAS, TOMACS, ACM CSUR, a Springer journal, or any conference/journal for a paper in ~/Documents/uia-documents/phd-latex-files/papers.
---

# Venue submission checklist

Desk rejections come from mechanical slips, not science: an author name left in the PDF metadata, nine pages instead of eight, a missing CCS block. This skill checks those mechanically and reports what fails.

## 1. Identify the venue and its current rules

Determine the venue from the document class and the user (`aamas.cls` → AAMAS; `acmart` with `acmsmall` → ACM journal such as TOMACS or CSUR; `sn-jnl` → Springer Nature). Then get the **current** rules, because limits change between years:

1. Formatting instructions shipped in the repo (e.g. `AAMAS_2026_Formatting_Instructions.pdf`, `acmguide.pdf`, `sn-article.tex` comments). Read them.
2. The venue's call for papers / author guidelines page (web fetch). Prefer this over memory for page limits, anonymity policy and supplementary rules.
3. `references/venues.md` for the stable conventions per venue family and what to look for.

State the rule source and date in the report. If you cannot confirm a limit, say "unconfirmed" rather than asserting one.

## 2. Compile and measure

Compile with latexmk (see `overleaf-paper-sync`). Then measure from the PDF, not the source:

```bash
pdfinfo <main>.pdf | grep -E 'Pages|Author|Title|Creator'     # poppler is installed
pdftotext -layout <main>.pdf - | grep -n -i -E 'references|bibliography|appendix|acknowledg'
```

Find the page where References starts to compute body pages vs reference pages. Check fonts are embedded (`pdffonts <main>.pdf`, every row `emb = yes`), which some submission systems enforce.

## 3. Run the checks

Work through the general list, then the venue section in `references/venues.md`.

**General**
- Page count within the limit for the submission type (body vs references vs appendix counted separately as the venue specifies).
- Template unmodified: no changed margins, `\vspace` abuse, font size changes, or forbidden packages (`geometry`, `times` with acmart).
- Log clean: no undefined references/citations, no `??` in the PDF text (`pdftotext ... | grep -n '??'`).
- Every figure and table referenced in the text; captions readable at print size; figures vector where possible.
- Bibliography: no `PLACEHOLDER`/`TODO` keys, no duplicate entries, consistent venue names, arXiv preprints updated to published versions where they exist.
- Acronyms defined at first use in the abstract and again in the body.
- Leftover markup: `\todo`, `TODO`, `FIXME`, `\hl{`, coloured comments, commented-out author notes that still render.

**Double-blind (when required)**
- No author names, affiliations, grant numbers, or acknowledgements in the PDF.
- PDF metadata (`pdfinfo` Author/Title fields) does not identify authors; set `\hypersetup{pdfauthor={}}` if needed.
- Self-citations in third person; no "our previous work [X]" that reveals identity; no non-anonymous repository links (use an anonymised mirror).

**Supplementary material and artefacts**: within the size and format limits; code links anonymised for review, real for camera-ready.

## 4. Report

```markdown
# Submission check: <paper> → <venue> <year> (<date>)
Rule sources: <files / URLs consulted>
Pages: <body> body + <refs> references (+ <app> appendix); limit <limit> (<confirmed|unconfirmed>)

## Must fix
- [ ] <issue> — <where> — <fix>
## Should fix
- [ ] ...
## Passed
<one line per check group>
```

Offer to fix the mechanical items (metadata, CCS block, leftover TODOs, `??`). Do not cut content to meet a page limit without the user deciding what goes.
