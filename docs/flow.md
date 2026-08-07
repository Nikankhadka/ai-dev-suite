# Flow: Suite Analysis and Target Architecture

Written 2026-08-06. An audit of this suite's sprawl, a verdict on the two vendored
ecosystems, and the target shape of the build loop.

The other docs in `docs/` describe what the tools are and how to run them. This one describes
what is wrong with the current arrangement and what to change.

---

## 1. What is installed

| Layer | Count | Scope | Always in context |
|---|---|---|---|
| Skills (symlinked to `~/.claude/skills` and `~/.agents/skills`) | 40 | all three harnesses | descriptions only, ~10.5K chars, ~2.6K tokens |
| Commands (`command/`) | 33 | **OpenCode only** | yes, ~1K tokens |
| Agents (`agent/`) | 5 | OpenCode only | on dispatch |
| Vendored submodules | 10 | - | - |
| Workflow docs (`docs/`) | 5 files, 12K words | - | - |
| Sync machinery (`scripts/`) | 3 scripts, 8 lib files, 19KB of JSON state | - | - |

Baseline routing surface before a single word is typed: roughly **5K tokens** of skill and
command descriptions, plus `instructions/AGENTS.md` loaded verbatim into every session on every
harness.

---

## 2. Root cause of the sprawl

Not "too many tools." Four structural decisions.

### 2.1 Every vendored skill is mirrored as a command, 1:1

29 of 33 commands have an identically named skill. `scripts/sync-mappings.json` makes this
explicit: each command maps to an `upstream` SKILL.md. The command adds exactly one thing the
skill lacks, the `agent:` routing field for OpenCode. Everything else is a re-description of the
skill, held in context twice, on the one harness where both are visible.

This is the primary multiplier. 40 skills is manageable. 40 skills plus 33 near-duplicate commands
is what makes the suite unnavigable.

### 2.2 Whole upstream repos are vendored, not the skills actually used

`scripts/link-skills.sh` globs every directory containing a `SKILL.md` across 10 sources. That
inherits upstream's course-authoring tooling wholesale. Currently linked globally, forever:

- `scaffold-exercises` - exercise stubs for a TypeScript course
- `migrate-to-shoehorn` - migrates `as` assertions to one specific library
- `writing-great-skills` - an authoring guide, not a workflow skill
- `teach` (1,490 words) - multi-session tutoring workspace
- `setup-pre-commit`, `git-guardrails` - run once per repo, then permanent dead weight

Six of 40 skills, ~1.4K description chars, that will never fire on this work.

### 2.3 The sync machinery is a control plane for a self-inflicted problem

`scripts/sync-upstream.sh` is 14.6KB, plus 8 lib files, a 7.7KB mapping file, and an 11KB state
file. Its job is drift detection between commands and the skills they wrap. That drift can only
exist because of the 1:1 mirror.

`instructions/AGENTS.md` says: do not build wrappers, control planes, policy layers, or custom
verifiers unless the direct path exposes a concrete blocker. Here the wrapper layer created the
blocker, then justified the control plane.

### 2.4 A router over your own tools is the diagnostic signal

`ask-matt` exists to tell you which of your own skills to use. That is not a feature. It is the
suite reporting that it has exceeded working-memory size.

The history confirms the pattern is cyclical. Commit `8e19d70` was "ECC agent orchestration
simplification: 14->7 agents, 27->10 commands, 10->4 skills". The suite consolidated to 4 skills,
then regrew to 40 in 14 commits. Without a rule about what earns a slot, it regrows again.

---

## 3. Overlap map

**Ponytail: 6 skills, 6 commands, plus a full copy in global instructions.**
`instructions/AGENTS.md` embeds the entire ponytail ladder as always-on instruction. The
`ponytail` skill (1,079 words) then restates it, and 5 sub-skills and 6 commands sit on top.
`ponytail-help` and `ponytail-gain` consume permanent context to print a help card and a benchmark
scoreboard. The `ponytail` mode-switch skill is dead: the rules are already unconditionally active
in the instructions file, so switching mode changes nothing.

