---
name: strategic-compact
description: Suggests fresh handoff around 100K context and stop-before-new-work at 160K, with manual compaction only as fallback.
---

# Strategic Compact

Prefer a fresh handoff at logical boundaries rather than letting context pressure shape the work. Manual compact (`/compact` where the harness supports it) is the fallback when a fresh handoff is impractical.

## When to Activate

- Long sessions approaching the 100K soft handoff threshold
- Multi-phase tasks (research -> plan -> implement -> test)
- Switching between unrelated tasks in the same session
- After completing a milestone, before starting new work
- Responses feel slower or less coherent (context pressure)
- Any session near 160K context. Do not intentionally start new work there; hand off first.

## Context Rotation Guide

| Phase transition           | Action | Why                                                               |
| -------------------------- | ------ | ----------------------------------------------------------------- |
| Research -> Planning       | Handoff | Research context is bulky; the plan is the distilled output       |
| Planning -> Implementation | Handoff | Plan lives in a task or file; start implementation fresh          |
| Implementation -> Testing  | Stay or hand off | Keep a small related context; rotate when switching focus |
| Debugging -> Next feature  | Handoff | Debug traces pollute context for unrelated work                   |
| Mid-implementation         | Stay    | Losing variable names, file paths, and partial state is costly    |
| After a failed approach    | Handoff | Keep the dead-end evidence in the ledger, not the active context  |

## Context Policy

- Around 100K context, prepare `.agent-handoff.md` and prefer a fresh session or worker
- At 160K, stop before starting new work and hand off
- Use compaction only when a fresh handoff would lose too much live state
- Treat model context limits as ceilings, not quality guarantees

## What Survives vs. What's Lost

| Persists                                      | Lost                                |
| --------------------------------------------- | ----------------------------------- |
| AGENTS.md / CLAUDE.md instructions            | Intermediate reasoning and analysis |
| Todo/task list                                | File contents previously read       |
| Files on disk (including `.agents/memory.md`) | Multi-step conversation context     |
| Git state (commits, branches)                 | Tool call history                   |

## Best Practices

1. Hand off after planning, once the plan is written to a todo list or file
2. Hand off after debugging, once the fix is confirmed
3. Never compact mid-implementation - preserve context for related changes still in flight
4. Suggest, don't force - this skill tells you when to suggest handoff or compact, the user decides if
5. Write anything important to `.agent-handoff.md` or `/memory` before compacting away the reasoning that produced it

## Avoiding Duplicate Context

Watch for the same information loaded twice: rules repeated in both the global and a project `AGENTS.md`, a skill restating what `AGENTS.md` already says, or two skills covering the same ground. Keep always-loaded files (both the global hub `AGENTS.md` and each project's own `AGENTS.md`) lean; put detail in on-demand skills instead.
