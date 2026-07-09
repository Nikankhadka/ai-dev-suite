---
description: Read and write project memory notes
agent: ops
subtask: true
---

# Memory Command

Maintain the project memory file: $ARGUMENTS

## What This Is

A plain markdown notes file — `.opencode/MEMORY.md` in the current project — where decisions, conventions, and gotchas that aren't obvious from the code get written down so future sessions don't rediscover them. This is a file you read and edit with normal tools; there is no separate instinct database, import/export mechanism, or cross-project sync.

## Operations

### View
- No argument, or `status` — read `.opencode/MEMORY.md` if it exists and summarize what's recorded. If the file doesn't exist, say so.

### Add
- `note <text>` — append a dated entry under the relevant heading. Create the file (with the structure below) if it doesn't exist yet.

### Promote
- `promote <topic>` — a note here applies beyond this one project (e.g. a workflow preference, not a project-specific fact). Copy it into `~/.config/opencode/instructions/INSTRUCTIONS.md` or an existing skill instead, so every project benefits — do not build a new storage mechanism to do this.

## What to Record

Only write down things that aren't derivable by reading the code:
- Non-obvious decisions and the reasoning behind them
- Gotchas, footguns, and constraints discovered the hard way
- Standing user feedback about how to approach this project's work

Don't record: file structure, dependency lists, git history, or anything `git log` / `git blame` already answers.

## File Format

```markdown
# Project Memory

## Decisions
- YYYY-MM-DD: <decision> — why: <reason>

## Gotchas
- <thing that will bite you> — <what to do instead>
```

**TIP**: Run `/memory` with no arguments before starting new work to see what's already recorded.
