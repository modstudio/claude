---
description: Comprehensive code review of all git changes
---

# Full Code Review

Executing comprehensive code review of **ALL git changes** (staged, unstaged, and untracked files).

---

## Phase 0: Project Context Already Loaded

**Project context was loaded by `/code-review-g` before mode selection.**

Available from project context:
- **Project**: `PROJECT_CONTEXT.project.name`
- **Issue Key**: Already extracted from branch using `PROJECT_CONTEXT.issue_tracking.regex`
- **Standards**: `PROJECT_CONTEXT.standards.location` and `.files[]`
- **Citation Format**: `PROJECT_CONTEXT.citation_format.*` (use for all rule citations)
- **Test Commands**: `PROJECT_CONTEXT.test_commands.*` (all, unit, feature, etc.)
- **Storage**: `${WIP_ROOT}/{ISSUE_KEY}-{slug}/` (where `WIP_ROOT` from `~/.claude/config/global.yaml`)
- **MCP Tools**:
  - YouTrack: `PROJECT_CONTEXT.mcp_tools.youtrack.enabled`
  - Laravel Boost: `PROJECT_CONTEXT.mcp_tools.laravel_boost.enabled`
- **YouTrack Docs**: `PROJECT_CONTEXT.youtrack_docs.available`

**Use these variables instead of hardcoded paths.**

---

## Progress Tracking

Use TodoWrite to create and track these phases:
1. Context gathering (YouTrack issue + docs, commits, task docs, file status)
2. Architecture review (ALL files - staged, unstaged, untracked)
3. Correctness & robustness analysis
4. Laravel standards check (if Laravel Boost enabled)
5. Test coverage verification
6. Test execution (using project test commands)
7. Report generation (with full context + file status warnings)

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

### 1.3 Load Business Context

#### 1.3.1 Get Issue Details from YouTrack

Use YouTrack MCP to retrieve issue information:

```
mcp__youtrack__get_issue
issueId: {ISSUE-KEY}
```

**Extract and record:**
- **Issue Summary:** [from YouTrack]
- **Issue Description:** [full description with business context]
- **Issue Type:** Feature/Enhancement/Fix/Technical/etc.
- **Custom Fields:** State, Priority, Assignee, Type, etc.
- **Tags:** Any relevant tags
- **Linked Issues:** Related/blocking/blocked-by issues
- **Comments:** Review recent comments for context

**Why this matters:**
- Understand the business problem being solved
- Know acceptance criteria if documented in issue
- See related issues that might affect implementation
- Understand priority and risk level

#### 1.3.2 Read YouTrack Knowledge Base Articles

Search for related documentation in local YouTrack docs:

**Step 1: Check Table of Contents**
```bash
# Read the TOC to find relevant articles
cat storage/app/youtrack_docs/000\ Table\ of\ Contents.md
```

**Step 2: Search for relevant articles based on:**
- Issue description keywords
- Domain areas mentioned (Product, Inventory, Shipping, etc.)
- Organizations involved (Schein, Medline, Owens, etc.)

**Step 3: Read relevant articles**

Common articles to check based on domain:
- **Product changes:** `STAR-A-136` - Product domain documentation
- **Inventory changes:** `STAR-A-38` - Inventory Data documentation
- **Shipping changes:** `STAR-A-177` - Shipping documentation
- **Import changes:** `STAR-A-5` - Import system documentation
- **Report changes:** `STAR-A-47` - Report system documentation
- **Organization changes:** `STAR-A-197` - Organization documentation

**How to find articles:**
```bash
# Search TOC for keywords
grep -i "product\|inventory\|shipping" storage/app/youtrack_docs/000\ Table\ of\ Contents.md

# Read specific article (example)
cat storage/app/youtrack_docs/088\ STAR-A-38.md  # Inventory article
```

**Extract from articles:**
- Business rules and constraints
- Data models and relationships
- Process flows and workflows
- Edge cases and special handling
- Integration points

#### 1.3.3 Read Task Documentation

Find and read ALL task documentation:
```bash
# Load .wip root from global config
WIP_ROOT="$HOME/.wip"  # From ~/.claude/config/global.yaml

# Find task folder
TASK_FOLDER=$(find "$WIP_ROOT" -type d -name "{ISSUE-KEY}*" 2>/dev/null | head -1)

# Read all markdown files
if [ -n "$TASK_FOLDER" ]; then
  find "$TASK_FOLDER" -name "*.md" -type f
fi
```
- Read all found files for task-specific requirements, architecture decisions
- Note key requirements and constraints

