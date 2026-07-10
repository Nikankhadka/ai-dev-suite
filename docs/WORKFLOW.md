# The Captain's Workflow

A step-by-step development workflow following Kun Chen's agent engineering method, adapted to this AI Dev Suite. Each section maps to a video chapter. Read top to bottom the first time, then use it as a quick-reference.

---

## The big picture (60 seconds)

```
You are the CAPTAIN. Your agents are CREWMATES.
Your job: plan the mission, divide the work, hold the quality bar.
Their job: do the actual coding, testing, reviewing, and shipping.

One command to remember for daily work: /ship
```

The workflow has 5 levels. Master each level before moving to the next:

```
Level 1 - Single crewmate         /ship
Level 2 - Parallel crewmates      /ship + treehouse
Level 3 - Overnight crew          gnhf
Level 4 - First mate              /firstmate
Level 5 - Captain's mindset       (you, thinking about what matters)
```

---

## Level 1: Single Crewmate

Everything starts here. One agent, one task, one clean pipeline.

### Step 1: Set sail in your project

```bash
cd ~/your-project
opencode        # or: claude / codex
```

First time? Initialize the project so the agent knows the stack:

```
/init-project
```

This detects your language, framework, and tooling. Writes `AGENTS.md` with verified commands so the agent never guesses. You only do this once per project.

### Step 2: Talk to your agent

