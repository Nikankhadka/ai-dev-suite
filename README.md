# AI Dev Suite

A complete, stack-agnostic agentic development workflow for a one-person team. Set it up once in `~/.config/opencode` and it works with OpenCode, Claude Code, and Codex CLI - same agents, commands, skills, and pipeline across every project.

No per-project setup beyond running `/init-project` in a new project.

> **If you're new to coding with AI agents**: this guide walks you through everything step by step. You don't need to know what an "agent harness" or "MCP server" is to get started.

---

## Table of contents

- [Prerequisites](#prerequisites)
- [Quick start](#quick-start)
- [Step-by-step setup](#step-by-step-setup)
  - [1. Clone and sync this suite](#1-clone-and-sync-this-suite)
  - [2. Install an agent harness](#2-install-an-agent-harness)
  - [3. Install Axi CLI tools](#3-install-axi-cli-tools)
  - [4. Install First Mate (optional)](#4-install-first-mate-optional)
  - [5. Set up voice input (optional)](#5-set-up-voice-input-optional)
  - [6. Configure global memory](#6-configure-global-memory)
  - [7. Create and use skills](#7-create-and-use-skills)
- [Day-to-day workflow](#day-to-day-workflow)
  - [Starting work in a project](#starting-work-in-a-project)
  - [Everyday work: the /ship pipeline](#everyday-work-the-ship-pipeline)
  - [Smaller tasks: standalone commands](#smaller-tasks-standalone-commands)
  - [Parallel work with Treehouse](#parallel-work-with-treehouse)
  - [Overnight tasks with gnhf](#overnight-tasks-with-gnhf)
  - [Before push: the no-mistakes pipeline](#before-push-the-no-mistakes-pipeline)
  - [Advanced: First Mate orchestrator](#advanced-first-mate-orchestrator)
- [Reference](#reference)
  - [Agents](#agents)
  - [Commands](#commands)
  - [Skills](#skills)
  - [Axi CLI tools](#axi-cli-tools)
  - [MCP Servers (fallback)](#mcp-servers-fallback)
  - [Cross-harness wiring](#cross-harness-wiring)
  - [Directory structure](#directory-structure)
- [Troubleshooting](#troubleshooting)
- [Maintenance and updates](#maintenance-and-updates)
- [License](#license)

---

## Prerequisites

Before you begin, make sure you have these installed:

| Tool | Why you need it | Install command |
|---|---|---|
| **Git** | Clone this repo and interact with GitHub | `brew install git` (macOS) |
| **Node.js** (v18+) | Most agent harnesses and CLI tools need it | `brew install node` (macOS) |
| **Homebrew** | Package manager for macOS | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |
| **npm** | Comes with Node.js - needed for some CLIs | (ships with Node.js) |
| **gh** (GitHub CLI) | Needed for GitHub operations (PRs, issues, auth) | `brew install gh` |

You should be comfortable running commands in a terminal. If you're new to terminal, spend 10 minutes learning: `ls`, `cd`, `mkdir`, `pwd`, and how to open a terminal window.

---

## Quick start

For the impatient - do these steps, then skip to [Day-to-day workflow](#day-to-day-workflow):

```bash
# 1. Clone this suite
git clone https://github.com/Nikankhadka/ai-dev-suite.git ~/.config/opencode

# 2. Enter the repo and run the installer
cd ~/.config/opencode && bash bin/sync-adapters.sh

# 3. Install an agent harness (choose one)
# OpenCode (recommended for beginners):
npm install -g @opencode-ai/cli

# ... or Claude Code:
npm install -g @anthropic-ai/claude-code

# ... or Codex CLI:
npm install -g @openai/codex

# 4. Start using it in any project
cd ~/your-project
opencode
# Then in the agent session, type: /init-project
# That's it!
```

**Next steps**: install the [Axi CLI tools](#3-install-axi-cli-tools) for a richer experience (parallel worktrees, overnight tasks, validation pipelines).

---

## Step-by-step setup

### 1. Clone and sync this suite

```bash
git clone https://github.com/Nikankhadka/ai-dev-suite.git ~/.config/opencode
cd ~/.config/opencode
bash bin/sync-adapters.sh
```

**What this does**: clones the suite and runs `sync-adapters.sh`, which:
- Creates symlinks so Claude Code and Codex CLI can read the same agents, commands, and skills as OpenCode
- Backs up any existing files that would be overwritten (appends `.pre-sync-adapters.bak`)

**Verify it worked**:

```bash
# Check the symlinks were created
ls -la ~/.claude/CLAUDE.md
# Should show: ~/.claude/CLAUDE.md -> ~/.config/opencode/instructions/RULES.md

ls -la ~/.agents/skills
# Should list several skills (stack-discovery, coding-standards, testing, etc.)
```

**Idempotent**: you can run `sync-adapters.sh` as many times as you want. It's smart about not breaking existing correct symlinks.

### 2. Install an agent harness

An "agent harness" is the program that runs the AI agent. Think of it as your copilot - it reads your instructions, talks to the AI model, and helps you write code. You only need **one** of these.

#### OpenCode (recommended for beginners)

OpenCode has a clean interface, works with many AI models, and auto-discovers agents/commands from this suite with zero config.

```bash
npm install -g @opencode-ai/cli
```

**Verify**:
```bash
opencode --version
# Should print a version number like 1.x.x
```

**Start a session**:
```bash
cd ~/your-project
opencode
```

#### Claude Code

Claude Code is Anthropic's official agent. It only works with Claude models.

```bash
npm install -g @anthropic-ai/claude-code
```

**Verify**:
```bash
claude --version
```

**Start a session**:
```bash
cd ~/your-project
claude
```

> Note: Claude Code requires an Anthropic API key or a Claude subscription.

#### Codex CLI

Codex CLI is OpenAI's agent. It only works with OpenAI models.

```bash
npm install -g @openai/codex
```

**Verify**:
```bash
codex --version
```

**Start a session**:
```bash
cd ~/your-project
codex
```

> Note: Codex CLI requires an OpenAI API key.

### 3. Install Axi CLI tools

Axi tools are a family of CLI utilities designed specifically for agents - they use less tokens, are faster, and have better agent ergonomics than equivalents like MCP servers. They power features like parallel worktrees, overnight tasks, and validation.

Install them with **one command** (using the Hermes package manager):

```bash
# Install Hermes (manages the axi CLI tools):
curl -fsSL https://hermes.axi.sh/install.sh | bash

# Then install the tools via Hermes:
hermes install gh-axi chrome-devtools-axi gnhf quota-axi
```

Alternatively, install `treehouse` and `no-mistakes` separately:

```bash
# Treehouse (Go-based git worktree manager):
go install github.com/kunchenguid/treehouse@latest

# No Mistakes (validation pipeline):
curl -fsSL https://no-mistakes.axi.sh/install.sh | bash
```

**Verify all tools are installed**:

```bash
command -v gh-axi      # GitHub code search, PRs, issues
command -v chrome-devtools-axi  # browser automation for agents
command -v gnhf        # overnight autonomous coding loops
command -v quota-axi   # LLM quota visibility
command -v no-mistakes # validation pipeline before push
command -v treehouse   # pooled git worktrees for parallel agents
```

Each should print a path like `/Users/you/.local/bin/gh-axi`.

**Note**: `gh-axi` needs GitHub authentication:

```bash
gh auth login
# Follow the prompts to authenticate
```

**What each tool does**:

| Tool | What it's for | When you'll use it |
|---|---|---|
| `gh-axi` | Search GitHub code, manage PRs/issues | First choice for looking up code examples |
| `chrome-devtools-axi` | Control a browser from the agent | When the agent needs to test a web UI |
| `gnhf` | "Good Night, Have Fun" - overnight task loop | When you want the agent working while you sleep |
| `quota-axi` | Check your LLM API usage/quotas | To see how many tokens you've used |
| `no-mistakes` | Validation pipeline: review, test, docs, lint, PR | Before pushing code to GitHub |
| `treehouse` | Manage "work trees" - independent copies of your repo | When running multiple agent tasks in parallel |

### 4. Install First Mate (optional)

First Mate is an orchestrator that manages multiple agents for you. Instead of launching agent sessions one by one, you tell First Mate what you need and it handles the rest.

> This is an **advanced** tool. Skip it until you're comfortable with the basics.

```bash
# Clone First Mate
git clone https://github.com/kunchenguid/firstmate ~/firstmate

# First Mate needs tmux (terminal multiplexer)
brew install tmux

# It also needs treehouse and no-mistakes (see step 3)
```

**Launch First Mate**:

```bash
tmux new-session -s firstmate -c ~/firstmate
```

Then follow the prompts inside the tmux session.

**Verify**:
```bash
test -d ~/firstmate && echo "First Mate is ready"
# Should print: First Mate is ready
```

### 5. Set up voice input (optional)

You can talk to your agent instead of typing. Voice is about 3x faster than typing (proven in a Stanford study).

**Install Open Super Whisper** (free, open-source, runs locally on your machine):

```bash
# Download from the GitHub releases page:
# https://github.com/nicoverbruggen/OpenSuperWhisper/releases
# Or install via Homebrew if available:
# brew install --cask open-super-whisper
```

Open the app, then in its settings:
1. Go to the transcription settings
2. Find the "Initial Prompt" or system prompt field
3. Add vocabulary specific to your projects (helps with accuracy):

```
common vocabulary: API, npm, git, GitHub, TypeScript, JavaScript, Python, React, Next.js, Node.js, WebSocket, CLI, JSON, YAML, Docker, Tailwind, PR, CI, CD, frontend, backend, database, schema, migration, endpoint, middleware, async, await, callback, promise, module, import, export, default, config, deploy, build, lint, test, debug, refactor, merge, rebase, commit, push, pull, branch, stash, revert, reset, cherry-pick, workflow, pipeline, agent, harness, harnesses, tmux, Neovim, WezTerm, opencode, codex, axiom, axi, treehouse, gnhf, no-mistakes, firstmate, lavish
```

**Use it**: when your agent session is waiting for input, speak instead of typing. The transcribed text appears in the input field.

### 6. Configure global memory

"Memory" is how you teach your agents your preferences and conventions. There are two levels:

#### Global memory (applies to every project)

This lives in `~/.config/opencode/instructions/RULES.md` and `~/.claude/CLAUDE.md` (which are symlinked together). Every agent session reads this file.

The sync script already set this up. You can see what's in it:

```bash
cat ~/.config/opencode/instructions/RULES.md
```

It contains rules like:
- Never use em dashes "-" (use plain dashes)
- Never auto-add agent name as co-author in commits
- Prefer quality over development cost
- Start bug fixes with end-to-end reproduction

**Edit it**: add your own preferences. Keep it short (under 30 lines) to save tokens:

```bash
echo "- Always use single quotes in JavaScript/TypeScript" >> ~/.config/opencode/instructions/RULES.md
```

> **Tip**: don't put too much in the global file. Project-specific things go in the project memory (next section).

#### Project memory (applies to one project)

When you run `/init-project` in a project, it creates:
- `AGENTS.md` - the main project instructions
- `.agents/memory.md` - session-learned facts (updated as you work)
- `.agents/map.md` - auto-generated project structure map

**How to use it**: as you work and notice the agent making the same mistake, tell it to "remember this in `.agents/memory.md`". Over time, the agent gets smarter about your specific project without you repeating yourself.

You can also use the `/memory` command inside an agent session:
```
/memory                      # show what's recorded
/memory note The build command is "npm run build" not "make"
/memory promote <topic>      # move a helpful rule to the global file
```

### 7. Create and use skills

Skills are bundles of instructions that only load when needed. Unlike memory files (which are always loaded), skills are "progressive disclosure" - the agent only sees a one-line description until it decides to use the skill. This saves tokens and keeps the agent focused.

**Skills included in this suite**:

| Skill | What it does |
|---|---|
| `stack-discovery` | Detects what language/framework a project uses instead of guessing |
| `coding-standards` | Naming, readability, error handling, security basics |
| `testing` | Test-driven development methodology (RED-GREEN-REFACTOR) and E2E testing |
| `lavish` | Creates interactive HTML planning pages for designing features |
| `strategic-compact` | When to suggest manually compacting the conversation to save context |

**Installing the Skill Creator** (for making your own skills):

```bash
# Vercel's npc tool helps install skills from the registry
npm install -g @vercel/npc

# Install the Skill Creator skill so your agent learns to create skills:
npc install skill-creator
```

**Creating a skill**: ask your agent to create one. Example:

> "Extract the E2E testing instructions from our AGENTS.md into a project-level skill."

The agent will create the skill file and update your memory to reference it instead.

**Where skills live**:
- Global skills: `~/.config/opencode/skills/<name>/SKILL.md`
- Project skills: `your-project/.agents/skills/<name>/SKILL.md`

> **Warning**: don't install random skills from the internet, even popular ones. Some skills are security risks (they can run arbitrary commands) or actually degrade performance. Stick to skills from trusted sources.

---

## Day-to-day workflow

This section shows you how a typical work session looks, from starting your agent to shipping code.

### Starting work in a project

```bash
cd ~/your-project
opencode   # or: claude / codex
```

**First time in this project?** Run:
```
/init-project
```
This detects your project's stack (language, framework, build tools), generates `AGENTS.md` with verified commands, creates a project map, and symlinks `CLAUDE.md -> AGENTS.md`. Commit the generated files to git.

### Everyday work: the /ship pipeline

For any non-trivial change, run `/ship` with your requirement:

```
/ship Add a dark mode toggle to the settings page
```

This runs a **gated pipeline** with up to 7 stages:

```
spec (optional) -> plan -> build -> review -> test -> docs -> release (optional)
```

Each stage has a gate that must pass before the next stage starts. If a stage fails after 3 attempts, the pipeline stops and reports what went wrong.

**What happens in each stage**:

1. **Plan** - The `planner` agent (read-only) analyzes the requirement, checks existing code for patterns, and produces a numbered plan with files to modify, acceptance criteria, and a test list. You approve before it proceeds.

2. **Build** - Implements the plan test-first. Runs build/lint/typecheck commands to verify.

3. **Review** - The `reviewer` agent checks for security issues, bugs, and code quality problems. Fixes critical/high issues automatically.

4. **Test** - Runs the full test suite plus E2E tests for the affected flow. No skipping or deleting tests.

5. **Docs** - Updates the project map and memory with what was learned.

6. **Release** (optional with `--release`) - Creates a PR using the `no-mistakes` pipeline.

After a ship, the agent emits a report table:

```
| Stage | Gate | Result |
|-------|------|--------|
| Plan  | G1   | PASS   |
| Build | G2   | PASS   |
| ...   | ...  | ...    |
```

### Smaller tasks: standalone commands

Not everything needs the full `/ship` pipeline. For focused work:

| Command | When to use | Example |
|---|---|---|
| `/plan` | Planning a complex feature without building yet | `/plan Add semantic search` |
| `/test` | Writing tests or fixing a bug test-first | `/test e2e Checkout flow` |
| `/review` | Quick code quality check on recent changes | `/review` (no args needed) |
| `/maintain` | Clean up dead code, refresh docs/memory | `/maintain` |
| `/docs` | Look up library/framework documentation | `/docs How to configure middleware in Express` |

### Parallel work with Treehouse

When you want to work on multiple things at the same time without agents stepping on each other:

```bash
# Inside your repo, run:
treehouse

# This creates an isolated copy of your repo (a "work tree")
# and drops you into it. You can run an agent here independently.

# Check all your work trees:
treehouse status

# When done, just close the terminal tab - treehouse recycles it
```

**Inside the work tree**, start an agent as usual:
```bash
cd ~/your-project-tree-1
opencode
# Work on task 1
```

Then in **another terminal tab**, do it again:
```bash
cd ~/your-project
treehouse
# Creates work tree 2, drops you in
opencode
# Work on task 2
```

The agents work on separate copies of your repo and never conflict.

> **Tip**: use this with tmux tabs for maximum efficiency. Each tab = one parallel agent.

### Overnight tasks with gnhf

"Good Night, Have Fun" runs agents autonomously in a loop until a stop condition is met. Perfect for tasks that don't need your supervision.

```bash
# Inside your repo:
gnhf "Pretend you are a user and find usability problems. Fix each one you find."
```

gnhf will:
1. Execute your objective
2. If successful, loop and do it again
3. If stuck, try a different approach
4. Continue until hitting a token cap, iteration limit, or stop condition

**Good use cases**:
- "Find and fix usability problems in the app"
- "Reduce page load time below 2 seconds"
- "Add E2E test coverage for all existing features"
- "Refactor any code that has obvious quality issues"

You can set limits to control cost:
```bash
gnhf --max-iterations 10 "Add dark mode support to all pages"
```

### Before push: the no-mistakes pipeline

After the agent says it's done, run the No Mistakes pipeline before pushing:

```
/nomistakes
```

This runs in an **isolated work tree** (so nothing affects your working directory) and:
1. Creates a branch and commits your changes
2. Rebases on the latest main branch, resolving conflicts
3. Runs an adversarial code review in a fresh context (catches most issues)
4. Tests the change end-to-end against the original intent (records screenshots/logs as evidence)
5. Updates documentation
6. Runs linting
7. Pushes to remote and creates a PR

**While it's running**, go work on something else. When it finishes, you get a PR with:
- Original intent summary
- What changed
- Test evidence (screenshots, logs, videos)
- Risk assessment (low/medium/high)
- Any problems it found and fixed

**Reviewing the PR**: look at the risk assessment first. For low-risk changes, a quick scan is usually enough. For high-risk changes, do a full diff review.

> This is how you scale: instead of reviewing every line of code, you review PRs. The pipeline catches most issues automatically.

### Advanced: First Mate orchestrator

First Mate is your "first mate" - instead of you managing multiple agent sessions, First Mate does it for you.

```
/firstmate Add an update command to all three of my repos
```

First Mate will:
1. Break the task into parallel subtasks
2. Create work trees via Treehouse
3. Launch agents in each work tree
4. Run No Mistakes validation on each
5. Report back when all are done

It runs in a tmux session, so you can watch progress or detach and come back later.

```bash
# Launch First Mate:
tmux new-session -s firstmate -c ~/firstmate

# Or from inside an agent session:
/firstmate <your objective>
```

> **Tip**: after using First Mate for a while, the bottleneck shifts from "how do I manage all these agents" to "what should I ask them to do next" - that's the sweet spot.

---

## Reference

### Agents

| Agent | Mode | Use for |
|---|---|---|
| `build` | primary | Day-to-day coding; dispatches the other four, mainly via `/ship` |
| `planner` | subagent, read-only | Implementation plans before non-trivial changes |
| `reviewer` | subagent | Code quality, security, build-error review |
| `tester` | subagent | Test-first implementation and E2E bug repro |
| `maintainer` | subagent | Dead-code cleanup, doc/map/memory refresh |

### Commands

| Command | Agent | Purpose |
|---|---|---|
| `/ship` | build | Full gated pipeline: spec (optional) -> plan -> build -> review -> test -> docs -> release (optional) |
| `/spec` | build | Product framing: problem, target user, success criteria, scope; writes to `docs/specs/` |
| `/plan` | planner | Implementation plan; waits for approval before code |
| `/test` | tester | TDD, E2E, bug repro, or coverage check |
| `/review` | reviewer | Quality/security/build-error review |
| `/maintain` | maintainer | Dead code, duplicates, doc/map/memory refresh |
| `/firstmate` | build | Launch a firstmate tmux orchestration session for parallel agent crew |
| `/init-project` | build | Generate `AGENTS.md` + `.agents/` for a project |
| `/audit` | build | Drift check for this suite, or for a project's `AGENTS.md`/`.agents/` freshness |
| `/memory` | build | Read/write `.agents/memory.md` |
| `/docs` | build | Library/framework docs lookup, cheapest source first |
| `/nomistakes` | build | `no-mistakes` CLI validation pipeline |
| `/gnhf` | build | `gnhf` CLI autonomous overnight loop |
| `/treehouse` | build | `treehouse` CLI pooled git worktrees |

### Skills

| Skill | Description | Loads when |
|---|---|---|
| `stack-discovery` | Runtime protocol for detecting a project's language/tooling instead of assuming one | Starting work in a project without a mapped AGENTS.md |
| `coding-standards` | Stack-agnostic naming, readability, immutability, error-handling, security-basics | Writing or reviewing code |
| `testing` | TDD (RED-GREEN-REFACTOR) and E2E methodology, stack-agnostic | Writing tests, fixing bugs, or doing E2E work |
| `lavish` | Interactive HTML planning artifacts for complex feature design | Planning complex features |
| `strategic-compact` | When to suggest manual compact at task boundaries | Long sessions approaching context limits |

### Axi CLI tools

| Tool | What it does | Install |
|---|---|---|
| `gh-axi` | GitHub code search, PRs, issues - first choice over MCP | `hermes install gh-axi` |
| `chrome-devtools-axi` | Agent-ergonomic browser automation | `hermes install chrome-devtools-axi` |
| `gnhf` | Overnight autonomous coding loops | `hermes install gnhf` |
| `quota-axi` | LLM quota visibility across providers | `hermes install quota-axi` |
| `no-mistakes` | Validation pipeline before push | `curl -fsSL https://no-mistakes.axi.sh/install.sh \| bash` |
| `treehouse` | Pooled git worktrees for parallel agents | `go install github.com/kunchenguid/treehouse@latest` |

### MCP Servers (fallback)

| Server | Tools | When to use |
|---|---|---|
| `context7` | `resolve-library-id`, `get-library-docs` | Current library docs, only after `gh-axi` doesn't answer it |
| `gh_grep` | GitHub code search | Fallback when `gh-axi` is unavailable |

**Tool hierarchy**: native harness tools (fastest, cheapest) -> Axi CLIs (token-efficient, no MCP round-trip) -> MCP servers (last resort)

### Cross-harness wiring

Created by `bin/sync-adapters.sh`. These symlinks make Claude Code and Codex CLI read the same config as OpenCode:

| Link | Target |
|---|---|
| `~/.claude/CLAUDE.md` | `instructions/RULES.md` |
| `~/.claude/commands` | `commands/` (whole directory) |
| `~/.claude/agents` | `adapters/claude/agents/` (generated) |
| `~/.claude/skills/<name>` | `skills/<name>/` (one per skill) |
| `~/.codex/AGENTS.md` | `instructions/RULES.md` |
| `~/.codex/prompts` | `commands/` (whole directory) |
| `~/.agents/skills/<name>` | `skills/<name>/` (one per skill) |

### Directory structure

```
~/.config/opencode/
├── opencode.jsonc            # OpenCode config (instructions, LSP, MCP)
├── instructions/
│   ├── RULES.md              # Cross-harness rules (loaded every session)
│   └── OPENCODE.md           # OpenCode-specific notes
├── agents/                   # 5 agent definitions (auto-discovered)
├── commands/                 # 14 command definitions
├── skills/                   # 5 on-demand skills
├── templates/                # AGENTS.md.template, memory.md.template
├── adapters/claude/agents/   # Claude Code agent files (generated - don't edit)
├── bin/sync-adapters.sh      # Installs symlinks for all harnesses
└── docs/
    ├── DEVELOPMENT.md        # Detailed command usage guide
    └── EVALS.md              # How this suite is verified
```

---

## Troubleshooting

**"command not found" for an axi CLI tool**
The tool isn't on your PATH. Add `~/.local/bin` to your PATH:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**`/ship` says "Run /init-project first"**
You haven't initialized this project yet. Run `/init-project` in the agent session.

**`gh-axi` says "not authenticated"**
Run `gh auth login` and follow the prompts.

**`tmux` not found when using firstmate**
Install tmux: `brew install tmux`

**`sync-adapters.sh` gives permission errors**
Make the script executable: `chmod +x bin/sync-adapters.sh`

**Voice input not working**
- Make sure Open Super Whisper is running
- Check microphone permissions in System Settings > Privacy & Security > Microphone
- Make sure the app is selected as the input device

**Agents stepping on each other (editing the same file)**
Use Treehouse to create isolated worktrees:
```bash
treehouse   # creates a fresh copy of the repo
```

**OpenCode doesn't show slash commands**
Make sure the `commands/` directory is present in `~/.config/opencode/commands/`. Run `bash bin/sync-adapters.sh` to regenerate.

**I broke something and need to start fresh**
```bash
cd ~/.config/opencode && git pull && bash bin/sync-adapters.sh
```

---

## Maintenance and updates

```bash
# Update the suite
cd ~/.config/opencode && git pull && bash bin/sync-adapters.sh

# Check for drift (broken symlinks, stale files, etc.)
opencode -c ~/.config/opencode   # or any project
# Then run: /audit
```

Run `/audit` periodically to check:
- All referenced files exist
- Symlinks are valid
- No stale generated adapter files
- No em dashes sneaked in
- Axi CLI tools are installed

---

## License

MIT
