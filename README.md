# AI Development Suite

A global OpenCode configuration providing an enterprise-grade agentic development workflow. Install once — get agents, skills, commands, tools, and MCP servers on every project.

## Quick Install

```bash
git clone https://github.com/Nikankhadka/agenticdevelopment.git ~/.config/opencode/
cd ~/.config/opencode && npm install && npm run build
source ~/.zshrc
```

Then in any project:

```bash
cd ~/your-project
opencode
/init   # creates AGENTS.md for this project
```

---

## Architecture

The suite has five layers that work together:

```
┌──────────────────────────────────────────────────────┐
│  Agents (14)     │  Skills (10)    │  Commands (28) │
│  Specialized AI  │  On-demand      │  Slash command  │
│  subagents       │  domain guides  │  shortcuts      │
├──────────────────────────────────────────────────────┤
│  Tools (7 built-in + 7 custom + 2 MCP + 2 enabled)  │
│  bash, edit, read, grep, glob, websearch, lsp, ...   │
├──────────────────────────────────────────────────────┤
│  Plugin Hooks  │  INSTRUCTIONS.md  │  MCP Servers   │
│  Auto-format,  │  Core behavioral  │  context7,     │
│  typecheck,    │  rules + agent    │  gh_grep       │
│  notifications │  orchestration    │                │
├──────────────────────────────────────────────────────┤
│  opencode.jsonc — master configuration               │
└──────────────────────────────────────────────────────┘
```

- **Agents** — specialized subagents dispatched for specific tasks (planning, review, testing, etc.)
- **Skills** — on-demand domain knowledge loaded via `skill({ name })`
- **Commands** — slash command shortcuts that route to agents with templates
- **Tools** — actions the AI can take (read files, run commands, search web, fetch docs)
- **Plugin hooks** — automatic formatting, typechecking, and safety checks
- **MCP servers** — external tool integrations (docs search, GitHub code search)

---

## Behavioral Guardrails

Four Karpathy-inspired principles applied automatically to every session:

1. **Surface assumptions** — state what's unclear, don't guess silently
2. **Minimum code** — no speculative features, no unnecessary abstractions
3. **Surgical changes** — touch only what you must; match existing style
4. **Define success criteria** — write tests first, loop until verified

---

## Agents (14)

Agents are specialized subagents dispatched by the primary `build` agent for focused tasks.

### Core Development

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| `planner` | Implementation planning | Complex features, refactoring |
| `architect` | System design | Architecture decisions |
| `tdd-guide` | Test-driven development | New features, bug fixes |
| `code-reviewer` | Code quality review | After writing code |
| `security-reviewer` | Security analysis | Auth, input handling, APIs |

### Operations

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| `build-error-resolver` | Fix build/type errors | Build failures |
| `e2e-runner` | E2E Playwright tests | Critical user flows |
| `refactor-cleaner` | Dead code cleanup | Code maintenance |
| `doc-updater` | Documentation | Updating docs/codemaps |
| `database-reviewer` | SQL optimization | Schema design, queries |

### Specialized

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| `python-reviewer` | Python code review | PEP 8, type hints, perf |
| `docs-lookup` | Context7 docs lookup | Library/framework docs |
| `harness-optimizer` | Config reliability | Tuning agent harness |
| `loop-operator` | Autonomous agent loops | Long-running tasks |

---

## Commands (28)

Slash commands route to agents with pre-built templates. Available from the TUI.

### Development Workflow

| Command | Agent | Purpose |
|---------|-------|---------|
| `/plan` | planner | Implementation planning |
| `/tdd` | tdd-guide | TDD: red → green → refactor |
| `/code-review` | code-reviewer | Code quality review |
| `/security` | security-reviewer | Security audit |
| `/build-fix` | build-error-resolver | Fix build errors |
| `/e2e` | e2e-runner | Playwright E2E tests |
| `/refactor-clean` | refactor-cleaner | Dead code cleanup |

### Quality & Verification

