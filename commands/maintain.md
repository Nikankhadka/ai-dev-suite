---
description: Clean dead code, consolidate duplicates, and update documentation
agent: maintainer
subtask: true
---

# Maintain Command

Analyze and clean up the codebase: $ARGUMENTS

## Your Task

1. **Detect dead code** using analysis tools
2. **Identify duplicates** and consolidation opportunities
3. **Safely remove** unused code with documentation
4. **Update documentation** to reflect recent changes

## Detection Phase

```bash
# Find unused exports
npx knip

# Find unused dependencies
npx depcheck

# Find unused TypeScript exports
npx ts-prune
```

## Removal Phase

### Before Removing
1. Search for usage - grep, find references
2. Check exports - might be used externally
3. Verify tests - no test depends on it
4. Document removal in DELETION_LOG.md

### Safe Removal Order
1. Remove unused imports first
2. Remove unused private functions
3. Remove unused exported functions
4. Remove unused types/interfaces
5. Remove unused files

## Documentation Updates

### Types of Docs to Update
- README.md - installation, features, setup
- API documentation - endpoints, request/response formats
- Code comments - JSDoc for public APIs
- Guides - how-to tutorials, troubleshooting

### Update Checklist
- README reflects current features
- API docs match endpoints
- JSDoc updated for changed functions
- Examples are working
- Links are valid

## Verification

After cleanup:
1. `npm run build` - builds successfully
2. `npm test` - all tests pass
3. `npm run lint` - no new lint errors
4. Documentation matches current code

**CAUTION**: Always verify before removing. When in doubt, ask or add `// TODO: verify usage` comment.
