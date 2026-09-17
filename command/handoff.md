---
description: Write a supervisor-owned .agent-handoff.md for another agent to continue
agent: supervisor
---

Write or refresh `.agent-handoff.md` in the current repo only when another agent or fresh session must continue this exact task.

The supervisor owns the file. Include:

- Objective and original request
- Selected flow, role/model assignments, and context usage if available
- Decisions already made
- Files touched or likely touched
- Verification plan and evidence gathered
- Blockers, risks, and explicit non-goals
- Exact next instruction for the successor

Make sure `.agent-handoff.md` is locally excluded, preferably in `.git/info/exclude`, and delete it when the task is complete.
