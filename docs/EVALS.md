# Evaluation Plan

How this suite is verified, across harnesses and across model tiers. Run the static checks via `/audit`; run the rest manually per the cadence in section 4.

## 1. Static checks (`/audit`, suite mode)

- Every file referenced by `README.md`, `instructions/RULES.md`, `instructions/OPENCODE.md`, and any `SKILL.md` exists on disk, and every real agent/command/skill file is listed in `README.md` (both directions).
- Every file in `commands/` has valid frontmatter (`description`, `agent`, `subtask`) and its `agent:` value matches a real file in `agents/`.
- Every symlink in the cross-harness map (README's "Cross-harness wiring" table) resolves.
- Every file in `adapters/claude/agents/` is newer than its source in `agents/` (rerun `bin/sync-adapters.sh` if not).
- No em dash (U+2014) anywhere in `*.md`/`*.jsonc`.
- No references to removed things: `query-docs`, `firstmate`, `lavish`, `frontend-patterns`, `backend-patterns`, `tdd-guide`, `e2e-runner`, `/orchestrate`, `tdd-workflow`, `e2e-testing`.
- `command -v` for each axi CLI a command wraps (`gnhf`, `treehouse`, `no-mistakes`, `gh-axi`, `quota-axi`, `chrome-devtools-axi`) - report missing ones, don't fail the audit for it.

## 2. Per-harness smoke matrix

Use a throwaway fixture repo (a small mixed-language sample, e.g. one JS file, one Python file, no framework) so detection can't cheat off a single obvious stack.

| Scenario | OpenCode | Claude Code | Codex CLI |
|---|---|---|---|
| Commands/skills appear in the slash menu with descriptions | check | check | check |
| `/init-project` produces `AGENTS.md` + `.agents/` + `CLAUDE.md` symlink; the Commands table entries actually run | check | check | check |
| `/plan` returns the plan template and writes no files | check | check | check |
| A test-writing request loads `testing`/`stack-discovery`; agent asks rather than assuming TypeScript on the fixture | check | check | check |
| `/ship --auto` on a one-file seeded feature: all 6 gates fire in order; then seed a failing test and confirm Gate 4 STOPs with a FAIL row | check | check | degrades to sequential single-agent execution per `ship.md` - confirm it still applies every gate |
| Rules are active: ask about em dashes, check a real commit has no agent co-author line | check | check | check |

Record results as a dated entry in section 5 below.

## 3. Lesser-model spot check

The suite is intentionally model-neutral - no per-agent model is pinned - so every prompt must be explicit enough that a smaller model produces a structurally similar result. Run on the same fixture repo with a small model selected at invocation (e.g. `claude --model haiku`, or an OpenCode session on a small model):

1. `/plan <small feature>`
2. `/review` on a diff with one obvious CRITICAL issue seeded in
3. `/test <small feature>`

**Pass criteria:** output follows the command's template structure, gates/checklists are echoed rather than skipped, no stack is assumed without checking, and a seeded failure produces a STOP/FAIL rather than a silent pass. Any divergence means the prompt relies on model intelligence it shouldn't - fix the prompt or skill, not the model.

## 4. Regression protocol

- After any edit to this repo: run `/audit`, then `bin/sync-adapters.sh`, then commit.
- After adding, renaming, or removing a command or agent: rerun that item's row in the smoke matrix, in OpenCode and Claude Code at minimum.
- Monthly, or after a harness version bump: run the full smoke matrix plus one lesser-model spot check. Append the result below.

## 5. Run log

<!-- Append one entry per full smoke-matrix run. Newest first. -->

### Template

```
## YYYY-MM-DD
Harnesses tested: OpenCode <version>, Claude Code <version>, Codex CLI <version>
Static checks: PASS/FAIL - notes
Smoke matrix: PASS/FAIL - notes on any row that failed
Lesser-model spot check: PASS/FAIL - notes
Follow-ups: ...
```
