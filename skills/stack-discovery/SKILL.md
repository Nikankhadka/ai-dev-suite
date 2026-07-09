---
name: stack-discovery
description: Runtime protocol for detecting a project's language, package manager, and test/build tooling instead of assuming one. Load this before writing code, tests, or commands in a project you have not already mapped, or whenever another skill or agent says "load stack-discovery".
---

# Stack Discovery

This suite is stack-agnostic. Never assume TypeScript, React, Jest, Playwright, or any other specific stack. Determine the real stack with this protocol, in order, stopping at the first step that gives a confident answer.

## Step 1: AGENTS.md wins

Read `AGENTS.md` at the project root if it exists. Its `## Stack` and `## Commands` sections are the source of truth - use them and skip the remaining steps. If `AGENTS.md` does not exist, run `/init-project` or continue to Step 2 for a one-off answer.

## Step 2: Detect from project files

Run `ls` at the project root and match against this table. Multiple hits are normal in polyglot repos - report all languages/tools found, not just the first match.

| Files found | Language / ecosystem |
|---|---|
| `package.json` + `package-lock.json` | Node.js, npm |
| `package.json` + `pnpm-lock.yaml` | Node.js, pnpm |
| `package.json` + `yarn.lock` | Node.js, yarn |
| `package.json` + `bun.lockb` | Node.js, bun |
| `pyproject.toml` (with `[tool.poetry]`) | Python, Poetry |
| `pyproject.toml` + `uv.lock` | Python, uv |
| `requirements.txt` | Python, pip |
| `go.mod` | Go |
| `Cargo.toml` | Rust, Cargo |
| `*.csproj` / `*.sln` | .NET / C# |
| `Gemfile` | Ruby, Bundler |
| `pom.xml` | Java, Maven |
| `build.gradle` / `build.gradle.kts` | Java/Kotlin, Gradle |
| `mix.exs` | Elixir, Mix |

For the test/build/lint commands, look inside the manifest before guessing:
- `package.json` `scripts` block - use the actual script names, do not assume `test`/`build`/`lint` exist under those exact names
- `pyproject.toml` `[tool.pytest]`, `[tool.ruff]`, or a `Makefile`/`tox.ini`
- `Makefile` at root - often the real entry point regardless of language
- CI config (`.github/workflows/*.yml`, `.gitlab-ci.yml`) - the commands CI runs are the ground truth for what "passing" means

For a test framework specifically, look for its config file or dependency: `jest.config.*`/`vitest.config.*`/`playwright.config.*` (JS), `pytest.ini`/`conftest.py` (Python), `*_test.go` convention (Go), etc. Do not assume Jest or Playwright just because the project is JavaScript - Vitest, Mocha, Cypress, and others are equally common.

## Step 3: gh-axi for real-world usage

If you need to see how a detected framework or library is actually used (an idiom, a config shape, an API signature) and it isn't obvious from the codebase itself, use `gh-axi` to search real code. Prefer this over MCP - no round-trip, cheaper in tokens.

## Step 4: MCP as last resort

Only if `gh-axi` is unavailable or insufficient, fall back to the `context7` MCP server: `resolve-library-id` to find the library, then `get-library-docs` to fetch documentation.

## Rule

If detection is genuinely ambiguous (e.g. two competing lockfiles, no manifest at all, a framework you don't recognize), stop and ask rather than guessing. A wrong stack assumption produces code, tests, or commands that silently fail to run.