**Use voice input if you can.** Talking is 3x faster than typing (Stanford study). Install [Open Super Whisper](https://github.com/nicoverbruggen/OpenSuperWhisper) for local, free transcription. Add your project vocabulary to its system prompt for better accuracy.

When voice is impractical (URLs, file paths), type instead.

### Step 3: Give the task - /ship

This is the core of the workflow. One command replaces manual planning, coding, reviewing, and testing:

```
/ship Add a dark mode toggle to the settings page
```

What runs behind the scenes (you do not need to memorize this):

```
spec (optional) -> plan -> build -> review -> test -> docs -> release (optional)
```

Each stage has a hard gate. If one fails, the pipeline stops and tells you what went wrong. You never get broken code shipped under your name.

**For bigger features**, plan visually first with lavish:

```
I want to consolidate the "What I Can Do" and "My Progress" buttons
into an achievement system. Come up with some options and let's discuss.
```

The agent will generate an interactive HTML page in your browser instead of a wall of terminal text. You annotate specific parts, click to make decisions, and send feedback - all without leaving the browser. When you are happy, say "start building" and the agent runs `/ship` on the agreed plan.

**For smaller tasks**, use standalone commands:

| Command | When |
|---|---|
| `/plan <feature>` | Plan without building yet |
| `/test <requirement>` | Write tests or fix a bug test-first |
| `/review` | Quick quality check on recent changes |
| `/maintain` | Clean up dead code, refresh docs |

### Step 4: Validate before push

When the agent says "done", do not start reviewing diffs manually. That becomes a bottleneck at scale. Instead, run the validation pipeline:

```
/nomistakes
```

This runs in an isolated worktree (your working directory is never affected) and does:

```
branch -> commit -> rebase -> adversarial review -> E2E test -> docs -> lint -> PR
```

**While it runs, go work on something else.** When it finishes, you get a PR with:
- What the original intent was
- What changed
- Test evidence (screenshots, logs, video)
- Risk assessment (low / medium / high)

Review the risk assessment first. For low-risk changes, a quick scan is enough. For high-risk changes, do a full diff review. This is how you scale without losing quality control.

### Step 5: Build your project memory

Every time the agent makes a mistake, correct it and tell it to remember:

```
Remember this in .agents/memory.md: the build command is "npm run build", not "make"
```

Over time, your crewmates get smarter about your specific project without you repeating yourself. When your memory file gets bloated with conditionally useful information (like E2E testing instructions that are only needed when making code changes), ask the agent to extract it into a skill:

```
Extract the E2E testing instructions from our AGENTS.md into a project-level skill.
```

Skills load on demand - the agent only reads them when it decides it needs them. This keeps your system prompt lean while keeping knowledge accessible.

---

## Level 2: Parallel Crewmates (Treehouse)

When you have 2 or 3 tasks at once, running them sequentially is slow. Run them in parallel with isolated worktrees.

### The problem

Two agents editing the same repo directory will conflict with each other. You need each agent in its own isolated copy.

### The solution: treehouse

**Tab 1** - Task A:
```bash
cd ~/your-project
treehouse           # creates an isolated worktree, drops you in
opencode
/ship Fix the voice input popover for kids
```

**Tab 2** - Task B:
```bash
cd ~/your-project
treehouse           # another isolated worktree
opencode
/ship Add screenshot action to image attachment menu
```

**Tab 3** - Task C:
```bash
cd ~/your-project
treehouse           # yet another worktree
opencode
/ship Fix the agent status bar to always show bot activity
```

All three agents run simultaneously and never step on each other. When you are done with a tab, just close it - treehouse recycles the worktree automatically.

**Check what is running:**
```bash
treehouse status
```

**Switch between tabs** using tmux keyboard shortcuts. Keep your hands on the keyboard.

> **Tip**: tell each agent to run `/nomistakes` after implementation so it validates and creates a PR while you keep working on the next task.

---

## Level 3: Overnight Crew (gnhf)

Some tasks do not need your supervision. These are perfect for running while you sleep or focus on something else.

### Good use cases

- "Pretend you are a user and find usability problems. Fix each one you find."
- "Reduce page load time below 2 seconds."
- "Add E2E test coverage for all existing features."
- "Refactor any code that has obvious quality issues."

### How to run it

```bash
cd ~/your-project
gnhf "Pretend you are a 7 year old kid using the app end to end.
Try different things. Find the first usability problem that would
confuse you or stop you from knowing how to proceed.
If you find a problem, stop and fix it, then rinse and repeat."
```

gnhf runs in a loop - it executes your objective, if successful it loops again, if stuck it tries a different approach, and continues until hitting a stop condition.

**Set limits to control cost:**
```bash
gnhf --max-iterations 10 "Add dark mode support to all pages"
```

**When you come back**, review the commits on the new branch and decide which ones to keep:
```bash
git log main..HEAD --oneline
```

---

## Level 4: First Mate (Orchestrator)

After juggling multiple parallel sessions for a while, context-switching between them gets exhausting. First Mate manages the crew for you.

### Setup (one time)

```bash
git clone https://github.com/kunchenguid/firstmate ~/firstmate
brew install tmux
```

### How to use

Tell First Mate what you need and it handles the rest:

```
/firstmate Add an update command to all three of my repos
```

First Mate will:
1. Break the task into parallel subtasks
2. Create worktrees via treehouse
3. Launch agents in each worktree
4. Run no-mistakes validation on each
5. Report back when all are done

It runs in a tmux session. You can watch progress or detach and come back later.

```bash
# Launch directly:
tmux new-session -s firstmate -c ~/firstmate

# Attach to an existing session:
tmux attach-session -t firstmate
```

**The sweet spot**: after using First Mate for a while, the bottleneck shifts from "how do I manage all these agents" to "what should I ask them to do next". That is when you know you have leveled up to true captain status.

---

## Level 5: Captain's Mindset

This is not a tool - it is a way of thinking.

### Where you spend your time

| Phase | Who does it | Your role |
|---|---|---|
| **Beginning** | Agent generates options via lavish | You clarify requirements, make design decisions |
| **Middle** | Agent codes, tests, reviews autonomously | You work on other tasks or think about strategy |
| **End** | Agent creates PR via no-mistakes | You review risk assessment, apply quality judgment |

The more time you free up in the middle, the more work you can do in parallel.

### What a great captain does

- **Talk to users** to understand what matters
- **Study the competitive landscape** to know what is worth building
- **Craft a clear treasure map** so your crew knows where to go
- **Hold the quality bar** at the end, not micromanage in the middle

### Technical decisions to remember

These rules are in your global memory (`instructions/AGENTS.md`) but worth understanding:

1. **Do not weight development cost heavily.** AI estimates tasks in days/weeks/months, but actually builds them in minutes. This biases the model toward cheap, low-quality solutions. Trust the agent to build things - focus on quality, not "ease of implementation."

2. **Bug fixes start with E2E reproduction.** Always reproduce the bug the way an end user would experience it first. Unit tests alone are not enough.

3. **Tool hierarchy matters.** Use native tools first, then Axi CLIs (token-cheap, no MCP round-trip), then MCP servers as a last resort. The wrong tool can 3x your token cost.

---

## Quick reference (the cheat sheet)

```
cd ~/your-project && opencode

# First time:
/init-project

# Daily work:
/ship <requirement>           # full pipeline
/ship <requirement> --auto    # skip plan-approval pause

# Before push:
/nomistakes

# Planning complex features:
(have a conversation, agent uses lavish automatically)

# Parallel work:
treehouse                     # in each tab, before launching agent

# Overnight:
gnhf "objective" --max-iterations 10

# Multiple tasks at once:
/firstmate <objective>

# Memory:
/memory                       # see what is recorded
/memory note <gotcha>         # teach the agent something
```

---

## Tool map

| Tool | What it does | When you use it |
|---|---|---|
| `/ship` | Full gated pipeline | Every non-trivial task |
| `/spec` | Product framing | Before `/ship` when scope is unclear |
| `/plan` | Implementation plan | When you want to plan without building |
| `/test` | TDD / E2E / bug repro | Writing tests or fixing bugs |
| `/review` | Code quality check | After writing code outside `/ship` |
| `/maintain` | Cleanup + docs refresh | Periodic maintenance |
| `/nomistakes` | Validation pipeline | Before every push to remote |
| `/gnhf` | Overnight autonomous loop | Tasks that do not need supervision |
| `/treehouse` | Pooled worktrees | Running multiple agents in parallel |
| `/firstmate` | Multi-agent orchestrator | When you want one command to manage many agents |
| `/memory` | Project memory management | When the agent keeps making the same mistake |
| `/docs` | Library/framework docs lookup | When you need current API docs |
| `/audit` | Suite/project drift check | Periodic health check |
| `lavish` | Interactive HTML planning | Complex features that need visual discussion |
