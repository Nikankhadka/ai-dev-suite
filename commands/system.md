---
description: Config audit and project setup
agent: ops
subtask: true
---

# System Command

Audit the current agent config or set up this project: $ARGUMENTS

## Operations

### Config Audit
- `audit` — Read `opencode.jsonc`, `instructions/INSTRUCTIONS.md`, the `commands/`, `prompts/agents/`, and `skills/` directories. Report:
  - Commands/agents/skills referenced in docs that don't exist as files (or vice versa)
  - Agent tool permissions that don't match what the agent's prompt claims to do
  - MCP servers configured but not documented, or documented but not configured
  - Stale references to removed functionality
  This is a read-only documentation-vs-reality check, not a scored/automated pipeline.

### Package Manager Setup
- `setup-pm` — Detect the project's package manager from lockfiles (`package-lock.json` → npm, `pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, `bun.lock` → bun) and report build/lint/test commands found in `package.json` scripts.

## Report Format

List what was checked, what was found, and any fixes applied (with file:line references).

**TIP**: Run `/system audit` after editing `opencode.jsonc` or any agent/command/skill file to catch drift between what's documented and what's configured.
