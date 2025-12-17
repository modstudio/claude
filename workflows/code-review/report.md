---
description: Comprehensive code review of all git changes
---

# Full Code Review

Executing comprehensive code review of **ALL git changes** (staged, unstaged, and untracked files).

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
    {content: "Context gathering (YouTrack, commits, task docs, file status)", status: "in_progress", activeForm: "Gathering context"},
    {content: "Extract requirements from task docs (create checklist)", status: "pending", activeForm: "Extracting requirements"},
    {content: "Auto-fix simple issues (formatting, debug statements)", status: "pending", activeForm: "Auto-fixing simple issues"},
    {content: "Architecture review (ALL files)", status: "pending", activeForm: "Reviewing architecture"},
    {content: "Correctness & robustness analysis", status: "pending", activeForm: "Analyzing correctness"},
    {content: "Requirements verification (compare vs task docs)", status: "pending", activeForm: "Verifying requirements"},
    {content: "Code quality review", status: "pending", activeForm: "Reviewing code quality"},
    {content: "Laravel standards check (if applicable)", status: "pending", activeForm: "Checking Laravel standards"},
    {content: "Test coverage verification", status: "pending", activeForm: "Verifying test coverage"},
    {content: "Test execution", status: "pending", activeForm: "Executing tests"},
    {content: "Report generation with suggestions table", status: "pending", activeForm: "Generating report"}
  ]
})
```

**Update todo list as you progress. Mark tasks complete immediately upon finishing.**

---

## Progress Tracking

The phases tracked by the todo list:
1. Context gathering (YouTrack issue + docs, commits, task docs, file status)
2. **Extract requirements from task docs** (create checklist)
3. **Auto-fix simple issues** (formatting, debug statements, whitespace)
4. Architecture review (ALL files - staged, unstaged, untracked)
5. Correctness & robustness analysis
6. **Requirements verification** (compare implementation vs task docs)
7. Code quality review
8. Laravel standards check (if Laravel Boost enabled)
9. Test coverage verification
10. Test execution (using project test commands)
11. Report generation (with requirements compliance matrix)
12. **Compile suggestions summary table** (all issues in one table)

## Phase 1: Context Gathering

**Issue key already available from Phase 0: `ISSUE_KEY`**

### 1.1 Discover Commit Range (Multi-Commit Support)

**If issue key extracted successfully:**
```bash
KEY='STAR-XXXX'  # Replace with actual issue key
git log --all --grep="$KEY" --oneline | head -n 50
LAST=$(git log --all --grep="$KEY" -n 1 --pretty=%H)
git branch -a --contains "$LAST" --format="%(refname:short)"
```

**Record:**
- All commits matching issue key
- Branch containing latest commit
- Commit range for review (not just current branch state)

**If no commits found or single-commit change:**
- Proceed with current branch state only

### 1.2 Load Task Documentation (MANDATORY)

**STOP - Execute this command before continuing:**

```bash
~/.claude/lib/bin/gather-context
```

This outputs all task context including:
- Project and git information
- All task documentation files with full contents
- Requirements, implementation plan, and previous decisions

**If YouTrack MCP available**, also fetch issue details:
```
mcp__youtrack__get_issue
issueId: ${ISSUE_KEY}
```

**Verify before continuing:**
- ✅ Script output reviewed
- ✅ Requirements and implementation plan understood
- ✅ Issue tracker data loaded (if MCP available)

### 1.3 Extract and Record Requirements (from Task Docs)

**If task docs were loaded, extract these key items:**

**From `02-functional-requirements.md`:**
- [ ] List all acceptance criteria (AC1, AC2, etc.)
- [ ] Note any constraints or edge cases mentioned
- [ ] Record expected behaviors

**From `03-implementation-plan.md`:**
- [ ] List planned components/files to be modified
- [ ] Note architectural decisions made
- [ ] Record any technical constraints

**Create Requirements Checklist:**
```markdown
## Requirements to Verify
| ID | Requirement | Status | Evidence |
|----|-------------|--------|----------|
| AC1 | [Description from task docs] | ⏳ Pending | |
| AC2 | [Description from task docs] | ⏳ Pending | |
| ... | ... | ... | |
```

**This checklist will be completed in Phase 6 (Requirements Verification).**

### 1.4 Analyze Scope (Staged AND Unstaged Files)

**CRITICAL:** Review must include BOTH staged and unstaged files.

```bash
# Check all modified files (staged and unstaged)
git status --short

