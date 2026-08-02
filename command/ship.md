---
description: Full gated pipeline - plan, build, review, test, document - for one requirement
argument-hint: <requirement> [--auto] [--release]
agent: build
subtask: false
---

# Ship

Run the full pipeline for: $ARGUMENTS

Pass `--auto` in $ARGUMENTS to skip the plan-approval pause (still runs every gate).

This command runs up to six stages in strict order. Each stage has a hard gate. **A failed gate after the stated max attempts means STOP and emit the report template with FAIL rows for that stage and every stage after it. Never skip a gate. Never proceed past a FAIL.**

## Stage 0: Context

Read `CONTEXT.md` and `.agents/memory.md` if they exist.

**GATE G0**: `CONTEXT.md` or `AGENTS.md` exists. If neither, load `stack-discovery` to detect the stack, then proceed with that knowledge.

## Stage 1: Plan

Use `/to-spec` to turn the requirement into a formal spec, then `/to-tickets` to break it into dependency-ordered tracer-bullet tickets.

**GATE G1**: the tickets contain (a) numbered steps, (b) a file list, (c) acceptance criteria, (d) blocking edges declared. If any are missing, retry once, naming the specific gap. If still missing, STOP.

Show the plan to the user. Proceed only on explicit approval - unless `--auto` was passed, in which case proceed automatically but still show the plan in the final report.

## Stage 2: Build

Implement the plan's tickets in dependency order, test-first via `/tdd` - red-green-refactor at pre-agreed seams. One vertical slice at a time: one test, one implementation, repeat.

**GATE G2**: run the build/lint/typecheck commands from the project's manifest or CI config. All must exit 0. On failure, fix and rerun - max 3 attempts. If still failing after 3, STOP and report which command and error.

## Stage 3: Review

Run `/code-review` on the diff - which performs a three-axis review (standards + spec + over-engineering).

**GATE G3**: zero CRITICAL or HIGH findings. On findings, fix and re-review - max 3 loops. If still blocked after 3, STOP and report the remaining findings.

## Stage 4: Test

Run the full test suite plus any E2E coverage for the affected user flows.

**GATE G4**: all tests pass, and no test was deleted or skipped to make this true. On failure, fix and rerun - max 3 attempts. If still failing, STOP and report.

## Stage 5: Docs

Run `/maintain` to clean up, consolidate, and refresh `CONTEXT.md` and `.agents/memory.md`.

**GATE G5**: `.agents/memory.md` has a new entry from this session.

## Stage 6: Release (optional)

Only runs when `--release` is present in `$ARGUMENTS`. Otherwise this stage is SKIPPED.

Run `/no-mistakes` to push changes through the full validation pipeline: branch, commit, rebase, adversarial review, E2E, docs, lint, push, PR, CI.

**GATE G6**: `/no-mistakes` completes successfully. On failure, fix and rerun - max 2 attempts. If still failing after 2, STOP and report the remaining issues.

## Report (always emit this, whether the run succeeded or stopped)

```markdown
# Ship Report: <requirement>

| Stage | Gate | Result | Evidence |
|---|---|---|---|
| Context | G0 | PASS/FAIL | ... |
| Plan | G1 | PASS/FAIL | ... |
| Build | G2 | PASS/FAIL | ... |
| Review | G3 | PASS/FAIL | ... |
| Test | G4 | PASS/FAIL | ... |
| Docs | G5 | PASS/FAIL | ... |
| Release | G6 | PASS/FAIL / SKIPPED | ... |

**Outcome**: SHIPPED / STOPPED at stage <N> - <reason>
```
