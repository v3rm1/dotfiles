---
name: research-paper-writing
description: Draft, restructure and revise research papers and manuscripts in LaTeX — multi-agent RL, simulation, survey and theory papers for venues like AAMAS, ACM TOMACS, ACM CSUR, NeurIPS/ICML/ICLR and Springer journals — with verified citations and claims grounded in actual results. Use whenever the user asks to write or rewrite an abstract, introduction, related work, method, results or conclusion; tighten a section; respond to reviewer comments; reframe a paper; port a paper to another venue; or add citations, even if they only say "make this paragraph better" inside a paper repo.
---

# Research paper writing

Adapted from Orchestra Research's `ml-paper-writing` and `systems-paper-writing` skills, narrowed to this user's work: JAX-based MARL for crisis/emergency response (ERLS simulator, holonic MARL), an ACM CSUR systematic review, a TOMACS simulator paper, and a Springer philosophy-of-intelligence manuscript. Write in British English.

## Before writing

1. **Load context.** Read the project's agent-memory node (`~/Documents/obsidian-files/obsidian-dashboard/agent_memory/_INDEX.md` → project → node). If it has an authoritative-claims section, that is the evidence boundary for every sentence you write.
2. **Read the paper as it stands**: main file and the sections around the one you are editing, so terminology, notation and macros stay consistent. Reuse existing `\newcommand` macros and notation; do not introduce parallel names.
3. **Know the venue** (template class, length, audience). An AAMAS reader wants the agent-level mechanism and a clean empirical comparison; a TOMACS reader wants simulation methodology, validation and reproducibility; a CSUR reader wants a taxonomy and synthesis, not a list of papers.

## The narrative

A paper is one claim with evidence, not a log of experiments. By the end of the introduction the reader should know:

- **What**: 1–3 specific contributions, phrased so they could be wrong.
- **Why it matters**: the gap in prior work, concretely (which methods fail, how, under which conditions).
- **Evidence**: the experiment that would convince a sceptic, and its headline result with uncertainty.

Honest negative or mixed results are publishable when framed as characterisation ("where and why hierarchical decomposition pays off") rather than superiority. Never let prose outrun the data: "comparable" when intervals overlap, "outperforms" only with a consistent gap across seeds.

## Section guidance

- **Abstract** (≈150–250 words): context → gap → approach → key quantitative result → implication. No citations, no undefined acronyms.
- **Introduction**: open with the concrete problem (e.g. coordination of heterogeneous responders under partial observability), not with "In recent years". End with an explicit contributions list that mirrors the paper's sections.
- **Related work**: organise by idea, not by paper; each paragraph ends with how this work differs. For MARL, the usual axes are CTDE vs decentralised training, value decomposition vs policy gradient, hierarchy/organisation, communication, and evaluation domains.
- **Method**: formal setting first (Dec-POMDP tuple, notation table if dense), then the mechanism, then the algorithm box. Every symbol defined before use.
- **Experiments**: research questions → setup (environments, baselines with versions and tuning budget, seeds, steps, compute) → results answering each question in order → ablations → limitations. Report mean ± std or confidence intervals with n seeds; for RL prefer IQM with bootstrapped CIs (rliable) when comparing many runs.
- **Conclusion**: what was shown, its limits, one or two concrete next steps. No new claims.

Paragraph craft: topic sentence states the point; one idea per paragraph; prefer active voice and concrete verbs; cut "very", "novel", "significantly" (unless statistical); define terms once and keep them fixed.

## Citations: never from memory

Hallucinated references are misconduct-level errors. Every new `\cite` must point to a BibTeX entry obtained from a real source:

1. **Zotero first.** The user's library is the curated source. If Zotero is running with Better BibTeX, fetch the entry for a citekey or search; otherwise ask the user to add the paper to Zotero or export it.
2. **DOI → BibTeX**: `curl -sLH "Accept: application/x-bibtex" https://doi.org/<DOI>`.
3. **Search** with the Semantic Scholar API (`https://api.semanticscholar.org/graph/v1/paper/search?query=...&fields=title,authors,year,venue,externalIds`) or arXiv, then resolve the DOI as above.

If a reference cannot be verified, insert `\cite{TODO_verify_<topic>}` and list every such placeholder to the user at the end. Prefer the published version over arXiv when one exists.

## Workflow

- Draft proactively when the evidence and framing are clear; deliver a complete section, then list the 2–3 decisions the author should confirm (framing, which results to headline, what to cut).
- Ask first only when the venue, the main claim or the result set is genuinely ambiguous.
- Edit in place in the `.tex` files with minimal diffs so Overleaf collaborators can follow; keep one sentence per line only if the repo already does.
- After substantive edits, compile and run the `paper-claims-check` skill on changed sections; before submission, the `venue-submission-checklist` skill. Sync and commit with `overleaf-paper-sync`.

## Responding to reviewers

Build a response table: comment → category (misunderstanding / missing experiment / presentation / disagreement) → action → location of change. Concede valid points plainly, run or schedule missing experiments rather than arguing, and quote the revised text in the response. Keep the tone factual and brief.