**Combined Context:**
By this point, you should have:
- ✅ Issue description and acceptance criteria (from YouTrack issue)
- ✅ Domain business rules (from YouTrack knowledge base)
- ✅ Task-specific implementation notes (from task docs)

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
- ⚠️ **WARNING:** If critical files are unstaged (migrations, models, tests), flag for attention

**Untracked Files:**
```bash
git ls-files --others --exclude-standard
```
- List all untracked files
- ⚠️ **WARNING:** New migrations, models, or tests should be tracked

**Record:**
- **Staged files:** [count] - [types]
- **Unstaged files:** [count] - [types]
- **Untracked files:** [count] - [types]
- **Total lines +/-:** [added/removed]
- **Commit range:** [if multi-commit]

**Files to Review:**
- ✅ Review ALL staged files
- ✅ Review ALL unstaged files
- ✅ Review ALL untracked files (if relevant to task)
- ⚠️ Flag if unstaged/untracked files should be staged

**Critical File Check:**
If any of these are unstaged or untracked:
- Migration files (`database/migrations/*.php`)
- New model files (`app/Models/*.php`, `app/Domains/*/Models/*.php`)
- New test files (`tests/**/*Test.php`)

**→ WARN:** These critical files should likely be staged before merge.

### 1.5 Load Project Standards
Read all standards documents:
- `.ai/rules/00-system-prompt.md` - Interaction rules
- `.ai/rules/20-architecture.md` - DDD, models, repositories, database
- `.ai/rules/10-coding-style.md` - Naming, typing, code quality
- `.ai/rules/30-testing.md` - Test coverage and conventions

**IMPORTANT - SSOT Citation Requirement:**
All findings reported in this review MUST cite specific rule references using format:
- `[ARCH §X.Y]` - Architecture rule, section X.Y from 20-architecture.md
- `[STYLE §X.Y]` - Code style rule, section X.Y from 10-coding-style.md
- `[TEST §X.Y]` - Testing rule, section X.Y from 30-testing.md
- `[LARAVEL §topic]` - Laravel best practice from Boost docs

This ensures traceability and allows developers to verify findings against documented standards.

## Phase 2: Architecture Review

For EACH modified file, verify compliance with `.ai/rules/20-architecture.md`:

### Backend Files (PHP)

**Models** (`app/Models/*.php`, `app/Domains/*/Models/*.php`):
- [ ] UUIDs used for IDs where applicable
- [ ] Static constructors for complex creation
- [ ] Eloquent relationships marked `@internal only for Eloquent`
- [ ] Classes declared `final` or `abstract`
- [ ] `$fillable` array properly defined
- [ ] `$casts` defined for booleans, dates, custom types
- [ ] Getter methods have return types
- [ ] No business logic (just accessors/data methods)
- [ ] Follows organization data structure (internal vs customer tables)

**Services** (`app/Services/*.php`, `app/Domains/*/Services/*.php`):
- [ ] Business logic in Command/Handler pattern (not in service methods)
- [ ] Uses DTOs for complex data (not raw arrays)
- [ ] All methods have type hints
- [ ] No database queries (delegated to repositories)
- [ ] Stateless where possible

**Handlers** (`app/Domains/*/Commands/Handlers/*.php`):
- [ ] Single responsibility per handler
- [ ] Dependencies injected via constructor
- [ ] Handles exactly one command
- [ ] Returns appropriate value or void
- [ ] Uses repositories for data access

**Repositories** (`app/Repositories/*.php`, `app/Domains/*/Repositories/*.php`):
- [ ] No business logic
- [ ] Query builders for complex queries
- [ ] Uses Criteria pattern for filters
- [ ] Readable queries (not over-optimized)
- [ ] No computed/raw SQL in model attributes

**Controllers** (`app/Http/Controllers/*.php`):
- [ ] Thin (delegates to handlers/services)
- [ ] Uses FormRequests for validation
- [ ] Returns via ResponseFactory
- [ ] Multi-action where appropriate

**FormRequests** (`app/Http/Requests/**/*.php`):
- [ ] All validation rules defined
- [ ] Uses custom validation rules when needed
- [ ] No business logic in authorize()

**Migrations** (`database/migrations/*.php`):
- [ ] Timestamp format: `YYYY_MM_DD_HHMMSS`
- [ ] Descriptive names
- [ ] Both `up()` and `down()` methods
- [ ] Uses Schema facade
- [ ] Reversible (down() actually works)
- [ ] Table names in `snake_case`
- [ ] Columns: `id` (UUID first), timestamps last
- [ ] Comments on columns for clarity
- [ ] Data migrations separate from schema migrations

### Frontend Files (Vue.js)

