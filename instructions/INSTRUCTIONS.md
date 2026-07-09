# ECC - Agent Orchestration Instructions

This document defines the core orchestration rules for a cross-compatible AI agent workflow (OpenCode, Claude Code, OpenAI Codex, and similar tools). Domain-specific guidance lives in on-demand skills — load them via the `skill` tool when a task matches a skill's description.

## Skill Loading

Skills are NOT preloaded. They are discovered automatically from `~/.config/opencode/skills/<name>/SKILL.md` and loaded on-demand via the native `skill({ name })` tool. Only load a skill when the task at hand matches its description. Available skills are listed in the `skill` tool description.

## Agent Orchestration

### Available Agents

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| planner | Planning + system design + database schema | Complex features, refactoring, architecture decisions |
| build (primary) | Day-to-day coding | General development tasks |
| reviewer | Code quality + security + build error fix | After writing code, security audit, build failures |
| tdd-guide | Test-driven development | New features, bug fixes |
| e2e-runner | E2E Playwright tests | Critical user flows |
| maintainer | Dead code cleanup + documentation | Code maintenance, doc updates |
| ops | Orchestration + memory + system control | Multi-agent pipelines, instincts, harness, loops |

### Workflow

```
plan → build → review → test → document
```

For complex tasks, run `/orchestrate` to coordinate multiple agents.

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

### Context Window Management

Avoid last 20% of context window for:
- Large-scale refactoring
- Feature implementation spanning multiple files
- Debugging complex interactions

Suggest `/compact` at logical task boundaries (after planning, after debugging, before switching features) rather than relying on arbitrary auto-compaction. Do not compact mid-implementation.

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

#### Engineering Commands

| Command | Agent | Purpose |
|---------|-------|---------|
| `/plan` | planner | Implementation planning with architecture and database design (no code til approved) |
| `/tdd` | tdd-guide | Red → Green → Refactor with 80%+ coverage |
| `/review` | reviewer | Code quality, security, and build error review |
| `/e2e` | e2e-runner | E2E Playwright tests |
| `/maintain` | maintainer | Dead code cleanup, consolidation, and documentation updates |
| `/orchestrate` | ops | Multi-agent pipeline for complex tasks |

#### System Commands

| Command | Agent | Purpose |
|---------|-------|---------|
| `/memory` | ops | Instinct management, evolve, skill creation, project memory |
| `/system` | ops | Harness, loops, project setup, model routing |
| `/eval` | ops | Evaluation, verification, quality gates |
| `/docs` | ops | Realtime documentation lookup via Context7 MCP |

---

## Project Initialization

To initialize project-specific instructions for a new project, run `/init` in opencode. This creates an `AGENTS.md` file with build/lint/test commands, architecture notes, and conventions. Commit `AGENTS.md` to Git.

---

## Success Metrics

You are successful when:
- All tests pass (80%+ coverage)
- No security vulnerabilities
- Code is readable and maintainable
- Performance is acceptable
- User requirements are met
