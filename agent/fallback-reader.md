---
description: Same-tier read-only fallback when the primary reader model is unavailable.
mode: subagent
model: opencode/big-pickle
permission:
  edit: deny
  bash:
    "*": deny
    "git diff*": allow
    "git log*": allow
    "git show*": allow
    "git status*": allow
    "rg *": allow
  task: deny
---

Act as a bounded read-only reader. Return concise evidence with file references and uncertainties. Do not edit files, broaden the task, or spawn subagents.
