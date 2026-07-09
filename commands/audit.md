---
description: Drift check for this suite (or, inside a project, for AGENTS.md/.agents/map.md freshness)
agent: build
subtask: true
---

# Audit

$ARGUMENTS

Determine scope: if run inside `~/.config/opencode` (or any clone of this suite), audit the suite itself. Otherwise, audit the current project's `AGENTS.md`/`.agents/` freshness.

## Suite audit checklist

- [ ] Every file referenced by `README.md`, `instructions/RULES.md`, `instructions/OPENCODE.md`, and any `SKILL.md` exists on disk, and every real agent/command/skill file is listed in `README.md` (both directions).
- [ ] Every command file in `commands/` has valid frontmatter (`description`, `agent`, `subtask`) and its `agent:` value matches a real file in `agents/`.
- [ ] Every symlink in the cross-harness map (see `bin/sync-adapters.sh`) resolves and is not dangling.
- [ ] Every file in `adapters/claude/agents/` is newer than its source in `agents/` (regenerate with `bin/sync-adapters.sh` if not).
- [ ] No em dash (Unicode U+2014) anywhere in `*.md`/`*.jsonc`/`*.txt` - run `grep -rn $'—' . --include='*.md' --include='*.jsonc' --include='*.txt'`.
- [ ] No references to removed things: `query-docs`, `frontend-patterns`, `backend-patterns`, `tdd-guide`, `e2e-runner`, `/orchestrate`.
- [ ] Positive checks:
  - `test -d ~/firstmate` (firstmate orchestrator directory)
  - `test -f $HUB/skills/lavish/SKILL.md` (lavish skill installed)
  - `command -v tmux` (firstmate prerequisite)
- [ ] `command -v` check for each axi CLI referenced by a command (`gnhf`, `treehouse`, `no-mistakes`, `gh-axi`, `quota-axi`, `chrome-devtools-axi`) - report which are missing, don't fail the audit for it.

Report each check as PASS/FAIL with the specific file:line for any failure, and propose the minimal fix.

## Project audit checklist

- [ ] `AGENTS.md` exists at project root.
- [ ] `.agents/map.md` exists and its generated-date is under 30 days old.
- [ ] Every file `.agents/map.md` references still exists.
- [ ] The commands in `AGENTS.md`'s Commands table still run (dry-run/help form is enough to confirm they exist).
- [ ] `CLAUDE.md` is a symlink to `AGENTS.md`.

If anything is stale, recommend running `/init-project --refresh` rather than fixing it by hand.
