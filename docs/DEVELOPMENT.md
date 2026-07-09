# Development Guide

A practical guide to using this suite from prompt to shipped change. The full agent/command/skill inventory lives only in `README.md` - this file covers how to actually use them, day to day.

---

## 1. The default flow

For anything non-trivial, run `/ship <requirement>`. It executes plan -> build -> review -> test -> docs as one gated pipeline (see `commands/ship.md` for the exact gates). Nothing in it is stack-specific - the stack is detected fresh every time via `AGENTS.md` or the `stack-discovery` skill.

For a single stage, or a smaller task that doesn't need the full pipeline, use the standalone commands below.

## 2. Standalone commands, stage by stage

### Plan

```
/plan Add semantic search to the marketplace
```

The `planner` agent (read-only) restates the requirement, identifies the stack, surveys existing patterns to reuse, breaks the work into dependency-ordered steps with acceptance criteria and a test list, and surfaces risks. It never writes code and waits for your approval before anything proceeds.

### Build

Work directly with the `build` (primary) agent for straightforward changes - it has full tool access and loads `stack-discovery` before touching an unfamiliar project. For anything that should be test-first, use `/test`.

### Test

```
/test User registration should validate email format
/test e2e Checkout flow completes successfully
/test coverage
```

The `tester` agent runs RED-GREEN-REFACTOR for new code/bug fixes (RED must be an observed, quoted failure - not assumed), writes E2E coverage for user flows, and reports coverage against the project's threshold.

### Review

```
/review
```

The `reviewer` agent checks `git diff` for security (OWASP-class issues), code quality, and build errors, fixing CRITICAL/HIGH findings and build errors with minimal diffs.

### Maintain (docs/cleanup)

```
/maintain
```

The `maintainer` agent removes dead code, consolidates duplicates, refreshes `AGENTS.md`/`.agents/map.md`, and appends a `.agents/memory.md` entry for anything worth remembering.

## 3. System commands

### Docs lookup (cheapest source first)

```
/docs How do I configure middleware in <framework>?
```

Checks project docs on disk first, then `gh-axi` for real-world usage, then `context7` MCP only as a last resort.

### Project memory

```
/memory                      # show what's recorded in .agents/memory.md
/memory note <text>          # append a decision/gotcha
/memory promote <topic>      # copy a cross-project note into instructions/RULES.md
```

### Audit

```
/audit
```

Inside this suite's repo: checks for dead references, broken symlinks, stale generated adapters, em dashes, and missing axi CLIs. Inside a project: checks `AGENTS.md`/`.agents/map.md` freshness.

## 4. Skills - when they load

Skills load on demand when a task matches their description; you never need to preload one manually.

| Skill | Loads when |
|---|---|
| `stack-discovery` | starting work in a project without a mapped `AGENTS.md`, or another skill/agent says to load it |
| `coding-standards` | writing or reviewing code for naming/readability/quality |
| `testing` | writing tests, fixing bugs, or doing E2E work |
| `strategic-compact` | a session is long or multi-phase and approaching context limits |

## 5. Quick reference

| Command | When |
|---|---|
| `/ship <requirement>` | the default for anything non-trivial |
| `/plan <feature>` | architecture/complex-feature planning alone |
| `/test <requirement>` | TDD, E2E, bug repro, or coverage alone |
| `/review` | after writing/modifying code, outside `/ship` |
| `/maintain` | cleanup/doc refresh alone |
| `/init-project` | first time in a new project, or `--refresh` to update the map |
| `/audit` | check this suite or a project for drift |
| `/docs <question>` | library/framework lookup |
| `/nomistakes` | before push: full validation pipeline (if installed) |
| `/gnhf <objective>` | overnight autonomous loop (if installed) |
| `/treehouse <action>` | pooled git worktrees (if installed) |
| `/compact` | after completing a phase, where the harness supports it |

## 6. Context management

- Compact at logical boundaries (after planning, after debugging, before switching features) - see the `strategic-compact` skill for the full decision table.
- Never compact mid-implementation.
- Avoid the last 20% of context window for complex, multi-file work.

## 7. Axi CLI tools

Installed globally, preferred over MCP equivalents. `/audit` reports which are present with `command -v`.

| Tool | Purpose |
|---|---|
| `gh-axi` | GitHub code search, PRs, issues - first choice over the `gh_grep` MCP fallback |
| `chrome-devtools-axi` | browser automation for agents |
| `no-mistakes` | validation pipeline (review, test, docs, lint, PR) - backs `/nomistakes` |
| `gnhf` | overnight autonomous iteration loops - backs `/gnhf` |
| `treehouse` | pooled git worktrees for parallel agents - backs `/treehouse` |
| `quota-axi` | LLM subscription quota visibility |

Every command wrapping one of these guards with `command -v <tool>` first and stops with an install hint if it's missing - it never simulates the tool's behavior itself.

## 8. New project setup

```bash
cd ~/new-project
opencode   # or claude / codex
/init-project
```

This detects the stack (any language - never assumes one), writes `AGENTS.md` with verified, real commands, generates `.agents/map.md` and `.agents/memory.md`, and symlinks `CLAUDE.md -> AGENTS.md`. Commit all of it to git. Run `/init-project --refresh` (or let `/ship` do it automatically in its docs stage) to keep the map current.
