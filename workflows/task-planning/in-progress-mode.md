# In Progress Mode - Review & Sync

**Mode**: Review existing work and sync docs with implementation
**When to use**: Resuming work, reviewing progress, docs out of sync with code

---

## Assumptions

- Work has already started
- `.wip` folder and/or git branch exists
- Code may have diverged from documentation
- Need to understand current state and sync docs

---

## Purpose

In Progress Mode performs a comprehensive review to:
- **Understand current state** - What's done, what's in progress, what's left
- **Identify discrepancies** - Where docs and code don't match
- **Sync documentation** - Update docs to reflect reality
- **Create alignment** - Ensure requirements ↔ implementation ↔ tests ↔ standards are aligned
- **Validate standards** - Check code against .ai/rules/ and Laravel best practices
- **Assess readiness** - Determine if implementation is merge-ready
- **Plan next steps** - Clear path forward with accurate docs

---

## Workflow Flow

### Step 1: Gather Current State

#### A) Check Git Branch and Get Issue Key

```bash
# Current branch
CURRENT_BRANCH=$(git branch --show-current)

# Extract issue key from branch name
if [[ "$CURRENT_BRANCH" =~ ([A-Z]+-[0-9]+) ]]; then
  ISSUE_KEY="${BASH_REMATCH[1]}"
  echo "Current branch: $CURRENT_BRANCH"
  echo "Issue key: $ISSUE_KEY"
else
  # Not on a feature branch - ask user for issue key
  echo "Not on a feature branch. Need issue key from user."
fi
```

**Important**: If NOT on a feature branch (e.g., on `develop`, `main`, or other non-standard branch):
- Ask user: "Which task are you reviewing? Please provide the issue key (e.g., ${PROJECT_CONTEXT.issue_tracking.pattern})"
- Validate against project pattern: `${PROJECT_CONTEXT.issue_tracking.regex}`
- Use provided issue key to find `.wip/{ISSUE_KEY}*` folder

#### B) Check for `.wip` Folder

**IMPORTANT**: `.wip` folders are PROJECT-LOCAL in the project directory (`./.wip/`), NOT global.

```bash
# Get .wip root using helper function
WIP_ROOT=$(get_wip_root)

# Check if .wip folder exists
if [ -z "$WIP_ROOT" ]; then
  echo "ERROR: No .wip folder found in project directory"
  echo "Would you like me to:"
  echo "1. Create .wip folder (mkdir .wip && echo '.wip' >> .gitignore)"
  echo "2. Search in a different location"
  echo "3. Skip task folder check"
  # STOP and ask user for guidance
  exit 1
fi

# If user provides issue key (or extracted from branch)
find "$WIP_ROOT" -type d -name "{PROJECT_KEY}-XXXX*"

# If no issue key, show all .wip folders
ls -la "$WIP_ROOT/"

# Present to user
echo "Found: $WIP_ROOT/{PROJECT_KEY}-XXXX-{slug}/"
```

#### C) Get All Code Changes

```bash
# Unstaged changes (working directory)
git diff

# Staged changes (ready to commit)
git diff --cached

# Committed changes on this branch (since diverged from base)
git log develop..HEAD --oneline
git diff develop..HEAD

# Summary
git diff --stat develop..HEAD
```

**Present summary:**
- Current branch: `{branch-name}`
- Commits on branch: X commits
- Files changed: Y files
- Staged changes: Z files
- Unstaged changes: W files

---

### Step 2: Review Existing Documentation

**Read all docs** from `.wip/{PROJECT_KEY}-XXXX-{slug}/`:

**Remember**: `.wip` is PROJECT-LOCAL in the project directory (`./.wip/`).

1. **Check which docs exist:**
   - [ ] `00-status.md` - Status & Overview
   - [ ] `01-functional-requirements.md` - Requirements
   - [ ] `02-decision-log.md` - Decision Log
   - [ ] `03-implementation-plan.md` - Technical Plan
   - [ ] `04-task-description.md` - Task Summary
   - [ ] `05-todo.md` - Implementation Checklist

2. **Check when docs were last updated:**
   - Compare file modification times
   - Compare with git commit dates
   - Identify stale docs (updated > 1 week ago but code changed recently)

