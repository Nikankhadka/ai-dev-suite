# Development Guide: ECC Workflow

A practical guide for using the ECC agent orchestration suite from ideation to delivery. Read this outside of OpenCode — the INSTRUCTIONS.md loaded every session only contains behavioral guardrails.

---

## 1. The Pipeline

```
Plan → Build → Review → Test → Document
```

For every feature or fix, follow this sequence. Complex tasks trigger `/orchestrate` which coordinates multiple agents automatically.

---

## 2. Day-to-Day Workflow

### Plan Phase (Complex Features)

```
/plan Add semantic search to the marketplace
```

The `planner` agent (read-only) will:
- Analyze requirements and surface assumptions
- Present tradeoffs between approaches
- Design system architecture and database schema
- Create step-by-step implementation plan
- NOT write any code — waits for your approval

### Build Phase

**TDD approach (recommended for new features / bug fixes):**
```
/tdd User registration should validate email format
```
The `tdd-guide` agent:
1. Writes failing tests first (RED)
2. Implements minimal code to pass (GREEN)
3. Refactors while keeping tests green
4. Checks 80%+ coverage

**Direct coding (simple changes):**
Work directly with the `build` agent. Access all tools, web search, MCP docs, and on-demand skills.

### Review Phase

After writing code:
```
/review
```
The `reviewer` agent checks:
- Code quality and maintainability
- Security vulnerabilities (OWASP Top 10)
- Build and TypeScript errors
- Reports issues by severity with fix suggestions

### Test Phase

```
/e2e  Checkout flow should complete successfully
```
The `e2e-runner` generates Playwright tests, runs them, and captures artifacts.

### Document Phase

```
/maintain
```
The `maintainer` agent:
- Detects and removes dead code
- Consolidates duplicates
- Updates documentation and codemaps
- Tracks deletions in DELETION_LOG.md

---

## 3. System Commands

### Documentation Lookup

```
/docs How do I configure Next.js middleware?
/docs What are the Supabase auth methods?
```

Uses Context7 MCP to fetch current docs. Always prefer over training data.

### Project Memory

```
/memory                      # Show what's recorded in .opencode/MEMORY.md
/memory note <text>          # Append a decision/gotcha to project memory
/memory promote <topic>      # Copy a cross-project note into INSTRUCTIONS.md
```

### System Management

```
/system audit                # Check docs/config for drift (stale refs, missing files)
/system setup-pm              # Detect package manager and build/lint/test commands
```

### Evaluation

```
/eval                        # Run evaluation against criteria
/eval quality-gate           # Run quality gates
/eval checkpoint             # Save verification state
```

---

## 4. Multi-Agent Orchestration

For complex tasks spanning multiple domains:

```
/orchestrate Build a real-time chat feature with WebSocket support
```

The `ops` agent decomposes the task and dispatches:
- `planner` for system design
- `tdd-guide` for test-first implementation
- `reviewer` for quality and security
- `e2e-runner` for end-to-end testing

### Orchestration Patterns

**Sequential:** Later tasks depend on earlier results
```
planner → tdd-guide → reviewer → e2e-runner
```

**Parallel:** Independent tasks run simultaneously
```
planner →├→ reviewer
         └→ e2e-runner
```

**Fan-Out/Fan-In:** Multiple perspectives, then synthesis
```
         ┌→ agent-1 ─┐
planner →├→ agent-2 ─┼→ synthesizer
         └→ agent-3 ─┘
```

---

## 5. Skills — When to Load

Skills are loaded on-demand when a task matches. Available skills:

| Skill | Use For |
|-------|---------|
| `coding-standards` | Naming conventions, immutability, code review |
| `tdd-workflow` | Red → Green → Refactor patterns |
| `e2e-testing` | Playwright integration, Page Object Model |
| `strategic-compact` | Long sessions, context management |
| `lavish` | Interactive HTML planning artifacts for complex design |

Skills auto-load when matching tasks are detected. You can also load explicitly:
```
skill({ name: "tdd-workflow" })
```

---

## 6. Quick Reference

### Essential Commands

| Command | When |
|---------|------|
| `/plan <feature>` | Complex features, architecture decisions |
| `/tdd <requirement>` | New features, bug fixes |
| `/review` | After writing/modifying code |
| `/e2e <flow>` | End-to-end testing |
| `/maintain` | Code cleanup, documentation |
| `/docs <question>` | Library/framework docs lookup |
| `/orchestrate <task>` | Complex multi-step tasks |
| `/nomistakes` | Before push: full validation pipeline |
| `/gnhf <objective>` | Overnight autonomous coding loop |
| `/treehouse <action>` | Manage pooled git worktrees |
| `/firstmate` | Orchestrate sub-agent crew |
| `/compact` | After completing a phase |

### Agent Permissions

| Agent | Access | Use Case |
|-------|--------|----------|
| `build` | All tools | Day-to-day coding |
| `planner` | Read + bash | Analysis, planning (no write/edit) |
| `reviewer` | All tools | Code review, security, build fix |
| `tdd-guide` | All tools | Test-first development |
| `e2e-runner` | All tools | E2E tests |
| `maintainer` | All tools | Cleanup, documentation |
| `ops` | Read + bash + edit | System management, orchestration |

### Context Management

- Run `/compact` at logical boundaries (after planning, after debugging, before switching features)
- Don't compact mid-implementation
- Avoid the last 20% of context window for complex work

---

## 7. Kunchen Tool Suite

These CLI tools are installed globally and preferred over MCP equivalents where available.

| Tool | Purpose | Install |
|------|---------|---------|
| `gh-axi` | GitHub code search, PRs, issues (primary) | `npm install -g gh-axi` |
| `chrome-devtools-axi` | Browser automation for agents | `npm install -g chrome-devtools-axi` |
| `no-mistakes` | Validation pipeline (review, test, docs, lint, PR) | Binary installer |
| `gnhf` | Overnight autonomous iteration loops | `npm install -g gnhf` |
| `treehouse` | Pooled git worktrees for parallel agents | `go install` |
| `firstmate` | Multi-agent crew orchestrator in tmux | Clone + `cd firstmate && claude` |
| `quota-axi` | LLM subscription quota visibility | `npm install -g quota-axi` |
| `lavish-axi` | Interactive HTML planning artifacts | `npx skills add` |

### Workflow Integration

- Use `gh-axi` for GitHub operations (cheaper, faster than gh_grep MCP)
- Run `/nomistakes` before pushing to validate changes
- Use `/treehouse get` to spawn isolated worktrees for parallel tasks
- Run `/firstmate` for complex multi-task projects
- Use `/gnhf` for long-running autonomous loops

---

## 8. New Project Setup

```bash
cd ~/new-project
opencode
/init          # Creates AGENTS.md for this project
```

`/init` auto-detects:
- Language and framework
- Package manager (npm, pnpm, yarn, bun)
- Test framework (Jest, Vitest, Playwright)
- Build/lint commands

Commit `AGENTS.md` to git — it's your project's instruction manual for every agent session.

---

## Behavioral Guardrails (Always Active)

From INSTRUCTIONS.md — applied to every task automatically:

1. **Surface Assumptions** — State explicitly, ask when uncertain, stop when confused.
2. **Minimum Code** — No speculative features. If 200 lines could be 50, rewrite it.
3. **Surgical Changes** — Touch only what you must. Don't refactor unbroken things.
4. **Define Success Criteria** — "Add X" → "Write tests for X, then make them pass."