# Separate staged from unstaged
git diff --cached --name-status  # Staged files
git diff --name-status           # Unstaged files

# Get statistics
git diff develop --stat          # All changes vs develop
```

**Categorize files:**

**Staged Files:**
```bash
git diff --cached --name-status
```
- List all staged files by type (migrations, models, services, tests, frontend)
- These are ready for commit

**Unstaged Files:**
```bash
git diff --name-status
```
- List all unstaged files by type

**Record:**
- **Staged files:** [count] - [types]
- **Unstaged files:** [count] - [types]
- **Total lines +/-:** [added/removed]
- **Commit range:** [if multi-commit]

**Files to Review:**
- ✅ Review ALL staged files
- ✅ Review ALL unstaged files
- ✅ Review ALL new/untracked files (if relevant to task)

### 1.5 Load Project Standards

{{MODULE: ~/.claude/modules/standards-loading.md}}

**IMPORTANT:** All findings MUST cite rule references per the citation standards in Phase 0.

## Phase 1.5: Auto-Fix Simple Issues

**BEFORE detailed review, fix trivial issues automatically.** This reduces noise and saves review time.

### Step 1: Run Project Linter/Fixer (if configured)

**Check project config for fixer commands and run them first:**

```bash
# PHP projects - run PHP CS Fixer on changed files
CHANGED_PHP=$(git diff develop --name-only --diff-filter=ACMR | grep '\.php$' | tr '\n' ' ')
if [ -n "$CHANGED_PHP" ]; then
  # Run PHP CS Fixer in fix mode
  docker compose exec -T {container} ./vendor/bin/php-cs-fixer fix $CHANGED_PHP --config=.php-cs-fixer.php
  # Or without docker:
  # ./vendor/bin/php-cs-fixer fix $CHANGED_PHP --config=.php-cs-fixer.php
fi

# JavaScript/TypeScript projects - run prettier/eslint fix
CHANGED_JS=$(git diff develop --name-only --diff-filter=ACMR | grep -E '\.(js|ts|vue|jsx|tsx)$' | tr '\n' ' ')
if [ -n "$CHANGED_JS" ]; then
  npx prettier --write $CHANGED_JS
  npx eslint --fix $CHANGED_JS
fi
```

**Use project-specific commands from `PROJECT_CONTEXT.fixer_commands`:**
```yaml
# Example project config
fixer_commands:
  php: "docker compose exec -T starship_server ./vendor/bin/php-cs-fixer fix {files}"
  js: "npx prettier --write {files} && npx eslint --fix {files}"
