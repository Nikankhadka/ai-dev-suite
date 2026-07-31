# Loop Flow: Loop Engineering and Multi-Agent Work

The other docs in `docs/` describe *what the tools are*. This one describes *how to run them as
loops*, which is the thing this suite is actually built for.

A loop is any arrangement where an agent does work, something checks the work, and the result
decides whether to continue or stop. Almost every tool in this suite is a loop with a different
radius: `/tdd` closes in seconds, `/no-mistakes` in minutes, `gnhf` in hours, a parallel crew over
a whole day. Get the loop right and the agent compounds. Get it wrong and it confidently produces
garbage all night.

**The one rule this whole doc hangs on:** a loop is only as good as the thing that can turn it
red. This is `diagnosing-bugs` phase 1 generalized. If nothing in your loop can produce a
mechanical, unambiguous failure, you do not have a loop. You have an agent talking to itself.

---

## Three loop scales

| Scale | Radius | Who closes it | Tools |
|---|---|---|---|
| **Inner** | seconds to minutes | the agent, mid-session | `/tdd`, `/diagnosing-bugs`, typecheck and test commands |
| **Outer** | minutes to hours | a gate, once per iteration | `/no-mistakes`, `/ship`, `/code-review` |
| **Fleet** | hours to overnight | you, at checkpoints | `gnhf`, `treehouse`, firstmate |

Pick the smallest scale that can hold the work. A fleet loop around a task that one inner loop
could finish is pure overhead, and every extra layer is another place for a stop condition to be
misread.

---

## Layer 0: harness-native loops (zero install)

Before reaching for a CLI, know what the harness already gives you.

**Claude Code**

- `/loop <interval> <prompt>` runs a prompt or slash command on a schedule. Omit the interval and
  the model paces itself, waking when it decides there is something to check. Use it for polling
  external state the harness cannot notify you about: a CI run, a deploy, a queue.
- Background Bash (`run_in_background`) keeps a long command alive across turns and re-invokes the
  agent when it exits. You do not need to poll it. Polling harness-tracked work is wasted tokens.
- Subagents run tasks in a fresh context. The value is not parallelism, it is *context isolation*:
  a reviewer that never saw the code being written catches what the author cannot.
- Worktrees (`isolation: "worktree"`) give an agent its own checkout, auto-cleaned if unchanged.

**OpenCode**

- Commands with `subtask: true` in their frontmatter run in a child session, so a long procedure
  does not consume the main context. `/maintain` and `/memory` already do this.
- The five personas in `.opencode/agent/` are the loop roles: `planner` frames, `builder` builds,
  `reviewer` checks, `debugger` diagnoses, `maintainer` cleans. Each is `mode: subagent`, so
  routing a command at a persona is how you get a clean context for that phase.

Layer 0 covers more than people expect. Reach past it only when you need durability across
sessions (`gnhf`), a real gate (`no-mistakes`), or true filesystem isolation (`treehouse`).

---

## Layer 1: the gate loop (no-mistakes)

A gate is what converts "the agent says it is done" into "something independent agreed it is
done." Everything above this layer depends on it. An overnight run without a gate just multiplies
whatever the agent got wrong on iteration one.

`no-mistakes` runs the pipeline in an isolated worktree, so your working copy is never touched:

```
intent -> rebase -> adversarial review -> test -> document -> lint -> push -> PR -> CI
```

Drive it through the AXI command family, which prints TOON to stdout and progress to stderr:

```bash
no-mistakes axi run --intent "<what you set out to accomplish>"
no-mistakes axi status                # inspect the active or most recent run
no-mistakes axi logs <step>           # one step's output
no-mistakes axi respond ...           # answer the current approval gate
no-mistakes axi run --yes             # auto-resolve every gate, no escalation
```

**`--intent` is the acceptance contract, not a diff summary.** It is required to start a run.
Write what the change was *for*. "Add a --json flag to status" is intent. "Modified status.go and
added a test" is not, and it makes the review axis useless because there is nothing to compare
against.

**Two invocation shapes.** Bare `/no-mistakes` validates work that is already committed.
`/no-mistakes <task>` does the work first, commits it on a feature branch, then validates, passing
your task text through as the intent.

