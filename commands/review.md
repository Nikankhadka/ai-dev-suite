---
description: Review code for quality, security, and fix build/TypeScript errors
agent: reviewer
subtask: true
---

# Review Command

Review code changes for quality, security, and fix build errors: $ARGUMENTS

## Your Task

1. **Get changed files**: Run `git diff --name-only HEAD`
2. **Run type check**: `npx tsc --noEmit` (if build fix requested)
3. **Analyze each file** for quality and security issues
4. **Fix errors** with minimal changes
5. **Generate structured report**

## Check Categories

### Security Issues (CRITICAL)
- Hardcoded credentials, API keys, tokens
- SQL injection vulnerabilities
- XSS vulnerabilities
- Missing input validation
- Insecure dependencies
- Path traversal risks
- Authentication/authorization flaws

### Code Quality (HIGH)
- Functions > 50 lines, Files > 800 lines
- Nesting depth > 4 levels
- Missing error handling
- console.log statements
- Missing tests for new code

### Build Errors
- Type inference failures → add type annotations
- Null/undefined errors → optional chaining
- Missing properties → add to interface
- Import errors → install package or fix path
- Make minimal changes, no refactoring

## Report Format

For each issue:
```
[SEVERITY] file.ts:123
Issue: [Description]
Fix: [How to fix]
```

## Decision
- **CRITICAL or HIGH issues**: Block, require fixes
- **MEDIUM issues**: Recommend fixes before merge
- **Build errors**: Fix with minimal diff, verify with tsc

**IMPORTANT**: Never approve code with security vulnerabilities. Fix build errors with minimal changes.
