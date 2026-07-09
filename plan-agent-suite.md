# Plan: Global Agent Development Suite

## Objective
Set up a cross-harness agent development suite inspired by kunchen's workflow — agent/LLM-agnostic, rooted in Claude Code's structure but fully leveraged by OpenCode, Codex CLI, and any future harness.

## Current Gaps (from audit)
1. No global memory file (`~/.claude/CLAUDE.md`)
2. No cross-harness symlink bridge
3. No project-level memory system
4. Kunchen's tools not installed: axi, no-mistakes, gnhf, lavish-axi, firstmate, treehouse, quota-axi
5. No automated validation pipeline (no-mistakes)
6. Skills missing: lavish (planning artifacts), no-mistakes (PR pipeline)
7. GitHub MCP in use instead of AXI CLI (3x cost, 2x latency penalty)
8. No voice input (Open Super Whisper)

## Architecture

```
┌──────────────────────────────────────────────┐
│              FIRSTMATE (Captain)              │
│  Receives high-level direction, decomposes,  │
│  delegates to agents across treehouse wkts   │
├──────────────────────────────────────────────┤
│         GLOBAL MEMORY (~/.claude/CLAUDE.md)   │
│         Symlinked to all harness configs      │
├──────────────────────────────────────────────┤
│   AGENT HARNESSES (all share same memory)     │
│   ┌──────────┐ ┌──────────┐ ┌──────────┐     │
│   │OpenCode  │ │ClaudeCode│ │Codex CLI │     │
│   │ + skills │ │ + skills │ │ + skills │     │
│   └──────────┘ └──────────┘ └──────────┘     │
├──────────────────────────────────────────────┤
│   AXI CLI WRAPPERS (git, browser, etc.)      │
│   ~3x cheaper, ~2x faster than MCP           │
├──────────────────────────────────────────────┤
│   VALIDATION: no-mistakes pipeline           │
│   → branch → commit → rebase → review →      │
│     E2E test → docs → lint → PR              │
├──────────────────────────────────────────────┤
│   LONG-RUNNING: gnhf (good night have fun)   │
│   Autonomous loops with token caps           │
├──────────────────────────────────────────────┤
│   PLANNING: lavish-axi (interactive HTML     │
│   artifacts for design discussions)          │
└──────────────────────────────────────────────┘
```

## Implementation Phases

---

### Phase 1: Memory & Cross-Harness Bridge

**Step 1.1 — Create global memory file**
- File: `~/.claude/CLAUDE.md`
- Content: kunchen's rules (7 rules, ~27 lines)
  - No em dash "—", use plain dash "-"
  - No auto co-author on commits
  - Don't modify auto-generated files
  - Don't weight dev cost; prefer quality/simplicity/robustness/scalability
  - E2E-first bug reproduction
  - Pixel-perfection obsession on UI
  - Fix lint/test failures on sight

**Step 1.2 — Symlink for OpenCode**
- `~/.config/opencode/CLAUDE.md` → `~/.claude/CLAUDE.md`
- Verify OpenCode loads it (check if opencode.jsonc `instructions` picks it up)

**Step 1.3 — Symlink for Codex CLI**
- Codex CLI config location: check `~/.codex/` or equivalent
- Symlink: `~/.codex/CLAUDE.md` → `~/.claude/CLAUDE.md`

**Step 1.4 — Create project-level memory template**
- File: `~/.config/opencode/AGENTS.md.template`
- Sections: Project context, repo layout, terminology, key components, E2E testing, conventions
- `/init` command copies this template into new projects as `AGENTS.md`
- Project-level symlink pattern: `project/.claude/CLAUDE.md` → `project/AGENTS.md`

**Step 1.5 — Update OpenCode INSTRUCTIONS.md**
- Remove any bloat that belongs in skills (E2E instructions → e2e-testing skill)
- Keep only: agent orchestration rules, behavioral guardrails, command reference
- Add note about global `CLAUDE.md` being loaded

**Verify Phase 1:**
- `ls -la ~/.claude/CLAUDE.md` exists and contains global rules
- `ls -la ~/.config/opencode/CLAUDE.md` is a symlink to it
- OpenCode session loads the global rules

---

### Phase 2: Install Kunchen's Tool Suite

**Step 2.1 — axi (Agent eXtensible Interface)**
- Repo: `github.com/kunchenguid/axi`
- Install: `git clone` into `~/.local/share/axi` and add to PATH
- Sub-steps: GitHub axi, Chrome DevTools axi, Lavish axi
- Configure: wire as CLI wrappers, NOT MCP servers (3x cheaper)

**Step 2.2 — no-mistakes (Validation Pipeline)**
- Repo: `github.com/kunchenguid/no-mistakes`
- Install: `git clone` into `~/.local/share/no-mistakes`
- Configure: set up as a skill for OpenCode and Claude Code
- Pipeline steps: branch → commit → rebase → adversarial review → E2E test → docs → lint → PR

**Step 2.3 — gnhf (Good Night Have Fun)**
- Repo: `github.com/kunchenguid/gnhf`
- Install: `git clone` into `~/.local/share/gnhf`
- For long-running autonomous agent loops (overnight tasks)
- Supports token caps, iteration caps, stop conditions