**Gate outcomes split three ways.** Findings the pipeline can fix, it fixes (`auto-fix`).
Ambiguous product decisions escalate to you (`ask-user`) instead of being silently resolved. Hard
failures stop the run. `--yes` collapses all of that into auto-resolve, including ask-user
findings. That is the right flag for a bounded overnight loop and the wrong flag for anything with
product judgment in it.

**Nesting is forbidden.** A validation-step agent inside an active run must inspect, fix and
return only its assigned phase. If a pipeline-control command returns `nested_gate_context`, stop
and hand back to the outer executor. Only `status`, `logs`, `help` and `doctor` are safe from the
inside.

**`/ship` is the same idea, local and staged.** `.opencode/command/ship.md` runs Context, Plan,
Build, Review, Test, Docs and optional Release with a hard gate on each (G0 through G6), a max
attempt count per gate, and a mandatory report table. It never proceeds past a FAIL. Use `/ship`
for one requirement end to end inside a session; use `no-mistakes` when the work is already
committed and needs to reach a push target.

---

## Layer 2: the autonomous loop (gnhf)

`gnhf` ("good night, have fun") repeatedly calls a coding agent until a natural-language stop
condition is met, committing each successful iteration.

```bash
gnhf --agent claude \
     --max-iterations 20 \
     --max-tokens 2000000 \
     --stop-when "the full suite passes 20 consecutive times and no unrelated files changed" \
     --prevent-sleep on \
     --worktree \
     "<worker prompt>"
```

Flags that matter: `--worktree` runs in a separate git worktree so several gnhf runs can share one
repo; `--current-branch` stays on your branch instead of creating a gnhf branch; `--push` pushes
after each successful iteration; `--max-iterations` and `--max-tokens` are your two hard stops.
Always check `gnhf --help` before relying on a flag rather than inventing one.

**The host orchestrates, gnhf executes.** Do not hand-implement inside a scope a gnhf worker owns.
Two writers on one scope produce conflicts that neither of them understands.

### Two modes, chosen up front

**Hands-Off** for bounded work with clear verification. Write one precise prompt, launch, wait.
Intervene only for hard failure, runaway scope, destructive behavior, or an impossible
prerequisite. Report the final status after exit.

**Companion** for uncertain, exploratory or design-heavy work. Poll the run, read each iteration's
diff, and tighten the next prompt when the worker drifts. Default to Companion whenever the user
asks to iterate until satisfied, hands you review findings, or asks for supervision.

**In Companion mode, "stop condition met" is not acceptance.** It means the worker stopped. You
still compare the result against the current requirements and fresh verification.

### The worker prompt skeleton

```text
Objective: <one concrete outcome>.

Use <agent/model requirement>. Work in this repo. Treat this as a long-running task.

Before coding, inspect the current repo, relevant docs, and recent commits.
Preserve user changes. Do not make unrelated refactors.

After each meaningful slice, run <verification commands>. If blocked, commit no
fake success; leave notes with the blocker and the evidence.

Stop only when: <observable completion condition>.
```

### Steering signals

| Signal | Action |
|---|---|
| Real blocker found | Stop, or relaunch with blocker-specific instructions |
| Good partial slice | Continue, or tighten the next stop condition |
| Skipped the research you asked for | Relaunch with research as the explicit first deliverable |
| Unrelated files changed | Stop and review before continuing |
| Success claimed with no verification | Review now; relaunch only with an evidence-based stop condition |
| Reviewer or user rejects the result | Relaunch with that finding as the sole bounded correction |

Steering prompt shape: state what already succeeded and its evidence, forbid redoing it, name the
one bounded correction, name the verification, restate the stop condition.

### Morning review

Never summarize an overnight run from memory. Reconstruct state first:

```bash
git status --short
git branch --show-current
git log --oneline --decorate --max-count=20
pgrep -fl 'gnhf|claude|codex|opencode' || true
```

If a run is still going, report that before anything else. Then report mode, agent, branch,
changes, verification results, whether the stop condition was actually satisfied, and the
recommended next action. Treat the worker's own notes as claims, not evidence.

---

## Layer 3: parallel isolation (treehouse)

Parallel agents in one working tree corrupt each other. Treehouse maintains a pool of reusable,
pre-warmed git worktrees, so dependencies and build caches survive between sessions instead of
being rebuilt on every branch switch.