3. **Read current status:**
   - What does `00-status.md` say about current phase?
   - What's marked as complete in `05-todo.md`?
   - What decisions were documented?

---

### Step 3: Compare Implementation vs Documentation

#### A) Review Changed Files

```bash
# List all files modified in this branch
git diff --name-only develop..HEAD

# Group by type
git diff --name-only develop..HEAD | grep "Migration"    # Migrations
git diff --name-only develop..HEAD | grep "app/Models"    # Models
git diff --name-only develop..HEAD | grep "app/Http"      # Controllers
git diff --name-only develop..HEAD | grep "tests/"        # Tests
git diff --name-only develop..HEAD | grep "resources/"    # Frontend
```

**Categorize changes:**
- Database: migrations, models
- Backend: controllers, services, commands, jobs
- Frontend: components, pages, assets
- Tests: unit, functional, integration
- Config: routes, config files

#### B) Check Against Implementation Plan

**Read `03-implementation-plan.md`** and compare:

**Questions to answer:**
- ✅ Does the plan list these files?
- ⚠️  Are there code changes not in the plan?
- ❌ Are there planned changes not yet implemented?

**Example analysis:**
```markdown
### Implementation vs Plan

**Matches Plan:**
- ✅ LoginController.php - listed in Phase 2
- ✅ CreateUsersTable migration - listed in Phase 1
- ✅ LoginTest.php - listed in testing section

**Not in Plan (new additions):**
- ⚠️  UserRepository.php - repository added but not documented
- ⚠️  EmailNotification.php - notification not in original plan
- ⚠️  PasswordResetController.php - extra feature added

**Planned but Not Implemented:**
- ❌ TwoFactorAuthController.php - listed in Phase 3, not started
- ❌ EmailService.php - listed in Phase 2, not created
```

#### C) Check Against Requirements

**Read `01-functional-requirements.md`** and compare:

**Questions to answer:**
- ✅ Do code changes fulfill acceptance criteria?
- ⚠️  Are there new features not documented?
- ❌ Are there requirements not yet implemented?

**Example analysis:**
```markdown
### Requirements vs Implementation

**Acceptance Criteria Met:**
- ✅ User can log in with email/password
- ✅ Invalid credentials show error message
- ✅ Successful login redirects to dashboard

**Implemented but Not in Requirements:**
- ⚠️  Password reset feature (bonus feature?)
- ⚠️  Remember me checkbox (extra feature?)

**Required but Not Implemented:**
- ❌ Two-factor authentication (required in acceptance criteria)
- ❌ Account lockout after failed attempts (security requirement)
```

---

### Step 4: Identify Discrepancies

**Create discrepancy checklist:**

#### Documentation Issues
- [ ] Docs out of date (last updated > 1 week ago, code changed recently)
- [ ] Missing docs (no `03-implementation-plan.md` but code exists)
- [ ] Code changes not documented in plan
- [ ] Implementation differs from documented plan
- [ ] Decisions not documented in `02-decision-log.md`

#### Code Issues
- [ ] Uncommitted changes (staged files)
- [ ] Uncommitted changes (unstaged/working directory files)
- [ ] Work in progress not matching current phase in `00-status.md`
- [ ] Tests missing for implemented features
- [ ] Acceptance criteria not met
- [ ] Code quality issues (commented code, debug statements)

#### Sync Issues
- [ ] YouTrack issue description differs from `04-task-description.md`
- [ ] Requirements changed but docs not updated
- [ ] Branch name doesn't match issue
- [ ] Status in `00-status.md` doesn't match actual progress
- [ ] `05-todo.md` not updated (items marked incomplete but code exists)

#### Standards Issues
- [ ] Architecture violations (patterns not followed, layer separation broken)
- [ ] Code style violations (naming, PSR compliance, Laravel conventions)
- [ ] Testing standards not met (missing tests, poor test quality)
- [ ] Security issues (OWASP violations, input validation gaps)
- [ ] Code quality issues (high complexity, performance problems, technical debt)
- [ ] .ai/rules/ guidelines not followed
- [ ] Implementation not ready for merge (critical issues present)

