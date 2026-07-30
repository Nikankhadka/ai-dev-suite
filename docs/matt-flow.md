# Matt Pocock Engineering Flow

A summary of the agent-assisted development workflow used by [Matt Pocock](https://github.com/mattpocock), extracted from his skills tutorial.

## Core Philosophy

**Treat the AI as a design partner, not a code monkey.** The skills exist to sharpen your thinking before a single line is written. Grilling precedes building. Specs precede implementation. Review is done by agents that didn't write the code — because the author is the worst reviewer.

**Be conscious of the context window.** The "smart zone" ends around 140K tokens — beyond that, attention degrades, hallucinations creep in, and the agent gets noticeably dumber. Treat your context window like a budget: plan work into sessions that stay comfortably inside the smart zone, clear context between tickets, and spawn sub-agents with fresh windows for review.

**Skills are lightweight by design.** Even with the full suite installed, the skills only consume ~660 tokens in the system prompt. They are user-invoked — you call them when you need them — so they don't leech into every conversation.

---

## 1. Installing the Skills

The skills repo is installed via the Vercel skills CLI:

```bash
npx skills@latest add mapco/skills
```

This assumes Node.js is installed (`npx` comes from Node). The installer walks through a few choices:

- **Skill selection**: The official, blessed skills (Matt Pocock) are listed first. Experimental "in-progress" skills are listed separately and may change or be deleted. Press space to select all official skills, then return.
- **Agent selection**: The skills work with any agent — Claude Code, Codex, Cursor, Copilot, etc. Select the harnesses you use.
- **Install scope**: **Project** keeps skills in the current directory (best for teams — everyone shares the same skill set). **Global** installs to your home directory (best for solo developers).
- **Link method**: Always choose **symlink**. Copying duplicates files and creates maintenance overhead.

After installation, the skills appear as slash commands (`/grill-with-docs`, `/implement`, `/to-spec`, etc.) or as auto-loaded skills the agent can reach for on its own (`/tdd`, `/code-review`, `/diagnosing-bugs`).

---

## 2. Running Setup

Before using the skills on a project, run the setup command:

```
/setup-matt-pocock-skills
```

This configures three things your project needs:

### Issue Tracker
Specs and tickets need to live somewhere. The skills support any tracker — the agent reads your local configuration and adapts:

- **Local markdown** (default) — Files stored in `.scratch/<slug>/issues/`
- **GitHub** — Native issues with labels and blocking relationships
- **Jira** — "Just say 'set it up with Jira' and it will"
- **Linear** — Same approach, the agent handles the integration

### Triage Labels
A vocabulary of labels the skills use to communicate ticket state (`ready-for-agent`, `in-progress`, `blocked`, etc.). Accept the defaults unless you have specific needs — the docs on the triage skill explain each label.

### Domain Documentation
The skills maintain a `context.md` file and ADRs (Architecture Decision Records) inside the repo. Choose:

- **Single context** — For 99% of projects. One bounded context, one set of docs.
- **Multi-context** — For monorepos with multiple independent domains.

After setup, the agent writes links into `CLAUDE.md` (or equivalent) pointing to the issue tracker docs, triage labels, and domain docs. Your project is now ready.

---

## 3. Getting Started — Ask Matt

The single best entry point: `/ask-matt`.

"Ask Matt" is literally Matt as a skill. It knows the entire ecosystem and routes you to the right skill for your situation. You can be vague — "I want to make some code changes, what flow should I use?" — and it will walk you through the answer.

More importantly, it tells you the main flow. Ask Matt will tell you: start at the top of the main flow and walk down in one unbroken context window.

---

## 4. The Main Flow

The default flow for any piece of work looks like this:

```
grill-with-docs  →  implement          (if work fits one session)
                 →  to-spec → to-tickets → implement   (if multi-session)
```

### Grill-with-Docs

This is where every task begins. It's a relentless interview that sharpens your idea into a defensible plan.

You start with something as vague as "I'd like to remove most of the internal tooling on this CLI." The agent:

1. Explores the codebase to build a clear map of what's relevant
2. Asks focused, probing questions — one at a time
3. Records decisions in ADRs and the project glossary as you answer
4. Stops only when you've walked the entire decision tree and reached shared understanding

A grilling session might be 6 questions for a small change, or 20+ for a complex feature. The output is **a plan you both agree on** — plus updated domain documentation that future sessions can build on.

### The Decision Fork

After grilling, you face a fork:

**If the work fits in one smart zone (~140K tokens):** Go straight to `/implement`. The agent has the plan in context, the work is small enough, and you can ship in this session.

**If the work needs multiple sessions:** Take the spec-and-tickets path. This compresses the discussion into persistent artifacts so future sessions can pick up where this one left off.

### To-Spec

`/to-spec` synthesizes the entire conversation into a formal spec — no interview, just compression of what's already been discussed.

The spec follows a template:

- **Problem Statement** — What's wrong and why it matters
- **Solution** — How we're going to fix it
- **User Stories** — Who benefits and how
- **Implementation Decisions** — Key technical choices and tradeoffs
- **Testing Decisions** — Where the testing seams are and what to test
- **Out of Scope** — Explicitly what we're NOT doing

The spec is published to the issue tracker (local markdown or GitHub/Jira/Linear) with the `ready-for-agent` label. This is the **destination** — the description of how everything looks at the end.

### To-Tickets

`/to-tickets` breaks the spec into a set of tracer-bullet tickets. Each ticket is a **vertical slice** — a narrow but complete path through every layer (schema, API, UI, tests) — that is:

- Demoable on its own
- Sized to fit in a single context window session
- Ordered with blocking edges (ticket B declares "I depend on ticket A")

Wide refactors across the codebase use an expand-contract pattern instead of vertical slicing.

The agent quizzes you on granularity and blocking edges, iterates until you approve, then publishes the tickets. Each ticket becomes a single session of work.

---

## 5. Implementation

### Implement

`/implement` executes a piece of work from a spec or set of tickets:

- Uses `/tdd` — test-driven development at pre-agreed testing seams
- Runs typechecking regularly as it goes
- Runs single test files regularly, the full test suite once at the end
- Follows up with `/code-review` to review the work
- Commits to the current branch

### Context Discipline

When working through multiple tickets:

- **Clear context between every ticket.** Finish ticket 1, commit, clear the context window, start ticket 2 fresh.
- **Never chain tickets in one session** unless you're confident the combined work stays under the smart zone.
- **One ticket, one session, one commit** — this keeps each piece reviewable and reversible.

---

## 6. Code Review

`/code-review` runs a multi-axis review against the diff between `HEAD` and a fixed point (a commit, branch, or merge-base). The genius is that it spawns parallel sub-agents — each with a fresh context window and no knowledge of who wrote the code:

- **Standards axis** — Does the code follow the repo's documented coding standards? Also carries a fixed baseline of 12 Fowler code smells: Mysterious Name, Duplicated Code, Feature Envy, Data Clumps, Primitive Obsession, Repeated Switches, Shotgun Surgery, Divergent Change, Speculative Generality, Message Chains, Middle Man, and Refused Bequest.
- **Spec axis** — Does the code faithfully implement the originating spec/PRD? Cross-checks every acceptance criterion.
- **Over-engineering axis** — What can be deleted or simplified?

Each axis produces a report under 400 words. They're deliberately kept separate — a change can pass one axis and fail another, so they must never be merged or reranked. Sub-agents are essential here: the agent that wrote the code is the worst reviewer of its own work.

---

## 7. Supporting Skills

Beyond the main flow, the engineering suite includes skills for specific situations:

### Before You Build
- **`/tdd`** — Red-green-refactor at pre-agreed seams. Write the failing test first, then the minimal implementation. Work in vertical slices.
- **`/prototype`** — Build a throwaway prototype to answer a design question before committing to an approach. Prototypes are meant to be discarded.
- **`/domain-modeling`** — Build and maintain the project's ubiquitous language. Record architectural decisions, pin down terminology, keep the glossary current.

### Planning at Scale
- **`/wayfinder`** — Plan a huge chunk of work — more than one session can hold — as a shared map of decision tickets on your tracker. Resolve them one at a time until the path is clear.
- **`/triage`** — Move issues and external PRs through a state machine: categorise, verify, grill if needed, and write agent-ready briefs.

### When Things Go Wrong
- **`/diagnosing-bugs`** — A systematic 6-phase diagnosis loop: reproduce, isolate, find root cause, fix, verify, prevent. Designed for hard bugs and performance regressions.
- **`/resolving-merge-conflicts`** — When you're mid-merge or mid-rebase and need help resolving conflicts methodically.

### Session Management
- **`/handoff`** — Compact the current conversation into a handoff document for another agent to pick up. Preserves decisions, context, and next steps across sessions.
- **`/teach`** — Learn a new skill or concept, within the current workspace.

---

## The Design Partner Mindset

**Grill before you build.** Sharp thinking prevents rework. A 20-question grilling session saves hours of wrong implementation.

**Context window is your budget.** Spend it on what matters. Clear context between tickets. Spawn sub-agents for review. Stay inside the smart zone.

**Specs are contracts.** The spec defines the destination. Tickets define the path. Compare implementation against the spec — not against your memory of the conversation.

**Never review your own code.** The agent that wrote it thinks it's fine. Sub-agents with fresh context catch what you'd miss.

---

## Tools Summary

| Tool | Role | Trigger |
|------|------|---------|
| **ask-matt** | Flow router — which skill fits your situation | `/ask-matt` |
| **setup-matt-pocock-skills** | Project configuration (tracker, labels, docs) | `/setup-matt-pocock-skills` |
| **grill-with-docs** | Interview + ADRs + glossary — sharpen the plan | `/grill-with-docs` |
| **to-spec** | Synthesize conversation into formal spec | `/to-spec` |
| **to-tickets** | Break spec into tracer-bullet tickets | `/to-tickets` |
| **implement** | Execute from spec/tickets (TDD + review) | `/implement` |
| **tdd** | Test-driven development at seams | `/tdd` |
| **code-review** | Multi-axis review (standards + spec + over-engineering) | `/code-review` |
| **prototype** | Throwaway prototype for design questions | `/prototype` |
| **wayfinder** | Plan massive multi-session work | `/wayfinder` |
| **triage** | Categorize and brief incoming issues | `/triage` |
| **diagnosing-bugs** | 6-phase systematic diagnosis | `/diagnosing-bugs` |
| **resolving-merge-conflicts** | Resolve in-progress git conflicts | `/resolving-merge-conflicts` |
| **domain-modeling** | Build ubiquitous language and record ADRs | `/domain-modeling` |
| **handoff** | Compact session for agent handoff | `/handoff` |
| **teach** | Learn a new concept interactively | `/teach` |

All skills are free and open source. Install them at [github.com/mattpocock/skills](https://github.com/mattpocock/skills).