**Step 2.4 — lavish-axi (Planning Artifacts)**
- Repo: `github.com/kunchenguid/lavish-axi`
- Install: as a skill for both OpenCode and Claude Code
- Creates interactive HTML artifacts for design discussions
- Uses project's design system for visual consistency

**Step 2.5 — treehouse (Parallel Worktrees)**
- Repo: `github.com/kunchenguid/treehouse`
- Install: `git clone` into `~/.local/share/treehouse`
- Manages `git worktree` create/list/clean lifecycle
- Reuses idle worktrees instead of creating new ones

**Step 2.6 — firstmate (Captain's Orchestrator)**
- Repo: `github.com/kunchenguid/firstmate`
- Install: `git clone` into `~/.local/share/firstmate`
- Top-level orchestrator: receives intent, decomposes, delegates to agents in treehouses
- Runs no-mistakes after implementation

**Step 2.7 — quota-axi (Token Budget)**
- Repo: `github.com/kunchenguid/quota-axi`
- Install: `git clone` into `~/.local/share/quota-axi`
- Track and cap token usage across sessions

**Verify Phase 2:**
- Each tool is cloned and available via `--help` or equivalent
- PATH includes tool directories
- Skills are discoverable by OpenCode

---

### Phase 3: OpenCode Integration Enhancements

**Step 3.1 — Create `/nomistakes` command**
- File: `~/.config/opencode/commands/nomistakes.md`
- Opens no-mistakes pipeline in current repo
- Agent: ops or reviewer

**Step 3.2 — Create lavish skill**
- File: `~/.config/opencode/skills/lavish/SKILL.md`
- Description: "Interactive planning with HTML artifacts using lavish-axi"
- Loaded on-demand for /plan or design discussions

**Step 3.3 — Replace GitHub MCP with AXI CLI**
- Remove `gh_grep` MCP server from `opencode.jsonc` (or keep as optional)
- Add AXI GitHub CLI wrapper instructions to INSTRUCTIONS.md
- Rationale: 3x cheaper tokens, 2x faster latency per kunchen's benchmarks

**Step 3.4 — Update planner agent prompt**
- File: `~/.config/opencode/prompts/agents/planner.txt`
- Integrate lavish-axi usage: for complex features, create interactive HTML artifact
- Keep fallback to text-based plans for simple tasks

**Step 3.5 — Add `gnhf` command for long-running tasks**
- File: `~/.config/opencode/commands/gnhf.md`
- Launches autonomous agent loop with objective + stop conditions

**Step 3.6 — Create `treehouse` command for parallel agents**
- File: `~/.config/opencode/commands/treehouse.md`
- Spawns new agent session in a fresh worktree

**Step 3.7 — Create `firstmate` command**
- File: `~/.config/opencode/commands/firstmate.md`
- Launches captain-level orchestrator session

**Verify Phase 3:**
- All new commands appear in OpenCode's slash command list
- `/nomistakes` triggers validation pipeline
- `/plan` with complex features uses lavish artifacts

---

### Phase 4: Voice Input & Ergonomics

**Step 4.1 — Install Open Super Whisper**
- Download from GitHub releases
- Configure local Whisper model for offline transcription
- Set up custom vocabulary prompt with your project names for accuracy

**Step 4.2 — Integrate with agent harnesses**
- Verify voice-to-text works in terminal (piped to agent input)
- Configure hotkey for voice activation

**Verify Phase 4:**
- Voice input transcribes with high accuracy including project-specific terms

---

### Phase 5: Workflow Documentation

**Step 5.1 — Write captain's runbook**
- File: `~/.config/opencode/CAPTAIN.md`
- Decision tree: When to use which tool
- Quick reference for all commands and tools

**Step 5.2 — Firstmate onboarding**
- Document how to teach firstmate your preferences
- How to add new projects to its awareness

---

## Key Principles (from kunchen)

1. **Global memory is minimal** — Only preferences that apply to EVERY session (~27 lines)
2. **Project memory is living** — Keep learning by appending to AGENTS.md when agents make mistakes
3. **Skills for conditional knowledge** — Move bloated project memory into skills (progressive disclosure)
4. **CLI over MCP** — AXI wrappers beat MCP servers for cost and speed
5. **Don't review diffs — review PRs** — Let no-mistakes pipeline catch issues, you review only risk items
6. **Planning (lavish) + approval (no-mistakes) = your bottleneck** — Agents do the middle work
7. **Never install random internet skills** — Security risk + often degrades performance

## Success Criteria

- All 3 harnesses share the same global memory via symlinks
- Project-level AGENTS.md loaded by all harnesses
- `/plan` produces lavish HTML artifacts for complex features
- `/nomistakes` runs full validation pipeline (branch → PR)
- `gnhf` runs overnight autonomous loops
- `treehouse` manages parallel worktrees
- `firstmate` orchestrates multi-agent workflows
- Voice input works across all harnesses
- No insecure/unverified skills installed