| Command | Purpose |
|---------|---------|
| `/verify` | Run verification loop (tests, lint, coverage) |
| `/quality-gate` | Quality gates on file/repo |
| `/test-coverage` | Analyze test coverage |
| `/security-scan` | Scan for vulnerabilities |

### Documentation

| Command | Agent | Purpose |
|---------|-------|---------|
| `/update-docs` | doc-updater | Update documentation |
| `/update-codemaps` | doc-updater | Update codemaps |

### Meta & Operations

| Command | Purpose |
|---------|---------|
| `/orchestrate` | Multi-agent pipeline for complex tasks |
| `/learn` | Extract patterns from session |
| `/checkpoint` | Save verification state |
| `/eval` | Run evaluation against criteria |
| `/model-route` | Route tasks by model and budget |
| `/harness-audit` | Audit harness reliability |
| `/loop-start` | Start autonomous agent loop |
| `/loop-status` | Check loop state |
| `/setup-pm` | Configure package manager |
| `/projects` | List known projects |

### Skill Management

| Command | Purpose |
|---------|---------|
| `/skill-create` | Generate skills from git history |
| `/evolve` | Cluster instincts into skills |
| `/promote` | Promote project instincts to global |
| `/instinct-status` | View learned instincts |
| `/instinct-import` | Import instincts |
| `/instinct-export` | Export instincts |

---

## Agent Skills (10)

On-demand domain knowledge loaded only when a task matches. The agent discovers available skills automatically and calls `skill({ name })` when needed.

| Skill | Description |
|-------|-------------|
| `api-design` | REST API patterns: resources, status codes, pagination, error responses |
| `backend-patterns` | Server architecture: Node.js, Express, database optimization |
| `frontend-patterns` | React, Next.js, state management, performance, forms |
| `coding-standards` | Naming conventions, immutability, code quality |
| `security-review` | Auth patterns, input validation, secrets management |
| `tdd-workflow` | Red → Green → Refactor with 80%+ coverage |
| `e2e-testing` | Playwright patterns, Page Object Model, CI integration |
| `verification-loop` | Multi-phase quality verification system |
| `strategic-compact` | Context window management for long sessions |
| `eval-harness` | Eval-driven development (EDD), pass@k metrics |

Skills load from `~/.config/opencode/skills/<name>/SKILL.md`. They are not pre-loaded — only injected into context when a matching task is detected.

---

## Tools (18)

### Built-in Tools (13)

Standard OpenCode tools available to all agents.

| Tool | Purpose |
|------|---------|
| `bash` | Execute shell commands |
| `edit` | Precise string replacements in files |
| `write` | Create or overwrite files |
| `read` | Read file contents |
| `grep` | Regex search across files |
| `glob` | File pattern matching |
| `skill` | Load agent skills |
| `todowrite` | Task tracking during sessions |
| `task` | Dispatch subagent tasks |
| `question` | Ask user for input/clarification |
| `webfetch` | Fetch web page content |
| `websearch` | Web discovery/search via Exa AI |
| `lsp` | Code intelligence (definitions, references, hover) |

### Custom Tools (7)

Project-specific tools extending the built-in set.

| Tool | Purpose |
|------|---------|
| `run-tests` | Run test suite with coverage detection |
| `check-coverage` | Check coverage against 80% threshold |
| `security-audit` | Audit dependencies, secrets, and code |
| `lint-check` | Run linter with auto-fix option |
| `format-code` | Detect and run code formatter |
| `git-summary` | Git branch, status, recent commits |
| `changed-files` | Files changed in current session |

### MCP Tools (from MCP servers)

| Server | Tools Provided | Use |
|--------|---------------|-----|
| `context7` | `context7_query-docs`, `context7_resolve-library-id` | Fetch current library docs |
| `gh_grep` | `gh_grep_searchGitHub` | Search public GitHub code |

---

## Plugin Hooks (Auto-Applied)

The ECC plugin (`plugins/ecc-hooks.ts`) provides automated guardrails:

