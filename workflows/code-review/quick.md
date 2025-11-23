---
description: Quick code review checklist for small changes
---

# Quick Code Review

Running fast checklist review for small changes. This review focuses on critical issues only.

**Use for:** Small PRs, bug fixes, minor refactors

---

## Phase 0: Project Context Already Loaded

**Project context was loaded by `/code-review-g` before mode selection.**

Available from project context:
- **Project**: `PROJECT_CONTEXT.project.name`
- **Issue Key**: Extracted from branch using `PROJECT_CONTEXT.issue_tracking.regex`
- **Standards**: `PROJECT_CONTEXT.standards.location` and `.files[]`
- **Citation Format**: Use `PROJECT_CONTEXT.citation_format.*` for all citations
- **Test Commands**: `PROJECT_CONTEXT.test_commands.*`
- **MCP Tools**: YouTrack, Laravel Boost (if enabled)

**Use these variables instead of hardcoded paths.**

---

**IMPORTANT:** All findings must cite specific rule references using project citation format:
- Architecture: Use `PROJECT_CONTEXT.citation_format.architecture`
- Style: Use `PROJECT_CONTEXT.citation_format.style`
- Test: Use `PROJECT_CONTEXT.citation_format.test` (if available)

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
```bash
git status database/migrations/
```

- [ ] All migration files staged/committed (no untracked)
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

---

## 3. Forbidden Code Check (1 min)

Quick grep for forbidden patterns:

```bash
git diff develop | grep -E "dd\(|var_dump|print_r|console\.log|die\("
```

- [ ] No debug statements found (`dd`, `var_dump`, `print_r`)
- [ ] No `console.log` in production code
- [ ] No `die()` statements

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