```bash
treehouse get                          # acquire a worktree, open a subshell in it
treehouse get --lease --lease-holder agent-A   # non-interactive: prints only the path to stdout
treehouse status                       # what is in the pool, active vs idle
treehouse return <path>                # release a lease, terminate lingering processes
treehouse prune                        # dry run by default; --yes to actually delete
treehouse init                         # write a default treehouse.toml
```

**Use `--lease` for anything scripted.** A leased worktree is reserved in persistent state, is
never handed to a later `get`, and is never removed by `prune` until you return it, even with no
process running inside it. Banners go to stderr and only the path goes to stdout, which is exactly
what an orchestrator needs.

**Prune is conservative on purpose.** A worktree is stale only when treehouse manages it, nothing
holds or runs in it, it has no uncommitted changes, and its HEAD is already merged into the
default branch. That is why it will not eat a half-finished overnight run.

**Treehouse or `gnhf --worktree`?** For one autonomous run, `--worktree` is enough and needs no
extra tool. Use treehouse when several agents share a repo, when you want the pre-warmed
dependency cache, or when something outside gnhf needs to hold a checkout.

**Convergence is the hard part, not the fan-out.** N parallel branches have to land. Keep each
branch to a single vertical slice, land them one at a time rather than as a batch, and use
`/resolving-merge-conflicts` for the ones that collide. If two branches keep colliding, they were
never independent tasks and should not have been parallelized.

---

## Layer 4: fleet orchestration (firstmate)

