# Module: linter-failure-handling

## Purpose
Handle linter/static analysis failures with root cause analysis and best practice solutions. The goal is NOT just to make checks pass, but to improve code quality and optimize linter configurations.

## Scope
CODE-REVIEW - Used after auto-fix phase when linter issues remain

## Mode
ANALYSIS (requires user approval for any suppressions)

---

## Configuration

Linter preferences are loaded from project YAML and available as environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `$PROJECT_LINTING_ALLOW_BASELINES` | Allow baseline files for gradual adoption | `false` |
| `$PROJECT_LINTING_ALLOW_INLINE_IGNORES` | Allow inline suppress comments | `false` |
| `$PROJECT_LINTING_PREFER_CONFIG` | Prefer config-level rules over inline | `true` |
| `$PROJECT_LINTING_REQUIRE_JUSTIFICATION` | Require documented reason for exceptions | `true` |

**Check project config before suggesting solutions:**

```bash
# Check what's allowed for this project
echo "Baselines allowed: $PROJECT_LINTING_ALLOW_BASELINES"
echo "Inline ignores allowed: $PROJECT_LINTING_ALLOW_INLINE_IGNORES"
```

**Respect project configuration** - Each project team decides their approach to:
- Baseline files (useful for gradual strictness adoption)
- Inline suppressions (some teams prefer, others prohibit)
- Config-level exceptions vs code fixes

---

## Core Principles

### 1. Never Suppress Without Understanding
- **DO NOT** add inline ignores without user approval
- **DO NOT** add config exceptions without user approval
- **DO** understand WHY the linter is flagging the issue first

### 2. Root Cause Analysis First
Every linter failure has one of these root causes:
1. **Genuine code issue** - Code violates best practices and should be fixed
2. **False positive** - Linter rule doesn't fit this codebase/situation
3. **Configuration gap** - Linter needs tuning for this tech stack
4. **Edge case** - Valid code pattern that linter doesn't recognize

### 3. Optimize the Process
The goal is continuous improvement:
- Reduce false positives by tuning rules
- Catch real issues by enabling appropriate rules
- Document decisions for future reference

---

## Failure Analysis Workflow

### Step 1: Collect All Failures

```bash
# Run linters in check/report mode and capture output
# PHP
./vendor/bin/php-cs-fixer fix --dry-run --diff 2>&1
./vendor/bin/phpstan analyse --error-format=table 2>&1
./vendor/bin/phpcs --report=full 2>&1

# JavaScript/TypeScript
npx eslint . --format=stylish 2>&1
npx tsc --noEmit 2>&1

# Python
ruff check . 2>&1
mypy . 2>&1
```

### Step 2: Categorize Each Failure

For each failure, determine:

| Category | Action | Example |
|----------|--------|---------|
| **Fix Required** | Modify code to comply | Missing return type, unused variable |
| **Rule Misconfigured** | Adjust linter config | Rule too strict for codebase patterns |
| **False Positive** | Consider rule adjustment | Valid pattern flagged incorrectly |
| **Requires Discussion** | Ask user | Architectural decision needed |

### Step 3: Analyze Based on Tech Stack

**PHP (Laravel):**
- PHPStan errors → Check level, consider adjusting rules in `phpstan.neon`
- PHP-CS-Fixer → Most are auto-fixable, check `.php-cs-fixer.php` for rule conflicts
- Psalm → Type inference issues often need proper annotations or config adjustments

**TypeScript/JavaScript:**
- ESLint → Check if rule makes sense for framework (Vue, React, etc.)
- TypeScript → Type errors usually indicate real issues
- Consider `strict` mode implications

**Python:**
- Ruff/Flake8 → Check if rule conflicts with project conventions
- MyPy → Type stubs may be needed for third-party libs
- Consider per-file vs global config in `pyproject.toml`

---

## Resolution Strategies

### Strategy 1: Fix the Code (Preferred)

**When to use:** The linter is right, code should change

```markdown
**Issue:** PHPStan error - Parameter $user has no type
**Root Cause:** Missing type declaration
**Solution:** Add type hint `User $user`
**Action:** Fix code directly
```

### Strategy 2: Tune the Configuration

**When to use:** Rule is too strict/lenient for this codebase globally

**Requires user approval before making changes.**

```markdown
**Issue:** ESLint `no-console` flagging intentional debug utilities
**Root Cause:** Debug utility file should allow console statements
**Recommendation:** Add override in `.eslintrc` for debug utility files
**Proposed Change:**
\`\`\`json
{
  "overrides": [{
    "files": ["**/debug/**"],
    "rules": {"no-console": "off"}
  }]
}
\`\`\`
**Trade-off:** Debug files won't be linted for console statements
```

### Strategy 3: Adjust Rule Level

**When to use:** Rule is valuable but current level causes false positives

**Requires user approval.**

