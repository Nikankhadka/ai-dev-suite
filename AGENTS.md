# Agent Instructions

This file provides context for AI agents working in this repository.

## Repository Purpose

This is the AI Dev Suite, a collection of skills, agents, commands, and configurations for
AI-assisted software development. It is NOT an application. It is a meta-repo that configures AI
coding agents.

The suite combines two workflow ecosystems:
- **Matt Pocock Skills** - Task-level engineering skills (TDD, code review, debugging, speccing, ticketing)
- **Kunchen Tools** - Infrastructure for agent workflows (visual planning with Lavish, validation with No-Mistakes, autonomous runs with gnhf, parallel worktrees with Treehouse, orchestration with Firstmate)

Start with [docs/unified-flow.md](docs/unified-flow.md) for the full suite, and
[docs/loop-flow.md](docs/loop-flow.md) for loop and multi-agent work.

## Key Files

- `opencode.jsonc` - OpenCode configuration (skills, permissions, MCP). The `skills.paths` list is curated: every entry costs description tokens in every prompt
- `instructions/AGENTS.md` - Global instructions, symlinked into Claude Code and Codex by `setup.sh`. Harness-specific commands must never be referenced here
- `.opencode/agent/*.md` - Agent persona definitions
- `.opencode/command/*.md` - Slash command definitions (OpenCode only)
- `vendor/mattpocock-skills/` - Submodule: Matt Pocock engineering skills
- `vendor/lavish-axi/` - Submodule: Lavish visual planning (skill + CLI)
- `vendor/no-mistakes/` - Submodule: No-Mistakes validation pipeline (skill + CLI)
- `vendor/gnhf/` - Submodule: gnhf autonomous agent loops (skill + CLI)
- `vendor/treehouse/` - Submodule: Treehouse worktree management (CLI)
- `vendor/firstmate/` - Submodule: Firstmate agent orchestration distro
- `vendor/axi/` - Submodule: AXI agent ergonomics specification
- `vendor/ponytail/` - Submodule: Ponytail lazy senior dev mode
- `vendor/taste-skill/` - Submodule: animated React/Next.js design. Not registered as a skill; loaded on demand by the router
- `vendor/hallmark/` - Submodule: structured HTML/CSS design. Not registered as a skill; loaded on demand by the router
- `skills/frontend-design/` - Local: design router skill + index wrappers for hallmark and taste-skill
- `scripts/link-skills.sh` - Symlinks skills into `~/.claude/skills` and `~/.agents/skills`. Must stay in sync with `skills.paths`
- `scripts/patch-skills.sh` - Applies agent-agnostic modifications to submodules
- `scripts/sync-upstream.sh` - Guided update when vendored skills change, driven by `scripts/sync-mappings.json`
- `setup.sh` - One-line installer for new machines
- `docs/unified-flow.md` - The full suite, tool by tool
- `docs/loop-flow.md` - Loop engineering and multi-agent work
- `docs/combined-workflow.md`, `docs/matt-flow.md`, `docs/kunchen-flow.md` - Earlier and per-upstream guides

## When Making Changes

1. Agent `.md` files: follow the existing format - clear purpose, core workflow, key principles
2. Commands: thin wrappers that describe what the referenced skill does. YAML frontmatter with a description. Do not paste a skill's body into a command; that copy will silently drift from the submodule
3. `opencode.jsonc`: valid JSONC (supports comments). Requires restart to apply
4. New skills: add to `skills/` in a named folder with a `SKILL.md`. Skills loaded from a global directory must never use paths relative to the current project
5. Submodule: `git pull` in the relevant `vendor/` directory, then commit the pointer, then run `scripts/link-skills.sh`
6. Documentation: update `docs/` when workflow patterns change, and add new docs to the `docs` section of `scripts/sync-mappings.json` so their references get drift-checked
7. Prose style: plain dashes, never em dashes, per `instructions/AGENTS.md`
