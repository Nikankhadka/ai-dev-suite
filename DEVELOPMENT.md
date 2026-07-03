# Development Guide: Plan to Delivery

A comprehensive guide for using OpenCode with the ECC agentic workflow to build projects from ideation to delivery. Read this outside of OpenCode as a reference — the INSTRUCTIONS.md that loads every session only contains behavioral guardrails (the "how").

---

## 1. Project Init

Every project starts with OpenCode understanding your codebase.

```bash
cd ~/new-project
opencode
/init
```

This creates an `AGENTS.md` in your project root with:
- Build, lint, test commands (auto-detected)
- Project structure, architecture notes
- Coding conventions
- Framework-specific patterns

**Commit AGENTS.md** to git — it's your project's instruction manual for every agent.

---

## 2. The Development Pipeline

Follow this sequence for every feature or fix:

```
Plan → TDD → Code → Review → Security → Verify → Deliver
```

### Plan

For complex features or refactoring, start here before any code:

```
/plan Add search with semantic embeddings
```

The `planner` agent will:
- Analyze requirements and surface assumptions
- Present tradeoffs between approaches
- Create a step-by-step implementation plan
- NOT write any code (read-only agent)

Verify the plan meets the behavioral guardlines: is it simple? Surgical? Has clear success criteria?

### TDD (Red → Green → Refactor)

For any new feature or bug fix:

```
/tdd User registration should validate email format
```

The `tdd-guide` agent:
1. Writes tests that fail (RED — validates tests exist and fail for the right reason)
2. Implements minimal code to pass (GREEN)
3. Refactors while keeping tests green
4. Checks 80%+ coverage

Run tests during development:

```
/test-coverage
```

### Code

For straightforward changes, work directly with the `build` agent:
- Access to all tools (read, write, edit, bash, grep, glob, etc.)
- Web search for research (`webfetch` + `websearch` + `context7` MCP)
- All skills available on-demand via `skill({ name: "..." })`

Load relevant skills for your task:

```
skill({ name: "api-design" })     # API endpoint patterns
skill({ name: "frontend-patterns" }) # React/component patterns
skill({ name: "backend-patterns" })  # Server-side architecture
skill({ name: "security-review" })   # Security best practices
```

### Code Review

After writing code:

```
/code-review
```

The `code-reviewer` agent checks for:
- Code quality and maintainability
- Potential bugs and edge cases
- Performance implications
- Adherence to project patterns

### Security Review

For code handling user input, auth, or sensitive data:

```
/security
```

Or for a deeper scan:

```
/security-scan
```

The `security-reviewer` checks:
- Hardcoded secrets
- Input validation
- SQL injection, XSS, CSRF
- Auth/authorization gaps
- Dependency vulnerabilities

### Verify

Before delivery, run the full verification loop:

```
/verify
```

This runs:
1. Build check (`npm run build`, `tsc --noEmit`)
2. Type check
3. Lint (`npm run lint`)
4. Test suite with coverage (`npm test -- --coverage`)
5. Security scan
6. Diff review

You also have granular verification:

```
/quality-gate            # Run quality gates
/eval criteria           # Run eval against criteria
/checkpoint              # Save verification state
```

### Delivery

Once verified:

```
/build-fix               # Resolve any remaining build errors
/test-coverage           # Final coverage check
```

---

## 3. Advanced Patterns

### Multi-Agent Orchestration

For complex tasks spanning multiple domains:

```
/orchestrate Build a real-time chat feature with WebSocket support
```

The `planner` agent decomposes the task and dispatches to specialized agents:
- `architect` for system design
- `tdd-guide` for test-first implementation
- `code-reviewer` for quality
- `security-reviewer` for security
- `build-error-resolver` if build fails

### Research-Driven Development

For tasks requiring external research:

```
/plan Research and implement background job processing
```

The agent uses:
- `websearch` for finding current solutions and libraries
- `context7` MCP for live documentation lookup
- `gh_grep` MCP for real-world code examples
- `webfetch` for reading official docs

### Documentation

```
/update-docs README for new API endpoint
/update-codemaps
```

The `doc-updater` agent reads your code and writes comprehensive documentation.

### Autonomous Agent Loops

For batch tasks that run unattended:

```
/loop-start Process all TODO comments in the codebase
/loop-status              # Check progress
```

---

## 4. Skill Selection Guide

When to load each skill during your workflow:

