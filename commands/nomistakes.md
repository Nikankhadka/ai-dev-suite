# Nomistakes Command

Runs the `no-mistakes` validation pipeline in the current repository.

## When to Use
- Before pushing to `main` (or any protected branch)
- After completing implementation, before opening a PR
- When you need a full quality gate: review, test, docs, lint

## Pipeline Stages
The pipeline runs: branch -> commit -> rebase -> adversarial review -> E2E test -> docs update -> lint -> PR

## Usage
```
/nomistakes
/nomistakes run --scope changes
/nomistakes status
/nomistakes help
```

## Configuration
Run `no-mistakes init` in the project to set up the local gate first.
