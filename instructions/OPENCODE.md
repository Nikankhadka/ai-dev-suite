# OpenCode-Specific Notes

Cross-harness rules live in `instructions/RULES.md` (loaded alongside this file). This file only covers OpenCode-native mechanics.

## Skill Loading

Skills are not preloaded. They are discovered from `~/.config/opencode/skills/<name>/SKILL.md` and loaded on demand via the native `skill({ name })` tool. Load a skill only when the task matches its description; available skills are listed in the `skill` tool description.

## Agents

| Agent | Mode | Use for |
|---|---|---|
| `build` | primary | day-to-day coding, dispatches the others |
| `planner` | subagent, read-only | implementation plans before non-trivial changes |
| `reviewer` | subagent | quality, security, build-error review |
| `tester` | subagent | test-first implementation and E2E bug repro |
| `maintainer` | subagent | dead code, doc/map/memory refresh |

Full agent and command inventories live only in `README.md` - do not duplicate them here.

See `docs/DEVELOPMENT.md` for command usage and `docs/EVALS.md` for how this suite is verified.
