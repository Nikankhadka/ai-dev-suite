# Firstmate Command

Orchestrator that spawns a crew of sub-agents in isolated worktrees.

## When to Use
- Complex multi-task projects that need parallel work
- You want to "talk to one agent, ship with a crew"
- Spawning investigation (scout) and implementation (ship) tasks concurrently

## Usage
```
/firstmate
/firstmate help    # Show available subcommands
/firstmate status  # View crew status
```

## Prerequisites
- tmux (session backend for crew management)
- treehouse (worktree pooling)
- no-mistakes (validation pipeline)
- gh authenticated (PR operations)

## Notes
The firstmate session runs in a tmux window. You talk to the first mate agent, and it dispatches crewmates for each task. Crewmates work in isolated treehouse worktrees. Completed work goes through the no-mistakes pipeline.
