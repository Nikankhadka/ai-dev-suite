# Combined Workflow: Matt Pocock + Kunchen

This guide merges [Matt Pocock's engineering skills](https://github.com/mattpocock/skills) with [Kun Chen's workflow infrastructure](https://github.com/kunchenguid) into one cohesive development flow.

## The Stack

```
┌─────────────────────────────────────────────────────┐
│                  Firstmate (Orchestration)            │
│  Single chat interface → spawns parallel crewmates    │
├─────────────────────────────────────────────────────┤
│                  Treehouse (Isolation)                │
│  One worktree per agent — no conflicts, auto-cleanup  │
├──────────────────┬──────────────────────────────────┤
│   Matt Pocock    │         Kunchen                   │
│   Task Skills    │    Infrastructure                 │
├──────────────────┼──────────────────────────────────┤
│  /tdd            │  Lavish (visual planning)         │
│  /code-review    │  No-Mistakes (validation)          │
│  /diagnosing-    │  gnhf (autonomous runs)           │
│    bugs          │  AXI (agent-ergonomic tools)       │
│  /to-spec        │                                   │
│  /to-tickets     │                                   │
│  /implement      │                                   │
│  /triage         │                                   │
│  /wayfinder      │                                   │
│  /grill-me       │                                   │
│  /prototype      │                                   │
│  /handoff        │                                   │
│  /teach          │                                   │
│  /ask-matt       │                                   │
├──────────────────┴──────────────────────────────────┤
│              Frontend Design                          │
│  hallmark (21 macrostructures, 20 OKLCH themes)      │
│  design-taste-frontend (animated React/Next.js)      │
│  /frontend-design (router)                            │
└─────────────────────────────────────────────────────┘
```

## Development Environment

| Tool | Purpose |
|------|---------|
| **WezTerm** | GPU-accelerated terminal emulator |
| **tmux** | Terminal multiplexer (session persistence, tabs) |
| **Neovim** | Modal text editor |
| **OpenSuperWhisper** | Local voice transcription (3x faster than typing) |

---

## Phase 1: Planning

### Visual Exploration (Lavish)
When the work is visual or complex, start with Lavish:
1. Agent generates HTML artifacts showing options, layouts, or comparisons
2. Opens in browser via `npx -y lavish-axi plan.html`
3. Annotate specific parts, make decisions inline
4. Feedback flows back to the agent

### Frontend Design Router
When the task involves frontend UI work, the planner invokes the `/frontend-design` router:
1. Detects project context (React/Next.js vs static HTML, animation needs, task type)
2. Routes to the appropriate design skill:
   - **Hallmark** — structured HTML/CSS with 21 macrostructures, 20 OKLCH themes, 58 quality gates. Best for static sites, audits, redesigns, and component-level design.
   - **Taste-Skill** — animated React/Next.js with GSAP/Motion. Dial-driven (VARIANCE/MOTION/DENSITY). Best for landing pages, portfolios, and cinematic UIs.
3. Loads a lightweight index wrapper first to orient, then the full skill
4. Asks the user for design context (audience, tone, use case) if not yet provided

### Structured Planning (Matt Pocock)
For architectural and non-visual decisions:
1. **`/ask-matt`** — Router to find the right skill for your situation
2. **`/grill-me`** — Relentless interview to stress-test ideas
3. **`/grill-with-docs`** — Grill + produce ADRs and glossary entries
4. **`/to-spec`** — Turn discussion into a formal spec, publish to issue tracker
5. **`/to-tickets`** — Break spec into dependency-ordered tracer-bullet tickets
6. **`/wayfinder`** — Plan huge multi-session work as decision tickets

### Domain Modeling
- **`/domain-modeling`** (Matt) — Build ubiquitous language, record architectural decisions

---

## Phase 2: Implementation

### Agent Personas (OpenCode)

| Agent | Role | Key Skills |
|-------|------|-----------|
| **builder** | Writes code | `/tdd`, `/implement`, `/prototype`, `/code-review` |
| **planner** | Designs features | `/grill-me`, `/to-spec`, `/to-tickets`, `/wayfinder` |
| **reviewer** | Reviews code | `/code-review` (two-axis: standards + spec) |
| **debugger** | Fixes bugs | `/diagnosing-bugs` (6-phase loop) |

### Coding Workflow (Matt)
1. **`/tdd`** — Red-green-refactor at pre-agreed seams. Write failing test first, then minimal implementation. Work in vertical slices.
2. **`/implement`** — Execute from a spec or ticket set using TDD at seams.
3. **`/prototype`** — Throwaway prototype to answer a design question before committing.
4. **`/code-review`** — Two-axis review (standards + spec) before committing.
5. **`/diagnosing-bugs`** — Systematic 6-phase diagnosis loop.

### Running in Parallel (Kunchen)
- **Treehouse** creates isolated worktrees for each parallel agent session
- **Firstmate** manages the parallelism — you talk to one agent, it spawns the crew

---

## Phase 3: Validation

### No-Mistakes Pipeline (Kunchen)
Instead of manually reviewing diffs, run changes through the automated pipeline:

```
Branch → Commit → Isolated Worktree → Intent Analysis →
Rebase → Adversarial Review → E2E Testing → Documentation →
Lint → Push → PR → CI Babysitting
```

**Trigger:** `git push no-mistakes` or the `/no-mistakes` command.

**How it works with Matt's skills:**
- The adversarial review phase runs `/code-review` in a fresh context
- E2E testing follows the project's established testing patterns
- Documentation pass updates ADRs and project memory
- PR is babysat until merged

### Auto-Fix vs Escalation
- Obvious problems are auto-fixed
- Ambiguous product decisions are escalated to you (not silently resolved)
- Risk assessment helps you decide how much time to spend reviewing

---

## Phase 4: Autonomous & Overnight Runs

### gnhf (Kunchen)
For verifiable objectives that can run unattended:

```bash
gnhf "Increase end-to-end test coverage to 80%.
Each iteration: identify untested flows, write tests, verify they pass.
Stop when coverage reaches 80%."
```

- Each successful iteration is committed
- Configurable token caps and iteration limits
- Runs overnight — wake up to a branch of clean, documented work

---

## Phase 5: Review & Merge

### PR Review
1. Check the No-Mistakes evidence (screenshots, videos, logs)
2. Review the risk assessment to decide depth of review
3. For low-risk changes: trust the pipeline, merge directly
4. For high-risk changes: deep review the diff, request changes if needed

### Knowledge Capture
- If the agent made a mistake, add it to the project memory file
- Extract conditional knowledge into skills when it grows too large
- Run `/handoff` to compact sessions for handoff between agents

---

## Session Management

### Starting Work
```bash
# Single task
treehouse                    # Fresh worktree
/task "Build the feature..."

# Multiple parallel tasks
firstmate                    # Talk to one agent
"Implement feature A, fix bug B, and refactor module C"
```

### During Work
- **Voice input** for fast prompting (OpenSuperWhisper)
- **Lavish** for visual planning and decision-making
- **Matt's skills** for structured engineering tasks
- **Treehouse status** to see active worktrees

### Ending Work
```bash
# Validate and ship
/no-mistakes                 # Run full validation pipeline

# Or kick off overnight work
/gnhf                        # Autonomous agent loop
```

---

## Agent Skills Reference

### Model-Invoked (AI reaches for these automatically)
| Skill | Source | When Used |
|-------|--------|-----------|
| tdd | Matt | Building features or fixing bugs test-first |
| code-review | Matt | Reviewing changes |
| diagnosing-bugs | Matt | Debugging hard problems |
| domain-modeling | Matt | Pinning down terminology |
| codebase-design | Matt | Designing deep module interfaces |
| prototype | Matt | Answering a design question |
| research | Matt | Investigating a question against sources |
| resolving-merge-conflicts | Matt | Mid-merge/rebase conflict resolution |
| grilling | Matt | Stress-testing plans (reusable interview loop) |
| frontend-design | Local | Design router — picks hallmark or taste-skill based on project context |
| hallmark | Nutlope | Structured HTML/CSS design — 21 macrostructures, 20 themes, 58 slop tests |
| design-taste-frontend | Leonxlnx | Animated React/Next.js design — dial-driven, GSAP/Motion, anti-slop rules |
| lavish | Kunchen | Visualizing complex responses as HTML artifacts |
| no-mistakes | Kunchen | Validating changes through pipeline |
| gnhf | Kunchen | Setting up autonomous agent loops |
| axi | Kunchen | Designing agent-ergonomic tools |

### User-Invoked (you explicitly call these)
| Command | Source | Purpose |
|---------|--------|---------|
| /ask-matt | Matt | Router — which skill fits your situation |
| /grill-me | Matt | Stress-test a plan or idea |
| /grill-with-docs | Matt | Grill + create ADRs and glossary |
| /to-spec | Matt | Turn conversation into a spec |
| /to-tickets | Matt | Break spec into dependency-ordered tickets |
| /implement | Matt | Implement from spec/tickets |
| /triage | Matt | Categorize, verify, and brief issues |
| /wayfinder | Matt | Plan multi-session work |
| /handoff | Matt | Compact session for agent handoff |
| /teach | Matt | Learn a new concept |
| /design | Local | Frontend design router — picks hallmark or taste-skill based on project context |
| /lavish | Kunchen | Visual planning with HTML artifacts |
| /no-mistakes | Kunchen | Run validation pipeline |
| /gnhf | Kunchen | Start autonomous agent loop |

---

## Key Principles

1. **Never review diffs manually** — use No-Mistakes, review only the evidence and risk assessment
2. **Voice first, type only when needed** — 3x faster, less friction
3. **Plan visually when possible** — Lavish over text walls
4. **Keep memory files minimal** — move conditional knowledge into skills
5. **Parallelize fearlessly** — Treehouse + Firstmate make parallel work safe
6. **Trust the pipeline for low-risk changes** — your time is better spent on direction-setting
7. **Don't trust popular skills blindly** — evaluate them, don't install based on stars
8. **AI codes faster than humans** — don't let "development cost" bias technical decisions toward low-quality shortcuts