```

**Record fixer results:**
- Files fixed by linter: {count}
- Types of fixes applied: {brief description}

### Step 2: Remove Debug Statements

**Find and remove debug statements that fixers might miss:**

```bash
# Find debug statements
git diff develop | grep -E "dd\(|var_dump|print_r|console\.log|die\("
```

**Fix manually using Edit tool:**
- [ ] Remove `dd()`, `var_dump()`, `print_r()`, `die()` debug statements
- [ ] Remove `console.log()` statements (unless in debug utility)

### Step 3: Final Cleanup

**After running fixers, check for remaining issues:**
- [ ] Trailing whitespace (should be fixed by linter)
- [ ] Missing newline at end of file (should be fixed by linter)
- [ ] Extra blank lines (should be fixed by linter)

### What NOT to Auto-Fix

**Always report these (don't auto-fix):**
- Variable/function renaming
- Adding type hints
- Restructuring code
- Any logic changes
- Missing tests
- Architecture issues

### Record Auto-Fixes

Track for final report:
```markdown
AUTO_FIXES_APPLIED:
- Linter/fixer ran: {Yes/No}
- Files fixed by linter: {count}
- Debug statements removed manually: {count}
- Total auto-fixes: {count}
```

## Phase 2: Architecture Review

For EACH modified file, verify compliance with `.ai/rules/20-architecture.md`.

**Reference:** {{MODULE: ~/.claude/modules/review-rules.md}}

Apply the following sections from the shared review rules:
- **Backend Architecture Rules** (Models, Services, Handlers, Repositories, Controllers, FormRequests, Migrations)
- **Frontend Architecture Rules** (Components, Architecture Pattern, API Clients, State Management)
- **Vue 3 Readiness Rules** (Composition API, Deprecated APIs, Template Syntax, Vuex → Pinia)

## Phase 2.5: Correctness & Robustness Analysis

For EACH modified file containing business logic, verify.

**Reference:** {{MODULE: ~/.claude/modules/review-rules.md}}

Apply the **Correctness & Robustness Rules** section (Logic Paths, Error Handling, Type Safety, Concurrency & Async, Data Handling, Transactional Integrity).

**Citation requirement:** All findings must reference [ARCH §correctness] or specific architecture rule.

## Phase 2.8: Requirements Verification (Compare Implementation vs Task Docs)

**If task docs were loaded in Phase 1.3, NOW verify implementation matches requirements.**

### Step 1: Complete the Requirements Checklist

For EACH requirement extracted in Phase 1.3:

| ID | Requirement | Status | Evidence (file:line or test) |
|----|-------------|--------|------------------------------|
| AC1 | [From task docs] | ✅ PASS / ⚠️ PARTIAL / ❌ MISSING | `app/Services/Foo.php:45` |
| AC2 | [From task docs] | ... | ... |

### Step 2: Verify Planned vs Actual Changes

Compare `03-implementation-plan.md` against actual changes:

**Planned files to modify:**
- [ ] File A - Was it modified? Does change match plan?
- [ ] File B - Was it modified? Does change match plan?

**Unexpected changes:**
- List any files modified that weren't in the plan
- Assess if these are necessary or scope creep

### Step 3: Check for Missing Implementation

**For each requirement marked ⚠️ PARTIAL or ❌ MISSING:**
- Document what's missing
- Severity: BLOCKER if core functionality, MAJOR if important, MINOR if edge case

### Step 4: Document Deviations

**If implementation differs from plan:**
- Document the deviation
- Assess if deviation is justified (better approach discovered)
- Flag if deviation needs discussion

**Output:** Requirements compliance matrix for final report.

## Phase 3: Code Quality Review

Check against `.ai/rules/10-coding-style.md`.

**Reference:** {{MODULE: ~/.claude/modules/review-rules.md}}

Apply the **Code Quality Rules** section (Naming, Typing, Comments, Code Metrics).

## Phase 4: Laravel Standards Check

Use `mcp__laravel-boost__search-docs` to verify Laravel best practices:

**Search queries:**
1. "database migrations best practices"
2. "Eloquent model fillable casts relationships"
3. "validation FormRequest rules"
4. "query builder joins performance"

**Verify:**
- [ ] Migrations follow Laravel 12.x conventions
- [ ] Model casts use appropriate types
- [ ] Queries avoid N+1 problems
- [ ] Validation rules properly structured
- [ ] Uses Laravel helpers where appropriate

## Phase 5: Test Coverage Analysis

### 5.1 Find Test Files
```bash
git status --short | grep -E "test|Test"
```

### 5.2 Verify Test Quality

Check EACH test file against `.ai/rules/30-testing.md`.

**Reference:** {{MODULE: ~/.claude/modules/review-rules.md}}

Apply the **Test Quality Rules** section (Test Class Structure, Test Quality, Test Coverage).

### 5.3 Identify Missing Tests

For each new/modified file WITHOUT tests, note:
- File path
- What needs testing
- Suggested test file location
- Test type needed (Unit/Functional/Acceptance)

## Phase 6: Test Execution

Run ALL affected test files using project test commands:

```bash
# For each test file:
${PROJECT_TEST_CMD_UNIT} {test-file-path}
```

**Record results:**
- Test file name
- Number of tests
- Number of assertions
- Execution time
- Status (PASS/FAIL)
- Any failures/errors with details

## Phase 7: Generate Comprehensive Report

Create detailed markdown report with these sections:

### Executive Summary
```markdown
✅ **Review Status:** [PASS / NEEDS WORK / FAIL]
📋 **Requirements:** [N/N implemented] (from task docs)
✅ **Tests:** [X of Y passing]
⚠️ **Critical Issues:** [N]
🔧 **Auto-Fixed:** [N] issues (formatting, debug statements)
📊 **Recommendation:** [APPROVE / NEEDS CHANGES / REJECT]
```

### Overview

**Issue Information:**
- **Issue Key:** [ISSUE-KEY]
- **Summary:** [from YouTrack]
- **Type:** [Feature/Enhancement/Fix/Technical]
- **Priority:** [from YouTrack custom fields]
- **State:** [from YouTrack custom fields]
- **Assignee:** [from YouTrack custom fields]

**Change Summary:**
- **Branch:** [branch name]
- **Commit Range:** [single commit / multiple commits / commit hash range]
- **Files Changed:** [total count] ([N] staged, [N] unstaged, [N] untracked)
- **Lines +/-:** [added/removed]
- **Migrations:** [count]
- **Components:** [backend/frontend/both]

**File Status Breakdown:**
- **Staged:** [N] files
- **Unstaged:** [N] files
- **New (untracked):** [N] files
- **Deleted:** [N] files

**Context Sources:**
- ✅ YouTrack issue description reviewed
- ✅ YouTrack knowledge base articles: [list article IDs, e.g., STAR-A-38, STAR-A-136]
- ✅ Task documentation: [list files found from $PROJECT_TASK_DOCS_DIR/{ISSUE_KEY}-{slug}/]

**Note:** This review analyzed ALL files (staged, unstaged, and untracked) with full business context.

### Requirements Compliance (from Task Docs)

**If task docs were loaded, include this section:**

| ID | Requirement | Status | Evidence |
|----|-------------|--------|----------|
| AC1 | [Description] | ✅ PASS | `file:line`, `TestClass::testMethod` |
| AC2 | [Description] | ⚠️ PARTIAL | Missing edge case handling |
| AC3 | [Description] | ❌ MISSING | Not implemented |

**Summary:**
- ✅ **Fully Implemented:** [N] of [Total] requirements
- ⚠️ **Partially Implemented:** [N] requirements (details above)
- ❌ **Missing:** [N] requirements (BLOCKER if core functionality)

**Plan vs Implementation:**
- **Planned Changes:** [N] files
- **Actual Changes:** [N] files
- **Deviations:** [List any significant deviations from plan]

**If no task docs:** "Task documentation not available - requirements verification skipped."

### Auto-Fixed Issues

🔧 **{N} issues auto-fixed** during review - no action required:

| Type | Count | Details |
|------|-------|---------|
| **Linter/Fixer** | {N} files | PHP CS Fixer / Prettier / ESLint |
| Debug statements | {N} | `dd()`, `console.log()`, `var_dump()` |
| Other manual fixes | {N} | Trailing whitespace, blank lines |
| **Total** | **{N}** | |

**Fixer command used:**
```bash
{actual command run, e.g.: docker compose exec -T starship_server ./vendor/bin/php-cs-fixer fix ...}
```

*These issues were fixed automatically. No findings reported for auto-fixed items.*

---

### What Was Done Well ✅

Organize positive findings by category:

**Architecture & Design:**
- [Specific good decisions]

**Code Quality:**
- [Well-written code examples]

**Testing:**
- [Good test practices]

**Documentation:**
- [Quality docs]

**Standards Compliance:**
- [Adherence to standards]

### Issues Found

Categorize by severity with specific details:

#### CRITICAL ⛔ (Blocking Merge)
For each critical issue:
```markdown
**Issue:** [Clear description]
**Location:** `file/path.php:line-number`
**Violation:** [ARCH §X.Y] or [STYLE §X.Y] or [TEST §X.Y]
**Current Code:**
```php
[actual code snippet]
```
**Problem:** [Why this blocks merge]
**Impact:** [What breaks/risks]
**Fix Required:**
```php
[corrected code or steps]
```
**Command:** `[bash command if applicable]`
```

Common critical issues:
- Failing tests
- Missing migration files
- Security vulnerabilities
- Data loss risks
- Syntax errors

#### MAJOR ⚠️ (Should Fix Before Merge)
Same format as critical (including Violation citation). Examples:
- Standards violations
- Missing tests for new code
- Poor patterns
- Performance issues
- N+1 queries

#### MINOR ℹ️ (Nice to Have)
Same format (including Violation citation). Examples:
- Naming improvements
- Documentation gaps
- Code organization
- Comment clarity

### GitHub-Ready Review Comments

For each issue that requires a GitHub PR comment, format as:

#### Inline Code Suggestions
For simple fixes that can be suggested inline:
````markdown
**[File]: `app/Services/ProductService.php:45-48`**

```suggestion
// Improved version
if (!empty($items)) {
    foreach ($items as $item) {
```
````

#### Architectural Issues
For broader architectural concerns:
```markdown
**Architecture — [Issue Title]** (CRITICAL/MAJOR/MINOR)
Path: `app/Services/ProductService.php:45-60`

**Issue:** [What's wrong]
**Violation:** [ARCH §X.Y]
**Impact:** [Why it matters]
**Fix:** [Concrete solution]

**References:**
- [Link to .ai/rules documentation]
- [Link to Laravel docs if applicable]
```

#### Test Coverage Gaps
For missing or inadequate tests:
```markdown
**Testing — Missing Coverage** (MAJOR)
Path: `app/Domains/Product/Handlers/UpdateProductHandler.php`

**Missing Tests:**
- [ ] `testHandlesEmptyInput()`
- [ ] `testThrowsExceptionOnInvalidData()`
- [ ] `testRollsBackTransactionOnFailure()`

**Violation:** [TEST §2.1] - All business logic must have tests
**Test Location:** `tests/Functional/Domains/Product/Handlers/UpdateProductHandlerTest.php`
```

#### Performance Issues
For N+1 queries, missing indexes, etc.:
```markdown
**Performance — [Issue Title]** (MAJOR)
Path: `app/Repositories/ProductRepository.php:120-135`

**Issue:** N+1 query detected
**Current:** Loading products in loop (1 + N queries)
**Fix:** Eager load relationships with `with(['organization', 'variants'])`

**Violation:** [ARCH §performance]
**Impact:** Page load time increases from 200ms to 2s with 100 products
```

### Architecture Compliance Matrix

| Standard | Status | Notes |
|----------|--------|-------|
| **DDD Structure** | ✅/❌ | [specific findings] |
| **Models** | ✅/❌ | [fillable, casts, relationships] |
| **Services/Handlers** | ✅/❌ | [business logic location] |
| **Repositories** | ✅/❌ | [query patterns] |
| **Database** | ✅/❌ | [migrations, conventions] |
| **Frontend** | ✅/❌ | [components, API clients] |
| **Vue 3 Readiness** | ✅/❌ | [no mixins, no deprecated APIs, v-slot syntax] |
| **Code Style** | ✅/❌ | [naming, typing, PSR-12] |
| **Testing** | ✅/❌ | [coverage, quality, conventions] |
| **Laravel Standards** | ✅/❌ | [best practices] |

### Test Results Summary

| Test File | Tests | Assertions | Time | Status |
|-----------|-------|------------|------|--------|
| ScheinConversionFactorCalculatorTest | 9 | 10 | 0.5s | ✅ PASS |
| RefreshScheinEdiCatalogNumberHandlerTest | 5 | 9 | 5.7s | ✅ PASS |
| ProductServiceTest | 8 | 21 | 8.0s | ✅ PASS |
| **TOTAL** | **22** | **40** | **14.2s** | **✅ ALL PASS** |

If any failures:
```markdown
#### Failed Tests

**Test:** `tests/Unit/FooTest.php::testBar`
**Error:** [error message]
**Cause:** [likely cause]
**Fix:** [how to resolve]
```

### Action Plan

**REQUIRED Before Merge:**
- [ ] [Fix critical issue in ProductService.php:142 - specific fix]
- [ ] [Add missing test for NewFeature]

**RECOMMENDED:**
- [ ] Refactor ScheinCalculator::calculate() (reduce complexity)
- [ ] Add PHPDoc to ProductRepository::findBySchein()
- [ ] Improve naming: `$product1` → `$scheinProduct`

**OPTIONAL:**
- [ ] Extract ProductValidator to separate class
- [ ] Add inline documentation for complex algorithm

### Risk Assessment

**Overall Risk:** [LOW / MEDIUM / HIGH]

**Risk Factors:**
- **Test Coverage:** [X%] - [LOW/MEDIUM/HIGH risk]
- **Migration Safety:** [Safe/Risky] - [details]
- **Breaking Changes:** [None/Minor/Major] - [details]
- **Code Complexity:** [Low/Medium/High] - [details]
- **Database Changes:** [Schema-only/Data migration/Both] - [details]

**Mitigation:**
- [Steps to reduce risks]
- [Rollback plan if needed]

### Documentation, Telemetry & Deployment Check

#### Documentation
- [ ] Task docs (`$PROJECT_TASK_DOCS_DIR/{ISSUE_KEY}-{slug}/`) reviewed and aligned with implementation
- [ ] YouTrack references accurate
- [ ] Code comments sufficient (only when non-obvious)
- [ ] Migration comments clear
- [ ] Breaking changes documented
- [ ] Environment variables documented (if new)

#### Telemetry & Observability
- [ ] Critical paths have logging at INFO level minimum
  - Example: Order creation, payment processing, inventory updates
- [ ] Errors logged with context at ERROR level
  - Include relevant IDs, user info, request data (sanitized)
- [ ] Metrics/traces for performance-sensitive operations
  - Database queries, external API calls, bulk operations
- [ ] No sensitive data in logs
  - ❌ Passwords, tokens, credit cards, PII
  - ✅ IDs, timestamps, status codes, sanitized params
- [ ] Log levels appropriate:
  - DEBUG: Development-only detailed info
  - INFO: Important business events
  - WARNING: Degraded functionality
  - ERROR: Failures requiring attention
  - CRITICAL: System-wide issues

**Citation:** All findings must reference [ARCH §observability] or specific logging standard.

#### Deployment Considerations
- [ ] Feature flags considered for risky changes
- [ ] Gradual rollout plan if needed (phased deployment)
- [ ] Rollback procedure documented
- [ ] Database migrations reversible
- [ ] No downtime expected OR maintenance window planned
- [ ] Cache clearing requirements noted
- [ ] Queue worker restart requirements noted

### Suggestions Summary Table

**REQUIRED:** Compile ALL issues from the review into a single summary table at the end of the report:

| # | Severity | Issue | Suggestion |
|---|----------|-------|------------|
| 1 | 🔴 Critical | [Brief issue title] | [Brief fix recommendation] |
| 2 | ⚠️ Major | [Brief issue title] | [Brief fix recommendation] |
| 3 | 📋 Minor | [Brief issue title] | [Brief fix recommendation] |

**Totals:** 🔴 X Critical | ⚠️ X Major | 📋 X Minor

This table provides a quick reference of all findings. Every issue from CRITICAL, MAJOR, and MINOR sections must appear here with:
- **#**: Sequential number
- **Severity**: 🔴 Critical / ⚠️ Major / 📋 Minor
- **Issue**: Short title (e.g., "N+1 query in ProductRepository")
- **Suggestion**: Brief fix (e.g., "Add eager loading with `with(['variants'])`")

### Final Recommendation

**Decision:** [APPROVE / REQUEST CHANGES / REJECT]

**Justification:**
[2-3 sentence summary of why this decision]

**Next Steps:**
1. [First step]
2. [Second step]
3. [Third step]

---

## Execution Constraints

**You MUST:**
- ✅ **Load full business context** using `~/.claude/lib/bin/gather-context`
- ✅ **Review ALL files** - staged, unstaged, AND new (untracked)
- ✅ **Auto-fix simple issues** before detailed review (Phase 1.5)
- ✅ Track all phases with TodoWrite
- ✅ Read actual file contents (never assume)
- ✅ Run ALL affected tests
- ✅ Provide specific line numbers and file paths
- ✅ Be objective and constructive
- ✅ Cite specific standards from `.ai/rules/`
- ✅ Give code examples for issues
- ✅ Provide bash commands for fixes

**Auto-Fix Allowed (Phase 1.5 only):**
- ✅ Remove debug statements (`dd()`, `console.log()`, `var_dump()`)
- ✅ Fix trailing whitespace
- ✅ Fix missing newlines at end of file
- ✅ Remove extra blank lines
- ✅ Fix obvious formatting issues

**You MUST NOT:**
- ❌ Make logic or behavioral code changes
- ❌ Rename variables or functions
- ❌ Add or modify type hints
- ❌ Restructure code
- ❌ Skip test execution
- ❌ Make assumptions without verification
- ❌ Use generic feedback ("improve naming")
- ❌ Overlook standards violations

**Format Requirements:**
- Use markdown with clear hierarchy
- Code blocks with syntax highlighting
- Checkboxes for action items
- Tables for structured data
- Status badges (✅❌⚠️ℹ️)
- File paths with line numbers
- Bash commands ready to copy-paste

Begin review now.
