# Agent Suite Instructions

Shared, global instructions for every agent session across all three harnesses this suite supports: Claude Code, OpenCode, and Codex CLI. This file lives once, at `instructions/AGENTS.md` in this repo (`~/.config/opencode`), and each harness's native entry point resolves straight to it:

| Harness | Native file | Resolves via |
|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md` | symlink to this file |
| Codex CLI | `~/.codex/AGENTS.md` | symlink to this file |
| OpenCode | `opencode.jsonc` `instructions` array | references this file directly |

No harness's format is treated as more canonical than another's here - this file is deliberately neutral. (This is a different file from a *project's own* `AGENTS.md`, generated per-project by `/init-project` - see Session start below for how the two relate.)

## Rules

- Never use the em dash "-". Use plain dash "-" instead
- When writing commit messages, NEVER auto-add your agent name as co-author
- Never manually modify CHANGELOG.md files or any files marked as auto-generated
- When making technical decisions, do not give much weight to development cost. Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it as possible
- When end-to-end testing a product, be picky about the UI and be obsessed with pixel perfection. If something clearly looks off, even if not directly related to what you are doing, fix it along the way
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness. If you see one, even if not caused by your work, still fix it

## Workflow

Pipeline: prompt -> spec (product framing, optional) -> plan -> build -> review -> test -> document -> release (optional via `/ship --release`). Run `/ship` for the full gated pipeline on non-trivial work.

Tool hierarchy: prefer native harness tools, then axi CLIs (token-cheap, no MCP round-trip), then MCP servers as the last resort.

### Session start

At the start of a session in a project, read that project's own `AGENTS.md` and `.agents/memory.md` if they exist. If the project has no `AGENTS.md`, tell the user and run `/init-project` before starting substantive work.

### When to dispatch a subagent vs. handle it yourself

Applies wherever the harness supports delegating to a specialist (`planner`, `reviewer`, `tester`, `maintainer`) - called "dispatch" here regardless of what a given harness calls the mechanism:

- Small, well-understood changes (typo fixes, single-function edits, config tweaks): handle directly, no dispatch needed.
- Anything touching multiple files, unclear requirements, or architecture decisions: dispatch `planner` first.
- After writing or changing code of any real size: dispatch `reviewer` before considering the work done.
- New features or bug fixes: work test-first per the `testing` skill; dispatch `tester` for E2E-flow work or when a dedicated test pass is warranted.
- Before wrapping up a task that changed behavior: dispatch `maintainer` to refresh docs/map/memory if `/ship` wasn't used.
- If your harness has no subagent dispatch available (or you're already running as one), do the work inline yourself rather than skipping a stage.
- Prefer `/ship` over ad hoc dispatch for any non-trivial task - it applies the gates in `commands/ship.md` so nothing gets skipped silently.

### Skills

Skills are never preloaded - each harness discovers them from `skills/<name>/SKILL.md` (via `~/.claude/skills`, `~/.agents/skills`, or this repo's own `skills/` directory for OpenCode) and loads one only when a task matches its description. You never need to preload a skill manually.

## Where things live

This repo is the single source for all three harnesses:

- **Agents**: `agents/*.md` - `build` (OpenCode's primary agent, no equivalent elsewhere) plus the four shared specialists (`planner`, `reviewer`, `tester`, `maintainer`), generated per-harness at `adapters/claude/agents/` (Claude Code) and `adapters/codex/agents/` (Codex CLI TOML)
- **Commands**: `commands/*.md` - one shared file per command, read natively by all three harnesses
- **Skills**: `skills/*/SKILL.md` - one shared file per skill, read natively by all three harnesses

See `README.md` for the full inventory and `docs/DEVELOPMENT.md` for day-to-day usage - this file only covers instructions loaded into every session.
