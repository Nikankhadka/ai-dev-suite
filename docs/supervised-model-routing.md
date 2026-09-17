# Supervised Model Routing

AI Dev Suite uses one senior supervisor and a flat set of bounded workers. The supervisor owns requirements, planning, delegation, synthesis, review, and acceptance. Readers gather evidence, implementers complete one approved slice, and reviewers independently check claims. Workers do not delegate.

This is a default workflow, not a new orchestration service. Project `AGENTS.md` files remain authoritative for stack, domain, commands, and environment details.

## Presets

| Harness | Supervisor | Reader | Implementer |
|---|---|---|---|
| Codex | `gpt-5.6-sol`, high | `gpt-5.6-luna`, low | `gpt-5.6-terra`, xhigh |
| Claude | `claude-opus-5`, high | `claude-haiku-4-5-20251001`, low | `claude-sonnet-5`, xhigh |
| OpenCode | `opencode-go/deepseek-v4.1-flash` | `opencode/muse-spark-1.3-contributor-free` | `opencode-go/deepseek-v4.1-flash` |

OpenCode uses `opencode/big-pickle` as the same-tier reader fallback. Codex profiles are selected with `codex -p supervisor`, `codex -p reader`, or `codex -p implementer`. The corresponding Codex custom agents can be requested by name. Claude starts on Opus and discovers the personal `reader` and `implementer` agents. OpenCode starts on the `supervisor` primary agent.

The choices follow each provider's intended tiering: Sol or Opus for ambiguous oversight, Luna or Haiku for narrow reads, and Terra, Sonnet, or DeepSeek for implementation. Current OpenAI guidance describes Terra as the balanced tier and Luna as the cost-sensitive tier. See [OpenAI models](https://developers.openai.com/api/docs/models), [Claude model configuration](https://code.claude.com/docs/en/model-config), and [OpenCode agents](https://opencode.ai/docs/agents).

When planning begins without a selected flow, ask once for Codex native, Claude native, OpenCode native, Opus-led Codex workers, Sol-led OpenCode workers, or custom. A hybrid flow is a coordination convention: use `.agent-handoff.md` to transfer verified state between separate harness sessions. It does not create a live cross-provider control plane.

## Reliability gate

Apply this proportionally:

1. Restate the requested outcome and constraints.
2. Define demonstrable completion criteria.
3. Identify standard and important edge-case tests before implementation planning.
4. For substantial, ambiguous, risky, architectural, or multi-file work, compare two viable approaches.
5. Implement one bounded slice.
6. Verify with repository-defined local commands and available development or staging environments.
7. Reread the original request and reject omissions, scope creep, skipped tests, or unsupported completion claims.

This adapts the [Dzangolab reliability definition](https://www.dzangolab.com/methodology/reliability/) and [ticket workflow](https://www.dzangolab.com/methodology/reliability/ticket/). Ponytail still decides the solution shape: the reliability gate requires evidence, not additional architecture or ceremony.

## Context and handoffs

Treat 100K active-context tokens as the soft handoff point. Finish the current small step, write `.agent-handoff.md`, and start a fresh context. At 160K, do not start new work. The handoff records the objective, original specification, Definition of Done, decisions, files touched, commands and results, remaining work, risks, and exact next verification. The receiving supervisor validates it against the repository and deletes it after completion.

These are conservative operating limits, not a universal scientific cutoff. Research shows that advertised window size does not guarantee reliable use of every token: [Lost in the Middle](https://arxiv.org/abs/2307.03172) found position-sensitive degradation, while [NoLiMa](https://arxiv.org/abs/2502.05167) found large declines on non-literal retrieval as context grew. Fresh, scoped contexts also reduce repeated high-tier input cost.

## Usage accounting

Every completion report should name each worker, model, role, and available input, cached-input, output, retry, and cost data. Use native sources:

- Codex: session token events and workspace Usage Insights where available.
- Claude: `/usage` for plan limits and `/cost` for API-backed session cost where supported.
- OpenCode: `opencode stats --models --cost`, plus session export when task-level detail is needed. See the [OpenCode CLI](https://opencode.ai/v2/docs/cli/commands/).

There is no reliable built-in cross-harness billing ledger. Keep the per-task summary in the final report and compare normalized tokens, retries, latency, and cost. Do not build a custom collector until repeated measurement proves it is needed.

## Limits

- Native provider configuration is authoritative when model aliases or availability change.
- Same-tier refreshes may be adopted when requested. Provider, billing, or capability-tier changes require confirmation.
- Subscription quotas and cached-token accounting are not directly comparable across providers.
- Parallel read or review work is capped at three workers. Parallel implementation, nested managers, or larger swarms require explicit approval.
- A worker summary is a claim until a supervisor verifies its diff, commands, screenshots, or CI evidence.
