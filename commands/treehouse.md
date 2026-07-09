# Treehouse Command

Manages pooled, reusable git worktrees for parallel agent sessions.

## When to Use
- Spawning a parallel agent to work on a separate task in the same repo
- Running independent changes that need isolated working trees
- Pooling worktrees to preserve dependencies and build caches

## Usage
```
/treehouse get <branch-name>    # Get or create a pooled worktree
/treehouse status               # List all worktrees and their states
/treehouse return               # Return current worktree to the pool
/treehouse cleanup              # Prune stale worktrees
```

## Notes
Worktrees preserve deps/build caches so each new session doesn't need a fresh install.