**Review: 5 overlapping paths.** `code-review` already runs over-engineering as its third axis.
`ponytail-review` is that axis standalone. `ponytail-audit` is the same at repo scope.
`improve-codebase-architecture` is the inverse operation, and the docs say to pair them. Claude
Code also ships built-in `simplify` and `/review`, duplicating `ponytail-review` and `code-review`
outright.

**Grilling: 3 skills for one behavior.** `grilling` is the engine. `grill-me` is a 20-word file
whose body is "Run a `/grilling` session." `grill-with-docs` is 34 words: "Run a `/grilling`
session, using the `/domain-modeling` skill." Both are pure indirection costing a description slot.

**Save-state: 5 competing mechanisms.** `stow` writes `.stow-notes.md`. `/memory` writes
`.agents/memory.md`. `handoff` writes a handoff doc. `strategic-compact` suggests `/compact`. Claude
Code has its own file-based memory directory. No rule says which wins, and the agents contradict
each other: `agent/builder.md` and `agent/maintainer.md` both mandate `.agents/memory.md` while
`stow` files to `.stow-notes.md`.

**Ship pipeline: 3 nested pipelines.** `command/ship.md` is a 6-gate pipeline whose Stage 6 calls
`/no-mistakes`, itself a 3,312-word full pipeline. Stage 3 calls `/code-review`, which spawns 3
sub-agents. Stage 5 calls `/maintain`, which calls `domain-modeling`. One `/ship --release`
invocation nests four independent orchestrators. `gnhf` is a fifth loop runner alongside them.

**Thin to empty:** `implement` (70 words), `resolving-merge-conflicts` (134), `research` (133),
`handoff` (134).

---

## 4. Matt versus Kunchen

They are not competitors. They operate at different layers of the same pipeline, which is why the
suite ended up with both and then felt bloated.

- **Matt is upstream discipline.** What gets built, and is it right. Grill, spec, tickets, TDD,
  multi-axis review. Unit of value: alignment before code exists.
- **Kunchen is downstream throughput.** Once code exists, validate and parallelize it. Worktrees,
  isolated validation, autonomous loops, orchestration. Unit of value: human review time removed
  after code exists.

Overlap is thin, and only at one seam: `/code-review` versus the no-mistakes adversarial review
stage.

### The real conflict

| | Matt | Kunchen |
|---|---|---|
| Where the human sits | Upstream, heavily. 20-question grilling before a line is written | Downstream and thin. "Engineering director", do not review diffs |
| What prevents defects | Shared understanding, specs as contracts | Pipeline gates, adversarial agents, E2E evidence |
| Context window | Explicit budget, clear between tickets, stay under 140K | Not a stated concern; parallelism sidesteps it |
| Cost to adopt | Markdown. Zero runtime | Real software: daemons, TUIs, CLIs, tmux, CI integration |

Matt assumes the expensive failure is building the wrong thing. Kunchen assumes it is your
attention being the bottleneck. Both are true, but only one is the current bottleneck here.

### Verdict

**Matt is the better flow. Kunchen is the better infrastructure, and about half of it earns its
keep at this scale.**

1. **Cost asymmetry.** Matt's suite is prompts: no install, no daemon, no version to track.
   Kunchen's is production software. `vendor/no-mistakes` alone is ~300 files across
   `internal/daemon`, `internal/tui`, `internal/cli`, `internal/pipeline`; `vendor/firstmate` is
   another ~200. That is a maintenance surface, and the upgrade path for it is the sync machinery
   in section 2.3.
2. **Kunchen's payoff curve needs volume that is not here.** no-mistakes pays off with real CI, a
   PR-based flow, and enough throughput that manual diff review is the constraint. Treehouse and
   firstmate pay off at 3+ concurrent agents on separate features.
3. **Two of the seven Kunchen tools are now native.** Claude Code ships worktree isolation and
   background subagents. Treehouse and firstmate largely reimplement them. Ponytail rung 4: use the
   native platform feature.
