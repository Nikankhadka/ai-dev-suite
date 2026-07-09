---
description: Full gated pipeline - plan, build, review, test, document - for one requirement
agent: build
subtask: false
---

# Ship

Run the full pipeline for: $ARGUMENTS

Pass `--auto` in $ARGUMENTS to skip the plan-approval pause (still runs every gate).

This command runs up to seven stages in strict order. Each stage has a hard gate. **A failed gate after the stated max attempts means STOP and emit the report template with FAIL rows for that stage and every stage after it. Never skip a gate. Never proceed past a FAIL.**

If this harness has no subagent dispatch available, execute each stage yourself, in order, applying the same gate - do not skip a stage just because you can't hand it to a separate agent.

## Stage 0: Context

Read `AGENTS.md` and `.agents/memory.md` if they exist.

**GATE G0**: `AGENTS.md` exists. If not, print "Run /init-project first" and STOP - do not guess the stack instead.

## Stage 1: Plan

Check if a matching spec exists in `docs/specs/` (from a prior `/spec` run). If one is found that covers this requirement, read it and provide it to the planner as context.

Dispatch the `planner` agent with the request, any existing spec, and the content of `AGENTS.md`.

**GATE G1**: the plan contains (a) numbered steps, (b) a file list, (c) acceptance criteria, (d) a test list. If any are missing, re-dispatch once, naming the specific gap. If still missing, STOP.

Show the plan to the user. Proceed only on explicit approval - unless `--auto` was passed, in which case proceed automatically but still show the plan in the final report.

## Stage 2: Build

Implement the plan's steps in order, test-first per the `testing` skill.

**GATE G2**: run the build/lint/typecheck commands from `AGENTS.md`'s Commands table. All must exit 0. On failure, fix and rerun - max 3 attempts. If still failing after 3, STOP and report which command and error.

## Stage 3: Review

Dispatch the `reviewer` agent on `git diff`.

**GATE G3**: zero CRITICAL or HIGH findings. On findings, fix and re-review - max 3 loops. If still blocked after 3, STOP and report the remaining findings.

## Stage 4: Test

Dispatch the `tester` agent: full suite plus E2E coverage for the affected user flow.

**GATE G4**: all tests pass, and no test was deleted or skipped to make this true. On failure, fix and rerun - max 3 attempts. If still failing, STOP and report.

## Stage 5: Docs

Dispatch the `maintainer` agent: run `/init-project --refresh`, update any docs the change made stale, append one entry to `.agents/memory.md`.

**GATE G5**: `.agents/map.md` timestamp updated and a new `.agents/memory.md` entry is present.

## Stage 6: Release (optional)

Only runs when `--release` is present in `$ARGUMENTS`. Otherwise this stage is SKIPPED.

Hand off to the `no-mistakes` CLI: branch, commit, rebase, adversarial review, E2E, docs, lint, PR, CI. Run `no-mistakes` in the project root.

**GATE G6**: `no-mistakes` exits 0. On failure, fix and rerun - max 2 attempts. If still failing after 2, STOP and report the remaining issues.

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