**Components** (`resources/js/components/**/*.vue`):
- [ ] File names in PascalCase
- [ ] Component `name` in PascalCase
- [ ] Self-closing empty tags
- [ ] Template tags in PascalCase
- [ ] Imports use `@` alias
- [ ] Include `.vue` extension in imports

**Architecture Pattern - Feature-Dominant with Ad-Hoc UI Layer:**
- [ ] Routes organized by feature domain
- [ ] Components reusable across features
- [ ] Composables extracted for shared logic
- [ ] Follows team's architectural pattern (not generic Vue best practices)

**API Clients** (`resources/js/services/**/*ApiClient.js`):
- [ ] Components don't call axios directly
- [ ] Request/response handling centralized
- [ ] Error handling included

**State Management** (Vuex):
- [ ] Only shared/cached/persistent UI state
- [ ] Mutations via `commit()` only
- [ ] Not used for local component state

## Phase 2.5: Correctness & Robustness Analysis

For EACH modified file containing business logic, verify:

### Logic Paths & Edge Cases
- [ ] All code paths covered (if/else, switch, early returns)
- [ ] Edge cases handled:
  - Empty arrays/collections
  - Null values
  - Zero and negative numbers
  - Boundary conditions (min/max values)
  - Empty strings
- [ ] Default values appropriate
- [ ] Fallback behavior defined

### Error Handling
- [ ] Exceptions properly caught and logged
- [ ] Error messages meaningful to developers
- [ ] User-facing errors appropriate
- [ ] Graceful degradation where applicable
- [ ] No silent failures
- [ ] Stack traces preserved when re-throwing

### Type Safety & Contracts
- [ ] Nullability handled correctly (`?Type` vs `Type`)
- [ ] Type contracts respected (method signatures)
- [ ] No unsafe type coercion
- [ ] Array type safety (`@param array<string, Product>`)
- [ ] Return types match documentation

### Concurrency & Async Patterns
- [ ] Race conditions considered
- [ ] Database transactions used for multi-step operations
- [ ] Locks used appropriately (Redis, database)
- [ ] Idempotency for retryable operations
- [ ] Queue job failures handled
- [ ] Event ordering considered

### Data Handling
- [ ] Timezone awareness in date operations
- [ ] DateTime objects used (not strings)
- [ ] Pagination bounds checked
- [ ] Large dataset handling (chunking, streaming)
- [ ] Memory usage considered for bulk operations
- [ ] Currency precision maintained (decimal types)

### Transactional Integrity
- [ ] Database transactions around multi-step operations
- [ ] Rollback on failure
- [ ] No partial state on errors
- [ ] Atomic operations where needed
- [ ] Savepoints for nested transactions

**Citation requirement:** All findings must reference [ARCH §correctness] or specific architecture rule.

## Phase 3: Code Quality Review

Check against `.ai/rules/10-coding-style.md`:

### Naming
- [ ] Precise, self-documenting names (no `product1`, `product2`)
- [ ] Booleans: `is*/has*/should*`
- [ ] Collections: plural; elements: singular
- [ ] Units in names: `*Seconds`, `*Dollars`, `*Meters`
- [ ] Intent-based: `$validPayload`, `$existingUser`

### Typing
- [ ] Scalar types declared everywhere possible
- [ ] Return types on all methods
- [ ] No `mixed` unless absolutely necessary
- [ ] Property types declared (PHP 7.4+)

### Comments
- [ ] Only when non-obvious
- [ ] PHPDoc for complex generics: `@return array<string, Product>`
- [ ] Links to business docs where relevant
- [ ] No commented-out code

### Code Quality
- [ ] Functions ≤50 lines (guideline)
- [ ] Lines ≤170 characters (guideline)
- [ ] No forbidden functions: `dd`, `var_dump`, `echo`, `print_r`, `dump`
- [ ] No debug statements left in code
- [ ] PSR-12 compliance

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

Check EACH test file against `.ai/rules/30-testing.md`:

**Test Class Structure:**
- [ ] Class declared `final`
- [ ] Method names in `camelCase`
- [ ] Return type `void` on all test methods
- [ ] Uses `self::assertSame()` NOT `$this->assertSame()`
- [ ] Uses `createStub()` preferred over `createMock()`
- [ ] Never uses `createMock()` (always use `createStub()` or `createConfiguredMock()`)

**Test Quality:**
- [ ] Descriptive variable names (`$expectedResult`, not `$result1`)
- [ ] Covers happy path
- [ ] Covers error scenarios
- [ ] Uses fixtures from `tests/Fixtures/`
- [ ] Uses builders from `tests/ModelBuilders/`
- [ ] Meaningful test data (not just `'test'`)
- [ ] Data providers for multiple scenarios
- [ ] Precise assertions (verify business effects, not just method calls)

