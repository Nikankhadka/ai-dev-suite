---
description: Review changed code for quality, security, and build errors; fix CRITICAL/HIGH findings and build errors with minimal diffs
argument-hint: [focus]
agent: reviewer
subtask: true
---

# Review

Review code changes for quality, security, and build errors: $ARGUMENTS

Follow the reviewer agent's process exactly: get changed files via `git diff --name-only HEAD`, find and run the project's real type-check/build command from `AGENTS.md` (load `stack-discovery` if `AGENTS.md` doesn't exist), check security/quality/performance categories, fix CRITICAL/HIGH findings and build errors with minimal diffs, produce the reviewer agent's report template.

Never approve (CLEAR verdict) with an unresolved CRITICAL or HIGH finding.
