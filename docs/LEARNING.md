# AI Dev Suite -- Concepts Explained (for juniors)

This document explains every major concept in this system from the ground up. Think of it as "what I wish someone told me before I started."

If you are a junior developer, read this first. Then go back to the README and the setup will make much more sense.

---

## Table of Contents

1. [The Big Picture](#1-the-big-picture)
2. [What is an AI Coding Agent?](#2-what-is-an-ai-coding-agent)
3. [Agent Harnesses (OpenCode, Claude Code, Codex CLI)](#3-agent-harnesses)
4. [Subagents (planner, reviewer, tester, maintainer)](#4-subagents)
5. [Commands and the /ship Pipeline](#5-commands-and-the-ship-pipeline)
6. [Skills -- Progressive Disclosure](#6-skills)
7. [Axi CLI Tools](#7-axi-cli-tools)
8. [Treehouse and Git Worktrees](#8-treehouse-and-git-worktrees)
9. [gnhf -- Overnight Autonomous Loops](#9-gnhf)
10. [First Mate -- The Orchestrator](#10-first-mate)
11. [The no-mistakes Pipeline](#11-the-no-mistakes-pipeline)
12. [MCP Servers (Model Context Protocol)](#12-mcp-servers)
13. [Cross-Harness Wiring and Symlinks](#13-cross-harness-wiring-and-symlinks)
14. [Memory -- Global vs. Project](#14-memory)
15. [Context Limits and Compaction](#15-context-limits-and-compaction)
16. [Spec-First Development](#16-spec-first-development)
17. [TDD -- Test-Driven Development](#17-tdd)
18. [The /audit Command and Drift](#18-the-audit-command-and-drift)
19. [Open Super Whisper -- Voice Input](#19-open-super-whisper)
20. [Glossary](#20-glossary)

---

## 1. The Big Picture

Imagine you are building a house.

- **You** are the architect. You decide what to build.
- **A construction crew** does the actual work. They are fast, but they need clear instructions.
- **An inspector** checks the work before it is finalized.
- **A tester** runs the plumbing to make sure it works.
- **A cleaner** tidies up after the work is done.

In software, **you** are still the architect. The AI coding agents are your construction crew. Each agent has a specific job. You tell them what to build, and they do the heavy lifting -- writing code, testing it, reviewing it, and maintaining it.

**The AI Dev Suite** is a collection of tools, configurations, and workflows that make this crew effective. It is not one product. It is a system you install and customize.

**The goal**: instead of writing every line of code yourself, you describe what you want, and the agents build it. You spend your time on decisions, not keystrokes.

---

## 2. What is an AI Coding Agent?

An AI coding agent is an AI model (like Claude or GPT) that has been given:

1. **Instructions** -- a file that describes how it should behave (its "personality" and rules)
2. **Tools** -- the ability to read files, write files, run commands, search the web, etc.
3. **Memory** -- a place to store facts it has learned about your project

When you type a message to the agent, it thinks about what to do, uses its tools to make changes, and replies with what it did.

**Key insight**: the agent is not magic. It follows instructions. If the instructions are bad, the agent will be bad. This suite gives the agent good instructions so you do not have to write them yourself.

### What agents are good at

- Writing boilerplate code
- Fixing bugs
- Writing tests
- Explaining code
- Refactoring
- Searching documentation

### What agents are bad at

- Making architectural decisions (that is your job)
- Understanding your business logic perfectly (you still need to verify)
- Remembering things across sessions (that is what memory files are for)

---

## 3. Agent Harnesses

An **agent harness** is the program that runs the AI agent. You type into it, it talks to the AI, and the AI uses tools through it.

Think of it like a web browser. Chrome, Firefox, and Safari all browse the web, but they look and work slightly differently.

Similarly, these harnesses all run AI coding agents:

| Harness | Made by | How you start it |
|---|---|---|
| **OpenCode** | Community | `opencode` |
| **Claude Code** | Anthropic | `claude` |
| **Codex CLI** | OpenAI | `codex` |

**This suite works with all three**. You can use whichever you prefer. The configuration is shared across all of them (this is called "cross-harness wiring" -- see section 13).

### Which one should you use?

- **OpenCode** -- lightweight, highly customizable, runs on any terminal. Good if you like tweaking things.
- **Claude Code** -- polished, well-supported, deeper integration with Claude. Good if you want things to "just work."
- **Codex CLI** -- newer, uses OpenAI models. Good if you prefer GPT over Claude.

You can also **switch between them** for different tasks. The suite adapts.

---

## 4. Subagents

A **subagent** is a specialized agent that only does one thing. The main agent (called "build") dispatches subagents when a specific skill is needed.

Think of it like a restaurant kitchen:

- **build** = the head chef. They coordinate everything and do the main cooking.
- **planner** = the prep cook. They read the recipe, check the pantry, and write down what needs to happen.
- **reviewer** = the food safety inspector. They check that nothing is burnt or undercooked.
- **tester** = the quality control person. They taste the food before it goes to the customer.
- **maintainer** = the cleaner. They wipe down counters and put ingredients away.

### The agents in detail

| Agent | Read-only? | What it does | When you use it |
|---|---|---|---|
| **build** | No (writes code) | Day-to-day coding, dispatches the others | Every session (this is your main agent) |
| **planner** | Yes (never writes) | Analyzes requirements, checks existing code, produces a numbered plan with files to modify and acceptance criteria | Before any non-trivial change |
| **reviewer** | Can fix critical issues | Checks for security flaws, bugs, code quality problems | After writing code |
| **tester** | No (writes tests) | Writes tests first (TDD), then the code to pass them, runs E2E flows | When adding features or fixing bugs |
| **maintainer** | Can fix issues | Removes dead code, consolidates duplicates, refreshes docs/map/memory | Periodically, or before wrapping up |

**How dispatching works**:

When you run `/ship Add dark mode`, the build agent:

1. Dispatches `planner` -- creates a plan
2. Shows you the plan -- you approve it
3. Builds the feature
4. Dispatches `reviewer` -- checks the code
5. Dispatches `tester` -- runs the tests
6. Dispatches `maintainer` -- updates docs/memory

Each subagent gets a **fresh context** -- it does not see the full conversation, only the relevant information it needs.

---

## 5. Commands and the /ship Pipeline

A **command** is a shortcut that tells the agent to run a specific workflow. Commands start with `/`.

Think of commands like VS Code快捷键. You could do everything by typing, but shortcuts make it faster.

### The most important command: /ship

`/ship` is the main workflow. It runs a **gated pipeline**:

```
spec (optional) -> plan -> build -> review -> test -> docs -> release (optional)
```

A **gated pipeline** means: each stage must pass before the next stage starts. If any stage fails, the pipeline stops and tells you what went wrong.

**Why a gated pipeline?** Because agents make mistakes. Without gates:
- The agent might skip writing tests
- The agent might introduce a security vulnerability
- The agent might leave dead code around

The gates protect you from these mistakes.

### All commands

| Command | What it does | When you use it |
|---|---|---|
| `/ship` | Full gated pipeline | Non-trivial changes |
| `/spec` | Write a product spec document | Before starting a feature |
| `/plan` | Create an implementation plan only | Planning without building yet |
| `/test` | Write tests or fix a bug test-first | Testing or debugging |
| `/review` | Quick code quality review | After writing code |
| `/maintain` | Clean up dead code, refresh memory | Before finishing a session |
| `/firstmate` | Launch First Mate orchestrator | Multi-project or parallel tasks |
| `/init-project` | Set up a new project for agents | First time in a project |
| `/audit` | Check for drift (broken things) | When things seem off |
| `/memory` | Read or write agent memory | To teach the agent something |
| `/docs` | Look up library documentation | When you need API docs |
| `/nomistakes` | Run no-mistakes validation | Before pushing to GitHub |
| `/gnhf` | Run gnhf autonomous loop | Boring repetitive tasks |
| `/treehouse` | Create isolated work tree | Parallel work |

---

## 6. Skills

A **skill** is a bundle of instructions that only loads when the agent needs it.

Think of skills like tool belts:

- When you are just walking around, you do not carry all your tools.
- When you need to hammer a nail, you grab the hammer.
- Skills work the same way. The agent only loads the skill when the task matches.

**Why not load everything at once?** Because AI agents have limited "context" (see section 15). Loading every instruction for every possible task would waste space and confuse the agent.

### Skills in this suite

| Skill | What it teaches the agent | When it loads |
|---|---|---|
| `stack-discovery` | How to detect what language/framework a project uses | Starting work in a new project |
| `coding-standards` | Naming conventions, error handling, security basics | Writing or reviewing code |
| `testing` | TDD methodology (RED-GREEN-REFACTOR) | Writing tests |
| `lavish` | How to create interactive HTML planning pages | Planning complex features |
| `strategic-compact` | When to suggest compacting the conversation | Long sessions |

### Global vs. project skills

- **Global skills** apply to every project. They live in `~/.config/opencode/skills/`.
- **Project skills** only apply to one project. They live in `your-project/.agents/skills/`.

### Creating your own skills

You can ask the agent to create a skill for you. For example:

> "Extract the E2E testing instructions from our AGENTS.md into a project-level skill."

The agent will create the skill file and update memory so it knows the skill exists.

**Important**: do not install random skills from the internet. Skills can run arbitrary commands, so a malicious skill could damage your system. Only use skills from trusted sources.

---

## 7. Axi CLI Tools

**Axi** is a framework for building AI-friendly command-line tools. Tools built with Axi have output that is easy for AI agents to parse (structured, predictable, no noise).

Think of Axi tools as "tools designed for robots, not humans." They are:

- **Token-efficient** -- they output only what is needed, no fancy formatting
- **Consistent** -- same structure every time
- **Composable** -- you can pipe them together

### Axi tools in this suite

| Tool | What it does | Why the agent uses it |
|---|---|---|
| `gh-axi` | GitHub search (code, PRs, issues) | First choice for finding code examples or checking PRs |
| `chrome-devtools-axi` | Browser automation | Taking screenshots, clicking buttons, testing UI |
| `gnhf` | Overnight autonomous loops | Running agents without supervision |
| `quota-axi` | LLM quota usage | Checking how many API calls you have left |
| `no-mistakes` | Validation pipeline | Checking changes before push |
| `treehouse` | Git worktrees | Creating isolated copies of a repo |

**Tool hierarchy**: the agent is programmed to use tools in this order, from cheapest to most expensive:

1. **Native harness tools** (built into the agent program) -- fastest, free
2. **Axi CLIs** (command line) -- token-cheap, no round-trip overhead
3. **MCP servers** (see section 12) -- last resort, highest overhead

---

## 8. Treehouse and Git Worktrees

**Treehouse** is a tool that creates isolated copies of your git repository called "worktrees."

### The problem Treehouse solves

Imagine you ask an agent to refactor authentication. While it is working, you realize you need to fix a quick bug in the same project. But the agent is editing files -- if you and the agent work at the same time, you will conflict.

**Treehouse solution**: the agent works in a separate copy of your repo. Your working directory is untouched.

### How it works

```bash
# Inside your repo:
treehouse

# This creates ~/your-project-tree-1 and puts you in it.
# Now you run the agent here.
# Your original project is untouched.
```

When you need another one:

```bash
# Open a new terminal
cd ~/your-project
treehouse   # creates worktree 2
```

### What is a worktree, technically?

A git worktree is a feature of git (not Treehouse). Normally, git only lets you have one copy of your repo checked out at a time. Worktrees let you check out multiple copies simultaneously, all sharing the same `.git` history.

Treehouse just makes this easier to manage. It:

- Creates the worktree
- Names it (e.g., `your-project-tree-1`)
- Drops you into it
- Recycles it when you are done

### Why this matters for junior devs

You do not need to understand how git worktrees work internally. Just know:

- `treehouse` = "give me a clean copy of my repo to work in"
- Safe for parallel work
- When done, close the terminal -- Treehouse recycles it

---

## 9. gnhf

**gnhf** stands for "Good Night, Have Fun." It is a tool that runs an AI agent in an autonomous loop until a stop condition is met.

### The problem gnhf solves

Some tasks are boring and repetitive but do not need human judgment:

- "Find and fix all linting errors"
- "Add type annotations to all functions"
- "Write E2E tests for every user flow"
- "Find and fix accessibility issues"

You do not want to sit there and supervise these. You want to start them and go to sleep (hence the name).

### How it works

```bash
gnhf "Find and fix any performance issues in the React components"
```

gnhf will:

1. Start an agent with your objective
2. When the agent finishes, check if the objective is met
3. If not fully met, start a new agent with a different approach
4. Continue until: token limit, iteration limit, or a stop condition

### Safety

You can set limits:

```bash
gnhf --max-iterations 10 "Add dark mode to all pages"
```

This runs at most 10 iterations, then stops. Good for controlling cost.

### When to use gnhf vs. /ship

- **/ship** -- when you want a structured, gated pipeline with review gates
- **gnhf** -- when you want an agent to just go do something unsupervised

Think of it like:

- `/ship` = "I want to carefully build a feature with quality checks"
- `gnhf` = "I want the agent to run wild on a boring task"

---

## 10. First Mate

**First Mate** is an orchestrator. Instead of you managing multiple agent sessions, First Mate does it for you.

### The problem First Mate solves

As you get more comfortable with agents, you will want to run multiple things in parallel:

- Update the API in repo A
- Fix a bug in repo B
- Add documentation in repo C

Normally, you would open three terminals and run three agents. First Mate automates this.

### How it works

You give First Mate a high-level objective:

```
/firstmate Add an update command to all three of my repos
```

First Mate:

1. Breaks the task into parallel subtasks
2. Creates worktrees via Treehouse (one per subtask)
3. Launches agents in each worktree
4. Runs no-mistakes validation on each result
5. Reports back when everything is done

It runs inside a `tmux` session, so you can watch progress or detach and come back later.

### What is tmux?

**tmux** is a terminal multiplexer. It lets you run multiple terminal sessions in one window, and keep them running even when you close the window.

Think of it like tabs in a browser, but for terminal sessions. When you use First Mate, it creates a tmux session with one tab per agent, so you can see what each one is doing.

### When to use First Mate

- You have 2+ repos that need similar changes
- You want to run a batch of unrelated tasks simultaneously
- You are comfortable with the basics and ready to scale up

---

## 11. The no-mistakes Pipeline

**no-mistakes** is a validation pipeline that runs before you push code to GitHub. It is the final safety net.

### Why do you need it?

Agents are not perfect. They can:

- Write code that does not compile
- Leave debug logs or secrets in the code
- Break existing tests
- Make changes you did not ask for

The no-mistakes pipeline catches these before they reach production.

### What it does

When you run:

```
/nomistakes
```

It:

1. **Creates a branch** from your changes
2. **Rebases** on the latest main branch (resolves conflicts)
3. **Runs an adversarial code review** -- a fresh agent looks at the code as if they are a security auditor looking for problems
4. **Tests the change** end-to-end against the original intent (records screenshots/logs as evidence)
5. **Updates documentation**
6. **Runs linting**
7. **Pushes to GitHub** and creates a PR

### The output

When it finishes, you get a PR with:

- **Summary** of what was changed and why
- **Test evidence** (screenshots, logs, videos)
- **Risk assessment** (low / medium / high)
- **Problems found and fixed**

### How to review the PR

- If **low risk**, a quick scan is usually enough
- If **high risk**, do a full diff review

### Why this matters

Instead of reviewing every line of code before pushing, you review PRs. The pipeline catches most issues automatically. This is how you scale as a developer -- you stop being the bottleneck.

---

## 12. MCP Servers

**MCP** stands for **Model Context Protocol**. It is a standard way for AI agents to talk to external tools and services.

Think of MCP servers like USB ports on a computer:

- Your computer has USB ports (MCP protocol)
- You plug in different devices (MCP servers) for different needs
- Each device does something specific

### How it works

```
Agent <--> MCP Protocol <--> MCP Server <--> External Service (e.g., GitHub, Docs)
```

The agent sends a request through the MCP protocol, the server translates it to the external service, and sends the result back.

### MCP servers in this suite

| Server | What it provides | When the agent uses it |
|---|---|---|
| `context7` | Library/framework documentation | When you ask for API docs (last resort) |
| `gh_grep` | GitHub code search | When `gh-axi` is unavailable (fallback) |

### Why use MCP servers last?

MCP servers have overhead:

1. The agent sends a request
2. The harness routes it to the MCP server
3. The MCP server processes it
4. The result comes back

Compare to Axi CLI tools, which run directly on your machine with no round-trip. Axi tools are faster and cheaper, so the agent uses them first.

---

## 13. Cross-Harness Wiring and Symlinks

**Cross-harness wiring** means: all three agent harnesses (OpenCode, Claude Code, Codex CLI) share the same configuration.

### The problem

Each harness looks for its configuration in a different place:

| Harness | Config location |
|---|---|
| OpenCode | `~/.config/opencode/` |
| Claude Code | `~/.claude/` |
| Codex CLI | `~/.codex/` |

If you had to configure each one separately, you would have three copies of everything, and they would drift apart.

### The solution: symlinks

A **symlink** (symbolic link) is like a shortcut on your desktop. It looks like a file but just points to another file.

The `bin/sync-adapters.sh` script creates symlinks so that:

```
~/.claude/CLAUDE.md        -> ~/.config/opencode/instructions/AGENTS.md
~/.codex/AGENTS.md         -> ~/.config/opencode/instructions/AGENTS.md
~/.claude/commands/        -> ~/.config/opencode/commands/
~/.codex/prompts/          -> ~/.config/opencode/commands/
~/.claude/agents/          -> ~/.config/opencode/adapters/claude/agents/
~/.codex/agents/           -> ~/.config/opencode/adapters/codex/agents/
~/.claude/skills/<name>/   -> ~/.config/opencode/skills/<name>/
~/.agents/skills/<name>/   -> ~/.config/opencode/skills/<name>/
```

Now all harnesses read the same files. Change one, and all three pick it up.

### When to re-run sync-adapters

Run `bash bin/sync-adapters.sh` whenever:

- You clone this suite for the first time
- You add or modify a command
- You add or modify a skill
- You add or modify an agent definition

---

## 14. Memory

**Memory** is where the agent stores facts it has learned. Without memory, every session starts from scratch.

### Two levels of memory

**Global memory** applies to every project. It lives in `~/.config/opencode/.agents/memory.md`.

Use it for:

- "Always use tabs, not spaces"
- "Never commit .env files"
- "Default branch name is main"

**Project memory** applies to one project. It lives in `your-project/.agents/memory.md`.

Use it for:

- "The build command is `npm run build`"
- "We use Vitest, not Jest"
- "The database URL is in .env.local"

### How to use memory

When the agent makes a mistake, tell it:

> "Remember in memory: we use `pnpm` not `npm`"

The agent will update `.agents/memory.md` so it remembers next time.

You can also use the `/memory` command:

```
/memory                         # show what is recorded
/memory note Tests use Vitest   # add a note
/memory promote <topic>         # move a project rule to global
```

### Why memory matters

Over time, the agent gets smarter about your specific setup without you repeating instructions. It is the difference between:

- Session 1: "Use Vitest, not Jest. Use tabs, not spaces."
- Session 10: (already knows, because it is in memory)

---

## 15. Context Limits and Compaction

**Context** is everything the agent can see at once: the conversation history, the files it has read, the instructions it was given.

### The problem

AI agents have a **context limit** -- a maximum amount of text they can handle at once. Popular models have limits like 100k tokens or 200k tokens (roughly 75k-150k words).

In a long session:

- You have had many back-and-forth messages
- The agent has read several files
- The agent has run multiple commands

Eventually, the agent runs out of space. It starts forgetting earlier instructions or conversations.

### The solution: compaction

**Compaction** is the process of summarizing the conversation so far into a shorter version. The agent keeps the important information and discards the rest.

This can happen:
- **Automatically** -- the harness decides it is running out of space and compacts
- **Manually** -- you or the agent suggest it

The `strategic-compact` skill teaches the agent to suggest compaction at logical boundaries, before the harness forces it. This is better because the agent can decide what is important to keep.

### How to avoid context problems

- Keep individual tasks focused and small
- Use `/ship` for structured work (each subagent gets fresh context)
- Use memory (section 14) so facts survive compaction
- If the agent seems confused about earlier instructions, suggest compacting

---

## 16. Spec-First Development

**Spec-first development** means writing a document that describes _what_ you want before writing _how_ to build it.

### The problem

Without a spec:

- You tell the agent "add a login page"
- The agent builds one
- You realize it does not handle Google OAuth
- The agent rebuilds it
- You realize the design should match the dashboard
- The agent rebuilds it again

Each rebuild wastes tokens and time.

### The solution: write a spec first

A spec answers:

- **Problem** -- what are we solving?
- **Target user** -- who is this for?
- **Success criteria** -- how do we know it works?
- **Scope** -- what is in, what is out?
- **Design constraints** -- colors, components, patterns?

Write this with `/spec`:

```
/spec Add a login page with Google OAuth
```

The agent writes a spec document to `docs/specs/login-page.md`. You review it and make changes. Only when the spec is approved does anyone write code.

### When to write a spec

- New features
- Complex changes
- Any time you are not 100% sure what you want

### When to skip the spec

- Typo fixes
- Simple refactors
- Bug fixes with clear reproduction steps

---

## 17. TDD -- Test-Driven Development

**TDD** stands for **Test-Driven Development**. It is a way of writing code where you write the test before you write the code.

### The three steps (RED-GREEN-REFACTOR)

**RED**: Write a test that fails.

```typescript
// You write this FIRST, before any implementation
it("adds two numbers", () => {
  expect(add(2, 3)).toBe(5);
});
```

Run the test. It fails because `add` does not exist yet. The test runner shows "RED" (failure).

**GREEN**: Write the minimum code to make the test pass.

```typescript
function add(a: number, b: number): number {
  return a + b;
}
```

Run the test. It passes. "GREEN."

**REFACTOR**: Improve the code while keeping the test green.

```typescript
// Maybe add type safety, error handling, etc.
// Then run tests again to make sure it still passes.
```

### Why TDD matters for agents

When an agent writes code without tests:

- You do not know if the code actually works
- The agent might think it is done but the code has bugs
- Future changes might break things silently

When the agent writes tests first:

- The tests define what "done" means
- You can verify the code works by running tests
- Future changes have a safety net

The `testing` skill in this suite enforces TDD. When you say "fix this bug" or "add this feature," the agent will:

1. Write a failing test that reproduces the bug or describes the feature
2. Write the code to make it pass
3. Run the tests to confirm

### What this looks like in practice

```
You: /test The checkout button does nothing when clicked
Agent: Writes a test that clicks the button and expects an API call
       (test fails -- RED)
       Fixes the button handler
       (test passes -- GREEN)
       Checks for other issues
       (REFACTOR)
```

---

## 18. The /audit Command and Drift

**Drift** is when your configuration files and the actual files on disk do not match.

### The problem

Over time, things get out of sync:

- You delete a skill directory, but the agent still references it
- A symlink breaks because the target was moved
- You install a new Axi tool but the agent does not know about it
- Someone (or something) adds em dashes to a file that should not have them

These small inconsistencies pile up and cause confusing errors.

### The solution: /audit

Running `/audit` checks:

- All referenced files exist
- All symlinks resolve to real files
- No stale generated adapter files
- No banned characters (em dashes)
- All Axi CLI tools are installed
- Agent definitions match what the suite expects

### When to run audit

- When things seem "off" (commands not working, agents behaving strangely)
- After making changes to the suite configuration
- Periodically (once a week)

---

## 19. Open Super Whisper

**Open Super Whisper** is a voice input tool. It listens to your microphone, converts speech to text, and types it wherever your cursor is.

### Why voice?

Typing is slow. Speaking is fast (about 3x faster).

Common uses:

- Dictating code or comments while keeping your hands on the keyboard
- Describing a bug out loud instead of typing it
- Voice commands like "open terminal" or "run tests"

### How it works

```bash
# Start Open Super Whisper
open-super-whisper

# It sits in your menubar/system tray
# Press the hotkey (default: Option or Ctrl+Shift) and speak
# Release and the text appears at your cursor
```

### Custom vocabulary

Open Super Whisper has a vocabulary file where you can add custom words (like library names, company names, jargon) so it transcribes them correctly:

```json
{
  "custom_vocab": ["OpenCode", "Claude Code", "Codex CLI", "npm", "pnpm", "TypeScript"]
}
```

### When voice works best

- Dictating code structure (function signatures, type definitions)
- Describing bugs or features to an agent
- Writing documentation or comments
- Quick commands in the terminal

### When voice does not work well

- Precise symbol names (`=>`, `===`, `||`)
- Complex punctuation
- Noisy environments

---

## 20. Glossary

| Term | Plain English definition |
|---|---|
| **Agent** | An AI program that can read, write, and run code based on your instructions |
| **Agent harness** | The program that runs the agent (OpenCode, Claude Code, Codex CLI) |
| **Axi** | A framework for building AI-friendly CLI tools |
| **CLI** | Command-line interface -- a program you run in the terminal |
| **Command** | A `/` shortcut that tells the agent to run a specific workflow |
| **Compaction** | Summarizing a conversation to fit within context limits |
| **Context** | Everything the agent can see at once (history, files, instructions) |
| **Cross-harness wiring** | Making all three agent harnesses share the same configuration |
| **Drift** | When files get out of sync with each other |
| **Gated pipeline** | A workflow where each stage must pass before the next starts |
| **Git worktree** | A git feature that lets you have multiple copies of a repo checked out |
| **gnhf** | "Good Night, Have Fun" -- runs agents autonomously in a loop |
| **Harness** | See "agent harness" |
| **MCP** | Model Context Protocol -- a standard for agents to talk to external tools |
| **Orchestrator** | A tool (like First Mate) that manages multiple agents |
| **Pipeline** | A sequence of automated stages |
| **Progressive disclosure** | Loading instructions only when needed (like skills) |
| **PR** | Pull request -- a proposed change to a codebase |
| **Skill** | A bundle of instructions that loads on demand |
| **Spec** | A document describing what to build before building it |
| **Subagent** | A specialized agent that does one thing (planner, reviewer, etc.) |
| **Symlink** | A file that points to another file (like a shortcut) |
| **TDD** | Test-Driven Development -- write tests first, then code |
| **tmux** | A program that lets you run multiple terminal sessions in one window |
| **Token** | A unit of text that LLMs use (roughly 0.75 words). Agents pay per token. |
| **Worktree** | See "git worktree" |

---

## Summary: How it all fits together

```
You (the developer)
  |
  |-- uses an Agent Harness (OpenCode / Claude Code / Codex CLI)
  |     |
  |     |-- runs the build agent (your main coding assistant)
  |     |     |
  |     |     |-- dispatches subagents (planner, reviewer, tester, maintainer)
  |     |     |-- uses commands (/ship, /test, /review, etc.)
  |     |     |-- loads skills on demand (stack-discovery, testing, etc.)
  |     |     |-- reads/writes memory (global + project)
  |     |
  |     |-- uses tools in order:
  |           1. Native harness tools (built-in)
  |           2. Axi CLI tools (gh-axi, gnhf, no-mistakes, treehouse, ...)
  |           3. MCP servers (context7, gh_grep)
  |
  |-- also uses:
       |-- Open Super Whisper (voice input)
       |-- First Mate (orchestrator for multi-repo work)
       |-- Treehouse (isolated worktrees for parallel agents)
       |-- /audit (drift checking)
```

---

**Next steps**: Read the [README.md](../README.md) for setup instructions. Come back here when you encounter a concept you do not understand.
