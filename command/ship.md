---
description: Run the default supervised development workflow for one requirement
argument-hint: <requirement> [--release]
agent: supervisor
subtask: false
---

# Ship

Run the default supervised development workflow from `instructions/AGENTS.md` for: $ARGUMENTS

Use `/ship` as a thin wrapper, not a separate six-stage workflow:

1. Restate the requested outcome, constraints, and selected flow
2. Define a proportional Definition of Done and verification plan, including standard and important edge cases
3. Compare two approaches only when the work is substantial, ambiguous, risky, architectural, or multi-file
4. Delegate one bounded implementation slice at a time
5. Review independently against the spec, project standards, simplicity, and evidence
6. Verify with the project-aware checks that are authorized and available
7. Reread the original request before declaring completion

If `--release` is present in `$ARGUMENTS`, run `/no-mistakes` after the work is committed and use the original requirement as the validation intent.

Always finish with a compact report:

- Outcome and files changed
- Verification commands and results
- Reviewer findings or "no blocking findings"
- Worker/model/token summary when available
- Any unrelated issues deferred to a separate task
