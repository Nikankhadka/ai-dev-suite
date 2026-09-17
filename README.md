# AI Dev Suite

Comprehensive agent skills suite for real software engineering, not vibe coding.

## What's Included

**Skills - Matt Pocock** (powered by [mattpocock/skills](https://github.com/mattpocock/skills)):
- **Engineering**: tdd, code-review, diagnosing-bugs, to-spec, to-tickets, implement, triage, wayfinder, grill-with-docs, domain-modeling, codebase-design, prototype, research, resolving-merge-conflicts
- **Productivity**: grill-me, handoff, grilling
- **Misc**: git-guardrails, setup-pre-commit

Vendored but not registered (see the `SKIP` list in `scripts/link-skills.sh`): ask-matt, teach,
writing-great-skills, scaffold-exercises, migrate-to-shoehorn.

**Skills - Kunchen** (powered by [kunchenguid](https://github.com/kunchenguid) tools):
- **lavish** - Visual planning with interactive HTML artifacts, annotations, and decisions
- **no-mistakes** - Automated validation pipeline (review, test, docs, lint, push, PR, CI)
- **gnhf** - Autonomous long-running agent loop for overnight/background work
- **axi** - Agent eXperience Interface design principles for token-efficient tools
- **stow** - Session knowledge sweep (from firstmate)

**Skills - local**:
- **ponytail** - Lazy senior dev mode, plus review, audit, debt, and gain companions
- **frontend-design** - Design router that loads hallmark or taste-skill on demand
- **stack-discovery** - Detect language, package manager, and tooling before writing code

**Vendor Tools** (CLI tools, referenced by skills):
- **treehouse** - Reusable, isolated git worktrees for parallel agent sessions
- **firstmate** - Agent distro for crew orchestration (talk to one, ship with many)

**Agents** (defined for OpenCode):
- `supervisor` - Plans, delegates, reviews evidence, and accepts work
- `reader` / `fallback-reader` - Bounded read-only discovery on low-cost models
- `builder` - Implements one bounded slice with TDD and evidence
- `planner` - Read-only requirements and test planning
- `reviewer` - Read-only review of one assigned axis
- `debugger` - Diagnoses bugs without implementing fixes
- `maintainer` - Removes dead code, consolidates duplicates, refreshes docs and memory

## Documentation

| Doc | What it covers |
|-----|----------------|
| [docs/unified-flow.md](docs/unified-flow.md) | The full suite, tool by tool. Start here. |
| [docs/loop-flow.md](docs/loop-flow.md) | Loop engineering and multi-agent work: gates, autonomous runs, parallel crews, failure recovery |
| [docs/supervised-model-routing.md](docs/supervised-model-routing.md) | Default model presets, bounded roles, context limits, handoffs, and usage accounting |
| [docs/combined-workflow.md](docs/combined-workflow.md) | Earlier merged Matt Pocock + Kunchen guide |
| [docs/matt-flow.md](docs/matt-flow.md) | Matt Pocock engineering skills on their own |
| [docs/kunchen-flow.md](docs/kunchen-flow.md) | Kunchen infrastructure on its own |

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/Nikankhadka/ai-dev-suite/main/setup.sh | bash
```

This clones to `~/.config/opencode`, initializes the submodules, links shared skills and global
instructions, merges native model defaults without replacing unrelated settings, and installs
suite-owned Claude, Codex, and Pi integration. Changed user settings receive timestamped backups.

## Supported Agents

Skills are symlinked into `~/.claude/skills` and `~/.agents/skills`, which all four harnesses read
globally - one source of truth, synced across every project. Pi receives the OpenCode commands as
prompt templates. OpenCode personas live in this repo, while setup
installs native Claude and Codex roles plus Pi model, context, instruction, and prompt settings.

| Harness | Skills | Commands | Agents |
|---------|--------|----------|--------|
| **OpenCode** | `~/.claude/skills` + `~/.agents/skills` symlinks | `~/.config/opencode/command/` | `~/.config/opencode/agent/` |
| **Claude Code** | `~/.claude/skills/` | not provided | `~/.claude/agents/` |
| **Codex** | `~/.agents/skills/` | not provided | `~/.codex/agents/` plus named profiles |
| **Pi** | `~/.agents/skills/` + `~/.claude/skills/` | `~/.pi/agent/prompts/` | shared global policy plus native CLI role flags |
| **Cursor / Windsurf** | markdown docs in `vendor/` | not provided | not provided |

## Commands (OpenCode and Pi prompt templates)

| Command | Description |
|---------|------------|
| `/grill-me` / `/grill-with-docs` | Grilling interviews (the second also writes ADRs) |
| `/to-spec` / `/to-tickets` | Spec and ticket generation |
| `/wayfinder` | Map work too large for one session |
| `/domain-modeling` | Ubiquitous language, CONTEXT.md, and ADRs |
| `/design` | Frontend design router (hallmark or taste-skill) |
| `/lavish` | Visual planning with interactive HTML artifacts |
| `/prototype` | Throwaway prototype for design questions |
| `/tdd` | Test-driven development loop |
| `/implement` | Implement from spec/tickets |
| `/ship` | Thin entrypoint to the global supervised workflow |
| `/code-review` | Three-axis code review |
| `/ponytail` | Switch lazy-dev intensity (lite, full, ultra, off) |
| `/ponytail-review` / `/ponytail-audit` | Over-engineering review of a diff, or of the whole repo |
| `/ponytail-debt` / `/ponytail-gain` / `/ponytail-help` | Debt ledger, impact scoreboard, quick reference |
| `/no-mistakes` | Run the validation pipeline |
| `/gnhf` | Autonomous agent loop |
| `/diagnosing-bugs` | Bug diagnosis loop |
| `/resolving-merge-conflicts` | Resolve an in-progress merge or rebase |
| `/triage` | Move issues through the triage state machine |
| `/maintain` | Dead code, duplicates, docs and memory refresh |
| `/memory` | Maintain `.agents/memory.md` |
| `/stow` | Sweep the session for durable knowledge before a reset |
| `/handoff` | Write the supervisor-owned `.agent-handoff.md` ledger |
| `/improve-codebase-architecture` | Codebase health scan |
| `/setup-matt-pocock-skills` | Configure issue tracker and labels |

## Updating Vendored Skills

`sync-upstream.sh` detects submodule changes, maps them to the local files they affect, and walks
you through each change:

```bash
bash scripts/sync-upstream.sh --dry-run   # see what upstream changed
bash scripts/sync-upstream.sh             # interactive review and apply
bash scripts/sync-upstream.sh --yes       # apply all well-defined changes
```

After pulling submodules manually, re-run the linker so every harness sees the same set:

```bash
git submodule update --remote
bash scripts/patch-skills.sh
bash scripts/link-skills.sh
```

## Structure

```
vendor/mattpocock-skills/     # Git submodule (Matt Pocock skills)
vendor/lavish-axi/            # Git submodule (Lavish, visual planning)
vendor/no-mistakes/           # Git submodule (No-Mistakes, validation pipeline)
vendor/gnhf/                  # Git submodule (gnhf, autonomous agent loops)
vendor/treehouse/             # Git submodule (Treehouse, worktree management)
vendor/firstmate/             # Git submodule (Firstmate, agent orchestration)
vendor/axi/                   # Git submodule (AXI, agent ergonomics spec)
vendor/ponytail/              # Git submodule (Ponytail, lazy senior dev mode)
vendor/taste-skill/           # Git submodule (loaded on demand by frontend-design)
vendor/hallmark/              # Git submodule (loaded on demand by frontend-design)
skills/                       # Repo-owned local skills
instructions/AGENTS.md        # Shared global instructions, linked into every harness
docs/                         # Workflow guides and documentation
templates/                    # File templates (project memory)
agent/                        # OpenCode global agent definitions
command/                      # OpenCode global slash commands
.opencode/                    # Project-scoped opencode state (plans)
scripts/link-skills.sh        # Symlink skills for Claude Code, OpenCode, Codex, and Pi
scripts/patch-skills.sh       # Apply agent-agnostic modifications
scripts/sync-upstream.sh      # Guided update when vendored skills change
setup.sh                      # One-line installer
```