**Not installed on this machine.** `vendor/firstmate/` is vendored for its skills and its model,
but the CLI is absent, so nothing below runs today. Install from
[kunchenguid/firstmate](https://github.com/kunchenguid/firstmate) to use it.

The model: you talk to one agent, the "first mate", and it spawns and supervises the crew. You say
"implement feature A, fix bug B, refactor module C" and it recognizes three parallel tasks, gets a
worktree per task, runs an agent in each, validates through no-mistakes, and comes back with PRs.
That is the step from sailor to captain.

Even without the CLI, six of its primitives are worth stealing into any loop you run here:

- **bearings** produces a "pick up where I left off" digest from live state. The generalizable
  rule: reconstruct from the filesystem and git, never from recollection.
- **ahoy** recaps only what happened since your last real message, and separately lists decisions
  you were asked for and never answered. A later unrelated message does not close an earlier
  question.
- **afk** is durable away-mode supervision, not just "keep going." The distinction that matters:
  an away agent should produce branches and a status report, not irreversible changes.
- **stow** sweeps a session for durable knowledge and files it to disk before a context reset.
  This is the only firstmate skill actually registered here, via `vendor/firstmate/skills`, so
  `/stow` works today.
- **decision-hold-lifecycle** forbids marking an investigation or review complete while a human
  decision it raised is still unresolved. Loops lose decisions faster than they lose code.
- **quota-array-dispatch** resolves how many workers to dispatch from current quota and pace
  signals. The general lesson: dispatch width is a function of remaining budget, not of how many
  tasks exist.

---

## Loop hygiene and failure recovery

This is the section that keeps loops from doing damage.

### Stop conditions

A stop condition must be **observable** (a command or an artifact proves it), **verifiable by
someone other than the worker**, and **bounded** (it can be reached).

| Bad | Why | Good |
|---|---|---|
| "looks good" | not observable | "`npm test` exits 0 and no file outside `src/auth/` changed" |
| "the code is clean" | not verifiable | "`/ponytail-review` reports nothing to cut" |
| "all bugs fixed" | not bounded | "the three issues in the linked ticket each have a regression test that fails on `HEAD~n`" |
| "tests pass" | passes by deletion | "tests pass and no test was deleted or marked skip" |

That last row is the one that bites in practice. A loop optimizing for a green suite will delete
the red test unless you forbid it.

### Evidence, not claims

A worker's summary is a claim. Evidence is a command you ran yourself, a diff you read, a
screenshot, a CI result. This applies to gnhf Companion review, to subagent reports, and to the
final "done" of any autonomous run. The cost of checking is a minute. The cost of not checking is
a morning spent unpicking a confident wrong branch.

### Drift detection between iterations

Check these after each iteration. Any one of them means stop and re-scope:

- Files changed outside the declared scope.
- The same fix attempted twice with different wording.
- New abstractions nobody asked for, especially "for later."
- Research or reproduction steps you asked for that were skipped.
- Commit messages getting vaguer as iterations go on. This is the earliest visible signal that a
  worker has lost the thread.

### Caps

Every unattended loop needs all three, because they fail differently:

- **Iteration cap** (`--max-iterations`) catches a loop that oscillates between two wrong states.
- **Token cap** (`--max-tokens`) catches a loop that is making progress far too expensively.
- **Wall-clock or checkpoint cap** catches everything else. If you are asleep, your checkpoint is
  the morning review, so make sure the run cannot push or merge before you see it.

An uncapped unattended loop is not autonomy, it is an unbounded write to your repo.

### Recovering a stuck or runaway loop

1. Reconstruct state before touching anything: `git status --short`, `git log --oneline -20`,
   `git branch --show-current`, and check for live worker processes.
2. Never clean up a worker branch with destructive git. No `reset --hard`, no `clean -fd`, no
   `branch -D`. `opencode.jsonc` already denies these, and that deny-list exists for exactly this
   moment.
3. Preserve the worker's output even when it is wrong. A wrong branch is evidence about the prompt
   that produced it.
4. Convert the failure into the next run's sole bounded correction. Do not relaunch the original
   prompt and hope.
5. If two relaunches fail on the same point, the stop condition is wrong, not the worker. Rewrite
   the condition.

---

## Choosing a loop

| Task shape | Loop | Why |
|---|---|---|
| Bounded, verifiable, one sitting | `/ship` | Gates in order, one report, no external process |
| Committed work that needs to reach a PR | `/no-mistakes` | Isolated worktree, adversarial review, CI babysitting |
| Bounded and verifiable, but long | gnhf Hands-Off with caps | Durable across hours, commits each iteration |
| Exploratory, design-heavy, unclear target | gnhf Companion | You steer between iterations |
| Hunting flakes or coverage | gnhf with a repetition-based stop condition | The check is mechanical, which is the ideal loop |
| Several independent tasks in a day | treehouse worktrees, one agent each | Isolation first, then fan out |
| Wide refactor across many files | not a loop, expand-contract via `/to-tickets` | Parallel agents on one wide change collide by construction |
| One hard bug | `/diagnosing-bugs` | Feedback loop first, then 3 to 5 hypotheses |
| Polling external state (CI, deploy) | Claude Code `/loop` | Cheap, no repo writes |

---

## The recommended default loop for this suite

**Direct, Delegate, Verify, Capture.** Four steps, and the fourth is the one everyone skips.

### 1. Direct

You set the destination, not the route.

```
/grill-with-docs      # relentless interview until every decision branch is resolved
/to-spec              # synthesize the conversation into a PRD, no re-interviewing
/to-tickets           # tracer-bullet slices with declared blocking edges
```

Use `/lavish` instead of prose whenever the decision is visual or comparative, and `/design` for
frontend work so the router picks the right design skill before anyone writes markup. For work too
large for one session, `/wayfinder` maps it as investigation tickets first.

The output that matters here is a set of tickets that each have an **observable acceptance
condition**. That condition becomes the stop condition of every loop downstream. If you cannot
write it now, you will not be able to write it at 2am either.

### 2. Delegate

One ticket, one loop, one isolated checkout.

```bash
treehouse get --lease --lease-holder ticket-14
# then, inside that worktree, either:
/ship "<ticket 14 acceptance condition>"
# or, for long or unattended work:
gnhf --agent claude --max-iterations 15 --worktree \
     --stop-when "<the ticket's acceptance condition>" "<worker prompt>"
```

Keep `ponytail` on while building. The cheapest review finding is the code that was never written.

### 3. Verify

Read evidence, not diffs.

```bash
no-mistakes axi run --intent "<the ticket's intent, in your words>"
no-mistakes axi status
```

For low-risk changes, the pipeline catches what you would have caught, and reading the diff is
theater. Spend your review attention on the high-risk ones and on every `ask-user` escalation,
because those are precisely the decisions the pipeline correctly refused to make for you.

`/code-review` is the same discipline at session scope, three axes as parallel subagents:
standards, spec, over-engineering. Never merge or rerank the axes. A change can pass one and fail
another, and the separation is what stops one from masking the other.

### 4. Capture

This is what makes loop 2 faster than loop 1. Skip it and every session pays the same startup cost
forever.

```
/memory note <the non-obvious decision and why>    # .agents/memory.md, project-scoped
/stow                                              # sweep the session before a context reset
/handoff                                           # only when passing to another agent mid-flight
```

The boundary between the three, since it is not obvious:

- **`/memory`** is a deliberate write of one durable fact into `.agents/memory.md`. Use it the
  moment you learn something, not at the end.
- **`/stow`** is an automatic sweep of a whole session for things you did not think to record. Use
  it before a context reset or a long break.
- **`/handoff`** compacts the live conversation so a different agent can continue *this* work. It
  is about continuity, not knowledge.

Record only what the code cannot tell you: decisions and their reasoning, gotchas found the hard
way, conventions you were corrected on. Never record file structure or dependency lists.

---

## Worked examples

### Overnight flake hunt

```bash
gnhf --agent claude \
     --max-iterations 30 --max-tokens 3000000 --prevent-sleep on --worktree \
     --stop-when "the full suite passes 20 consecutive runs, no test was deleted or skipped, and no non-test file changed without a stated reason" \
     "Objective: eliminate flakiness in the E2E suite.
      Each iteration: run the suite, identify one flaking test, diagnose the actual race or
      timing dependency, fix the root cause, and commit. Do not add retries, do not increase
      timeouts, do not skip tests. If a flake cannot be fixed, commit a note with the evidence
      and move to the next one."
```

Hands-Off mode. The verification is mechanical, the stop condition closes the two obvious cheats
(deleting tests, adding retries), and both caps are set. Morning: reconstruct state, read the
commits, spot-check two fixes against their evidence.

### Three-task parallel day

1. `/to-tickets` produces three slices with no shared blocking edges. Verify that before fanning
   out, because tickets that block each other are one sequential task wearing a disguise.
2. `treehouse get --lease --lease-holder task-a` (and b, c). Three isolated checkouts.
3. One agent per worktree, each running `/ship` against its ticket's acceptance condition.
4. Land them one at a time. First one merges clean; rebase the others; `/resolving-merge-conflicts`
   for anything that collides.
5. `treehouse return <path>` for each, then `/stow` once at the end for the whole day.

### Review-findings loop

The tightest loop in the suite, and the most underused. Each review finding becomes the sole
acceptance criterion of the next bounded run.

1. `/code-review` or a `no-mistakes` gate produces findings.
2. Take one finding. Preserve its severity, its file and line scope, and its original wording.
3. Relaunch bounded: fix only that finding, preserve completed work, verify with a named command,
   stop when the finding is no longer true.
4. Re-review. Repeat until nothing blocking remains.

Never batch findings into one "address the review" run. Batching is how a loop turns a review into
a refactor.

---

## Anti-patterns

- **A loop with no red.** Nothing in the iteration can mechanically fail, so the agent grades its
  own homework and always passes.
- **"Looks good" as a stop condition.** The worker decides when it is done, which is the one
  decision it should never own.
- **Working inside a scope a worker owns.** Two writers, one scope, conflicts neither understands.
- **Treating completion as acceptance.** "Stop condition met" means the worker stopped. Nothing
  more.
- **Uncapped unattended runs.** Autonomy without caps is an unbounded write to your repo.
- **Swarming subagents when one agent and a gate would do.** Every spawn re-derives context you
  already have. Fan out for *isolation* (a reviewer who never saw the code) or for genuinely
  independent tasks, never for speed on one task.
- **Parallelizing a wide refactor.** Expand-contract through tickets instead; parallel agents on
  one wide change collide by construction.
- **Skipping capture.** The loop that never writes down what it learned runs at the same speed on
  day 30 as on day 1.

---

## Related docs

- [unified-flow.md](unified-flow.md) - the full suite, tool by tool
- [combined-workflow.md](combined-workflow.md) - the earlier merged Matt Pocock and Kunchen guide
- [matt-flow.md](matt-flow.md) - the Matt Pocock engineering skills on their own
- [kunchen-flow.md](kunchen-flow.md) - the Kunchen infrastructure on its own
