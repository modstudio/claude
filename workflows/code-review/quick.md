---
description: Quick code review checklist for small changes
---

# Quick Code Review

Running fast checklist review for small changes. This review focuses on critical issues only.

**Use for:** Small PRs, bug fixes, minor refactors

---

## Phase 0: Project Context

{{MODULE: ~/.claude/modules/phase-0-context.md}}

**Severity Levels:** {{MODULE: ~/.claude/modules/severity-levels.md}}

**Citation Format:** {{MODULE: ~/.claude/modules/citation-standards.md}}

---

## 📋 MANDATORY: Initialize Todo List

**IMMEDIATELY after loading context, create a todo list to track review progress:**

```javascript
TodoWrite({
  todos: [
    {content: "Check scope (decide quick vs full review)", status: "in_progress", activeForm: "Checking scope"},
    {content: "Check critical files (migrations, models, services, frontend)", status: "pending", activeForm: "Checking critical files"},
    {content: "Run auto-fix phase (linter, debug statements)", status: "pending", activeForm: "Running auto-fix phase"},
    {content: "Verify tests", status: "pending", activeForm: "Verifying tests"},
    {content: "Run tests", status: "pending", activeForm: "Running tests"},
    {content: "Generate quick report", status: "pending", activeForm: "Generating quick report"}
  ]
})
```

**Update todo list as you progress. Mark tasks complete immediately upon finishing.**

---

## 1. Scope Check (1 min)

```bash
git status --short
git diff develop --stat
```

**Record:**
- Files changed: _____
- Lines +/-: _____
- Type: [Backend/Frontend/Both/Migrations/Tests]

**Quick decision:**
- If >500 lines changed → Use `/code-review-full` instead
- If complex architectural changes → Use `/code-review-full` instead
- Otherwise → Continue with quick review

---

## 2. Critical File Checks (2 min)

### Migration Files (if any)
- [ ] Migrations have both `up()` and `down()` methods
- [ ] Migration timestamps are sequential
- [ ] Data migrations are safe (no data loss)
- [ ] Column comments present for new fields

### Model Changes (if any)
For each modified model:
- [ ] `$fillable` array updated for new columns
- [ ] `$casts` defined for booleans/dates
- [ ] Methods have return types
- [ ] No business logic (only getters/setters)
- [ ] Relationships marked `@internal only for Eloquent`

### Service/Handler Changes (if any)
- [ ] Business logic in handlers, not controllers
- [ ] Uses DTOs, not raw arrays (for >2-3 parameters)
- [ ] Type hints everywhere
- [ ] No obvious N+1 query issues

### Frontend Changes (if any)
- [ ] No `axios` calls in components (use `*ApiClient`)
- [ ] Props properly typed
- [ ] No `console.log` left behind
- [ ] Components use PascalCase
- [ ] Imports use `@` alias

### Vue 3 Readiness (if frontend changes)
- [ ] No new mixins introduced (use composables `use*.js` instead)
- [ ] No `$on`/`$off`/`$once` usage (removed in Vue 3)
- [ ] No filters `{{ value | filter }}` (use computed/methods)
- [ ] Uses `v-slot` syntax, not deprecated `slot` attribute
- [ ] No `Vue.set()`/`Vue.delete()` calls

---

## 3. Auto-Fix Phase (Code Style & Debug Statements)

**Run fixers and remove debug statements before reviewing.**

### Step 1: Run Code Style Fixer

```bash
# Get changed PHP files
CHANGED_PHP=$(git diff develop --name-only --diff-filter=ACMR | grep '\.php$' | tr '\n' ' ')

# Run PHP CS Fixer on changed files
if [ -n "$CHANGED_PHP" ]; then
  docker compose exec -T {container} ./vendor/bin/php-cs-fixer fix $CHANGED_PHP --config=.php-cs-fixer.php
fi

# For JS/TS projects:
CHANGED_JS=$(git diff develop --name-only --diff-filter=ACMR | grep -E '\.(js|ts|vue)$' | tr '\n' ' ')
if [ -n "$CHANGED_JS" ]; then
  npx prettier --write $CHANGED_JS && npx eslint --fix $CHANGED_JS
fi
```

