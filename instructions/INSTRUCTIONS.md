# ECC - Agent Orchestration Instructions

This document defines the core orchestration rules for a cross-compatible AI agent workflow (OpenCode, Claude Code, OpenAI Codex, and similar tools). Domain-specific guidance lives in on-demand skills — load them via the `skill` tool when a task matches a skill's description.

## Skill Loading

Skills are NOT preloaded. They are discovered automatically from `~/.config/opencode/skills/<name>/SKILL.md` and loaded on-demand via the native `skill({ name })` tool. Only load a skill when the task at hand matches its description. Available skills are listed in the `skill` tool description.

## Agent Orchestration

### Available Agents

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| planner | Implementation planning | Complex features, refactoring |
| architect | System design | Architectural decisions |
| tdd-guide | Test-driven development | New features, bug fixes |
| code-reviewer | Code review | After writing code |
| security-reviewer | Security analysis | Before commits |
| build-error-resolver | Fix build errors | When build fails |
| e2e-runner | E2E testing | Critical user flows |
| refactor-cleaner | Dead code cleanup | Code maintenance |
| doc-updater | Documentation | Updating docs |
| database-reviewer | Database optimization | SQL, schema design |

### Immediate Agent Usage

No user prompt needed:
1. Complex feature requests - Use **planner** agent
2. Code just written/modified - Use **code-reviewer** agent
3. Bug fix or new feature - Use **tdd-guide** agent
4. Architectural decision - Use **architect** agent

---

## Behavioral Guardrails

Prevent common LLM coding mistakes (from [Karpathy's observations](https://x.com/karpathy/status/2015883857489522876)). Apply to every task. Bias toward caution on non-trivial work.

### 1. Surface Assumptions, Don't Hide Confusion
- State assumptions explicitly before implementing. If uncertain, ask.
- When multiple interpretations exist, present them — don't pick silently.
- When confused, stop, name what's unclear, and seek clarification.

### 2. Minimum Code, Nothing Speculative
- No features beyond what was asked. No abstractions for single-use code.
- No unrequested "flexibility" or "configurability."
- If 200 lines could be 50, rewrite it. Would a senior engineer call this overcomplicated?

### 3. Surgical Changes — Touch Only What You Must
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor unbroken things. Match existing style.
- Remove only imports/variables YOUR changes made unused. Mention dead code — don't delete unless asked.
- Test: every changed line traces directly to the user's request.

### 4. Define Success Criteria, Loop Until Verified
- "Add X" → "Write tests for X, then make them pass"
- "Fix bug" → "Write a test that reproduces it, then fix"
- Multi-step: state `1. [Step] → verify: [check], 2. ...`
- Strong criteria let you loop independently to completion.

---

## Performance Optimization

### Model Selection Strategy

**Qwen 3.6 Plus** (default, fast, cost-effective):
- Day-to-day development tasks
- Lightweight agents (tdd-guide, doc-updater, e2e-runner)
- General coding and refactoring

**DeepSeek V4 Pro** (deepest reasoning):
- Complex architectural decisions (planner, architect)
- Code and security review (code-reviewer, security-reviewer)
- Build error resolution (build-error-resolver)
- Database optimization (database-reviewer)

### Context Window Management

Avoid last 20% of context window for:
- Large-scale refactoring
- Feature implementation spanning multiple files
- Debugging complex interactions

Suggest `/compact` at logical task boundaries (after planning, after debugging, before switching features) rather than relying on arbitrary auto-compaction. Do not compact mid-implementation.

### Build Troubleshooting

If build fails:
1. Use **build-error-resolver** agent
2. Analyze error messages
3. Fix incrementally
4. Verify after each fix

---

## ECC Plugin Automation

The ECC plugin provides automated hooks (loaded via `opencode.jsonc`):

### Automatic (handled by plugin hooks)
- **Prettier formatting** on JS/TS file edits (strict profile)
- **TypeScript check** (`tsc --noEmit`) after each .ts/.tsx edit (strict profile)
- **console.log detection** — warns on file edit and audits on session idle
- **Security pre-checks** — warns before dangerous bash commands (`git push`, doc file creation)
- **Desktop notification** on task completion
- **Shell env injection** — PROJECT_ROOT, PACKAGE_MANAGER, DETECTED_LANGUAGES, ECC_VERSION

### Commands Available (native opencode slash commands)

| Command | Purpose | Agent |
|---|---|---|
| `/plan` | Implementation planning (no code til approved) | planner |
| `/tdd` | Red → Green → Refactor with 80%+ coverage | tdd-guide |
| `/code-review` | Quality/security/maintainability review | code-reviewer |
| `/security` | Deep security audit | security-reviewer |
| `/build-fix` | Fix TypeScript/build errors | build-error-resolver |
| `/e2e` | E2E Playwright tests | e2e-runner |
| `/refactor-clean` | Dead code cleanup | refactor-cleaner |
| `/orchestrate` | Multi-agent pipeline | planner |

---

## Project Initialization

To initialize project-specific instructions for a new project, run `/init` in opencode. This creates an `AGENTS.md` file (the cross-compatible standard, analogous to `CLAUDE.md`) with build/lint/test commands, architecture notes, and conventions. Commit `AGENTS.md` to Git.

---

## Success Metrics

You are successful when:
- All tests pass (80%+ coverage)
- No security vulnerabilities
- Code is readable and maintainable
- Performance is acceptable
- User requirements are met