---

### Step 5: Present Findings to User

**Create comprehensive review report:**

```markdown
# In Progress Review: {PROJECT_KEY}-XXXX - {Task Summary}

**Review Date**: {current-date}
**Reviewed By**: Claude Code (In Progress Mode)

---

## Current State

- **Branch**: {branch-name}
- **Issue**: [{PROJECT_KEY}-XXXX]({youtrack-url})
- **Status in docs**: {status from 00-status.md}
- **Last doc update**: {date from git log}
- **Last code commit**: {date of latest commit}

---

## Code Changes Summary

### Commits
- **Total commits**: X commits on this branch
- **Latest commit**: "{commit message}" ({date})
- **First commit**: "{commit message}" ({date})

### Files Changed
- **Total files**: Y files modified
- **Migrations**: Z files
- **Models**: W files
- **Controllers**: V files
- **Tests**: U files
- **Frontend**: T files

### Git State
- **Staged**: A files ready to commit
- **Unstaged**: B files with uncommitted changes
- **Untracked**: C new files

---

## Documentation Review

### Existing Docs
- ✅ **Present**: 00-status.md (updated {date})
- ✅ **Present**: 01-functional-requirements.md (updated {date})
- ⚠️  **Outdated**: 05-todo.md (updated 2 weeks ago, code changed yesterday)
- ❌ **Missing**: 03-implementation-plan.md

### Documentation Completeness
- Standard structure: 4/6 files present
- Docs up to date: 2/4 files current
- Missing critical docs: implementation plan

---

## Discrepancies Found

### 1. Implementation vs Plan

**Matches Plan:**
- ✅ {File1} - documented in Phase X, implemented
- ✅ {File2} - documented in Phase Y, implemented

**Not in Plan:**
- ⚠️  {File3} - new file, not documented
  - Impact: Medium
  - Action needed: Add to plan or remove if experimental
- ⚠️  {File4} - extra feature added
  - Impact: High
  - Action needed: Update requirements and plan

**Planned but Missing:**
- ❌ {File5} - listed in Phase Z, not implemented
  - Impact: High (blocking feature)
  - Action needed: Implement or remove from plan

### 2. Requirements vs Code

**Acceptance Criteria Met:**
- ✅ {Criterion 1}
- ✅ {Criterion 2}

**Implemented but Not Required:**
- ⚠️  {Feature X} - implemented but not in requirements
  - Question: Was this intentional or scope creep?
  - Action: Add to requirements or remove

**Required but Not Implemented:**
- ❌ {Feature Y} - in acceptance criteria, not implemented
  - Impact: Blocking completion
  - Action: Implement or update requirements

### 3. Testing Status

**Test Coverage:**
- ✅ {Feature A} - has tests
- ⚠️  {Feature B} - implemented but no tests
- ❌ {Feature C} - tests planned but not written

### 4. Git State Issues

**Staged Changes:**
- {File X} - ready to commit
- {File Y} - ready to commit
- Question: Are these ready or should they be split into separate commits?

**Unstaged Changes:**
- {File Z} - has uncommitted changes
- Question: WIP or ready to stage?

### 5. Documentation Sync

**Status Mismatch:**
- `00-status.md` says: "Phase 2 in progress"
- Code evidence suggests: "Phase 2 complete, Phase 3 started"
- Action: Update status to reflect reality

**Todo List Mismatch:**
- `05-todo.md` Phase 2 items still marked incomplete
- But code shows these features are implemented
- Action: Mark items complete, update checklist

### 6. Standards Compliance

**Architecture Conformance:**
- ✅ Repository pattern properly implemented
- ⚠️  Some business logic in models (should be in services)
- ❌ Direct database queries in controller (violates layer separation)
- Action: Refactor to follow architecture guidelines

**Code Style:**
- ✅ PSR-12 formatting consistent
- ⚠️  Missing docblocks on 5 methods
- ❌ Variable names too short in UserProcessor class
- Action: Add docblocks, improve naming per style guide

**Security:**
- ✅ Input validation present
- ⚠️  API tokens in code (should use .env)
- ❌ No XSS protection on user-generated content
- ❌ Missing rate limiting on login endpoint
- Action: Fix critical security issues before merge

**Code Quality:**
- ✅ Functions small and focused
- ⚠️  High cyclomatic complexity in OrderProcessor::process()
- ❌ Debug statements (dd, var_dump) present in 3 files
- Action: Remove debug code, refactor complex methods

**Implementation Readiness:**
- Overall: ⚠️ 70% ready (needs work)
- Critical blockers: 2 (security issues)
- Action: Address critical issues before merge

---

## Recommended Actions

### Immediate (Critical)
1. ❗ Fix XSS vulnerability in user content display (SECURITY)
2. ❗ Add rate limiting to login endpoint (SECURITY)
3. ❗ Remove debug statements (dd, var_dump) from production code
4. ❗ Update `03-implementation-plan.md` to document actual implementation
5. ❗ Clarify unstaged files - commit, stash, or discard?
6. ❗ Update `00-status.md` with current phase

### Important (Should Do)
7. ⚠️  Move API tokens to .env file (security best practice)
8. ⚠️  Refactor OrderProcessor::process() to reduce complexity
9. ⚠️  Add missing docblocks to methods
10. ⚠️  Add {Feature X} to `01-functional-requirements.md`
11. ⚠️  Create tests for {Feature B}
12. ⚠️  Update `05-todo.md` to mark completed items
13. ⚠️  Document decision to add {Feature X} in `02-decision-log.md`

### Optional (Nice to Have)
14. 💡 Improve variable naming in UserProcessor class
15. 💡 Refactor business logic from models to services
16. 💡 Consider creating YouTrack subtask for {Feature Y}
17. 💡 Update YouTrack issue description with current scope
18. 💡 Add code comments to explain {complex logic}

---

## Next Steps

**After syncing docs, recommend:**
1. Complete {Feature Y} (blocking requirement)
2. Add tests for {Feature B}
3. Commit staged changes
4. Continue to Phase {next-phase}

**Or, if blocked:**
- Clarify requirements with stakeholders
- Update plan to match reality
- Re-prioritize based on actual scope
```

