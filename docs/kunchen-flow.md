# Kunchen Development Flow

A summary of the agent-assisted development workflow used by [Kun Chen (kunchenguid)](https://github.com/kunchenguid), extracted from his workflow walkthrough.

## Core Philosophy

**Think of yourself as an engineering director, not a developer.** Your job is not to review every line of code - it's to create good processes and culture, then rely on your crew of AI agents to carry them out. The bottleneck must shift from code review to strategic direction.

---

## 1. Memory Files

Two tiers of memory, progressively disclosed:

### Global Memory (~27 lines)
Loaded into every agent session across all projects. Keep it minimal - only personal preferences:

```
- Never use the em dash (U+2014). Use plain dash "-" instead
- When writing commit messages, NEVER auto-add your agent name as co-author
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated
- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- For one-off or infrequent operational work, start with the simplest direct end-to-end path.
  Do not build wrappers, control planes, policy layers, custom verifiers, or automation unless
  the direct path exposes a concrete blocker or repeated need that justifies the added machinery.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned
  with how an end user would experience it as possible.
- When end-to-end testing a product, be picky about the UI and be obsessed with pixel perfection.
  If something clearly looks off, even if not directly related, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness.
  If you see one, even if not caused by your work, still get it fixed.
- Before using "dynamic workflows", "ultra code" or any harness feature that immediately spawns
  a large swarm of subagents, always explain the tradeoffs and ask for explicit approval.
```

File location: `~/.claude/CLAUDE.md` (symlinked to `~/.agents/CLAUDE.md` so both point to the same file). Use the command `ln -sfn ~/.claude/CLAUDE.md ~/.agents/CLAUDE.md` to keep them in sync.

### Project Memory
Per-project file (`AGENTS.md` / `CLAUDE.md`), built incrementally:
- Project context and repo layout
- Terminology glossary
- Component architecture
- End-to-end testing instructions
- Conventions and gotchas

**Every time the agent makes a mistake, correct it and ask it to store the learning in the project memory file.** Over time, agents working in that project get smarter.

### Skills (for conditional knowledge)
Move situationally-useful knowledge from memory files into skills. Skills use progressive disclosure:
- Only the description is loaded into the system prompt
- The full content is loaded only when the agent decides it needs the skill
- This prevents token waste on irrelevant context

**Install skills with:** `npx skills add <repo>`

**Rule of thumb:** Don't install random skills from the internet. Popularity does not equal quality. Only install skills that have been rigorously evaluated.

---

## 2. Voice Input

Voice is 3x faster than typing (backed by Stanford research). Use:

- **[OpenSuperWhisper](https://github.com/superduper-ai/OpenSuperWhisper)** - free, open-source, local whisper transcription
- Customize the transcription model's system prompt with your common vocabulary (project names, technical terms)
- Fall back to typing only for URLs and file paths

---

## 3. Agent Ergonomics (AXI)

[AXI](https://axi.md) is a set of 10 principles for building agent-ergonomic CLI tools. Key insight: tool design dramatically affects agent performance.

| Approach | Token Cost | Latency | Success Rate |
|----------|-----------|---------|-------------|
| GitHub MCP | 3x baseline | 2x baseline | Lower |
| GitHub CLI | 1x baseline | 1x baseline | Baseline |
| **GitHub AXI** | **0.6x baseline** | **Faster** | **100%** |

**When giving tools to agents, do research on their efficiency.** Prefer AXI-compliant tools over MCP servers. The 10 principles include:
- Token-efficient output formats (TOON vs JSON - 40% token savings)
- Machine-parseable output over human-readable prose
- Single-responsibility commands
- Progressive disclosure in help output

---

## 4. Planning with Lavish

Instead of reading walls of text in the terminal, use **[Lavish](https://github.com/kunchenguid/lavish-axi)** to generate interactive HTML artifacts:

1. Agent generates an HTML artifact visualizing options, plans, or comparisons
2. Opens in the browser via `npx -y lavish-axi <file.html>`
3. User annotates specific elements, makes decisions, and sends feedback
4. Agent incorporates feedback and rebuilds

Lavish uses the project's design system so artifacts look consistent with the actual app. Supports Mermaid diagram whiteboards for architecture discussions.

---

## 5. Validation with No-Mistakes

When the agent says it's done, don't review the diff manually. Send it through the **[No-Mistakes](https://github.com/kunchenguid/no-mistakes)** pipeline:

```
Branch → Commit → Isolated Worktree → Intent Analysis → Rebase →
Adversarial Review → E2E Testing → Documentation → Linting →
Push → PR → CI Babysitting
```

Key features:
- All validation runs in an isolated worktree (never touches your repo)
- Adversarial review catches obvious problems and auto-fixes them
- Ambiguous product decisions are escalated to you (not auto-resolved)
- E2E testing records evidence (screenshots, videos, logs)
- Documentation is auto-updated
- PR is babysat until merged (merge conflicts, CI failures)

**Trigger with:** `git push no-mistakes` or the `/no-mistakes` skill.

**Risk assessment:** For low-risk changes, the pipeline catches everything you would. Only spend review time on high-risk changes.

---

## 6. Long-Running Tasks with gnhf

**[gnhf](https://github.com/kunchenguid/gnhf)** ("good night, have fun") runs agents autonomously for hours:

```bash
gnhf "Pretend you are a 7-year-old kid and use the app end-to-end.
Find usability problems that would confuse you. If you find one, fix it.
Rinse and repeat."
```

Features:
- Token caps and iteration caps
- Stop conditions (natural-language)
- Each successful iteration is committed
- Can run overnight - wake up to a branch of clean work

**Best for:** verifiable objectives (reducing page load time, increasing test coverage, auto-research), or judgment-based tasks where you trust the agent's evaluation.

---

## 7. Parallel Worktrees with Treehouse

Run multiple agents in parallel without conflicts using **[Treehouse](https://github.com/kunchenguid/treehouse)**:

```bash
treehouse          # Drop into a fresh worktree
treehouse status   # List all worktrees (active vs idle)
```

- Each agent gets its own isolated worktree
- Idle worktrees are reused (no repeated `git worktree add`)
- Closing a terminal tab frees the worktree for reuse
- No mental overhead tracking which worktree is doing what

---

## 8. Orchestration with Firstmate

**[Firstmate](https://github.com/kunchenguid/firstmate)** is the "first mate" - talk to one agent, ship with a crew:

```
"Add an update CLI command to lavish-axi, no-mistakes, and gnhf"
```

Firstmate:
1. Realizes this is 3 parallel tasks
2. Spawns tmux tabs for each
3. Creates worktrees via Treehouse
4. Runs agents in each worktree
5. Validates all changes through No-Mistakes
6. Presents finished PRs for review

**This is how you level up from sailor to captain.** You stop managing individual agent sessions and start giving direction to your first mate.

---

## The Captain's Mindset

Once you have a first mate managing your crew, the bottleneck shifts from task management to **direction-setting**:

1. Talk to users and understand what matters
2. Understand the competitive landscape
3. Craft a clear treasure map for your crew
4. Let the crew execute while you focus on the next destination

---

## Tools Summary

| Tool | Role | Install |
|------|------|---------|
| **OpenSuperWhisper** | Voice transcription | macOS app |
| **AXI** | Tool design principles | `npx skills add kunchenguid/axi` |
| **Lavish** | Visual planning | `npx -y lavish-axi` |
| **No-Mistakes** | Validation pipeline | `curl .../install.sh \| sh` |
| **gnhf** | Autonomous agent loops | `npm install -g gnhf` |
| **Treehouse** | Worktree management | `curl .../install.sh \| sh` |
| **Firstmate** | Agent orchestration | `git clone` + launch agent inside |

All tools are free and open source.