| Phase | Skills to Load |
|-------|---------------|
| Planning | `api-design`, `backend-patterns`, `frontend-patterns` |
| Architecture | `coding-standards` |
| Development (API) | `api-design`, `backend-patterns`, `database-reviewer` |
| Development (Frontend) | `frontend-patterns`, `frontend-slides` |
| Testing | `tdd-workflow`, `e2e-testing` |
| Security | `security-review` |
| Delivery | `eval-harness`, `strategic-compact` |

For Expo projects, additionally load: `expo-building-native-ui`, `expo-api-routes`, `expo-deployment`, `expo-upgrading-expo`, `expo-use-dom`, `expo-ui`, `expo-tailwind-setup`, `expo-module`, `expo-native-data-fetching`, `expo-observe`, `expo-add-app-clip`, `expo-brownfield`, `expo-cicd-workflows`, `expo-dev-client`, `expo-eas-update-insights`.

---

## 5. Cost Optimization

### Model Strategy
- **Qwen 3.6 Plus** (default): Day-to-day coding, lightweight agents
- **DeepSeek V4 Pro**: Complex architecture, code review, security, build errors, database optimization

Use `/model-route` to route specific tasks to the right model:

```
/model-route Design database schema --budget high
/model-route Fix typo in README --budget low
```

### Context Management
- Run `/compact` at logical boundaries (after planning, after debugging, before switching features)
- Don't compact mid-implementation
- Save important state to files before compacting

### Config Settings (from opencode.jsonc)
- All tools enabled via `"permission": "allow"` — no approval prompts
- MCP servers enabled: Context7 (docs), Grep by Vercel (code)
- `websearch` available via `OPENCODE_ENABLE_EXA=1`
- `lsp` available via `OPENCODE_EXPERIMENTAL_LSP_TOOL=true`
- Model selection manual (no defaults set)

---

## 6. Project Types

### Web App (Next.js, etc.)

1. `/init` → auto-detects TypeScript, npm, Next.js
2. Use `api-design`, `frontend-patterns`, `backend-patterns` skills
3. `/tdd` for features, `/code-review` after, `/security` before push

### Expo / React Native

1. `/init` → auto-detects TypeScript, Expo
2. Load relevant Expo skills: `expo-building-native-ui`, `expo-api-routes`, `expo-deployment`
3. Use Expo Go for development (`npx expo start`)

### API / Backend

1. `/init` → auto-detects framework
2. Use `api-design`, `backend-patterns`, `database-reviewer` skills
3. `/plan` for architecture decisions, `/tdd` for endpoints

### Python / Data Science

1. `/init` → auto-detects Python
2. Use `python-reviewer` for code review
3. `/code-review` with python type hints focus

---

## 7. Quick Reference

### Essential Commands

| Command | When |
|---------|------|
| `/plan <feature>` | Before implementing complex work |
| `/tdd <requirement>` | New features, bug fixes |
| `/code-review` | After writing/modifying code |
| `/security` | Code handling user input or auth |
| `/verify` | Before delivery/commit |
| `/build-fix` | When build fails |
| `/orchestrate <task>` | Complex multi-step tasks |
| `/compact` | After completing a phase |

### Essential Skills

| Skill | Use for |
|-------|---------|
| `api-design` | REST API design patterns |
| `backend-patterns` | Server architecture, caching, DB |
| `frontend-patterns` | React, component design |
| `tdd-workflow` | Test patterns, Red-Green-Refactor |
| `security-review` | Security checklists |
| `e2e-testing` | Playwright integration |
| `database-reviewer` | SQL, schema, RLS policies |

### Agent Quick Reference

| Agent | Access | Use Case |
|-------|--------|----------|
| `build` | All tools | Day-to-day coding |
| `planner` | Read-only | Analysis, planning |
| `tdd-guide` | All tools | Test-first development |
| `code-reviewer` | Read + bash | Code quality review |
| `security-reviewer` | All tools | Security audit |
| `build-error-resolver` | All tools | Fix build/type errors |
| `e2e-runner` | All tools | E2E Playwright tests |

---

## Behavioral Guardlines (Always Active)

These rules apply to every task automatically (from INSTRUCTIONS.md):

1. **Surface Assumptions** — State assumptions explicitly. If uncertain, ask. When confused, stop and clarify.
2. **Minimum Code** — No features beyond what was asked. No speculative abstractions. If 200 lines could be 50, rewrite it.
3. **Surgical Changes** — Touch only what you must. Don't refactor unbroken things. Remove only what YOUR changes made unused.
4. **Define Success Criteria** — Transform "Add X" into "Write tests for X, then make them pass". Loop until verified.
