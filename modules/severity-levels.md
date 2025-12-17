# Severity Levels Module

**Module:** Issue severity classification
**Version:** 1.0.0

This module defines severity levels for code review findings, task blockers, and issue classification. All workflows should reference this module for consistent severity definitions.

---

## Severity Definitions

### BLOCKER / CRITICAL (Stop the Merge)

**Symbol:** 🔴 or ⛔

Issues that **must be fixed before merge**. The code cannot ship with these present.

**Criteria:**
- Correctness issues (code doesn't do what it should)
- Security vulnerabilities (injection, XSS, auth bypass)
- Data loss or corruption risks
- Architecture violations affecting behavior or maintainability
- Failing tests
- Missing migrations (schema required for code to work)
- Syntax errors or runtime crashes

**Examples:**
- SQL injection in user input handling
- Missing `$fillable` on model with mass assignment
- N+1 query in high-traffic endpoint causing timeouts
- Business logic returns wrong results
- Tests fail on CI

**Action:** Must fix before merge. PR cannot be approved.

---

### MAJOR (Should Fix Before Merge)

**Symbol:** ⚠️

Substantial issues that **increase technical debt or risk**. Should be addressed in this PR.

**Criteria:**
- Standards violations (architecture, code style)
- Missing tests for new code
- New mixins introduced (should use composables)
- Using deprecated/removed APIs
- Performance issues (N+1 in low-traffic areas)
- Poor error handling
- Missing input validation

**Examples:**
- Business logic in controller instead of handler
- New public method without tests
- Using `$on`/`$off` (removed in Vue 3)
- Raw axios calls in Vue component
- Missing type hints on public API

**Action:** Should fix before merge. Reviewer may approve with conditions.

---

### MINOR (Non-Blocking)

**Symbol:** 📋 or ℹ️

Small but worthwhile improvements. **Encourage fixing in this PR** but non-blocking.

**Criteria:**
- Naming improvements
- Documentation gaps
- Code organization suggestions
- Old syntax that works but has better alternatives
- Missing comments on complex logic
- Suboptimal but functional patterns

**Examples:**
- Variable named `$data` instead of `$orderItems`
- Missing PHPDoc on complex method
- Using old `slot="name"` instead of `v-slot:name`
- Global component registration instead of local

**Action:** Nice to have. Mention in review, let author decide priority.

---

### NIT (Optional Polish)

**Symbol:** 💡

Trivial polish items. **Can be skipped** or handled in follow-up.

**Criteria:**
- Style preferences (not rule violations)
- Minor formatting tweaks
- Alternative approaches (neither better nor worse)
- Cosmetic improvements

**Examples:**
- "I'd personally use X instead of Y"
- Slightly different variable ordering
- Extra blank line preferences
- Comment wording suggestions

**Action:** Optional. Mention if helpful, don't block on these.

---

## Auto-Fix Policy

Some issues should be **fixed automatically** rather than reported. This saves review time and reduces noise.

### AUTO-FIX (Fix Silently, Don't Report)

**Symbol:** 🔧 (internal use only - not shown in reports)

Simple, mechanical fixes that have **zero risk** of changing behavior or introducing bugs.

**Two-Step Auto-Fix Process:**

#### Step 1: Run Project Linter/Fixer

**ALWAYS run the project's code style fixer first** on changed files:

```bash
# PHP projects (PHP CS Fixer)
CHANGED_PHP=$(git diff develop --name-only --diff-filter=ACMR | grep '\.php$')
./vendor/bin/php-cs-fixer fix $CHANGED_PHP --config=.php-cs-fixer.php

# JavaScript/TypeScript (Prettier + ESLint)
CHANGED_JS=$(git diff develop --name-only --diff-filter=ACMR | grep -E '\.(js|ts|vue)$')
npx prettier --write $CHANGED_JS && npx eslint --fix $CHANGED_JS
```

**This automatically fixes:**
- Code formatting (indentation, spacing, line length)
- Import ordering
- Trailing commas, semicolons
- Whitespace issues
- Many PSR-12/Airbnb style violations

#### Step 2: Manual Auto-Fixes

After running fixers, manually fix these remaining issues:

**Criteria for Manual Auto-Fix:**
- ✅ Purely cosmetic/formatting changes
- ✅ No behavioral impact whatsoever
- ✅ Single, obvious correct fix
- ✅ Easily reversible if needed

**Manual Auto-Fix Examples:**
- `console.log` / `dd()` / `var_dump()` / `die()` debug statements
- Simple typos in comments (if obvious)
- Obvious dead code that fixers don't catch

**NOT Auto-Fix (Always Report):**
- ❌ Any logic changes
- ❌ Renaming variables/functions (could break external references)
- ❌ Adding/removing code beyond formatting
- ❌ Type annotations (might affect runtime in some languages)
- ❌ Anything requiring judgment calls
- ❌ Changes to public APIs
- ❌ Test modifications

### Auto-Fix Workflow

1. **Run project fixer** on changed files (PHP CS Fixer, Prettier, ESLint, etc.)
2. **Detect** remaining simple issues during review
3. **Verify** it meets auto-fix criteria (purely cosmetic, zero risk)
4. **Apply fix** using Edit tool
5. **Log briefly** in review summary
6. **Do NOT** list individual auto-fixed items in findings

### Summary Mention Format

```markdown
### Auto-Fixed Issues

🔧 **{N} issues auto-fixed** during review:

| Type | Count | Details |
|------|-------|---------|
| Linter/Fixer | {N} files | PHP CS Fixer / Prettier |
| Debug statements | {N} | `dd()`, `console.log()` |
| Other | {N} | Manual formatting fixes |

- No action required - already applied
```

---

## Quick Reference Table

| Level | Symbol | Block Merge? | Must Fix? | Examples |
|-------|--------|--------------|-----------|----------|
| BLOCKER | 🔴 ⛔ | Yes | Yes | Security, correctness, failing tests |
| MAJOR | ⚠️ | Conditional | Should | Standards violations, missing tests |
| MINOR | 📋 ℹ️ | No | Encouraged | Naming, docs, old syntax |
| NIT | 💡 | No | Optional | Style preferences, polish |

---

## Decision Tree

```
Is the code BROKEN or INSECURE?
  └─ Yes → BLOCKER

Does it violate documented STANDARDS?
  └─ Yes → Is it architectural/testable?
             └─ Yes → MAJOR
             └─ No → MINOR

Is it a STYLE preference?
  └─ Yes → NIT

Does it affect MAINTAINABILITY significantly?
  └─ Yes → MAJOR
  └─ Somewhat → MINOR
  └─ Barely → NIT
```

---

## Usage in Reports

### Format for Findings

```markdown
**[SEVERITY]:** [Issue title]
**Location:** `file/path.php:line-number`
**Violation:** [STANDARD §section] (if applicable)
**Issue:** [What's wrong]
**Fix:** [How to resolve]
```

### Summary Table Format

| # | Severity | Issue | Suggestion |
|---|----------|-------|------------|
| 1 | 🔴 BLOCKER | [Issue title] | [Brief fix] |
| 2 | ⚠️ MAJOR | [Issue title] | [Brief fix] |
| 3 | 📋 MINOR | [Issue title] | [Brief fix] |

**Totals:** 🔴 X Blocker | ⚠️ X Major | 📋 X Minor | 💡 X Nit

---

## Category-Specific Severity

### Vue 3 Readiness

| Issue | Severity |
|-------|----------|
| New mixins (use composables) | MAJOR |
| Using `$on`/`$off`/`$once` | MAJOR |
| Using filters `{{ val \| filter }}` | MAJOR |
| Old `slot="name"` syntax | MINOR |
| Global component registration | MINOR |
| Not using composable for new shared logic | NIT |

### Testing

| Issue | Severity |
|-------|----------|
| Failing tests | BLOCKER |
| No tests for new code | MAJOR |
| Using `createMock()` instead of `createStub()` | MINOR |
| Test naming improvements | NIT |

### Security

| Issue | Severity |
|-------|----------|
| SQL injection | BLOCKER |
| XSS vulnerability | BLOCKER |
| Auth bypass | BLOCKER |
| Missing CSRF protection | MAJOR |
| Missing input validation | MAJOR |

---

**End of Module**
