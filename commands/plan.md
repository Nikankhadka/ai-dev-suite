---
description: Create implementation plan with architecture and database design
agent: planner
subtask: true
---

# Plan Command

Create a detailed implementation plan with architecture and database design: $ARGUMENTS

## Your Task

1. **Restate Requirements** - Clarify what needs to be built
2. **Architecture Design** - System design and component relationships
3. **Database Design** - Schema, indexes, RLS, migrations (if applicable)
4. **Identify Risks** - Surface potential issues, blockers, and dependencies
5. **Create Step Plan** - Break down implementation into phases
6. **Wait for Confirmation** - MUST receive user approval before proceeding

## Output Format

### Requirements Restatement
[Clear, concise restatement of what will be built]

### Architecture Changes
[Components, data flow, integration points]

### Database Changes (if applicable)
[Schema changes, indexes, RLS policies, migrations]

### Implementation Phases
[Phase 1: Description]
- Step 1.1 (File: path)
- Step 1.2 (File: path)
...

### Dependencies
[List external dependencies, APIs, services needed]

### Risks
- HIGH: [Critical risks that could block implementation]
- MEDIUM: [Moderate risks to address]
- LOW: [Minor concerns]

**WAITING FOR CONFIRMATION**: Proceed with this plan? (yes/no/modify)

**CRITICAL**: Do NOT write any code until the user explicitly confirms with "yes", "proceed", or similar affirmative response.
