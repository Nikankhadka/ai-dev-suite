# GNHF Command (Good Night Have Fun)

Launches an autonomous overnight coding loop with automated commit/rollback.

## When to Use
- Long-running tasks that don't need supervision
- Overnight autonomous iteration on a feature
- Batch refactoring across multiple files

## Usage
```
/gnhf <objective> --max-iterations 5 --max-tokens 100000
/gnhf status
/gnhf stop
```

## Stop Conditions
- `--max-iterations`: Maximum loop iterations (default: 3)
- `--max-tokens`: Token budget cap (default: 50000)
- Manual: `/gnhf stop` ends the loop gracefully

## Configuration
`~/.gnhf/config.yml` for default settings and model selection.