---

### Step 6: Ask User to Clarify Discrepancies

**Use AskUserQuestion to resolve each major discrepancy:**

**Example questions:**
1. "UserRepository.php was added but not in the plan. Should I update the plan to include it?"
   - Options: "Yes, update plan", "No, remove the file", "It's temporary, leave as-is"

2. "Password reset was implemented but not in requirements. Was this intentional?"
   - Options: "Yes, add to requirements", "No, remove the feature", "Keep as bonus feature"

3. "You have 3 unstaged files. What should I do with them?"
   - Options: "Commit them", "Stash them for later", "Discard changes"

4. "Phase 2 seems complete in code but docs say 'In Progress'. Update status to Phase 3?"
   - Options: "Yes, move to Phase 3", "No, Phase 2 still has work", "Review Phase 2 checklist first"

---

### Step 7: Fix or Update Documentation

**Based on user's answers, update docs:**

#### Update `00-status.md`
- Set correct current status
- Update current phase
- Mark completed phases
- Update next actions
- Add timestamp

#### Update `03-implementation-plan.md`
- Add files that were implemented but not planned
- Remove or mark as deferred features not implemented
- Update phase descriptions to match reality
- Add new phases if scope expanded

#### Update `01-functional-requirements.md`
- Add features that were implemented
- Remove or defer features that aren't happening
- Update acceptance criteria to match implementation
- Add edge cases discovered during implementation

#### Update `05-todo.md`
- Mark completed items as done
- Add new items discovered
- Remove items no longer relevant
- Reorganize based on current phase

#### Update `02-decision-log.md`
- Document why extra features were added
- Document why planned features were deferred
- Document technical decisions made during implementation
- Mark user-confirmed decisions

#### Update `04-task-description.md`
- Sync with current scope
- Update to reflect actual implementation
- Keep concise for YouTrack

---

### Step 8: Create Alignment Matrix

**Ensure requirements ↔ implementation ↔ tests ↔ standards are aligned:**

