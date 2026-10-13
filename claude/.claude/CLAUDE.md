# Skills & Automation

## graphify
- Skill: `~/.claude/skills/graphify/SKILL.md` — any input to knowledge graph. Trigger: `/graphify`.
- When user types `/graphify`, use graphify skill before doing anything else.
- Auto-use: on any programming project (non-LaTeX work), always use graphify to maintain code knowledge graph.

# Agent Memory
Only for project related memory sharing between different AI agents. Do not create notes for non-project queries and tasks.

## Structure
- Index: `~/Documents/obsidian-files/obsidian-dashboard/agent_memory/_INDEX.md` — lists topics/entities, short summary of each, lists only.
- Node files: group by project (project is a directory), file named by topic holds detail. Index entry links to its node file.
- Note format: `## <date-stamp>` heading per update, entry content below it. New updates append a new dated heading rather than rewriting prior ones.
- Store lives in `obsidian-dashboard` repo — see [[multiRepoCommit]] for its commit pairing.

## Usage
- Session start: read `_INDEX.md`, filtered by project, to recall prior context.
- When a topic/entity in index is relevant to current conversation, read its node file for detail.
- Don't re-read node files already read this session.
- Update at session end: append to relevant note if it already exists, using date stamp as key for update. If no note exists, create it.

# Token Minimization

Minimize token usage without sacrificing correctness:
- Don't re-read files already read this session.
- Don't re-derive facts already established in context.
- Prefer targeted reads/greps over broad ones (specific path/line range/pattern over whole-file or whole-repo scans).
- Keep tool-call chains tight — no exploratory calls that don't inform next step.
- Don't pad responses with redundant restated context or redundant summaries.
- Applies globally, in addition to any per-session effort-level or verbosity settings (e.g. caveman mode).

# Git & Repo Hygiene

## gitignoreHygiene
Whenever git project encountered: check `.gitignore`, update to ignore graphify output folder (`graphify-out/`, permanent, always ignore) plus lang-appropriate unnecessary files/dirs/compile artifacts (e.g. `node_modules`, `__pycache__`, `*.pyc`, `.venv`, `target/`, `dist/`, `build/`, `*.o`, `*.class` — pick set matching detected language(s)).

## gitPushPolicy
Never run `git push` — local git ops (add/commit/rebase/etc) only, always. Never add a Claude signature/co-author line to commit messages.

## multiRepoCommit
Paper repos (`uia-documents/phd-latex-files/...`) and `obsidian-dashboard` (holds [[agentMemory]] store) often change together in a session — commit both when both touched, don't leave one dangling.

## overleafSync
Paper repos synced to an Overleaf git remote — before committing there, `fetch` + `rebase` first (Overleaf-side/collaborator edits cause divergence often).

## configScopeCheck
Before editing a global agent-config file (`~/.claude/CLAUDE.md`, `~/.gemini/GEMINI.md`, etc), confirm which agent/tool is actually active in the current session — don't assume Claude Code. Past mistake: edited `~/.claude/CLAUDE.md` while operating under Antigravity/Gemini CLI, which reads `~/.gemini/GEMINI.md` instead.

# Environment & Tools

## direnvProjectTools
If project dir has `.envrc` (direnv), do NOT rely on plain `which`/PATH lookups for project-scoped tools (python, pixi, uv, etc) — direnv's shell hook only fires on interactive prompts, so tool-run non-interactive bash never applies it, and PATH stays wrong. Instead: `direnv exec <dir> <cmd>` per command, or once per session `eval "$(direnv export bash)"` (or `zsh`) before other calls in that dir, then normal `which` resolves correctly. If `.envrc` not yet allowed, run `direnv allow <dir>` first (one-time, ask user if unsure it's safe).

## texbinPath
TeX Live tools (tlmgr, pdflatex, latex, xelatex, lualatex, etc) all live in `/Library/TeX/texbin` — stable, system-wide, not project-dependent. Use that path directly instead of `which`.

## uvEphemeralEnvs
For one-off/temporary Python tool or dependency needs (e.g. a script needing a library not installed), prefer `uv` over global pip installs: use `uv venv` / `uv run --with <pkg>` / `uvx <tool>` to create a scoped, throwaway env instead of `pip install --user`. When the task is done, clean up: remove any venv dirs you created (e.g. `rm -rf .venv` in a scratch location) and don't leave ad-hoc tool installs lying around. Persistent project envs (with a checked-in pyproject.toml/requirements) are not "temporary" — don't tear those down.

# Output Style

## noTrailingSummaries
After completing a task or following an instruction, do not append an end-of-task summary or restate what was just done/asked. State results inline as you go; stop when done.

## britishEnglish
Use British English spelling in all written output — docs, LaTeX, prose, comments (e.g. "colour", "optimise", "behaviour").
