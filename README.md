# ECC Agentic Development Workflow

Global OpenCode configuration providing an enterprise-grade agentic development workflow. Use it on ANY project — one install, all the tools, skills, and agents ready to go.

## Quick Install

```bash
git clone https://github.com/Nikankhadka/agenticdevelopment.git ~/.config/opencode/
cd ~/.config/opencode && npm install && npm run build
```

Then in any project:

```bash
cd ~/your-project
opencode
/init   # creates AGENTS.md for this project
```

## What's Included

### Behavioral Guardrails

4 Karpathy-inspired principles applied automatically to every session:
- Surface assumptions & ask when confused
- Minimum code, nothing speculative
- Surgical changes — touch only what you must
- Define success criteria, loop until verified

### 26 On-Demand Agent Skills

| Skill | When to Load |
|-------|-------------|
| `tdd-workflow` | Writing tests, bug fixes |
| `security-review` | Auth, input handling, API endpoints |
| `api-design` | REST API design |
| `backend-patterns` | Server-side architecture |
| `frontend-patterns` | React, state, components |
| `frontend-slides` | HTML presentations |
| `e2e-testing` | Playwright tests |
| `coding-standards` | Code quality review |
| `strategic-compact` | Context management |
| `eval-harness` | Eval-driven development |

Plus 16 Expo-specific skills (building native UI, API routes, deployment, etc.) — loaded via `skill({ name: "..." })`.

### 14 Specialized Agents

| Agent | Purpose |
|-------|---------|
| planner | Implementation planning |
| architect | System design |
| tdd-guide | Test-driven development |
| code-reviewer | Code review |
| security-reviewer | Security analysis |
| build-error-resolver | Fix build errors |
| e2e-runner | E2E Playwright tests |
| refactor-cleaner | Dead code cleanup |
| doc-updater | Documentation |
| database-reviewer | SQL optimization |
| python-reviewer | Python code review |
| docs-lookup | Context7 MCP docs lookup |
| harness-optimizer | Config reliability |
| loop-operator | Autonomous loops |

### 30+ Slash Commands

```
/plan          /tdd         /code-review
/security      /build-fix   /e2e
/refactor-clean              /orchestrate
/learn         /checkpoint  /verify
/eval          /update-docs /test-coverage
/quality-gate  /model-route /security-scan
/loop-start    /loop-status /harness-audit
/skill-create  /evolve      /projects
/instinct-status            /setup-pm
```

### 7 Custom Tools

- `run-tests` — Run test suite with coverage
- `check-coverage` — Check coverage thresholds
- `security-audit` — Security vulnerability scanning
- `format-code` — Auto-format files
- `lint-check` — Lint analysis
- `git-summary` — Git branch, status, diff summary
- `changed-files` — List files changed in session

### Plugin Hooks (Auto-Applied)

- Prettier formatting on JS/TS edits
- TypeScript check after .ts/.tsx edits
- `console.log` detection
- Security pre-checks on dangerous commands
- Desktop notification on task completion
- Shell env injection (PROJECT_ROOT, PACKAGE_MANAGER, etc.)
- Auto-approve for safe operations (reads, formatters, tests)
- Context compaction with ECC state preservation

### MCP Servers (Auto-Available)

- **Context7** — Real-time documentation search (`use context7`)
- **Grep by Vercel** — Code search on GitHub (`use gh_grep`)

## Directory Structure

```
~/.config/opencode/
├── opencode.jsonc          # Main config
├── instructions/
│   └── INSTRUCTIONS.md     # Core behavioral + orchestration rules
├── plugins/
│   ├── index.ts            # Plugin entry point
│   └── ecc-hooks.ts        # All hook implementations
├── skills/                 # 26 on-demand agent skills
│   ├── tdd-workflow/
│   ├── security-review/
│   ├── coding-standards/
│   └── ...
├── commands/               # 30+ slash command templates
│   ├── plan.md
│   ├── tdd.md
│   └── ...
├── prompts/agents/         # Agent system prompts
│   ├── planner.txt
│   ├── code-reviewer.txt
│   └── ...
├── tools/                  # 7 custom tool implementations
│   ├── run-tests.ts
│   ├── check-coverage.ts
│   └── ...
├── dist/                   # Compiled TypeScript (regenerated)
├── package.json
└── tsconfig.json
```

## Architecture

This config is designed for **cross-compatible agent tooling** (OpenCode, Claude Code, OpenAI Codex, etc.):
- Skills use standard YAML frontmatter with `name` + `description`
- Behavioral rules are OpenCode-primary with Claude fallback
- Works with all major AI coding agents

## Update

```bash
cd ~/.config/opencode && git pull && npm install && npm run build
```

## License

MIT