```markdown
## Requirements ↔ Implementation ↔ Testing ↔ Standards Alignment

| Requirement | In Docs? | Implemented? | Tested? | Standards Met? | Status | Action Needed |
|-------------|----------|--------------|---------|----------------|--------|---------------|
| User login with email/password | ✅ | ✅ | ✅ | ✅ | Complete | None |
| Password reset | ❌ | ✅ | ⚠️ Partial | ⚠️ Style issues | Misaligned | Add to requirements, complete tests, fix style |
| Two-factor auth | ✅ | ❌ | ❌ | N/A | Not started | Implement or defer |
| Remember me checkbox | ❌ | ✅ | ❌ | ❌ Security gap | Bonus feature | Add to docs, create tests, add CSRF protection |
| Account lockout | ✅ | ⚠️ Partial | ❌ | ⚠️ No rate limit | In progress | Complete implementation, add tests, add rate limiting |

### Legend
- ✅ Complete and aligned
- ⚠️  Partial or out of sync
- ❌ Missing or not implemented

### Summary
- **Aligned**: 1 requirement
- **Needs sync**: 3 requirements
- **Not started**: 1 requirement
```

---

### Step 8.5: Code Standards & Implementation Readiness Check

**Ensure full implementation readiness and standards conformance:**

#### A) Load Project Standards

**Read project-specific standards** from `.ai/rules/` (location from project YAML):

```bash
# List all standard docs
ls -la .ai/rules/

# Key standards to check:
# - 00-system-prompt.md - Overall system context
# - 01-core-workflow.md - Development workflow
# - code-architecture.md - Architecture patterns
# - codestyle.md - Code style guidelines
# - testing-standards.md - Testing requirements
```

**Read all relevant standards:**
- [ ] Architecture guidelines
- [ ] Code style rules
- [ ] Testing requirements
- [ ] Security standards
- [ ] Performance guidelines
- [ ] Laravel best practices (if applicable)

---

#### B) Validate Code Against Standards

**Architecture Conformance:**

Check implementation against documented architecture patterns:

```markdown
### Architecture Standards Review

**Pattern Compliance:**
- ✅ Repository pattern used (as per ARCH guidelines)
- ✅ Service layer implemented for business logic
- ⚠️  Command bus not used (should be for async operations)
- ❌ Direct DB queries in controller (violates ARCH §Data Access)

**Layer Separation:**
- ✅ Controllers are thin, delegate to services
- ✅ Models contain only data/relationships
- ⚠️  Some business logic in model methods (should be in service)
- ❌ Frontend directly accessing database (violates separation)

**Dependency Injection:**
- ✅ Constructor injection used
- ✅ Type hints present
- ❌ Service location pattern used in 2 files (anti-pattern)
```

**Code Style Conformance:**

Check code against style guidelines:

```markdown
### Code Style Review

**Naming Conventions:**
- ✅ Classes use PascalCase
- ✅ Methods use camelCase
- ✅ Variables are descriptive
- ⚠️  Some variable names too short ($d, $tmp)

**Documentation:**
- ✅ Public methods have docblocks
- ⚠️  Missing @param types in 3 methods
- ⚠️  Complex logic lacks inline comments
- ❌ No class-level docblocks

**Laravel Standards:**
- ✅ Eloquent relationships properly defined
- ✅ Mass assignment protection configured
- ⚠️  Raw SQL used instead of Query Builder (2 instances)
- ❌ Not using Laravel validation rules (manual validation)

**PSR Compliance:**
- ✅ PSR-12 formatting
- ✅ Proper namespace declarations
- ❌ Line length exceeds 120 chars (5 locations)
```

**Testing Standards:**

Check test coverage and quality:

```markdown
### Testing Standards Review

**Test Coverage:**
- ✅ Unit tests for services
- ✅ Feature tests for controllers
- ⚠️  Edge cases not fully tested
- ❌ Missing tests for error scenarios

**Test Quality:**
- ✅ Descriptive test names
- ✅ Proper arrange-act-assert structure
- ⚠️  Some tests have multiple assertions (hard to debug)
- ❌ No integration tests for critical flow

**Laravel Testing Best Practices:**
- ✅ Using RefreshDatabase trait
- ✅ Factories for test data
- ⚠️  Not using Pest (project standard)
- ❌ Missing HTTP tests for API endpoints
```

