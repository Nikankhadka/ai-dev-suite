# Agent Instructions

This file provides context for AI agents working in this repository.

## Repository Purpose

This is the AI Dev Suite — a collection of skills, agents, commands, and configurations for AI-assisted software development. It is NOT an application — it's a meta-repo that configures AI coding agents.

The suite combines two workflow ecosystems:
- **Matt Pocock Skills** — Task-level engineering skills (TDD, code review, debugging, speccing, ticketing)
- **Kunchen Tools** — Infrastructure for agent workflows (visual planning with Lavish, validation with No-Mistakes, autonomous runs with gnhf, parallel worktrees with Treehouse, orchestration with Firstmate)

See [docs/combined-workflow.md](docs/combined-workflow.md) for the full merged workflow guide.

## Key Files

- `opencode.jsonc` — OpenCode configuration (skills, permissions, MCP)
- `.opencode/agent/*.md` — Agent persona definitions
- `.opencode/command/*.md` — Slash command definitions
- `vendor/mattpocock-skills/` — Submodule: Matt Pocock engineering skills
- `vendor/lavish-axi/` — Submodule: Lavish visual planning (skill + CLI)
- `vendor/no-mistakes/` — Submodule: No-Mistakes validation pipeline (skill + CLI)
- `vendor/gnhf/` — Submodule: gnhf autonomous agent loops (skill + CLI)
- `vendor/treehouse/` — Submodule: Treehouse worktree management (CLI)
- `vendor/firstmate/` — Submodule: Firstmate agent orchestration distro
- `vendor/axi/` — Submodule: AXI agent ergonomics specification
- `vendor/taste-skill/` — Submodule: Taste-Skill anti-slop frontend design (animated React/Next.js)
- `vendor/hallmark/` — Submodule: Hallmark anti-AI-slop design skill (structured HTML/CSS)
- `skills/frontend-design/` — Local: Design router skill + index wrappers for hallmark and taste-skill
- `scripts/link-skills.sh` — Creates symlinks for multi-agent skill access
- `scripts/patch-skills.sh` — Applies agent-agnostic modifications to submodules
- `setup.sh` — One-line installer for new machines
- `docs/kunchen-flow.md` — Kunchen development workflow summary
- `docs/combined-workflow.md` — Combined Matt Pocock + Kunchen workflow guide

## When Making Changes

1. Agent `.md` files: Follow the existing format — clear purpose, core workflow, key principles
2. Commands: Thin wrappers that describe what the referenced skill does. YAML frontmatter with description
3. `opencode.jsonc`: Valid JSONC (supports comments). Requires restart to apply
4. New skills: Add to `skills/` directory with `SKILL.md` inside a named folder
5. Submodule: `git pull` in the relevant `vendor/` directory to update, then commit the pointer
6. Documentation: Update `docs/` when workflow patterns change