4. **The Kunchen half that matters is already adopted.** `instructions/AGENTS.md` is Kunchen's
   global memory file near verbatim. Minimal always-on global memory with everything conditional
   pushed into skills is the highest-value idea in that flow, and it costs nothing.

### Keep, drop

| From Kunchen | Verdict |
|---|---|
| Global/project memory split | Keep. Already in place |
| AXI | Keep. Principles, not software. Correct about MCP being a token tax |
| gnhf | Keep. No Matt equivalent. Overnight runs on verifiable objectives are a real capability |
| no-mistakes | Conditional. Only once pushing PRs to a repo with CI |
| lavish | Optional. An output format, not a workflow |
| treehouse, firstmate | Drop. Superseded by native worktrees and background agents |

From Matt, drop the course-authoring leftovers (`scaffold-exercises`, `migrate-to-shoehorn`,
`writing-great-skills`, `teach`) and `ask-matt` once the suite is small enough not to need a router.

---

## 5. The loop: what exists and what is missing

### 5.1 The chain exists

`/ship "<requirement>" --release` is genuinely a plan, build, review, test, document, push chain.

| Desired step | Exists | Where |
|---|---|---|
| Grilling plans everything | Yes, but **outside** the pipeline | manual `/grill-with-docs` |
| "Implement" | Yes | `/ship <requirement>` |
| Auto TDD | Yes | Stage 2 calls `/tdd` |
| Reviewed | Yes | Stage 3, `/code-review`, 3 parallel subagents |
| Tested | Yes | Stage 4, full suite, gate forbids deleting tests |
| Docs and memory | Yes | Stage 5 calls `/maintain` |
| Pushed | Yes, opt-in | Stage 6 `--release` calls `/no-mistakes` |
| Auto-compaction between phases | **No** | advisory only |

### 5.2 Four gaps

**Grilling is not in the chain, and cannot be.** `command/ship.md` Stage 1 calls `/to-spec`, which
explicitly does not interview. `/ship` assumes grilling already happened in the same window. Run it
cold and Stage 1 synthesizes from nothing. This is correct design, since grilling requires a human
by definition, but it means the automatic part can only begin after the spec exists.

**`/ship` runs all six stages in one context window.** Its frontmatter is `subtask: false`, while
`command/maintain.md` and `command/memory.md` are `subtask: true`. By Stage 4 the window holds the
grilling transcript, the spec, the tickets, every file read during Build, and the review findings.
The pipeline creates the exact context bloat it should prevent.

**Nothing compacts automatically.** `strategic-compact` says "Suggest, don't force." There is no
hook: `.claude/settings.local.json` has permissions only, `opencode.jsonc` has no hooks or plugins.
It is a decision table, not a mechanism.

**It is a chain, not a loop.** `/ship` runs once per requirement, top to bottom, and stops. It has
gates with retry counts but no outer iteration. `gnhf` is the only repeat-until-condition loop, and
it does not run the ship stages.

### 5.3 Isolation, not compaction

Compaction is the wrong lever. It is lossy recovery from a context that should never have
accumulated. The right lever is **isolation**: each stage gets a fresh window and reads a *file*,
not conversation history.

Both vendored doctrines already say this. Matt: clear context between every ticket, one ticket one
session one commit. no-mistakes: run the pipeline in an isolated worktree. `loop-flow.md`: the
value of subagents "is not parallelism, it is context isolation."

If every stage boundary is a file handoff, context never bloats and compaction becomes unnecessary
rather than automatic.

---

## 6. Target loop

```
[human, one window]  /grill-with-docs -> /to-spec -> /to-tickets
                     writes spec.md + tickets/*.md to disk
                     === context ends here, permanently ===

[automatic, per ticket, fresh window each]
   for each ticket with no unmet blockers:
     subagent(builder)   reads the ticket file only  -> /tdd -> commit
     subagent(reviewer)  reads the diff only         -> /code-review
     if findings: one bounded run per finding, then re-review
     append to .agents/memory.md
     === window discarded ===

[once, after the last ticket]
   /no-mistakes --intent "<spec problem statement>"  -> push, PR, CI
```