---

#### C) Security & Quality Review

**OWASP Security Checklist:**

```markdown
### Security Review

**Input Validation:**
- ✅ Request validation in place
- ✅ SQL injection protected (using Query Builder)
- ⚠️  File upload validation incomplete
- ❌ No XSS protection for user-generated content

**Authentication & Authorization:**
- ✅ Middleware protecting routes
- ✅ Policy checks in controllers
- ⚠️  Some admin checks use if statements (should use policies)
- ❌ No rate limiting on login endpoint

**Data Protection:**
- ✅ Passwords properly hashed
- ✅ Sensitive data not logged
- ⚠️  API tokens in code (should use .env)
- ❌ No encryption for PII fields

**Error Handling:**
- ✅ Try-catch blocks in critical sections
- ⚠️  Some error messages expose system details
- ❌ No custom error pages (shows stack traces)
```

**Code Quality Metrics:**

```markdown
### Code Quality

**Maintainability:**
- ✅ Functions are small and focused
- ✅ DRY principle followed
- ⚠️  Some code duplication in validation logic
- ❌ High cyclomatic complexity in OrderProcessor::process()

**Performance:**
- ✅ Eager loading used to prevent N+1
- ⚠️  No caching for expensive queries
- ⚠️  Large dataset processing not chunked
- ❌ Missing database indexes on foreign keys

**Error Handling:**
- ✅ Exceptions used appropriately
- ⚠️  Generic exception catching (should be specific)
- ❌ No logging for critical errors

**Technical Debt:**
- ⚠️  3 TODO comments in production code
- ⚠️  Commented-out code blocks (5 instances)
- ❌ Debug statements not removed (dd(), var_dump)
```

---

#### D) Implementation Readiness Criteria

**Checklist before marking complete:**

**Code Completeness:**
- [ ] All acceptance criteria implemented
- [ ] Edge cases handled
- [ ] Error scenarios covered
- [ ] User feedback messages added
- [ ] Loading states implemented (frontend)

**Code Quality:**
- [ ] No debug statements (dd, var_dump, console.log)
- [ ] No commented-out code
- [ ] No TODO comments (or documented in backlog)
- [ ] Code formatted per standards
- [ ] Docblocks complete

**Testing:**
- [ ] Unit tests passing
- [ ] Feature tests passing
- [ ] Manual testing completed
- [ ] Edge cases tested
- [ ] Error scenarios tested

**Security:**
- [ ] Input validation complete
- [ ] Authorization checks in place
- [ ] No sensitive data exposed
- [ ] OWASP top 10 reviewed
- [ ] Security testing done

**Standards Conformance:**
- [ ] Architecture patterns followed
- [ ] Code style compliant
- [ ] Laravel best practices used
- [ ] .ai/rules/ guidelines met
- [ ] No linting errors

**Documentation:**
- [ ] Code comments added for complex logic
- [ ] API documentation updated (if applicable)
- [ ] README updated (if applicable)
- [ ] Decision log updated
- [ ] Implementation plan matches reality

**Performance:**
- [ ] No N+1 queries
- [ ] Expensive operations cached
- [ ] Database indexes added
- [ ] Large datasets chunked
- [ ] Performance tested

---

#### E) Create Standards Conformance Report

```markdown
### Standards Conformance Summary

**Overall Compliance**: 75% (⚠️ Needs attention)

**By Category:**
- Architecture: ✅ 90% compliant (1 minor issue)
- Code Style: ⚠️ 70% compliant (needs cleanup)
- Testing: ⚠️ 65% compliant (missing tests)
- Security: ❌ 55% compliant (critical issues)
- Performance: ⚠️ 70% compliant (needs optimization)

**Critical Issues (Must Fix):**
1. ❌ XSS vulnerability in user content display
2. ❌ No rate limiting on authentication endpoints
3. ❌ Debug statements in production code
4. ❌ Missing tests for error scenarios

**Important Issues (Should Fix):**
5. ⚠️  API tokens hardcoded (use .env)
6. ⚠️  Complex method exceeds cyclomatic complexity limit
7. ⚠️  Missing database indexes on foreign keys
8. ⚠️  Some validation not using Laravel validators

**Minor Issues (Nice to Fix):**
9. 💡 Docblocks incomplete
10. 💡 Code duplication in validation
11. 💡 Some variable names not descriptive
12. 💡 TODO comments present

**Compliance Recommendation:**
- ❌ **NOT READY** for merge - Critical security issues
- Action: Fix items 1-4, then re-review
```

