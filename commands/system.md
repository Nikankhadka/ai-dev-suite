---
description: Harness, loops, project setup, and model routing
agent: ops
subtask: true
---

# System Command

Manage harness configuration, agent loops, project setup, and model routing: $ARGUMENTS

## Operations

### Harness
- `harness-audit` - Audit harness reliability and eval readiness
- `setup-pm` - Configure package manager for project

### Loops
- `loop-start` - Start controlled agentic loops with clear stop conditions
- `loop-status` - Check loop state and checkpoints

### Routing
- `model-route` - Route tasks by model complexity and budget

## Report Format

List current configuration, changes made, and verification results.

**TIP**: Run `/system harness-audit` to check harness health before starting loops.
