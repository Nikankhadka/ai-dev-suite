# ECC — Agent Orchestration Suite

A global OpenCode configuration providing an enterprise-grade agentic development workflow. Install once — get agents, skills, commands, tools, and MCP servers on every project.

## Quick Install

```bash
git clone https://github.com/Nikankhadka/agenticdevelopment.git ~/.config/opencode/
cd ~/.config/opencode
source ~/.zshrc
```

Then in any project:
```bash
cd ~/your-project
opencode
/init
```

---

## Architecture

```
┌──────────────────────────────────────────────────────┐
│  Agents (7)        │  Skills (5+)    │  Commands (14)│
│  Specialized AI    │  On-demand     │  Slash command │
│  subagents         │  domain guides │  shortcuts     │
├──────────────────────────────────────────────────────┤
│  CLI Tools (axi-family, primary) + MCP Servers       │
│  gh-axi > gh_grep fallback                           │
├──────────────────────────────────────────────────────┤
│  Global Memory: ~/.claude/CLAUDE.md                  │
│  Shared across Claude Code, OpenCode, Codex CLI     │
├──────────────────────────────────────────────────────┤
│  INSTRUCTIONS.md + ~/.claude/CLAUDE.md               │
│  Cross-harness rules + OpenCode-specific             │
├──────────────────────────────────────────────────────┤
│  opencode.jsonc — master configuration               │
└──────────────────────────────────────────────────────┘
```

---

## Agents (7)

Agents are specialized subagents dispatched by the primary `build` agent.

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| `build` (primary) | Day-to-day coding | General development |
| `planner` | Planning + system design + DB schema | Complex features, architecture |
| `reviewer` | Code quality + security + build fix | After writing code, build failures |
| `tdd-guide` | Test-driven development | New features, bug fixes |
| `e2e-runner` | E2E Playwright tests | Critical user flows |
| `maintainer` | Dead code cleanup + documentation | Code maintenance, doc updates |
| `ops` | Orchestration + memory + docs | Multi-agent pipelines, project memory notes, config audits |

---

## Commands (14)

### Engineering

| Command | Agent | Purpose |
|---------|-------|---------|
| `/plan` | planner | Implementation plan with architecture and DB design |
| `/tdd` | tdd-guide | Red → Green → Refactor, 80%+ coverage |
| `/review` | reviewer | Code quality, security, build error fix |
| `/e2e` | e2e-runner | Playwright E2E tests |
| `/maintain` | maintainer | Dead code cleanup + doc updates |
| `/orchestrate` | ops | Multi-agent pipeline for complex tasks |
| `/nomistakes` | ops | Validation pipeline (review, test, docs, lint, PR) |
| `/gnhf` | ops | Autonomous overnight coding loop |
| `/treehouse` | ops | Pooled git worktrees for parallel agents |
| `/firstmate` | ops | Orchestrate a crew of sub-agents in worktrees |

### System

| Command | Agent | Purpose |
|---------|-------|---------|
| `/memory` | ops | Instinct management, skills, project memory |
| `/system` | ops | Harness, loops, project setup, model routing |
| `/eval` | ops | Evaluation, verification, quality gates |
| `/docs` | ops | Realtime docs lookup via Context7 MCP |

---

## Skills (5+)

Domain knowledge loaded on-demand via `skill({ name })` when a task matches.

| Skill | Description |
|-------|-------------|
| `coding-standards` | Naming conventions, immutability, code quality |
| `tdd-workflow` | Red → Green → Refactor with 80%+ coverage |
| `e2e-testing` | Playwright patterns, Page Object Model, CI |
| `strategic-compact` | Context window management for long sessions |
| `lavish` | Interactive HTML planning artifacts for complex design |

---

## CLI Tools (Primary)

CLI tools are preferred over MCP for lower token cost and no round-trip latency.

| Tool | Use |
|------|-----|
| `gh-axi` | GitHub code search, PRs, issues (first choice) |
| `chrome-devtools-axi` | Agent-ergonomic browser automation |
| `gnhf` | Overnight autonomous coding loops |
| `quota-axi` | LLM quota visibility across providers |
| `no-mistakes` | Validation pipeline before push |
| `treehouse` | Pooled git worktrees for parallel agents |
| `firstmate` | Multi-agent crew orchestration in tmux |
| `lavish-axi` | Interactive HTML planning artifacts |

## MCP Servers (Fallback)

| Server | Tools | Use |
|--------|-------|-----|
| `context7` | `query-docs`, `resolve-library-id` | Fetch current library docs |
| `gh_grep` | `searchGitHub` | Fallback when gh-axi unavailable |

## Workflow

```
Plan → Build → Review → Test → Document
```

For complex tasks, run `/orchestrate` to coordinate multiple agents.

### New Project Setup

1. `opencode` in any project
2. `/init` generates project-specific AGENTS.md
3. Commit AGENTS.md to Git

---

## Environment Variables

```bash
export OPENCODE_ENABLE_EXA=1       # enables websearch
export OPENCODE_EXPERIMENTAL=true  # enables LSP tool
```

---

## Global Memory (Cross-Harness)

```
~/.claude/CLAUDE.md             # Global rules — loaded by all harnesses
~/.codex/AGENTS.md              # Symlink → ~/.claude/CLAUDE.md
```

## Directory Structure

```
~/.config/opencode/
├── opencode.jsonc              # Master config
├── AGENTS.md.template          # Template for /init in new projects
├── instructions/
│   └── INSTRUCTIONS.md         # OpenCode-specific orchestration rules
├── prompts/agents/             # Agent system prompts (6 .txt files)
├── commands/                   # Command templates (10+4 .md files)
├── skills/                     # 5 on-demand skills
├── .agents/skills/lavish       # Lavish skill from npx installer
```

---

## Maintenance

```bash
cd ~/.config/opencode && git pull
```

---

## License

MIT