---

### Step 9: Present Updated State

**Show what was synced:**

```markdown
# ✅ Documentation Synced with Implementation

## What Was Updated

### 00-status.md
- ✅ Updated status from "Phase 2 - In Progress" → "Phase 3 - In Progress"
- ✅ Updated next actions
- ✅ Marked Phase 2 complete

### 01-functional-requirements.md
- ✅ Added password reset feature to requirements
- ✅ Added remember me checkbox to requirements
- ✅ Updated acceptance criteria

### 03-implementation-plan.md
- ✅ Added UserRepository.php to Phase 2
- ✅ Added EmailNotification.php to Phase 2
- ✅ Updated Phase 3 to include password reset

### 05-todo.md
- ✅ Marked Phase 2 items complete
- ✅ Added Phase 3 checklist items
- ✅ Added "Create tests for password reset"

### 02-decision-log.md
- ✅ Documented decision to add password reset (user-requested feature)
- ✅ Documented decision to use repository pattern (technical best practice)

## What Still Needs Work

### Critical (Must Fix Before Merge)
- ❗ XSS vulnerability in user content display (SECURITY)
- ❗ Missing rate limiting on login endpoint (SECURITY)
- ❗ Remove debug statements from code (dd, var_dump)
- ❗ Two-factor authentication (required but not started)
- ❗ Tests for password reset feature
- ❗ Commit staged files

### Important (Should Fix)
- ⚠️  Move API tokens to .env file
- ⚠️  Refactor complex OrderProcessor::process() method
- ⚠️  Add missing docblocks
- ⚠️  Complete account lockout feature
- ⚠️  Tests for remember me checkbox

### Standards Compliance
- Overall: ⚠️ 70% compliant (needs improvement)
- **NOT READY** for merge due to critical security issues
- Must fix items 1-3 before code review

## Ready to Continue?

**Current status**: Phase 3 - In Progress
**Merge readiness**: ❌ NOT READY (critical security issues)
**Next task**: Fix critical security issues
**After that**: Implement two-factor authentication, add missing tests

Would you like to:
1. Fix critical security issues first (RECOMMENDED)
2. Continue with Phase 3 implementation
3. Focus on adding tests first
4. Review standards compliance report
5. Something else
```

---

## Checklist

### Gather Current State
- [ ] Check current git branch
- [ ] If NOT on feature branch, ask user for issue key
- [ ] Check if `.wip` folder exists using `get_wip_root()` - if not, ask user for guidance
- [ ] Search for `.wip/{PROJECT_KEY}-XXXX*` or list all .wip folders (remember: PROJECT-LOCAL)
- [ ] Get unstaged changes (`git diff`)
- [ ] Get staged changes (`git diff --cached`)
- [ ] Get committed changes (`git log develop..HEAD`, `git diff develop..HEAD`)
- [ ] Present summary of current state

### Review Documentation
- [ ] Read all existing docs in `.wip/` folder (PROJECT-LOCAL in project directory)
- [ ] Check which docs exist and which are missing
- [ ] Check when docs were last updated
- [ ] Identify stale docs (old but code is recent)

### Compare & Analyze
- [ ] List all changed files and categorize them
- [ ] Compare implementation vs `03-implementation-plan.md`
- [ ] Compare code vs `01-functional-requirements.md`
- [ ] Identify what matches, what's extra, what's missing
- [ ] Check test coverage

### Identify Discrepancies
- [ ] Create comprehensive list of discrepancies
- [ ] Categorize: Documentation, Code, Sync, Testing
- [ ] Assess impact (critical, important, optional)
- [ ] Determine actions needed

### Present & Clarify
- [ ] Create detailed review report
- [ ] Present findings to user clearly
- [ ] Ask user to clarify each major discrepancy
- [ ] Get user's decisions on how to resolve