- **Prettier formatting** on JS/TS file edits (strict profile)
- **TypeScript check** (`tsc --noEmit`) after each `.ts`/`.tsx` edit
- **console.log detection** — warns on edit, audits on session idle
- **Security pre-checks** — warns before `git push`, doc file creation
- **Desktop notification** on task completion
- **Shell env injection** — `PROJECT_ROOT`, `PACKAGE_MANAGER`, `DETECTED_LANGUAGES`
- **Auto-approve safe ops** — reads, formatters, test runners

---

## MCP Servers

### Context7
Real-time documentation search. Accesses current docs for any library/framework.

```
How do I set up Prisma with Postgres? use context7
```

### Grep by Vercel
Search public GitHub repositories for real-world code examples.

```
Show me real-world useEffect cleanup patterns. use gh_grep
```

---

## Environment Variables

Required for full functionality:

```bash
export OPENCODE_ENABLE_EXA=1      # enables websearch tool
export OPENCODE_EXPERIMENTAL=true  # enables lsp tool + experimental features
```

These are automatically added to `~/.zshrc` during install. Reload with `source ~/.zshrc`.

---

## Workflow Patterns

### TDD Loop
```
/tdd
> Add user registration endpoint
```
1. Agent writes failing tests first
2. Implements minimum code to pass
3. Refactors with coverage check
4. Loops until 80%+ coverage

### Code Review Loop
```
/code-review
> Review the changes in src/auth/
```
1. Reviewer agent analyzes quality, security, maintainability
2. Reports issues by severity
3. Suggests fixes with examples

### Security Audit Loop
```
/security-scan
> Scan src/api/ for vulnerabilities
```
1. Checks input validation, auth, secrets, injection
2. Flags by severity (critical → low)
3. Provides remediation steps

### Planning → Implementation
```
/plan
> Add rate limiting to all API endpoints
```
1. Planner agent creates structured implementation plan
2. User reviews, iterates, approves
3. Switch to build mode for execution

---

## Directory Structure

```
~/.config/opencode/
├── opencode.jsonc              # Master config (agents, commands, MCP, tools, LSP)
├── instructions/
│   └── INSTRUCTIONS.md         # Core behavioral rules + agent orchestration
├── agents/                     # Agent definitions (not in this repo — defined in opencode.jsonc)
├── skills/                     # 10 on-demand agent skills
│   ├── api-design/SKILL.md
│   ├── backend-patterns/SKILL.md
│   ├── coding-standards/SKILL.md
│   ├── e2e-testing/SKILL.md
│   ├── eval-harness/SKILL.md
│   ├── frontend-patterns/SKILL.md
│   ├── security-review/SKILL.md
│   ├── strategic-compact/SKILL.md
│   ├── tdd-workflow/SKILL.md
│   └── verification-loop/SKILL.md
├── commands/                   # 28 slash command templates
│   ├── plan.md
│   ├── tdd.md
│   ├── code-review.md
│   └── ...
├── prompts/agents/             # Agent system prompts (.txt files)
│   ├── planner.txt
│   ├── code-reviewer.txt
│   └── ...
├── plugins/                    # Auto-applied hook implementations
│   ├── index.ts
│   └── ecc-hooks.ts
├── tools/                      # 7 custom tool implementations
│   ├── index.ts                # Barrel export
│   ├── run-tests.ts
│   ├── check-coverage.ts
│   ├── security-audit.ts
│   ├── format-code.ts
│   ├── lint-check.ts
│   ├── git-summary.ts
│   └── changed-files.ts
├── dist/                       # Compiled TypeScript (regenerated on build)
├── package.json
└── tsconfig.json
```

---

## New Project Setup

1. Navigate to any project and run `opencode`
2. Run `/init` to generate an `AGENTS.md` with project-specific build/lint/test commands
3. Commit `AGENTS.md` to Git
4. The suite auto-detects project language, package manager, and test framework

---

## Maintenance

```bash
# Update to latest
cd ~/.config/opencode && git pull && npm install && npm run build

# Reload env vars
source ~/.zshrc
```

---

## License

MIT
