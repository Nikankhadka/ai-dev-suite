---
name: strategic-compact
description: Suggests manual context compaction at logical intervals to preserve context through task phases rather than arbitrary auto-compaction.
origin: ECC
---

# Strategic Compact Skill

Suggests manual `/compact` at strategic points in your workflow rather than relying on arbitrary auto-compaction.

## When to Activate

- Running long sessions that approach context limits (200K+ tokens)
- Working on multi-phase tasks (research → plan → implement → test)
- Switching between unrelated tasks within the same session
- After completing a major milestone and starting new work
- When responses slow down or become less coherent (context pressure)

## Why Strategic Compaction?

Auto-compaction triggers at arbitrary points:
- Often mid-task, losing important context
- No awareness of logical task boundaries
- Can interrupt complex multi-step operations

Strategic compaction at logical boundaries:
- **After exploration, before execution** — Compact research context, keep implementation plan
- **After completing a milestone** — Fresh start for next phase
- **Before major context shifts** — Clear exploration context before different task

## How It Works

There is no automated hook behind this skill — OpenCode's native compaction is configured via `"compaction"` in `opencode.jsonc` (auto-compacts near the context limit, with no awareness of task boundaries). This skill is a purely advisory prompt: when you notice you're approaching a logical boundary (see the decision guide below) or the conversation is getting long, proactively suggest `/compact` to the user yourself rather than waiting for automatic compaction to fire mid-task.

If you want OpenCode to auto-compact, set it in `opencode.jsonc`:

```jsonc
{
  "compaction": {
    "auto": true,
    "prune": false,
    "reserved": 10000
  }
}
```

## Compaction Decision Guide

Use this table to decide when to compact:

| Phase Transition | Compact? | Why |
|-----------------|----------|-----|
| Research → Planning | Yes | Research context is bulky; plan is the distilled output |
| Planning → Implementation | Yes | Plan is in TodoWrite or a file; free up context for code |
| Implementation → Testing | Maybe | Keep if tests reference recent code; compact if switching focus |
| Debugging → Next feature | Yes | Debug traces pollute context for unrelated work |
| Mid-implementation | No | Losing variable names, file paths, and partial state is costly |
| After a failed approach | Yes | Clear the dead-end reasoning before trying a new approach |

## What Survives Compaction

Understanding what persists helps you compact with confidence:

| Persists | Lost |
|----------|------|
| AGENTS.md / CLAUDE.md instructions | Intermediate reasoning and analysis |
| TodoWrite task list | File contents you previously read |
| Files on disk (incl. `/memory` notes) | Multi-step conversation context |
| Git state (commits, branches) | Tool call history and counts |
| | Nuanced user preferences stated verbally |

## Best Practices

1. **Compact after planning** — Once plan is finalized in TodoWrite, compact to start fresh
2. **Compact after debugging** — Clear error-resolution context before continuing
3. **Don't compact mid-implementation** — Preserve context for related changes
4. **Suggest, don't force** — This skill tells you *when* to suggest `/compact`; the user decides *if*
5. **Write before compacting** — Save important context to files or memory before compacting
6. **Use `/compact` with a summary** — Add a custom message: `/compact Focus on implementing auth middleware next`

## Token Optimization Patterns

### Trigger-Table Lazy Loading
Instead of loading full skill content at session start, use a trigger table that maps keywords to skill paths. Skills load only when triggered, reducing baseline context by 50%+:

| Trigger | Skill | Load When |
|---------|-------|-----------|
| "test", "tdd", "coverage" | tdd-workflow | User mentions testing |
| "e2e", "playwright", "user flow" | e2e-testing | End-to-end test work |
| "naming", "refactor", "review" | coding-standards | Code quality/convention work |

### Context Composition Awareness
Monitor what's consuming your context window:
- **AGENTS.md / CLAUDE.md files** — Always loaded, keep lean
- **Loaded skills** — Each skill adds 1-5K tokens
- **Conversation history** — Grows with each exchange
- **Tool results** — File reads, search results add bulk

### Duplicate Instruction Detection
Common sources of duplicate context:
- Same rules in both global and project config directories
- Skills that repeat AGENTS.md instructions
- Multiple skills covering overlapping domains

## Related

- [The Longform Guide](https://x.com/affaanmustafa/status/2014040193557471352) — Token optimization section
- Use `/memory` to save durable notes to a file before compacting away the reasoning that produced them
