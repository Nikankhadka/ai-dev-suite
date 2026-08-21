---
description: Maintain the project progress tracker at .agents/progress.md
argument-hint: [update <text> | status]
agent: build
subtask: true
---

# Progress

Maintain the project progress tracker: $ARGUMENTS

## What this is

A plain markdown tracker - `.agents/progress.md` in the current project - listing milestones and their tickets with live status, so any session can see where the project stands without reading git history. Edited with normal tools; no database, no sync.

## Operations

- **View** - no argument, or `status`: read `.agents/progress.md` if it exists and summarize milestone/ticket states. If it doesn't exist, say so and note that the project hasn't tracked progress yet.
- **Update** - `update <text>`: apply the described change - add milestones or tickets, flip statuses, refresh summaries. Create the file from `~/.config/opencode/templates/progress.md.template` if it doesn't exist yet (that path is the suite root, not the current project - if it is missing, use the File format below directly).

## File format

```markdown
# Project Progress

## M1: <milestone name>
- [ ] T1: <one-line summary>                      (open)
- [~] T2: <one-line summary> - done: X, next: Y   (in progress)
- [x] T3: <one-line summary> (YYYY-MM-DD)         (done)
```

**TIP**: read `.agents/progress.md` at the start of a session, alongside `.agents/memory.md`.
