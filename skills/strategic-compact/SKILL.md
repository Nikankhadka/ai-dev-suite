---
name: strategic-compact
description: Suggests manual context compaction at logical task boundaries instead of relying on arbitrary auto-compaction. Load when a session is long, multi-phase, or approaching context limits.
---

# Strategic Compact

Suggest a manual compact (`/compact` where the harness supports it) at logical boundaries rather than letting it happen mid-task.

## When to Activate

- Long sessions approaching context limits
- Multi-phase tasks (research -> plan -> implement -> test)
- Switching between unrelated tasks in the same session
- After completing a milestone, before starting new work
- Responses feel slower or less coherent (context pressure)

## Compaction Decision Guide

| Phase transition | Compact? | Why |
|---|---|---|
| Research -> Planning | Yes | Research context is bulky; the plan is the distilled output |
| Planning -> Implementation | Yes | Plan lives in a todo list or file; free up context for code |
| Implementation -> Testing | Maybe | Keep if tests reference recent code; compact if switching focus |
| Debugging -> Next feature | Yes | Debug traces pollute context for unrelated work |
| Mid-implementation | No | Losing variable names, file paths, partial state is costly |
| After a failed approach | Yes | Clear the dead-end reasoning before trying a new approach |

## What Survives vs. What's Lost

| Persists | Lost |
|---|---|
| AGENTS.md / CLAUDE.md instructions | Intermediate reasoning and analysis |
| Todo/task list | File contents previously read |
| Files on disk (including `.agents/memory.md`) | Multi-step conversation context |
| Git state (commits, branches) | Tool call history |

## Best Practices

1. Compact after planning, once the plan is written to a todo list or file
2. Compact after debugging, once the fix is confirmed
3. Never compact mid-implementation - preserve context for related changes still in flight
4. Suggest, don't force - this skill tells you *when* to suggest, the user decides *if*
5. Write anything important to a file or `/memory` before compacting away the reasoning that produced it

## Avoiding Duplicate Context

Watch for the same information loaded twice: rules repeated in both a global and project instructions file, a skill restating what `AGENTS.md` already says, or two skills covering the same ground. Keep always-loaded files (RULES.md, AGENTS.md) lean; put detail in on-demand skills instead.
