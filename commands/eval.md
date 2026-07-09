---
description: Run evaluation, verification, and quality gates
agent: ops
subtask: true
---

# Eval Command

Run evaluation, verification checkpoints, and quality gates: $ARGUMENTS

## Operations

### Evaluation
Run structured evaluation against acceptance criteria:
- **Binary Grader** - Pass/Fail
- **Scalar Grader** - Score 0-100
- **Rubric Grader** - Category scores

### Verification
- `checkpoint` - Save verification state and progress
- `verify` - Run verification loop against criteria

### Quality Gates
- `quality-gate` - Run quality gates on file/repo scope
- Check: lint, types, tests, coverage, security

## Evaluation Process

### Step 1: Define Criteria
```
Acceptance Criteria:
1. [Criterion 1] - [weight]
2. [Criterion 2] - [weight]
```

### Step 2: Run Tests
For each criterion: execute relevant test, collect evidence, score result

### Step 3: Calculate Score
```
Final Score = Σ (criterion_score × weight) / total_weight
```

### Step 4: Report
```
## Overall: [PASS/FAIL] (Score: X/100)

| Criterion | Score | Weight | Weighted |
|-----------|-------|--------|----------|
| [Criterion 1] | X/10 | 30% | X |
```

## Quality Gates

Run before deployment:
- [ ] All tests pass
- [ ] TypeScript build succeeds
- [ ] Lint passes
- [ ] No security vulnerabilities
- [ ] Test coverage >= 80%
- [ ] No console.log in production code

**TIP**: Use eval for acceptance testing before marking features complete.
