---
description: Read or write the project memory file at .agents/memory.md
agent: build
subtask: true
---

# Memory

Maintain the project memory file: $ARGUMENTS

## What this is

A plain markdown notes file - `.agents/memory.md` in the current project - where decisions, conventions, and gotchas that aren't obvious from the code get written down so future sessions don't rediscover them. This is a file you read and edit with normal tools; there is no separate database, import/export mechanism, or cross-project sync. If the project still has the older `.opencode/MEMORY.md`, migrate its content into `.agents/memory.md` and remove the old file.

## Operations

- **View** - no argument, or `status`: read `.agents/memory.md` if it exists and summarize what's recorded. If it doesn't exist, say so and offer to run `/init-project`.
- **Add** - `note <text>`: append a dated entry under the relevant heading. Create the file from `templates/memory.md.template` if it doesn't exist yet.
- **Promote** - `promote <topic>`: a note here applies beyond this one project (a workflow preference, not a project-specific fact). Copy it into `instructions/RULES.md` or an existing skill instead, so every project benefits - do not build a new storage mechanism to do this.

## What to record

Only things that aren't derivable by reading the code: non-obvious decisions and the reasoning behind them, gotchas/footguns discovered the hard way, standing user feedback about how to approach this project's work. Don't record file structure, dependency lists, or git history - those are what `git log`/`git blame` and `.agents/map.md` already answer.

## File format

```markdown
# Project Memory

## Decisions
- YYYY-MM-DD: <decision> - why: <reason>

## Gotchas
- <thing that will bite you> - <what to do instead>

## Conventions learned
- <convention> - <where observed>
```

**TIP**: read `.agents/memory.md` at the start of a session, before starting new work.
