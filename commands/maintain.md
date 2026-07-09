---
description: Clean dead code, consolidate duplicates, and refresh documentation/project map/memory
agent: maintainer
subtask: true
---

# Maintain

Analyze and clean up the codebase: $ARGUMENTS

Follow the maintainer agent's process exactly: detect dead code/duplicates using whatever the project's actual stack provides (check `AGENTS.md` or load `stack-discovery` - don't assume a specific tool is installed), remove SAFE items first with tests run after each batch, consolidate duplicates, then refresh docs and run `/init-project --refresh` for the project map, and append a `.agents/memory.md` entry for anything non-obvious learned.

Use the maintainer agent's safety checklist before removing anything, and its after-cleanup checklist before reporting done.
