---
description: Two-axis code review — standards and spec, run as parallel sub-agents
---

Run the code-review skill on the diff between HEAD and a fixed point (commit, branch, tag, or merge-base). Pin the fixed point, identify the spec source, identify the standards sources, then spawn both review axes as parallel sub-agents. Present findings under `## Standards` and `## Spec` headings. Never merge or rerank — the separation is deliberate.
