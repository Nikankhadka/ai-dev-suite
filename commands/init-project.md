---
description: Generate the standard per-project footprint - AGENTS.md, .agents/map.md, .agents/memory.md, CLAUDE.md symlink
agent: build
subtask: true
---

# Init Project

$ARGUMENTS

Pass `--refresh` to only regenerate `.agents/map.md` and re-verify the `AGENTS.md` Commands table, leaving `## Project Context`, `## Conventions`, and memory untouched.

## Full init (no `--refresh`)

1. **Detect the stack.** Load the `stack-discovery` skill and run its detection protocol (Step 2: match project files against the table). Report every language/tool found - this is a polyglot-safe detection, not a single-language guess.
2. **Verify commands before writing them.** For each candidate build/lint/typecheck/test/e2e/dev command found in a manifest, Makefile, or CI config, confirm it actually exists (a `--help` or dry-run invocation is enough) before putting it in `AGENTS.md`. Never write a guessed command.
3. **Generate `AGENTS.md`** at the project root from `templates/AGENTS.md.template`, filled in:
   - `## Project Context` - one paragraph, inferred from README/package description if present, else ask.
   - `## Stack` - detected language(s), package manager, key frameworks, with versions where found.
   - `## Commands` - a table of verified, exact, runnable commands (build/lint/typecheck/test/e2e/dev - only include the ones that actually exist for this project).
   - `## Structure` - a 5-line summary plus "see `.agents/map.md` for the full map".
   - `## Conventions` - commit format, branch naming, anything detectable from existing config (linter rules, `.editorconfig`, CI checks).
   - `## Memory` - fixed pointer text: "session-learned facts live in `.agents/memory.md` - read it at session start."
4. **Generate `.agents/map.md`**: a 2-level directory tree plus key files, each with a one-line purpose. Header: `<!-- GENERATED <date> by /init-project - do not hand-edit -->`.
5. **Generate `.agents/memory.md`** from `templates/memory.md.template` if it doesn't already exist (never overwrite existing memory).
6. **Symlink** `CLAUDE.md -> AGENTS.md` (`ln -sf AGENTS.md CLAUDE.md`) so Claude Code picks it up; Codex and OpenCode read `AGENTS.md` natively, no extra file needed.
7. Offer to commit `AGENTS.md`, `CLAUDE.md`, and `.agents/` (including `memory.md` - this is a one-man-company setup, no team-secrets concern here, but flag it if you spot anything that looks like a credential).

## Refresh (`--refresh`)

1. Regenerate `.agents/map.md` only (same format, new timestamp).
2. Re-run the verification in step 2 above against the existing `## Commands` table in `AGENTS.md`; flag (don't silently change) any command that no longer works.
3. Leave `## Project Context`, `## Conventions`, and `.agents/memory.md` untouched.

This refresh step is what `/ship` Stage 5 calls automatically after every shipped change.
