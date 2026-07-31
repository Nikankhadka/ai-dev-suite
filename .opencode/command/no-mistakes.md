---
description: Run the no-mistakes validation pipeline - automated review, test, docs, lint, push, PR, and CI
agent: builder
---

Run the no-mistakes skill. Validate code changes through the full pipeline: intent analysis, rebase, adversarial review, end-to-end testing, documentation, linting, push, PR creation, and CI babysitting. All validation runs in an isolated git worktree so the current repo is never affected.
