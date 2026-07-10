---
description: Test-first implementation, E2E flow testing, bug reproduction, or coverage check - stack-agnostic
argument-hint: <requirement> | e2e <flow> | coverage
agent: tester
subtask: true
---

# Test

$ARGUMENTS

Load the `testing` skill first and follow it exactly. Determine the mode from the arguments:

- **No prefix, a requirement/feature description** -> test-first implementation (TDD): write the failing test, observe and quote RED, implement minimally, observe and quote GREEN, refactor with tests green.
- **`e2e <flow>`** -> end-to-end test for that user flow: real user-visible behavior, resilient selectors, condition-based waits, no fixed sleeps.
- **A bug description** -> reproduce it first in as close to a real end-user setting as possible (E2E-first per the global rule), confirm it fails for the right reason, then run the RED-GREEN cycle to fix it.
- **`coverage`** -> find the project's actual coverage command (via `AGENTS.md` or `stack-discovery`) and report the gap against the threshold (80% default, 100% for money/auth/security-critical code).

Use the tester agent's report template. Never delete, skip, or weaken a test to force a pass.
