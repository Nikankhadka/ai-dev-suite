---
description: Three-axis code review - standards, spec, and over-engineering, run as parallel sub-agents
agent: reviewer
---

Run the code-review skill on the diff between HEAD and a fixed point (commit, branch, tag, or merge-base). Pin the fixed point, identify the spec source, identify the standards sources, then spawn all three review axes as parallel sub-agents: Standards (does code follow coding standards?), Spec (does code match the issue/PRD?), Over-engineering (can code be deleted or simplified?). Present findings under `## Standards`, `## Spec`, and `## Over-engineering` headings. Never merge or rerank - the separation is deliberate.