**Record:**
- Files fixed by linter: _____ (count)

### Step 2: Remove Debug Statements

```bash
# Find debug statements
git diff develop | grep -E "dd\(|var_dump|print_r|console\.log|die\("
```

**If found, use Edit tool to remove:**
- `dd()` - Remove entire statement
- `var_dump()` - Remove entire statement
- `print_r()` - Remove entire statement
- `console.log()` - Remove entire statement (unless in debug utility file)
- `die()` - Remove entire statement

**Record:**
- Debug statements removed: _____ (count)

---

## 4. Test Verification (1-2 min)

### Find test files:
```bash
git status --short | grep -E "test|Test"
```

**For each test file, quick check:**
- [ ] Class is `final`
- [ ] Methods use `camelCase`
- [ ] Uses `self::assertSame()` not `$this->assertSame()`
- [ ] No `createMock()` (use `createStub()` or `createConfiguredMock()`)
- [ ] Descriptive variable names

**Coverage check:**
- [ ] New public methods have tests
- [ ] Modified business logic has tests

---

## 5. Run Tests (2-3 min)

Run ALL modified test files:

```bash
# Run each modified test file:
docker compose --project-directory . -f ./docker-compose.yml exec -u1000 starship_server ./vendor/bin/phpunit {test-file-path}
```

**Record results:**
- Tests run: _____
- Status: [PASS/FAIL]

If tests FAIL:
- ❌ **STOP** - Address failing tests before merge
- Document failure reason
- Provide fix guidance

---

## 6. Quick Report

### Status

**Overall:** [✅ PASS / ⚠️ NEEDS WORK / ❌ FAIL]

### Auto-Fixed
- 🔧 Files fixed by linter: [count]
- 🔧 Debug statements removed: [count]

### Scope
- Files changed: [count]
- Lines +/-: [added/removed]
- Tests: [X/Y passing]

### Critical Issues Found

If any critical issues:
```markdown
⛔ **CRITICAL:** [Issue description]
**File:** `path/to/file.php:line`
**Violation:** [ARCH §X.Y] or [STYLE §X.Y] or [TEST §X.Y]
**Fix:** [How to resolve]
```

Otherwise:
```markdown
✅ No critical issues found
```

### Major Issues Found

If any major issues:
```markdown
⚠️ **MAJOR:** [Issue description]
**File:** `path/to/file.php:line`
**Violation:** [ARCH §X.Y] or [STYLE §X.Y] or [TEST §X.Y]
**Fix:** [How to resolve]
```

Otherwise:
```markdown
✅ No major issues found
```

### Quick Wins (Optional improvements)

- [ ] [Optional improvement 1]
- [ ] [Optional improvement 2]

### Action Required

**Before Commit:**
```bash
# [List any bash commands needed]
```

**Changes Needed:**
- [ ] [Required change 1]
- [ ] [Required change 2]

### Final Decision

**Recommendation:** [APPROVE ✅ / FIX REQUIRED ⚠️ / REJECT ❌]

**Justification:** [One sentence why]

**Next Steps:** [What to do next]

---

## Constraints

**This quick review checks:**
- ✅ Critical file issues (migrations, models, tests)
- ✅ Forbidden code patterns
- ✅ Test execution
- ✅ Basic standards compliance

**This quick review DOES NOT check:**
- ❌ Full architecture compliance
- ❌ Laravel standards via Boost
- ❌ Detailed code quality
- ❌ Complex business logic validation
- ❌ Performance optimization
- ❌ Full documentation review

**For comprehensive review, use:** `/code-review-full`

---

Begin quick review now.
