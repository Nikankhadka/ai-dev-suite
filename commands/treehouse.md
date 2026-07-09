---
description: Manage pooled git worktrees for parallel agent sessions via the treehouse CLI
agent: build
subtask: true
---

# Treehouse

Manages pooled, reusable git worktrees for parallel agent sessions: $ARGUMENTS

## Guard

First run `command -v treehouse`. If it is not found, tell the user it isn't installed and stop.

## When to use

Spawning a parallel agent to work on a separate task in the same repo; running independent changes that need isolated working trees; pooling worktrees to preserve dependencies and build caches.

## Usage

```
/treehouse get <branch-name>    # get or create a pooled worktree
/treehouse status               # list all worktrees and their states
/treehouse return               # return current worktree to the pool
/treehouse cleanup              # prune stale worktrees
```

Worktrees preserve deps/build caches so each new session doesn't need a fresh install.
