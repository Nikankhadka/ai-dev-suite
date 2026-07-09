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
│  Agents (7)        │  Skills (4)    │  Commands (10)│
│  Specialized AI    │  On-demand     │  Slash command │
│  subagents         │  domain guides │  shortcuts     │
├──────────────────────────────────────────────────────┤
│  Built-in Tools + 2 MCP Servers                      │
├──────────────────────────────────────────────────────┤
│  INSTRUCTIONS.md  │  MCP Servers                     │
│  Core behavioral  │  context7,                       │
│  rules + agent    │  gh_grep                         │
│  orchestration    │                                  │
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
| `ops` | Orchestration + memory + system | Multi-agent pipelines, instincts, loops |

---

## Commands (10)

### Engineering

| Command | Agent | Purpose |
|---------|-------|---------|
| `/plan` | planner | Implementation plan with architecture and DB design |
| `/tdd` | tdd-guide | Red → Green → Refactor, 80%+ coverage |
| `/review` | reviewer | Code quality, security, build error fix |
| `/e2e` | e2e-runner | Playwright E2E tests |
| `/maintain` | maintainer | Dead code cleanup + doc updates |
| `/orchestrate` | ops | Multi-agent pipeline for complex tasks |

### System

| Command | Agent | Purpose |
|---------|-------|---------|
| `/memory` | ops | Instinct management, skills, project memory |
| `/system` | ops | Harness, loops, project setup, model routing |
| `/eval` | ops | Evaluation, verification, quality gates |
| `/docs` | ops | Realtime docs lookup via Context7 MCP |

---

## Skills (4)

Domain knowledge loaded on-demand via `skill({ name })` when a task matches.

| Skill | Description |
|-------|-------------|
| `coding-standards` | Naming conventions, immutability, code quality |
| `tdd-workflow` | Red → Green → Refactor with 80%+ coverage |
| `e2e-testing` | Playwright patterns, Page Object Model, CI |
| `strategic-compact` | Context window management for long sessions |

---

## MCP Servers

| Server | Tools | Use |
|--------|-------|-----|
| `context7` | `query-docs`, `resolve-library-id` | Fetch current library docs |
| `gh_grep` | `searchGitHub` | Search public GitHub code |

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

## Directory Structure

```
~/.config/opencode/
├── opencode.jsonc              # Master config
├── instructions/
│   └── INSTRUCTIONS.md         # Behavioral rules + orchestration
├── prompts/agents/             # Agent system prompts (6 .txt files)
├── commands/                   # Command templates (10 .md files)
├── skills/                     # 4 on-demand skills
```

---

## Maintenance

```bash
cd ~/.config/opencode && git pull
```

---

## License

MIT
