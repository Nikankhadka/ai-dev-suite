# Global Agent Development Suite

A stack-agnostic, harness-agnostic agentic development workflow for a one-person team. Set it up once here; it is symlinked into Claude Code, OpenCode, and Codex CLI, so opening any project in any of the three gives the same agents, commands, skills, and pipeline - no per-project setup beyond `/init-project`.

This is the only file with the full agent/command/skill inventory - don't duplicate these tables elsewhere.

## Install

```bash
git clone <this-repo> ~/.config/opencode
cd ~/.config/opencode
bin/sync-adapters.sh
```

`sync-adapters.sh` generates the Claude Code agent adapters and creates every symlink listed below. It is idempotent - rerun it any time after editing this repo (existing correct symlinks are left alone; anything else in the way is backed up to `<path>.pre-sync-adapters.bak` before relinking).

Then, in any project:
```bash
cd ~/your-project
opencode   # or: claude / codex
/init-project
```

## Architecture

```
agents/*.md, commands/*.md, skills/*/SKILL.md   <- single source of truth
        |
        +-- OpenCode reads these directly (native auto-discovery)
        |
        +-- bin/sync-adapters.sh --> adapters/claude/agents/*.md (generated)
        |                        --> symlinks into ~/.claude, ~/.codex, ~/.agents
        |
        +-- Claude Code / Codex CLI read the symlinked copies
```

Tool hierarchy used throughout: native harness tools first, then axi CLIs (cheap, no MCP round-trip), then MCP servers as the last resort.

## Agents (5)

| Agent | Mode | Use for |
|---|---|---|
| `build` | primary | day-to-day coding; dispatches the other four, mainly via `/ship` |
| `planner` | subagent, read-only | implementation plans before non-trivial changes |
| `reviewer` | subagent | code quality, security, build-error review |
| `tester` | subagent | test-first implementation and E2E bug repro |
| `maintainer` | subagent | dead-code cleanup, doc/map/memory refresh |

Definitions live in `agents/*.md`. `build` has no Claude Code adapter (it maps to OpenCode's primary-agent concept, which Claude Code and Codex CLI don't need a translated file for - their main session already has full tool access).

## Commands (12)

| Command | Agent | Purpose |
|---|---|---|
| `/ship` | build | full gated pipeline: plan -> build -> review -> test -> docs |
| `/plan` | planner | implementation plan; waits for approval before code |
| `/test` | tester | TDD, E2E, bug repro, or coverage check |
| `/review` | reviewer | quality/security/build-error review |
| `/maintain` | maintainer | dead code, duplicates, doc/map/memory refresh |
| `/init-project` | build | generate `AGENTS.md` + `.agents/` for a project |
| `/audit` | build | drift check for this suite, or for a project's `AGENTS.md`/`.agents/` freshness |
| `/memory` | build | read/write `.agents/memory.md` |
| `/docs` | build | library/framework docs lookup, cheapest source first |
| `/nomistakes` | build | `no-mistakes` CLI validation pipeline |
| `/gnhf` | build | `gnhf` CLI autonomous overnight loop |
| `/treehouse` | build | `treehouse` CLI pooled git worktrees |

Definitions live in `commands/*.md`. The last three wrap external axi CLIs and no-op with an install hint if the binary isn't on `PATH`.

## Skills (4)

| Skill | Description |
|---|---|
| `stack-discovery` | runtime protocol for detecting a project's language/tooling instead of assuming one |
| `coding-standards` | stack-agnostic naming, readability, immutability, error-handling, security-basics |
| `testing` | TDD (RED-GREEN-REFACTOR) and E2E methodology, stack-agnostic |
| `strategic-compact` | when to suggest manual `/compact` at task boundaries |

Definitions live in `skills/*/SKILL.md`. Loaded on demand, never preloaded.

## CLI Tools (axi family - primary, cheaper than MCP)

| Tool | Use |
|---|---|
| `gh-axi` | GitHub code search, PRs, issues - first choice over MCP |
| `chrome-devtools-axi` | agent-ergonomic browser automation |
| `gnhf` | overnight autonomous coding loops |
| `quota-axi` | LLM quota visibility across providers |
| `no-mistakes` | validation pipeline before push |
| `treehouse` | pooled git worktrees for parallel agents |

Check `command -v <tool>` before relying on one - `/audit` reports which are installed.

## MCP Servers (fallback only)

| Server | Tools | Use |
|---|---|---|
| `context7` | `resolve-library-id`, `get-library-docs` | current library docs, only after `gh-axi` doesn't answer it |
| `gh_grep` | GitHub code search | fallback when `gh-axi` is unavailable |

## Cross-harness wiring (created by `bin/sync-adapters.sh`)

| Link | Target |
|---|---|
| `~/.claude/CLAUDE.md` | `instructions/RULES.md` |
| `~/.claude/commands` | `commands/` (whole directory) |
| `~/.claude/agents` | `adapters/claude/agents/` (generated) |
| `~/.claude/skills/<name>` | `skills/<name>/` (one link per skill) |
| `~/.codex/AGENTS.md` | `instructions/RULES.md` (Codex merges this with each project's own `AGENTS.md`) |
| `~/.codex/prompts` | `commands/` (whole directory) |
| `~/.agents/skills/<name>` | `skills/<name>/` (Codex's real global skills path - one link per skill) |

## Workflow

```
prompt -> plan -> build -> review -> test -> document
```

Run `/ship` for the full gated version of this pipeline on anything non-trivial. Standalone commands (`/plan`, `/test`, `/review`, `/maintain`) exist for smaller, single-stage work.

### New project setup

1. `opencode` (or `claude` / `codex`) in any project
2. `/init-project` generates `AGENTS.md` + `.agents/map.md` + `.agents/memory.md`, and symlinks `CLAUDE.md -> AGENTS.md`
3. Commit `AGENTS.md`, `CLAUDE.md`, and `.agents/` to git

## Directory structure

```
~/.config/opencode/
├── opencode.jsonc            # OpenCode config: instructions, permission, lsp, mcp only
├── instructions/
│   ├── RULES.md              # cross-harness rules, loaded by all three harnesses every session
│   └── OPENCODE.md           # OpenCode-only notes
├── agents/                   # 5 agent definitions (OpenCode-native, auto-discovered)
├── commands/                 # 12 command definitions (OpenCode-native, auto-discovered)
├── skills/                   # 4 on-demand skills
├── templates/                # AGENTS.md.template, memory.md.template (used by /init-project)
├── adapters/claude/agents/   # generated Claude Code agent files - do not hand-edit
├── bin/sync-adapters.sh      # regenerates adapters, (re)creates all symlinks
└── docs/
    ├── DEVELOPMENT.md        # usage guide
    └── EVALS.md              # how this suite is verified
```

## Maintenance

```bash
cd ~/.config/opencode && git pull && bin/sync-adapters.sh
```

Run `/audit` periodically (or after editing this repo) to catch drift.

## License

MIT
