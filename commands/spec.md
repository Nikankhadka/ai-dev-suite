---
description: Product framing - problem, target user, success criteria, scope cuts
argument-hint: <requirement>
agent: build
subtask: false
---

# Spec

Create a product specification for: $ARGUMENTS

This is the product framing step that happens before `/plan`. It defines the problem, target user, success criteria, and scope so the plan has clear boundaries.

## Stage 0: Context

Read `AGENTS.md` and `.agents/memory.md` if they exist.

## Stage 1: Design the spec

Dispatch the `planner` agent (read-only) with the request to design a product specification covering:

1. **Problem** - what is the user's pain point or unmet need?
2. **Target user** - who is this for? What do we know about them?
3. **Success criteria** - how will we know this is done? Must be measurable.
4. **In scope / Out of scope** - explicit boundaries to prevent scope creep.
5. **Open questions** - what is not yet decided and needs a decision before building?

The planner returns the spec content but must not write any file.

## Stage 2: Write the spec file

Determine the spec slug from the request (lowercase, hyphen-separated). Write the spec to:

```
docs/specs/<slug>.md
```

Using this template:

```markdown
# Spec: <title>

## Problem

...

## Target user

...

## Success criteria

- [ ] ...

## Scope

| In scope | Out of scope |
|---|---|
| ... | ... |

## Open questions

- [ ] ...
```

**GATE G1**: The spec file is written and contains all 5 sections. If any section is missing, re-dispatch the planner and rewrite.

## Outcome

**WAITING FOR CONFIRMATION**: present the spec to the user with this line and stop. Do not proceed to `/plan` or implementation until the user replies "yes", "proceed", or confirms.

When the spec is confirmed, suggest running `/ship <requirement>` or `/plan <requirement>` as the next step.

(End of file - total 70 lines)
