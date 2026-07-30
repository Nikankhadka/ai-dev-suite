# AI Dev Suite

Comprehensive agent skills suite for real software engineering — not vibe coding.

## What's Included

**Skills** (powered by [mattpocock/skills](https://github.com/mattpocock/skills)):
- **Engineering**: tdd, code-review, diagnosing-bugs, to-spec, to-tickets, implement, triage, wayfinder, grill-with-docs, domain-modeling, codebase-design, prototype, research, resolving-merge-conflicts
- **Productivity**: grill-me, handoff, teach, writing-great-skills, grilling
- **Misc**: git-guardrails, scaffold-exercises, setup-pre-commit, migrate-to-shoehorn
- Plus 9 in-progress skills

**Agents** (defined for OpenCode):
- `builder` — Implements code with TDD + code review
- `planner` — Designs features with grilling + specs
- `reviewer` — Reviews code on two axes (standards + spec)
- `debugger` — Diagnoses bugs with a 6-phase loop

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/Nikankhadka/ai-dev-suite/main/setup.sh | bash
```

## Supported Agents

- **Claude Code** — skills auto-load from `~/.claude/skills/`
- **OpenCode** — skills via `skills.paths` in `opencode.jsonc`
- **Codex** — skills auto-load from `~/.agents/skills/`
- **Cursor / Windsurf** — skills as markdown docs in vendor/

## Commands (OpenCode)

| Command | Description |
|---------|------------|
| `/tdd` | Test-driven development loop |
| `/code-review` | Two-axis code review |
| `/diagnosing-bugs` | Bug diagnosis loop |
| `/grill-me` / `/grill-with-docs` | Grilling interviews |
| `/to-spec` / `/to-tickets` | Spec and ticket generation |
| `/implement` | Implement from spec/tickets |
| `/triage` / `/wayfinder` | Issue management |
| `/handoff` / `/teach` | Productivity tools |
| `/prototype` | Throwaway prototype for design questions |
| `/improve-codebase-architecture` | Codebase health scan |
| `/ask-matt` | Router — which skill to use |
| `/setup-matt-pocock-skills` | Configure issue tracker and labels |

## Updating Skills

```bash
git -C vendor/mattpocock-skills pull origin main
bash scripts/patch-skills.sh
bash scripts/link-skills.sh
```

## Structure

```
vendor/mattpocock-skills/   # Git submodule (upstream skills)
skills/                     # Repo-owned local skills
.opencode/agent/            # OpenCode agent definitions
.opencode/command/          # OpenCode slash commands
scripts/link-skills.sh      # Symlink skills for all agents
scripts/patch-skills.sh     # Apply agent-agnostic modifications
setup.sh                    # One-line installer
```