```markdown
**Issue:** PHPStan level 8 flagging dynamic property access patterns
**Root Cause:** Level too strict for current codebase patterns
**Recommendation:** Adjust specific rule, not entire level
**Proposed Change:**
\`\`\`neon
parameters:
  ignoreErrors:
    - '#Access to an undefined property#'
      path: src/Legacy/*
\`\`\`
**Trade-off:** Specific pattern allowed in specific path only
```

### Strategy 4: Use Baseline (If Project Allows)

**When to use:** Gradual strictness adoption, legacy codebase migration

**Check first:**
```bash
if [[ "$PROJECT_LINTING_ALLOW_BASELINES" == "true" ]]; then
  echo "Baselines are allowed for this project"
fi
```

**If `$PROJECT_LINTING_ALLOW_BASELINES` = true:**
```markdown
**Issue:** 200+ existing errors when enabling stricter analysis
**Root Cause:** Legacy code predates current standards
**Recommendation:** Generate baseline, enforce on new code only
**Command:** `./vendor/bin/phpstan analyse --generate-baseline`
**Trade-off:** Legacy issues tracked separately, new code enforced
```

**If `$PROJECT_LINTING_ALLOW_BASELINES` = false:** Do not suggest baselines. Focus on fixing issues or adjusting rules instead.

### Strategy 5: Add Path-Based Exceptions

**When to use:** Certain directories have different requirements (e.g., tests, migrations)

**Requires user approval.**

```markdown
**Issue:** TypeScript strict null checks failing in test mocks
**Root Cause:** Test mocks intentionally use partial objects
**Recommendation:** Adjust tsconfig for test files
**Proposed Change:** Create `tsconfig.test.json` extending base with relaxed rules
**Trade-off:** Tests have slightly less strict typing (acceptable for mocks)
```

---

## User Approval Required

**STOP and ask user before:**

1. Adding ANY inline ignore/suppress comment
2. Modifying linter configuration files
3. Generating or updating baselines
4. Disabling rules globally or per-path
5. Adding files/directories to ignore lists
6. Changing rule severity levels

**Present to user:**

```markdown
## Linter Configuration Changes Needed

The following changes require your approval:

### 1. [Issue Description]
- **File:** `path/to/file.ts:42`
- **Error:** `[error message]`
- **Root Cause:** [analysis]
- **Recommended Fix:** [solution]
- **Alternative:** [if applicable]
- **Trade-off:** [what we give up]

**Options:**
1. Fix the code (recommended if feasible)
2. Adjust rule configuration
3. Use baseline (if project allows)
4. Defer (add to tech debt tracking)
```

---

## Output Format

```markdown
## Linter Analysis Report

### Project Config
- **Baselines allowed:** $PROJECT_LINTING_ALLOW_BASELINES
- **Inline ignores allowed:** $PROJECT_LINTING_ALLOW_INLINE_IGNORES
- **Prefer config over inline:** $PROJECT_LINTING_PREFER_CONFIG
- **Require justification:** $PROJECT_LINTING_REQUIRE_JUSTIFICATION

### Summary
- **Total failures:** {N}
- **Auto-fixable:** {N} (already fixed in auto-fix phase)
- **Requires code change:** {N}
- **Requires config change:** {N} (needs approval)
- **Requires discussion:** {N}

### Failures Requiring Code Changes

| File | Line | Rule | Issue | Recommended Fix |
|------|------|------|-------|-----------------|
| ... | ... | ... | ... | ... |

### Configuration Recommendations

{detailed analysis with approval requests}

### Process Improvements

Based on this analysis, consider:
1. [Recommendation for improving linter config]
2. [Recommendation for avoiding similar issues]
3. [Recommendation for team documentation]
```

---

## Common Anti-Patterns

### ❌ Suppress Without Context
```typescript
// BAD: No explanation
// @ts-ignore
someProblematicCode();
```

### ❌ Blanket Disable
```javascript
// BAD: Disables rule for entire file without reason
/* eslint-disable no-unused-vars */
```

### ❌ Config Bloat
```json
// BAD: Too many exceptions without documented reasons
{
  "rules": {
    "rule1": "off",
    "rule2": "off",
    "rule3": "off"
  }
}
```

### ✅ Documented Suppression (If Allowed)
```typescript
// GOOD: Explains why, uses expect-error, references issue
// @ts-expect-error - External library type mismatch, tracked in PROJ-123
externalLibraryCall(data);
```

### ✅ Targeted Config Adjustment
```json
// GOOD: Specific override for specific case with clear scope
{
  "overrides": [{
    "files": ["src/legacy/**/*.ts"],
    "rules": {"@typescript-eslint/no-explicit-any": "warn"}
  }]
}
```

---

## Integration with Auto-Fix Phase

This module runs AFTER auto-fix when issues remain:

1. Auto-fix phase runs fixers
2. Verify with dry-run
3. If failures remain → invoke this module
4. Load project linting config preferences
5. Analyze each failure by category
6. Present findings to user with recommendations
7. Apply ONLY user-approved changes
8. Document decisions for future reference

---

**End of Module**
