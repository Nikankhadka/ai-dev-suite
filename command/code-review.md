---
description: Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes: Standards (does the code follow this repo's documented coding standards?) and Spec (does the code match what the originating issue/spec asked for?). Runs both reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to \\"review since X\\".
agent: reviewer
---

Run the code-review skill on the diff between HEAD and a fixed point (commit, branch, tag, or merge-base). Pin the fixed point, identify the spec source, identify the standards sources, then spawn all three review axes as parallel sub-agents: Standards (does code follow coding standards?), Spec (does code match the issue/PRD?), Over-engineering (can code be deleted or simplified?). Present findings under `## Standards`, `## Spec`, and `## Over-engineering` headings. Never merge or rerank - the separation is deliberate.
