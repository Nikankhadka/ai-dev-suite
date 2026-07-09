---
name: coding-standards
description: Baseline, stack-agnostic coding conventions for naming, readability, immutability, error handling, and code-quality review. Load stack-discovery alongside this for language/framework-specific patterns.
---

# Coding Standards

Universal principles that apply regardless of language or framework. For anything language-specific (naming case conventions, idiomatic error types, framework patterns), load `stack-discovery` first to identify the stack, then apply that language's own idioms on top of these principles.

## When to Activate

- Starting a new module or feature
- Reviewing code for quality and maintainability
- Refactoring existing code
- Setting up or enforcing lint/format/type-check rules

## Core Principles

### 1. Readability first
Code is read far more than it is written. Prefer clear names and straightforward control flow over clever one-liners. Self-documenting code beats comments that restate what the code does.

### 2. KISS
Ship the simplest solution that satisfies the requirement. No premature optimization, no speculative generality.

### 3. DRY, applied with judgment
Extract genuinely repeated logic into a shared function once it repeats a third time, not the first time it looks similar. Two similar lines are not a duplication problem; a premature abstraction is worse than the duplication it prevents.

### 4. YAGNI
Do not build configurability, flags, or extension points for requirements that have not been asked for. Add complexity only when a real need exists.

### 5. Naming
Names should say what a thing is or does, not its type or a vague placeholder (`data`, `temp`, `x`). Function names are verb-based; the name should make the call site read like a sentence.

### 6. Immutability by default
Prefer creating new values over mutating existing ones, when the language and performance budget allow it. Mutate deliberately and locally when the language idiom calls for it (e.g. accumulator patterns), not as a default habit.

### 7. Explicit error handling
Every call that can fail (I/O, network, parsing, external services) has its failure path handled or explicitly propagated - never silently swallowed. Error messages should say what failed and, where possible, why.

### 8. Input validation at boundaries
Validate at the edges of the system - user input, external API responses, file/config parsing. Trust internal code and framework guarantees once past the boundary; do not re-validate the same value repeatedly.

### 9. No speculative abstraction
Don't design interfaces, plugin systems, or configuration layers for hypothetical future requirements. A bug fix doesn't need a refactor bundled in; a one-shot script doesn't need a reusable module.

## Security Basics

- Never hardcode credentials, API keys, or tokens - read from environment or a secrets manager
- Treat all external input (user input, API responses, file contents) as untrusted until validated
- Avoid string-concatenated queries/commands where a parameterized or escaped alternative exists (the mechanism is stack-specific - look it up via `stack-discovery` if unfamiliar)
- Don't log secrets or full request/response bodies that may contain sensitive data

## Code Smell Checklist (use during review)

- Functions doing more than one thing, or long enough that a reader loses the thread (a rough signal, not a hard line count)
- Deep nesting - prefer early returns/guard clauses over pyramids of conditionals
- Magic numbers or strings with no named meaning
- Duplicated logic across three or more call sites with no shared home
- Dead code, unused exports, or commented-out blocks left in place
- A comment explaining WHAT the code does where the code itself could just say that via naming

## Comments

Default to none. Write a comment only when the WHY is non-obvious - a hidden constraint, a workaround for a specific external bug, an invariant a future editor could easily break. If removing the comment would not confuse a future reader, remove it.