Concrete edits to get there:

- **Stage 1 becomes a precondition, not a stage.** `/ship` reads `spec.md` and `tickets/` from disk.
  If they are absent it stops and says to grill first. That removes the grilling ambiguity.
- **Stages 2 through 4 move to `subtask: true`**, one subagent invocation per ticket. The five
  personas in `agent/` are already `mode: subagent` and are already exactly these roles. The wiring
  exists; `/ship` does not use it.
- **The review stage must be a fresh subagent regardless.** The author is the worst reviewer of its
  own work. Stage 3 currently reviews inside the window that wrote the code, defeating the point.
- **The loop condition is the ticket's acceptance criterion**, which `/to-tickets` already forces
  you to declare. That is the "red" that makes it a loop instead of an agent talking to itself.

For the unattended version, that per-ticket block is exactly a `gnhf` worker prompt with
`--stop-when "<the ticket's acceptance criterion>"` and `--worktree`. No new machinery is needed.
`/ship` needs to stop hoarding one context window.

**Harness gap.** `/ship` lives in `command/`, which is OpenCode only; `~/.claude/commands` is empty.
The pipeline is absent from Claude Code, the harness with native worktrees, background subagents,
and automatic context summarization. `/ship` should become a skill so all three harnesses get it.

---

## 7. Recommendations, ranked

1. **Delete the command layer, keep 4.** 29 of 33 are skill wrappers, and skills are invocable by
   name on all three harnesses without them. Keep `ship`, `maintain`, `memory`, `design`, the four
   with no skill behind them. If agent routing is needed, put the persona hint in the skill body,
   not a parallel file tree. This removes 29 files, ~1K tokens of permanent OpenCode context, and
   the entire reason `sync-upstream.sh` exists.
2. **Stop globbing.** Convert `link-skills.sh` to an explicit allowlist. Drop `scaffold-exercises`,
   `migrate-to-shoehorn`, `writing-great-skills`, `teach`, `setup-pre-commit`, `git-guardrails`,
   `ask-matt`, `ponytail-help`, `ponytail-gain`, `ponytail`, `grill-me`, `grill-with-docs`,
   `implement`. Thirteen skills, ~2.5K description chars, and every future submodule bump becomes a
   deliberate choice instead of an automatic import.
3. **Collapse the review cluster to two.** Keep `code-review` (already carries the over-engineering
   axis) and `ponytail-audit` (repo scope, genuinely different). Drop `ponytail-review`.
4. **Pick one save-state mechanism.** `.agents/memory.md` is referenced by two agent personas and a
   command; make it the single target. Repoint or drop `stow`.
5. **Restructure `/ship` per section 6**, and promote it from command to skill.
6. **Delete the sync machinery once #1 lands.** ~19KB of scripts and ~19KB of JSON state have
   nothing left to check. Direct path: bump a submodule, run `link-skills.sh`, see what breaks.
7. **Docs: 5 files to 1.** Keep `unified-flow.md` and this file. `combined-workflow.md`,
   `matt-flow.md`, and `kunchen-flow.md` are self-declared superseded in `AGENTS.md`. Fold
   `loop-flow.md` in if its loop content is still current.
8. **Add the rule that prevents regrowth.** One line in `AGENTS.md`: *a skill earns a global slot
   only if it has fired in the last 30 days and no existing skill covers it; everything else stays
   vendored but unlinked.* Without this, the `8e19d70` cycle repeats.

Net: 40 skills to ~24, 33 commands to 4, 5 docs to 1, sync machinery gone. Roughly 60% of the
always-on routing surface removed with no capability lost, because every deletion is a wrapper, a
duplicate, or an upstream skill for work that is not done here.

---

## Related docs

- [unified-flow.md](unified-flow.md) - the full suite, tool by tool
- [loop-flow.md](loop-flow.md) - loop engineering and multi-agent work
- [matt-flow.md](matt-flow.md), [kunchen-flow.md](kunchen-flow.md),
  [combined-workflow.md](combined-workflow.md) - the per-upstream guides this analysis covers
