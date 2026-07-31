# AI Dev Suite - Unified Development Flow

A comprehensive guide merging [Matt Pocock's engineering skills](https://github.com/mattpocock/skills), [Kun Chen's workflow infrastructure](https://github.com/kunchenguid), and the full AI Dev Suite toolset into one cohesive captain-to-crew development flow.

## Core Philosophy

**You are the captain, not a sailor.** Your bottleneck must shift from code review and task management to strategic direction. The suite provides three layers to make that happen:

1. **Foundation** - Memory, voice, and agent ergonomics that make every interaction smarter
2. **Process** - Planning, implementation, and validation skills that you orchestrate but don't micromanage
3. **Orchestration** - Parallel crews, autonomous runs, and knowledge capture that let you give direction once and ship many times

**Never review diffs manually.** Trust the validation pipeline. Review the evidence - screenshots, logs, risk assessments - not the raw code.

**Voice first. Plan visually. Parallelize fearlessly.**

For how to run these tools as iterate-verify-commit loops and parallel crews, see
[loop-flow.md](loop-flow.md). This doc covers the tools; that one covers the loop discipline.

---

## Part 0: The Developer Environment

### Terminal Stack

| Tool | Purpose |
|------|---------|
| **WezTerm** | GPU-accelerated terminal emulator |
| **tmux** | Terminal multiplexer - session persistence, tabs, splits |
| **Neovim** | Modal text editor |

### Voice Input

Voice is 3x faster than typing. Use **[OpenSuperWhisper](https://github.com/superduper-ai/OpenSuperWhisper)** - free, open-source, local whisper transcription. Customize its system prompt with your common vocabulary (project names, technical terms). Fall back to typing only for URLs and file paths.

### Memory Files

Two tiers, progressively disclosed:

**Global Memory** - one file, `instructions/AGENTS.md` in this repo, symlinked to `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, and `~/.agents/CLAUDE.md` by `setup.sh`. Loaded into every session across all projects and harnesses. Keep it minimal: personal preferences, coding principles, gotchas. Never let it bloat, and never reference a harness-specific command in it - it is read by harnesses that do not have those commands.

**Project Memory** (`AGENTS.md` / `CLAUDE.md` per project) - Built incrementally:
- Project context and repo layout
- Terminology glossary
- Component architecture
- End-to-end testing instructions
- Conventions and recurring mistakes

**Every time the agent makes a mistake, correct it and ask it to store the learning in the project memory file.** Over time, agents working in that project get smarter. When conditional knowledge grows too large, extract it into skills - skills use progressive disclosure, so only the description loads into the system prompt.

### Agent Ergonomics

**[AXI](https://axi.md)** provides 10 principles for building agent-ergonomic CLI tools. When giving tools to agents, do research on their efficiency. Prefer AXI-compliant tools over MCP servers - the token savings (40% vs JSON) and success rate improvements are dramatic.

### Stack Discovery

Before any work begins, the **stack-discovery** protocol detects what your project actually uses - language, package manager, test framework, build tooling - from manifests rather than assumptions. Never assumes TypeScript, React, Jest, or Playwright. Stops and asks when truly ambiguous.

---

## Part 1: Project Setup

### Installing the Suite

The suite installs itself, submodules included:

```bash
curl -fsSL https://raw.githubusercontent.com/Nikankhadka/ai-dev-suite/main/setup.sh | bash
```

That clones to `~/.config/opencode`, initializes every vendored submodule, symlinks the skills into `~/.claude/skills` and `~/.agents/skills`, and links `instructions/AGENTS.md` as the global instruction file for Claude Code and Codex.

Slash commands are OpenCode-only and live in `.opencode/command/`. Skills work on every harness.

To install an upstream skill set on its own, without this suite, use the Vercel skills CLI, for example `npx skills@latest add mattpocock/skills`.

### Project Configuration

Run the Matt Pocock setup to configure the project's tracker, labels, and docs:

```
/setup-matt-pocock-skills
```

This configures:
- **Issue tracker** - GitHub, Jira, Linear, or local markdown (`.scratch/` directory)
- **Triage labels** - Vocabulary the skills use to communicate ticket state
- **Domain docs** - Single context for most projects, multi-context for monorepos

### Agent Personas

The suite defines specialized agent personas, each with tailored skill access:

| Agent | Role | Key Skills |
|-------|------|-----------|
| **builder** | Writes code | `/tdd`, `/implement`, `/prototype`, `/code-review` |
| **planner** | Designs features | `/grill-me`, `/to-spec`, `/to-tickets`, `/wayfinder`, `/lavish` |
| **reviewer** | Reviews code | `/code-review` (three-axis: standards + spec + over-engineering) |
| **debugger** | Fixes bugs | `/diagnosing-bugs` (6-phase loop) |
| **maintainer** | Cleans house | `/maintain`, `stack-discovery`, `domain-modeling` |

---

## Part 2: Planning & Design

### When to Use What

| Situation | Tool | Why |
|-----------|------|-----|
| "I have a vague idea" | `/grill-with-docs` | Interview sharpens it into a plan + creates ADRs |
| "I need to compare options" | **Lavish** | Visual comparison beats a wall of text |
| "I need UI/UX design" | `/design` | Routes to the right design skill for your stack |
| "I need a brand identity" | **brandkit** | Generates brand-guidelines boards and logo systems |
| "I need to explore the codebase" | `/domain-modeling` | Builds terminology and records architecture decisions |
| "This is a massive multi-sprint feature" | `/wayfinder` | Plans as decision tickets on the tracker |

### Visual Planning with Lavish

When the work is visual or complex, **[Lavish](https://github.com/kunchenguid/lavish-axi)** replaces walls of terminal text with interactive HTML artifacts:

1. Agent generates an HTML artifact - a plan, comparison table, diagram, or layout
2. Opens in the browser via `npx -y lavish-axi plan.html`
3. You annotate specific elements, make decisions, and send feedback
4. Agent rebuilds with your input and the cycle continues

Supports Mermaid diagram whiteboards for architecture discussions. Uses the project's design system so artifacts feel consistent with the actual app. Export to self-contained HTML, share via ht-ml.app, convert Mermaid to Excalidraw whiteboards.

### Frontend Design Router

When the task involves UI work, `/design` detects your project context and routes to the right design skill:

- **React/Next.js with animations** → **Taste-Skill** - Animated UIs with GSAP/Motion. Dial-driven (VARIANCE/MOTION/DENSITY). Cinematic landing pages, portfolios, scroll-driven experiences. The taste-skill repo also ships `gpt-taste` (elite UX/UI), `image-to-code` (design image to implementation), and `imagegen-frontend-web` / `imagegen-frontend-mobile` (generating design references). These are not registered skills or commands - ask the router to load one by name from `vendor/taste-skill/skills/`.
- **Static HTML or audits** → **Hallmark** - Structured HTML/CSS with 21 macrostructures, 20 OKLCH themes, 58 quality gates. Best for static sites, component-level design, audits, and redesigns. Anti-AI-slop by design.
- **Redesigning existing projects** → **redesign-existing-projects** - Audits current design, identifies generic AI patterns, applies premium standards without breaking functionality.

Specialized aesthetics live alongside taste-skill in `vendor/taste-skill/skills/`, loaded by name on demand rather than registered:
- **industrial-brutalist-ui** - Raw mechanical interfaces, Swiss typography + military terminal aesthetics
- **minimalist-ui** - Clean editorial style, warm monochrome, typographic contrast
- **high-end-visual-design** - Agency-grade fonts, spacing, shadows, and card structures

### Structured Planning (Matt Pocock)

For architectural and non-visual decisions, the Matt Pocock skills provide a rigorous interview-and-document cycle:

1. **`/ask-matt`** - Router that tells you which skill fits your situation. "How do I get started?" is a valid prompt.
2. **`/grill-with-docs`** - Relentless interview that walks the entire decision tree. Produces a shared understanding plus ADRs and glossary entries. This is where "I want to change X" becomes a crisp, defensible plan.
3. **`/domain-modeling`** - Build and maintain the project's ubiquitous language. Record architectural decisions, pin down terminology.
4. **`/wayfinder`** - For truly massive work (more than one agent session can hold), create a shared map of decision tickets on the tracker and resolve them one at a time.

---

## Part 3: Speccing & Ticketing

When work spans multiple sessions, compress the plan into persistent artifacts:

### To-Spec

`/to-spec` synthesizes the conversation into a formal spec/PRD - no interview, just compression of what's been discussed. Published to the tracker with the `ready-for-agent` label.

The template covers: Problem Statement, Solution, User Stories, Implementation Decisions, Testing Decisions, and Out of Scope. This is the **destination** - what the world looks like when the work is done.

### To-Tickets

`/to-tickets` breaks the spec into tracer-bullet tickets. Each ticket is a **vertical slice** - a narrow but complete path through every layer - that fits in a single context window. Tickets declare their blocking edges ("I depend on ticket A"), creating a dependency graph the agent can follow.

Wide refactors use an expand-contract pattern instead of vertical slicing.

---

## Part 4: Implementation

### Coding

**`/implement`** executes work from a spec or set of tickets:
- Uses `/tdd` - test-driven development at pre-agreed testing seams
- Runs typechecking regularly, single test files regularly, full suite at the end
- Follows up with `/code-review` and commits

**`/tdd`** - Red-green-refactor. Write the failing test first, then the minimal implementation. Work in vertical slices at the highest possible testing seam.

**`/prototype`** - Build a throwaway prototype to answer a design question before committing to an approach. Prototypes are meant to be discarded.

### Coding Style: Ponytail

**[Ponytail](https://github.com/kunchenguid/ponytail)** is a coding style skill that forces the laziest solution that actually works. It channels a senior dev who has seen everything:

```
Ladder: YAGNI → existing codebase → stdlib → native platform →
        already-installed dep → minimal code
```

Three intensities:
- **lite** - Gentle nudge toward simplicity
- **full** (default) - Aggressively question every dependency and abstraction
- **ultra** - Question whether the task needs to exist at all

Use on ANY coding task. Companion skills:
- `/ponytail-review` - Code review focused exclusively on over-engineering (one line per finding: location, what to cut, what replaces it)
- `/ponytail-audit` - Whole-repo scan for what to delete, simplify, or replace with stdlib
- `/ponytail-debt` - Harvest every `ponytail:` comment into a debt ledger

### Parallel Execution (Kunchen)

**Treehouse** gives each agent its own isolated git worktree from a reusable pool. Dependencies and build cache stay intact between sessions:

```bash
treehouse          # Drop into a fresh worktree
treehouse status   # List all worktrees (active vs idle)
```

**Firstmate** is your "first mate" - talk to one agent, it spawns the crew:

```
"Implement feature A, fix bug B, and refactor module C"
```

Firstmate realizes these are 3 parallel tasks, spawns tmux tabs for each, creates Treehouse worktrees, runs agents in each worktree, validates all changes through No-Mistakes, and presents finished PRs. This is how you level up from sailor to captain.

---

## Part 5: Validation

### No-Mistakes Pipeline

When the agent says it's done, don't review the diff. Send it through the **[No-Mistakes](https://github.com/kunchenguid/no-mistakes)** pipeline:

```
Branch → Commit → Isolated Worktree → Intent Analysis → Rebase →
Adversarial Review → E2E Testing → Documentation → Lint →
Push → PR → CI Babysitting
```

Key features:
- All validation runs in isolated worktrees - your repo is never touched
- Adversarial review catches obvious problems and auto-fixes them (`auto-fix` gate)
- Ambiguous product decisions are escalated to you (`ask-user` gate, not silently resolved)
- E2E testing records evidence: screenshots, videos, logs
- Documentation is auto-updated
- PR is babysat until merged (handles merge conflicts, CI failures)

Two invocation modes:
- **Validate-only**: bare `/no-mistakes` - validates already-committed changes
- **Task-first**: `/no-mistakes <task>` - does the work, commits on a feature branch, then validates

You must supply `--intent` - what you set out to accomplish, not a description of the diff.

**Risk assessment**: For low-risk changes, the pipeline catches everything you would. Only spend review time on high-risk changes.

### Code Review Integration

No-Mistakes' adversarial review step can run `/code-review` in a fresh context - three axes as parallel sub-agents:

- **Standards** - 12 Fowler code smells + repo's documented standards
- **Spec** - Compare implementation against the originating spec/PRD
- **Over-engineering** - What can be deleted or simplified

Sub-agents are critical: the agent that wrote the code is the worst reviewer of its own work. Fresh contexts with no knowledge of the author catch what the author would miss.

---

## Part 6: Autonomous & Long-Running Tasks

**[gnhf](https://github.com/kunchenguid/gnhf)** ("good night, have fun") runs agents autonomously for hours:

```bash
gnhf "Increase end-to-end test coverage to 80%.
Each iteration: identify untested flows, write tests, verify they pass.
Stop when coverage reaches 80%."
```

Features:
- Token caps and iteration caps
- Stop conditions in natural language
- Each successful iteration is committed
- Can run overnight - wake up to a branch of clean, documented work

Two modes:
- **Hands-Off** - One bounded run with a precise prompt, constraints, and stop condition. Launch and wait. Best for well-defined, verifiable tasks.
- **Companion** - The host agent actively supervises, steering the worker between iterations. Inspects diffs, runs verification, launches follow-up rounds. Best for exploratory or design-heavy tasks.

Best for: verifiable objectives (reducing page load time, increasing test coverage, auto-research), or judgment-based tasks where you trust the agent's evaluation.

---

## Part 7: Review, Knowledge Capture & Continuous Improvement

### PR Review

When No-Mistakes finishes:
1. Check the evidence (screenshots, videos, logs)
2. Review the risk assessment
3. Low-risk: trust the pipeline, merge directly
4. High-risk: deep review the diff, request changes if needed

### Capturing Knowledge

**Stow** (from Firstmate) sweeps the conversation for durable knowledge before the session ends:

```
/stow
```

It captures: user preferences (working style, tooling), project facts (build/test/deploy architecture), operational gotchas (sharp edges, workarounds), and undone next steps. Files things into CLAUDE.md, AGENTS.md, existing TODO/BACKLOG files, or a private `.stow-notes.md`.

Outputs a "safe-to-end" verdict and a RESUME POINTER - exactly which files a fresh session should load to continue.

**Handoff** compacts the current session into a document for another agent:

```
/handoff
```

Use when you're passing work between agents or clearing context for the next ticket.

### Architecture Health

Periodically run these to keep the codebase lean:

- **`/improve-codebase-architecture`** - Scans the codebase for deepening opportunities, presents them as a visual HTML report, then grills through whichever you pick.
- **`/ponytail-audit`** - Whole-repo audit for over-engineering: ranked list of what to delete, simplify, or replace with stdlib/native equivalents.
- **`/maintain`** - Clean dead code, consolidate, refresh docs.

---

## Part 8: Bug Fixing, Maintenance & Edge Cases

### Diagnosing Bugs

`/diagnosing-bugs` runs a 6-phase systematic diagnosis loop:

1. **Build a tight feedback loop** - the most important phase. Get a command that can go red deterministically before reading any code: a failing test, a curl script, a headless browser run, a replayed trace, a bisection harness. If you start reading code before a red-capable command exists, stop.
2. **Reproduce and minimize** - run the loop, watch it fail, shrink to the smallest scenario that still fails.
3. **Hypothesize** - generate 3 to 5 ranked, falsifiable hypotheses and show them before testing. Single-hypothesis debugging anchors on the first plausible idea.
4. **Instrument** - change one variable at a time. Prefer a debugger or REPL over logs. Tag debug output so it is removable.
5. **Fix with a regression test** - write the test first, at a correct seam, from the minimized repro. Then fix.
6. **Cleanup and post-mortem** - remove instrumentation, state the confirmed hypothesis in the commit, and ask what would have prevented the bug.

### Triage

`/triage` moves incoming issues through a state machine: categorise, verify the report, grill if details are missing, and write agent-ready briefs. This turns raw GitHub issues into implementable tickets.

### Merge Conflicts

`/resolving-merge-conflicts` handles in-progress git merge/rebase conflicts methodically - useful when parallel worktrees eventually converge.

### Learning

`/teach` teaches you a new skill or concept interactively within the current workspace.

---

## Part 9: The Captain's Workflow - End-to-End Example

Here's what a real day looks like with the unified flow:

### Morning: Direction-Setting

1. **Voice note** - Dictate the day's priorities via OpenSuperWhisper: "Today I need to add a dashboard, fix the auth bug, and redesign the landing page."

2. **Lavish plan** - For the dashboard architecture: agent generates an HTML artifact with component tree, data flow, and route design. Open in browser, annotate decisions, send feedback.

3. **Grill-with-docs** - For the auth bug: start a grilling session. Agent explores the codebase, asks questions, produces ADRs documenting the fix approach.

4. **Frontend-design** - For the landing page redesign: the router detects it's Next.js, routes to taste-skill. Agent generates designs with GSAP scroll animations.

### Midday: Execution

5. **To-spec + to-tickets** - The dashboard is multi-session work. Compress the Lavish-augmented plan into a spec, then break into tracer-bullet tickets with dependency edges.

6. **Firstmate launch** - Talk to one agent: "Implement ticket 1 (auth bug) and ticket 2 (dashboard data layer)." Firstmate spawns two tmux tabs, two Treehouse worktrees, two agents running in parallel.

7. **Implement with ponytail** - Each agent uses `/implement` with ponytail (lite): TDD at seams, minimal dependencies, no speculative abstractions. Typechecking runs continuously. Tests run per-file, then full suite at the end.

### Afternoon: Validation

8. **No-Mistakes** - Both branches go through the pipeline: intent analysis, rebase, adversarial review, E2E testing, docs, lint, push, PR, CI babysitting. Evidence recorded throughout.

9. **Code review integration** - The adversarial review phase spawns sub-agents for standards, spec, and over-engineering checks. Findings with `ask-user` gates are escalated to you.

### Evening: Autonomous

10. **gnhf overnight** - "Run the full E2E test suite 20 times. Every time a test flakes, fix it and commit. Stop when all 20 runs pass cleanly." Launch and walk away.

### Next Morning: Review & Capture

11. **Review evidence** - Check No-Mistakes evidence (screenshots, videos, logs, risk assessments). Merge low-risk PRs directly. Deep-review the high-risk ones.

12. **Stow** - Sweep the sessions for durable knowledge: what worked, what broke, what to remember. Filed into project memory. Fresh sessions load the RESUME POINTER and continue.

---

## Master Tools Reference

### Planning & Design

| Tool | Role | Trigger |
|------|------|---------|
| **Lavish** | Visual planning with interactive HTML | `npx -y lavish-axi` |
| **frontend-design** | UI design router (taste-skill / hallmark) | `/design` (skill name is `frontend-design`) |
| **hallmark** | Structured HTML/CSS, 21 macrostructures, 58 quality gates | Loaded by router |
| **taste-skill** | Animated React/Next.js, GSAP/Motion, dial-driven | Loaded by router |
| **brandkit** | Brand-guidelines boards, logo systems, identity decks | Load by path from vendor/taste-skill/skills/ |
| **gpt-taste** | Elite UX/UI + advanced GSAP motion | Load by path from vendor/taste-skill/skills/ |
| **image-to-code** | Design-image-to-implementation workflow | Load by path from vendor/taste-skill/skills/ |
| **imagegen-frontend-web** | Section-by-section landing page design images | Load by path from vendor/taste-skill/skills/ |
| **imagegen-frontend-mobile** | Premium mobile app screen concepts | Load by path from vendor/taste-skill/skills/ |
| **industrial-brutalist-ui** | Raw mechanical interfaces, Swiss + military | Load by path from vendor/taste-skill/skills/ |
| **minimalist-ui** | Clean editorial style, warm monochrome | Load by path from vendor/taste-skill/skills/ |
| **high-end-visual-design** | Agency-grade fonts, spacing, shadows | Load by path from vendor/taste-skill/skills/ |
| **redesign-existing-projects** | Audit and upgrade existing sites | Load by path from vendor/taste-skill/skills/ |
| **ask-matt** | Flow router - which skill fits your situation | `/ask-matt` |
| **grill-with-docs** | Interview + ADRs + glossary | `/grill-with-docs` |
| **grill-me** | Relentless interview (no docs) | `/grill-me` |
| **domain-modeling** | Build ubiquitous language, record ADRs | `/domain-modeling` |
| **wayfinder** | Plan massive multi-session work | `/wayfinder` |

### Speccing & Ticketing

| Tool | Role | Trigger |
|------|------|---------|
| **to-spec** | Synthesize conversation into formal spec | `/to-spec` |
| **to-tickets** | Break into tracer-bullet tickets with blocking edges | `/to-tickets` |
| **triage** | Categorize, verify, and brief issues | `/triage` |

### Implementation

| Tool | Role | Trigger |
|------|------|---------|
| **implement** | Execute from spec/tickets (TDD + review) | `/implement` |
| **tdd** | Test-driven development at seams | `/tdd` |
| **ponytail** | Lazy senior dev - simplest solution that works | `/ponytail lite\|full\|ultra` |
| **prototype** | Throwaway prototype for design questions | `/prototype` |
| **code-review** | Three-axis review (standards + spec + over-engineering) | `/code-review` |
| **ponytail-review** | Review focused on over-engineering only | `/ponytail-review` |
| **ponytail-audit** | Whole-repo scan for what to delete | `/ponytail-audit` |
| **ponytail-debt** | Harvest `ponytail:` comment shortcuts into ledger | `/ponytail-debt` |
| **ponytail-gain** | Scoreboard: ponytail's measured impact | `/ponytail-gain` |

### Validation & Orchestration

| Tool | Role | Trigger |
|------|------|---------|
| **No-Mistakes** | Full validation pipeline (review → test → docs → lint → push → PR → CI) | `/no-mistakes` |
| **Treehouse** | Isolated git worktrees for parallel agents | `treehouse` |
| **Firstmate** | Agent orchestration - one chat, parallel crew | `firstmate` |
| **gnhf** | Autonomous overnight agent loops | `gnhf "<objective>"` |

### Knowledge & Maintenance

| Tool | Role | Trigger |
|------|------|---------|
| **stow** | Sweep conversation for durable knowledge | `/stow` |
| **handoff** | Compact session for agent handoff | `/handoff` |
| **diagnosing-bugs** | 6-phase systematic bug diagnosis | `/diagnosing-bugs` |
| **resolving-merge-conflicts** | Resolve in-progress git conflicts | `/resolving-merge-conflicts` |
| **improve-codebase-architecture** | Scan for deepening opportunities | `/improve-codebase-architecture` |
| **maintain** | Clean dead code, consolidate, refresh docs | `/maintain` |
| **teach** | Learn a new concept interactively | `/teach` |
| **stack-discovery** | Detect project language/tooling from manifests | Skill auto-load |
| **setup-matt-pocock-skills** | Configure tracker, labels, domain docs | `/setup-matt-pocock-skills` |

### Environment

| Tool | Role |
|------|------|
| **OpenSuperWhisper** | Voice transcription (3x faster than typing) |
| **AXI** | 10 principles for agent-ergonomic tool design |
| **WezTerm + tmux + Neovim** | Terminal development environment |

---

All tools in this suite are free and open source.