**Test Coverage:**
- [ ] All new public methods have tests
- [ ] All new classes have tests
- [ ] Modified business logic has tests
- [ ] Edge cases covered

### 5.3 Identify Missing Tests

For each new/modified file WITHOUT tests, note:
- File path
- What needs testing
- Suggested test file location
- Test type needed (Unit/Functional/Acceptance)

## Phase 6: Test Execution

Run ALL affected test files:

```bash
# For each test file:
docker compose --project-directory . -f ./docker-compose.yml exec -u1000 starship_server ./vendor/bin/phpunit {test-file-path}
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
✅ **Tests:** [X of Y passing]
⚠️ **Critical Issues:** [N]
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
- ✅ **Staged:** [N] files ready for commit
- ⚠️ **Unstaged:** [N] files modified but not staged
- ⚠️ **Untracked:** [N] new files not in git
- 🗑️ **Deleted:** [N] files removed

**Context Sources:**
- ✅ YouTrack issue description reviewed
- ✅ YouTrack knowledge base articles: [list article IDs, e.g., STAR-A-38, STAR-A-136]
- ✅ Task documentation: [list files found from $WIP_ROOT/{ISSUE_KEY}-{slug}/]

**Note:** This review analyzed ALL files (staged, unstaged, and untracked) with full business context.

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

### Files Requiring Attention

**CRITICAL:** Review includes staged AND unstaged files.

**File Status Summary:**
| Category | Count | Action Required |
|----------|-------|-----------------|
| Staged | [N] | ✅ Ready for commit |
| Unstaged | [N] | ⚠️ Review and stage if needed |
| Untracked | [N] | ⚠️ Add to git if needed |

**Staged Files (Ready for commit):**
```
✅ app/Services/ProductService.php
✅ app/Models/Product.php
✅ tests/Unit/ProductServiceTest.php
```

**Unstaged Files (Modified but not staged):**
```
⚠️ app/Models/Product.php
⚠️ app/Repositories/ProductRepository.php
```
**Action:** Review changes and stage if they should be included in this commit.

**Untracked Files (New files not in git):**
```
⚠️ database/migrations/2025_11_13_100000_add_new_fields.php
⚠️ tests/Fixtures/Products/NewProductFixture.php
```
**Action:** Critical files (migrations, models, tests) should be added to git.

**Deleted Files:**
```
✅ app/OldClass.php (confirmed dead code removal)
✅ app/Deprecated/Service.php (confirmed cleanup)
```

**⚠️ WARNINGS:**

If critical files are unstaged or untracked:
```markdown
**WARNING - Critical Unstaged Files:**
- `database/migrations/2025_11_13_100000_*.php` - Migration should be staged
- `app/Models/NewModel.php` - New model should be staged

**Command to stage:**
```bash
git add database/migrations/2025_11_13_100000_*.php
git add app/Models/NewModel.php
```
```

**Note:** All files (staged, unstaged, untracked) were reviewed for compliance.

### Action Plan

**REQUIRED Before Commit:**
```bash
# 1. Stage migration files
git add database/migrations/2025_11_13_100000_*.php

# 2. Fix critical issue in ProductService.php:142
[specific fix]

# 3. Add missing test for NewFeature
[test creation steps]
```

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
- [ ] Task docs ($WIP_ROOT/{ISSUE_KEY}-{slug}/) reviewed and aligned with implementation
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
- ✅ **Load full business context:**
  - Get issue from YouTrack using `mcp__youtrack__get_issue`
  - Read relevant YouTrack knowledge base articles from `storage/app/youtrack_docs/`
  - Read task documentation from `$WIP_ROOT/{ISSUE_KEY}-{slug}/`
- ✅ **Review ALL files** - staged, unstaged, AND untracked
- ✅ **Check file status** explicitly using `git diff --cached` and `git diff`
- ✅ **Warn** if critical files (migrations, models, tests) are unstaged or untracked
- ✅ Track all phases with TodoWrite
- ✅ Read actual file contents (never assume)
- ✅ Run ALL affected tests
- ✅ Provide specific line numbers and file paths
- ✅ Be objective and constructive
- ✅ Cite specific standards from `.ai/rules/`
- ✅ Give code examples for issues
- ✅ Provide bash commands for fixes

**You MUST NOT:**
- ❌ Make any code changes
- ❌ Create or edit files
- ❌ Run formatters or fixers
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
