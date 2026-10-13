# Venue families

Stable conventions only. Always confirm limits and policies against the current call for papers; numbers here are what to look for, not authority.

## AAMAS (International Conference on Autonomous Agents and Multiagent Systems)

- Class: `aamas.cls` (ACM-derived, two-column). Sample files ship with the template (`AAMAS_20XX_sample.tex`); compare the preamble against the current year's sample, since the class and the logo/copyright block change yearly.
- Main track has historically been double-blind with a body page limit plus unlimited references; check whether the current year's limit is 8 pages and whether appendices must go into a separate supplementary file.
- The submission version uses the anonymous option of the class; camera-ready switches it off and adds the real author block and the IFAAMAS copyright/licence text.
- Check: `\setcopyright`/licence macros match the year's instructions; CCS concepts and keywords present if the template requires them; the extended abstract or blue sky tracks have different limits.

## ACM journals with `acmart` + `acmsmall` (TOMACS, CSUR, TOPS etc.)

- `\documentclass[acmsmall]{acmart}`; for review `[acmsmall,review,anonymous]` if the journal is double-blind (CSUR and TOMACS policies differ; check the author guidelines).
- Required front matter: `\begin{CCSXML}...\end{CCSXML}` plus `\ccsdesc[...]{...}` (generate at dl.acm.org/ccs, do not invent concept paths), `\keywords{...}`, abstract before `\maketitle`.
- `\acmJournal{TOMACS}` / `\acmJournal{CSUR}` set correctly; rights block (`\setcopyright`, `\acmYear`, DOI fields) left as the template default for submission, filled in only at acceptance.
- Bibliography style `ACM-Reference-Format`; every entry needs complete venue info and DOIs where available.
- CSUR: surveys are judged on coverage and taxonomy; check that the methodology section states search strings, databases, dates and inclusion/exclusion criteria.
- No page limit on most ACM journals, but CSUR has a guideline length; check.

## Springer Nature journals (`sn-jnl` class)

- Class options select the reference style (e.g. `sn-mathphys-num`, `sn-apa`, `sn-basic`); keep whichever the target journal requires.
- Mandatory declarations section (in recent templates): Funding, Competing interests, Ethics approval, Consent, Data availability, Code availability, Author contributions. Missing declarations is a common return-to-author reason.
- Abstract length limit per journal (often 150–250 words); keywords 4–6.
- Check `missfont.log` is absent after compiling (missing fonts on BasicTeX are common with `sn-jnl`).

## Systematic reviews (PRISMA 2020)

For a systematic review or survey claiming systematic methodology (e.g. the ACM CSUR MARL review), check the 27-item PRISMA 2020 checklist is satisfied and ideally included as supplementary material:

- Title identifies the report as a systematic review; structured abstract (PRISMA for Abstracts).
- Introduction: rationale; explicit objectives/research questions.
- Methods: eligibility criteria; information sources with last search date; full search strategy for every database; selection process (how many reviewers, independence, tools); data collection process; data items; risk-of-bias / quality assessment; synthesis methods.
- Results: study selection with a **PRISMA flow diagram** (identified → screened → excluded with reasons → included), study characteristics table, results of syntheses.
- Discussion: limitations of the evidence and of the review process.
- Other: registration/protocol (or a statement that none exists), funding, competing interests, availability of data and extraction forms.

Flag any count mismatch between the flow diagram, the text and the included-studies table; reviewers check these first.
