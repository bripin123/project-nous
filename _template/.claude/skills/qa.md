---
name: qa
description: Use after implementation to run systematic QA testing, find bugs, fix them, and generate regression tests. 3 tiers (Quick/Standard/Exhaustive).
---

# /qa — QA Testing + Bug Fixing

> Run browser-based QA tests or code-based functional tests.
> Fix bugs when found + automatically generate regression tests.

## Usage
```
/qa                          # Full QA (default: standard tier)
/qa --quick                  # critical/high only
/qa --exhaustive             # Everything including low/cosmetic
/qa --report-only            # Bug report only (no fixes)
```

## Test Tiers

| Tier | Scope | Time |
|------|-------|------|
| **Quick** | Critical + High only | ~30 sec |
| **Standard** | + Medium (default) | ~2 min |
| **Exhaustive** | + Low + Cosmetic | ~5 min |

## Protocol

### Phase 1: Environment Assessment
- Detect test framework (jest, vitest, pytest, playwright, etc.)
- Understand existing test file structure (naming, import style)
- Determine project type (webapp/API/CLI/library)

### Phase 2: Systematic Testing
**If webapp:**
- Traverse each page
- Per-page check: visual confirmation, interactions, forms, navigation, error states, console errors
- Responsive check (if possible)

**If API:**
- Call each endpoint
- Verify success/error/edge-case responses
- Check permissions for endpoints requiring authentication

**If library/CLI:**
- Test by public API function
- Edge cases, error handling

### Phase 3: Issue Classification
| Severity | Criteria |
|--------|------|
| **Critical** | Function broken, data loss, security vulnerability |
| **High** | Major function failure, severe UX issue |
| **Medium** | Partial function failure, inconvenience |
| **Low** | Minor UI, improvement |
| **Cosmetic** | Typo, alignment |

### Phase 4: Fix Loop (Unless --report-only)
For each issue:
1. Pinpoint source location
2. Minimal fix
3. **Generate regression test** (matching project conventions)
4. Verify test execution
5. Atomic commit (1 commit per issue)

### Regression Test Rules
- Read 2-3 existing project test files to grasp conventions
- Use identical naming, import, and assertion styles
- Set preconditions that precisely reproduce the bug's codepath
- Skip tests for pure CSS/cosmetic bugs
- Include attribution comment: `// Regression: [Issue description]`

### Phase 5: QA Report
```markdown
## QA Report

### Summary
- Found: [N] items (Critical [N], High [N], Medium [N], Low [N])
- Fixed: [N] items
- Regression tests generated: [N] items

### Issues
| # | Severity | Description | Status |
|---|--------|------|------|
| 1 | Critical | 500 error on login failure | Fixed ✅ |
| 2 | Medium | Date format mismatch | Fixed ✅ |
```

## Notes
- Verify working tree is clean before fixing (if dirty, suggest commit/stash)
- If a fix causes regression, execute `git revert HEAD` then report
- Auto-abort if 50+ items found (fundamental quality issue)
