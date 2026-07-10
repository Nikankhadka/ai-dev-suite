---
description: Run the no-mistakes validation pipeline (review, test, docs, lint, PR) via the no-mistakes CLI
argument-hint: [run --scope changes | status | help]
agent: build
subtask: true
---

# No-Mistakes

Runs the `no-mistakes` validation pipeline in the current repository: $ARGUMENTS

## Guard

First run `command -v no-mistakes`. If it is not found, tell the user it isn't installed and stop - do not simulate the pipeline yourself.

## When to use

Before pushing to `main` (or any protected branch); after completing implementation, before opening a PR; whenever a full quality gate is needed (review, test, docs, lint).

## Pipeline stages

branch -> commit -> rebase -> adversarial review -> E2E test -> docs update -> lint -> PR

## Usage

```
/nomistakes
/nomistakes run --scope changes
/nomistakes status
/nomistakes help
```

## Configuration

Run `no-mistakes init` in the project once to set up the local gate before first use.
