# Agent Instructions

This file provides context for AI agents working in this repository.

## Repository Purpose

This is the AI Dev Suite — a collection of skills, agents, commands, and configurations for AI-assisted software development. It is NOT an application — it's a meta-repo that configures AI coding agents.

## Key Files

- `opencode.jsonc` — OpenCode configuration (skills, permissions, MCP)
- `.opencode/agent/*.md` — Agent persona definitions
- `.opencode/command/*.md` — Slash command definitions
- `vendor/mattpocock-skills/` — Submodule containing engineering skills
- `scripts/link-skills.sh` — Creates symlinks for multi-agent skill access
- `scripts/patch-skills.sh` — Applies agent-agnostic modifications to submodule
- `setup.sh` — One-line installer for new machines

## When Making Changes

1. Agent `.md` files: Follow the existing format — clear purpose, core workflow, key principles
2. Commands: Thin wrappers that describe what the referenced skill does. YAML frontmatter with description
3. `opencode.jsonc`: Valid JSONC (supports comments). Requires restart to apply
4. New skills: Add to `skills/` directory with `SKILL.md` inside a named folder
5. Submodule: `git pull` in `vendor/mattpocock-skills/` to update, then commit the pointer
