---
name: overleaf-paper-sync
description: Safely sync, compile and commit a LaTeX paper repository that has an Overleaf git remote, and commit the paired obsidian-dashboard agent-memory changes alongside it. Use whenever working in ~/Documents/uia-documents/phd-latex-files/papers/* or any repo whose remote is git.overleaf.com — before editing (to pull collaborator changes), after editing (to compile and commit), when the user says "sync with Overleaf", "commit the paper", "make a latexdiff", "pull Overleaf changes", or when a rebase against Overleaf has diverged.
---

# Overleaf paper sync

Paper repos live under `~/Documents/uia-documents/phd-latex-files/papers/` (e.g. `holonic-MARL-AAMAS`, `MARL_Review`, `intelligence`, `ERLS-Paper`). Most have `origin` pointing at `git.overleaf.com`, where co-authors edit directly, so local and remote diverge often. Merge commits from Overleaf syncs make history unreadable, so this workflow always rebases.

## Before editing: pull collaborator changes

```bash
git -C <paper> status --short          # stash or commit local work first
git -C <paper> fetch origin
git -C <paper> rebase origin/HEAD      # Overleaf uses main or master depending on project age
```

If the rebase conflicts, resolve in the `.tex` files (keep both authors' intent; ask the user when edits genuinely compete), `git add`, `git rebase --continue`. Do not use `git pull` with merge, and never force anything.

## After editing: compile

TeX binaries are in `/Library/TeX/texbin` (use full paths; `which` can miss them). Compile with latexmk so bibliography and cross-references settle:

```bash
cd <paper> && /Library/TeX/texbin/latexmk -pdf -interaction=nonstopmode -halt-on-error <main>.tex
```

`<main>` is the file with `\documentclass` (`main.tex`, `sn-main.tex`, `expanded_main.tex`...). After compiling, scan the `.log` for:

- `undefined references` / `Citation ... undefined` — broken `\ref`/`\cite` keys.
- `Overfull \hbox` larger than ~10pt — visible text running into the margin.
- `There were multiply-defined labels`.

Report these; fix the ones caused by your own edits. Extra TeX packages belong in `~/Library/texmf/tex/latex/`, not in the repo, so Overleaf stays clean.

## Commit

Stage only source changes. Build artefacts (`*.aux *.bbl *.blg *.fdb_latexmk *.fls *.log *.out *.synctex.gz`, the PDF unless the repo already tracks it, `claims-check-*.md`) should not go to Overleaf; if `.gitignore` is missing these, add them.

Write a short imperative commit message describing the change to the paper (e.g. `Align abstract and Sec. 6 with final scaling results`). No co-author or tool signature lines.

**Do not run `git push`.** The user pushes themselves. Finish by giving them the exact command, e.g. `git -C ~/Documents/uia-documents/phd-latex-files/papers/<paper> push origin HEAD`. If the push is likely to be rejected (remote moved since your fetch), say so and tell them to fetch and rebase first.

## Paired agent-memory commit

When the session touched the project's agent-memory note in `~/Documents/obsidian-files/obsidian-dashboard`, commit that repo too so the two never drift apart:

```bash
git -C ~/Documents/obsidian-files/obsidian-dashboard add agent_memory/
git -C ~/Documents/obsidian-files/obsidian-dashboard commit -m "agent_memory: <project> — <what changed>"
```

## latexdiff on request

To show reviewers or supervisors what changed since a baseline commit or tag. BasicTeX does not ship `latexdiff`/`latexpand`; if `/Library/TeX/texbin/latexdiff-vc` is missing, ask the user to run `sudo /Library/TeX/texbin/tlmgr install latexdiff latexpand` first.

```bash
cd <paper>
/Library/TeX/texbin/latexdiff-vc --git --flatten -r <baseline-commit> <main>.tex --pdf
```

This writes `<main>-diff<baseline>.pdf`. If `--flatten` chokes on the project structure, check out the baseline into a temp worktree, flatten both sides with `latexpand`, and run plain `latexdiff old.tex new.tex > diff.tex`. Keep diff outputs out of commits.
