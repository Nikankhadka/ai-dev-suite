# Global Agent Instructions

These rules apply to every agent session across all harnesses (Claude Code, OpenCode, Codex CLI).

- Never use the em dash "-". Use plain dash "-" instead
- When writing commit messages, NEVER auto-add your agent name as co-author
- Never manually modify CHANGELOG.md files or any files marked as auto-generated
- When making technical decisions, do not give much weight to development cost. Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it as possible
- When end-to-end testing a product, be picky about the UI and be obsessed with pixel perfection. If something clearly looks off, even if not directly related to what you are doing, fix it along the way
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness. If you see one, even if not caused by your work, still fix it

## Workflow

Pipeline: prompt -> plan -> build -> review -> test -> document. Run `/ship` for the full gated pipeline on non-trivial work.

Tool hierarchy: prefer native harness tools, then axi CLIs (token-cheap, no MCP round-trip), then MCP servers as the last resort.

At the start of a session in a project, read `AGENTS.md` and `.agents/memory.md` if they exist. If `AGENTS.md` does not exist, run `/init-project` before starting substantive work.
