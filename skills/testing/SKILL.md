---
name: testing
description: Test-driven development (Red-Green-Refactor) and end-to-end testing methodology, stack-agnostic. Use when writing new features, fixing bugs, or verifying user-facing flows. Load stack-discovery alongside this to find the actual test runner and commands.
---

# Testing

Two disciplines: Part A is test-first development for new code and bug fixes. Part B is end-to-end (E2E) testing of real user flows. Neither part prescribes a framework - find the project's actual test tooling via `stack-discovery` first, then apply the protocol below with that tooling.

## Part A: Test-Driven Development

### The cycle

1. **RED** - write a test that fails for the right reason before writing implementation code.
2. **GREEN** - write the minimum code needed to make that test pass.
3. **REFACTOR** - improve the code with tests still green: remove duplication, improve names, no behavior change.

### RED gate (mandatory, do not skip)

Before touching production code, confirm a valid RED state:
- The test actually runs (compiles/imports successfully) using the project's real test command from `AGENTS.md` or detected via `stack-discovery`.
- It fails, and you can quote the failure message or assertion output.
- The failure is caused by the missing/buggy behavior you're about to implement - not by a syntax error, missing dependency, or broken test setup.

A test that was written but never executed does not count as RED. If you cannot produce a real failure message, you have not verified RED.

### GREEN gate

After implementing, rerun the same test target and confirm it now passes. Quote the pass result. Do not mark a task done on the assumption that a fix "should" work - the RED-to-GREEN transition must be observed.

### Bug fixes specifically

"Fix bug X" always means: reproduce X as a failing test first (ideally an E2E reproduction matching how a real user hits it - see Part B), then fix, then confirm GREEN. Never patch behavior you have not first reproduced.

### Coverage

Look up the project's actual coverage command and threshold (from `AGENTS.md`, a CI config, or a coverage/lint config file detected via `stack-discovery`). Default target if the project has no stated threshold: 80% for standard code paths, 100% for anything touching money, auth, or security-sensitive logic. Never delete or skip a test to make a coverage or pass-rate number look better.

### Checkpoint discipline (when under git)

If the repo is under git, commit at each stage boundary so the RED/GREEN evidence is preserved:
- one commit for the failing test (RED), message like `test: add reproducer for <feature/bug>`
- one commit for the minimal fix (GREEN), message like `fix: <feature/bug>`
- one optional commit after refactor, tests still green

Verify each checkpoint commit is reachable from the current branch HEAD before treating it as satisfied - commits on other branches or from unrelated history don't count.

### Per-cycle checklist

- [ ] Test written before implementation
- [ ] RED observed and quoted (not assumed)
- [ ] Minimal implementation written
- [ ] GREEN observed and quoted
- [ ] Refactor done with tests still green, or explicitly skipped as unnecessary
- [ ] No test deleted, skipped, or weakened to force a pass

## Part B: End-to-End Testing

### Principles

- Test the user-visible flow, not implementation details or internal state. Assert on what a real user would see (visible text, resulting page/state), not on internals.
- Use resilient selectors your test framework exposes for this purpose (semantic roles, test-id attributes, accessible labels) - avoid brittle selectors tied to styling or DOM structure that changes for unrelated reasons.
- Wait for the actual condition that matters (a response, a state change, an element becoming visible) rather than a fixed sleep/timeout. Fixed timeouts are the single most common source of flakiness.
- Capture failure artifacts (screenshot, trace, or log - whatever the detected framework supports) on failure so a failure is debuggable without reproducing it live.

### E2E-first bug reproduction

When reproducing a reported bug, build the reproduction as close to the real end-user experience as possible: same entry point, same interaction sequence, same environment class (browser/CLI/API caller) the user actually used. This surfaces the real problem instead of a proxy for it, so the eventual fix actually solves it.

### Flaky test handling

1. Identify: rerun the suspect test several times in a row (most frameworks support a repeat/retry flag) to confirm instability before touching it.
2. Diagnose the likely cause: a race condition, a fixed-timeout wait, or environment/order dependence between tests.
3. Fix the root cause (condition-based waiting, proper isolation) rather than papering over it with retries alone.
4. If a fix isn't immediately possible, quarantine the test explicitly (skip/fixme with a tracked reason) rather than deleting it or leaving it silently red.

### Page-object-style organization

For UI flows with reusable navigation/interaction, group locators and actions for a given page or screen into one place (a "page object") rather than repeating raw selectors across many tests. This is a pattern, not a framework requirement - apply it if the detected framework and codebase already lean this way.

### Financial, auth, and other critical flows

Flows involving money movement, authentication, or irreversible actions get end-to-end coverage before being considered done, get 100% coverage per the TDD section above, and should never run destructive variants against production.

## UI review standard

When you can see the UI (via a browser tool, screenshot, or running the app), review it with the same pixel-perfect standard as functional correctness. If something looks visually off - misalignment, wrong spacing, broken responsive layout - fix it along the way even if unrelated to the current task, per the global engineering-excellence rule.
