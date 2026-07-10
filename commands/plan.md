---
description: Create a stack-agnostic implementation plan; wait for approval before any code is written
argument-hint: <feature or requirement>
allowed-tools: Read, Grep, Glob, Bash
agent: planner
subtask: true
---

# Plan

Create a detailed implementation plan for: $ARGUMENTS

Follow the planner agent's process exactly: restate the requirement, identify the stack (via `AGENTS.md` or the `stack-discovery` skill - never assume a language or framework), survey existing patterns to reuse, break the work into dependency-ordered steps, list acceptance criteria and required tests, surface risks.

Use the planner agent's output template. Do not write or edit any file.

**WAITING FOR CONFIRMATION**: end with this line and stop. Do not proceed to implementation until the user replies "yes", "proceed", or similar.