### Update Documentation
- [ ] Update `00-status.md` with current status
- [ ] Update `03-implementation-plan.md` with actual implementation
- [ ] Update `01-functional-requirements.md` with new/removed features
- [ ] Update `05-todo.md` to reflect completed and remaining items
- [ ] Update `02-decision-log.md` with new decisions
- [ ] Update `04-task-description.md` if scope changed

### Create Alignment
- [ ] Build requirements ↔ implementation ↔ tests matrix
- [ ] Identify gaps in alignment
- [ ] Document actions needed to align
- [ ] Present clear picture of what's aligned vs what needs work

### Code Standards & Readiness Check
- [ ] Read project standards from `.ai/rules/` directory
- [ ] Validate architecture conformance (patterns, layers, DI)
- [ ] Check code style compliance (naming, docs, Laravel, PSR)
- [ ] Verify testing standards (coverage, quality, best practices)
- [ ] Review security (OWASP checklist, input validation, auth)
- [ ] Assess code quality (maintainability, performance, technical debt)
- [ ] Complete implementation readiness checklist
- [ ] Create standards conformance report with compliance %
- [ ] Identify critical, important, and minor issues
- [ ] Determine merge readiness recommendation

### Present Results
- [ ] Show what was synced
- [ ] Show what still needs work
- [ ] Update `00-status.md` with next actions
- [ ] Ask user if ready to proceed or needs further review

---

## Examples

### Example 1: Work Started, Needs Review

See README.md - Mode 3: In Progress Mode section for typical scenarios.

### Example 2: Resuming After Break

See README.md - Mode 3: In Progress Mode section for typical scenarios.

---

## Best Practices

### When to Use In Progress Mode

**Use when:**
- ✅ Resuming work after a break
- ✅ Taking over someone else's work
- ✅ Code has diverged from docs
- ✅ User asks "where am I?" or "what's my progress?"
- ✅ Before continuing long-running task
- ✅ Periodically (weekly) on active tasks

**Don't use when:**
- ❌ Starting brand new task (use Default Mode)
- ❌ Just finished planning (use Default Mode)
- ❌ Exploring new idea (use Greenfield Mode)
- ❌ Docs are already up to date

### Tips for Effective Reviews

1. **Be thorough** - Check every aspect: code, docs, git state, tests, and standards
2. **Be objective** - Report reality, not what docs say
3. **Categorize clearly** - Separate what's done, what's extra, what's missing
4. **Prioritize** - Not all discrepancies are equal (security > functionality > style)
5. **Check standards first** - Load .ai/rules/ before reviewing code
6. **Ask questions** - Let user clarify intent rather than assume
7. **Update everything** - Sync all docs, not just some
8. **Create alignment** - Ensure requirements ↔ implementation ↔ tests ↔ standards all align
9. **Flag security issues** - Always highlight OWASP violations as critical
10. **Assess merge readiness** - Explicitly state if code is ready or needs work

### Common Pitfalls to Avoid

- ❌ Don't skip uncommitted changes - they often have important context
- ❌ Don't assume extra features are bugs - ask user first
- ❌ Don't update docs without user confirmation
- ❌ Don't ignore test gaps - highlight them
- ❌ Don't skip standards review - security issues can be critical
- ❌ Don't approve code that's not merge-ready - flag blockers clearly
- ❌ Don't overlook .ai/rules/ - project standards are requirements
- ❌ Don't rush - thorough review saves time later

---

## Mode Transitions

### In Progress → Default

**When**: After syncing docs, ready to continue with clean state

**Steps:**
1. Confirm all discrepancies resolved
2. Confirm all docs updated
3. Update `00-status.md` with "Ready to Continue"
4. Return to Phase 5 (Implementation) workflow from Default Mode
5. Continue with accurate docs as source of truth

### Any Mode → In Progress (Health Check)

**When**: User asks "where am I?" or wants progress review

**Steps:**
1. Run full In Progress review
2. Present current state
3. Identify and resolve discrepancies
4. Return to previous mode once synced

---

**Return to**: [Task Planning README](./README.md)
