---
description: Launch an autonomous overnight coding loop via the gnhf CLI, with commit/rollback
agent: build
subtask: true
---

# GNHF (Good Night Have Fun)

Launches an autonomous overnight coding loop with automated commit/rollback: $ARGUMENTS

## Guard

First run `command -v gnhf`. If it is not found, tell the user it isn't installed and stop - do not attempt to imitate an unsupervised loop yourself.

## When to use

Long-running tasks that don't need supervision; overnight autonomous iteration on a feature; batch refactoring across multiple files.

## Usage

```
/gnhf <objective> --max-iterations 5 --max-tokens 100000
/gnhf status
/gnhf stop
```

## Stop conditions

`--max-iterations` (default 3), `--max-tokens` (default 50000), or manual `/gnhf stop`.

## Configuration

`~/.gnhf/config.yml` for default settings and model selection.
