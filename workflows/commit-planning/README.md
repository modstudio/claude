# Commit Planning Workflow

Create focused commit plans with clear, structured commit messages following project standards.

## Quick Start

```bash
# Invoke commit planning
/commit-plan-g

# Workflow will:
# 1. Load your project context
# 2. Extract issue key from branch name
# 3. Analyze all changes (staged, unstaged, untracked)
# 4. Create logical commit groupings
# 5. Generate commit messages per project standards
# 6. Present plan for your approval
# 7. Execute commits after approval
```

---

## File Structure

```
~/.claude/
├── commands/
│   └── commit-plan-g.md       ← Entry point
│
└── workflows/
    └── commit-planning/
        ├── README.md           ← This file (reference docs)
        └── main.md             ← Workflow implementation
```

---

## How It Works

### 1. Project Detection

Automatically detects your project and loads configuration:

```bash
cd ~/Projects/starship
# Detects: Starship
# Issue pattern: STAR-####
# Standards: .ai/rules/
# Commit format: From dev-processes.md

cd ~/Projects/alephbeis-app
# Detects: Alephbeis
# Issue pattern: AB-####
# Standards: .ai/rules/
# Commit format: From project standards
```

### 2. Issue Key Extraction

Extracts issue key from current branch name:

```bash
# Branch examples:
feature/STAR-2233-Add-Feature → STAR-2233
hotfix/AB-1378-Fix-Bug → AB-1378
bugfix/STAR-2250-Fix-Auth → STAR-2250

# Uses project-specific regex from YAML:
ISSUE_KEY=$(git branch --show-current | grep -oE "${PROJECT_CONTEXT.issue_tracking.regex}")
```

### 3. Change Analysis

Analyzes all changes in your working directory:

- **Staged changes**: `git diff --cached`
- **Unstaged changes**: `git diff`
- **Untracked files**: `git ls-files --others --exclude-standard`

Groups changes logically by:
- Feature/purpose
- Dependencies
- File types
- Change types

### 4. Commit Planning

Creates focused, atomic commits:

```markdown
## Commit 1: Database schema changes
Files: migrations/*, database/schema.sql
Reason: Infrastructure changes first

## Commit 2: Domain models
Files: app/Models/*.php
Reason: Core logic using new schema

## Commit 3: Business services
Files: app/Services/*.php
Reason: Services using models

## Commit 4: API endpoints
Files: app/Http/Controllers/*.php, routes/*.php
Reason: Endpoints using services

## Commit 5: Tests
Files: tests/**/*.php
Reason: Tests for all above
```

### 5. Message Generation

Generates commit messages following project standards:

**Standard format** (if no custom format):
```
{ISSUE_KEY}: {type}: {brief description}

{detailed explanation}

{additional context}
```

**Example**:
```
STAR-2233: feat: Add warehouse queue processing

Implements queue-based warehouse fulfillment to handle high volume
orders without blocking the main request thread.

- Uses Laravel queues for async processing
- Adds QueueWarehouseOrder job
- Implements retry logic with exponential backoff
```

---

## Key Requirements

### ✅ Always Included

1. **Issue key in every commit**: Extracted from branch name
2. **Clear, descriptive messages**: Following project standards
3. **Logical groupings**: Atomic, focused commits
4. **Proper ordering**: Dependencies first
5. **Complete context**: Why changes were made

### ❌ Never Included

1. **AI attribution**: No "Generated with Claude", "Co-authored-by: Claude", etc.
2. **Vague messages**: No "updates", "fixes", "changes"
3. **Mixed concerns**: One commit = one logical change
4. **Breaking commits**: Each commit should leave codebase working

---

## Commit Message Standards

### Subject Line (First Line)

**Format**: `{ISSUE_KEY}: {type}: {brief description}`

**Rules**:
- Include issue key: `STAR-2233:`, `AB-1378:`
- Use type prefix (if conventional commits): `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`
- Keep under 72 characters
- Use imperative mood: "Add feature" not "Added feature"
- Capitalize first letter
- No period at end (unless project requires it)

**Examples**:
```
STAR-2233: feat: Add warehouse queue processing
AB-1378: fix: Resolve TypeError in word character set
STAR-2250: refactor: Extract auth logic to service
AB-1390: test: Add unit tests for queue processor
```

### Body (Optional but Recommended)

**Format**: Detailed explanation after blank line

**Rules**:
- Wrap at 72 characters
- Explain WHAT and WHY, not HOW
- Use bullet points for multiple items
- Reference documentation, decisions, standards
- Leave blank line between subject and body

**Example**:
```
STAR-2233: feat: Add warehouse queue processing

Implements queue-based warehouse fulfillment to handle high volume
orders without blocking the main request thread.

Changes:
- Uses Laravel queues for async processing
- Adds QueueWarehouseOrder job with retry logic
- Implements exponential backoff for failed jobs
- Updates fulfillment service to dispatch jobs

References: [ARCH §Queue-Based-Processing]
```

### Footer (Optional)

**Format**: Additional metadata after blank line

**Common uses**:
- Breaking changes: `BREAKING CHANGE: description`
- Related issues: `Relates-to: #123`
- References: `See-also: PR #456`

---

## Commit Grouping Strategies

### By Layer (Recommended for Full-Stack)

```
Commit 1: Database/migrations
Commit 2: Models/entities
Commit 3: Services/business logic
Commit 4: Controllers/API
Commit 5: Views/frontend
Commit 6: Tests
Commit 7: Documentation
```

### By Feature (Recommended for Small Changes)

```
Commit 1: Add user authentication
Commit 2: Add password reset flow
Commit 3: Add email verification
```

### By Type (Recommended for Refactoring)

```
Commit 1: Extract common logic to helper
Commit 2: Update all usages to use helper
Commit 3: Remove duplicated code
Commit 4: Update tests
```

### Hybrid Approach (Recommended for Complex Features)

```
Commit 1: Infrastructure (migrations, config)
Commit 2: Core feature implementation
Commit 3: UI/frontend changes
Commit 4: Tests for all above
Commit 5: Documentation updates
```

---

## Best Practices

### Commit Size

**Good sizes**:
- 3-7 commits for typical feature
- 1-2 commits for bug fix
- 5-15 commits for large feature
- 1 commit for documentation only

**Too small**:
- 50 commits for one feature
- Each semicolon is a commit
- Breaks functionality between commits

**Too large**:
- One commit for entire feature
- Mixing multiple unrelated changes
- 100+ files in one commit

### Commit Quality

**High quality indicators**:
- ✅ Each commit has single clear purpose
- ✅ Commit message explains WHY
- ✅ Code works after each commit
- ✅ Can be reviewed independently
- ✅ Can be reverted without breaking things

**Low quality indicators**:
- ❌ "WIP" or "temp" in message
- ❌ "Fixed stuff" or "updates"
- ❌ Mix of unrelated changes
- ❌ Code doesn't compile after commit
- ❌ Missing issue key

### Commit Order

**Correct dependency order**:
1. Configuration/environment
2. Database migrations
3. Models using new schema
4. Services using models
5. Controllers using services
6. Routes for controllers
7. Views using controllers
8. Tests for everything

**Why order matters**:
- Each commit should leave codebase working
- Later commits depend on earlier ones
- Makes bisecting easier
- Makes reviewing easier
- Makes reverting safer

---

## Workflow Steps

### Step 1: Verify Context
- Check you're in git repository
- Verify current branch
- Extract issue key from branch name
- Load project commit standards

### Step 2: Analyze Changes
- List all staged files
- List all unstaged files
- List all untracked files
- Understand what changed and why

### Step 3: Group Changes
- Create logical commit groupings
- Order by dependencies
- Ensure each group is atomic
- Verify completeness

### Step 4: Generate Messages
- Follow project standards
- Include issue key
- Write clear subject lines
- Add detailed body if needed
- No AI attribution

### Step 5: Present Plan
- Show complete commit plan
- List all files in each commit
- Preview commit messages
- Wait for user approval

### Step 6: Execute (After Approval)
- Stage files for each commit
- Create commit with message
- Verify commit created
- Report progress
- Continue to next commit

### Step 7: Summary
- Show all commits created
- Provide git log output
- Suggest next steps (push, create PR)

---

## Edge Cases

### No Issue Key in Branch

**Problem**: Branch doesn't contain issue key

**Solutions**:
1. Ask user to provide issue key manually
2. Proceed without (not recommended)
3. Suggest creating properly named branch

**Example**:
```bash
# Bad branch names:
fix-auth
feature/new-thing
update-docs

# Good branch names:
feature/STAR-2233-Add-Auth
bugfix/AB-1378-Fix-TypeError
docs/STAR-2250-Update-README
```

### On Protected Branch

**Problem**: Currently on master/main/develop

**Solution**:
1. **STOP immediately**
2. Warn user
3. Suggest creating feature branch
4. Do NOT commit

### Mix of Unrelated Changes

**Problem**: Changes span multiple features

**Solutions**:
1. Group by feature
2. Commit one feature, stash others
3. Create separate branches
4. Ask user preference

### Very Large Changeset

**Problem**: 50+ files changed

**Solutions**:
1. Look for natural groupings (5-10 commits)
2. Balance atomicity vs commit count
3. Group related changes
4. Split by layer or feature

---

## Examples

### Example 1: Simple Bug Fix

**Branch**: `bugfix/STAR-2233-Fix-Null-Pointer`

**Changes**:
- `app/Services/UserService.php` - Add null check
- `tests/Unit/UserServiceTest.php` - Add test for null case

**Commit Plan**:
```
Commit 1: Fix null pointer in UserService

STAR-2233: fix: Add null check in getUserOrders

Prevents null pointer exception when user has no orders.

- Add early return if user is null
- Add test coverage for null user case
```

### Example 2: New Feature

**Branch**: `feature/AB-1378-Add-Export`

**Changes**:
- `database/migrations/2024_01_15_create_exports_table.php` - New table
- `app/Models/Export.php` - New model
- `app/Services/ExportService.php` - Export logic
- `app/Http/Controllers/ExportController.php` - API endpoints
- `routes/api.php` - New routes
- `tests/Feature/ExportTest.php` - Feature tests

**Commit Plan**:
```
Commit 1: Add export database schema
Files: database/migrations/*
Message: AB-1378: feat: Add exports table migration

Commit 2: Add Export model
Files: app/Models/Export.php
Message: AB-1378: feat: Add Export model

Commit 3: Add export service
Files: app/Services/ExportService.php
Message: AB-1378: feat: Add export generation service

Commit 4: Add export API endpoints
Files: app/Http/Controllers/ExportController.php, routes/api.php
Message: AB-1378: feat: Add export API endpoints

Commit 5: Add export tests
Files: tests/Feature/ExportTest.php
Message: AB-1378: test: Add export functionality tests
```

### Example 3: Refactoring

**Branch**: `refactor/STAR-2250-Extract-Auth-Logic`

**Changes**:
- `app/Services/AuthService.php` - New service (extracted)
- `app/Http/Controllers/LoginController.php` - Updated to use service
- `app/Http/Controllers/RegisterController.php` - Updated to use service
- `tests/Unit/AuthServiceTest.php` - New tests

**Commit Plan**:
```
Commit 1: Extract auth logic to service
Files: app/Services/AuthService.php, tests/Unit/AuthServiceTest.php
Message: STAR-2250: refactor: Extract authentication logic to service

Commit 2: Update controllers to use AuthService
Files: app/Http/Controllers/Login*.php, app/Http/Controllers/Register*.php
Message: STAR-2250: refactor: Update controllers to use AuthService
```

---

## Troubleshooting

### Problem: Too many changes to plan
**Solution**:
- Break into multiple sessions
- Commit some changes first
- Stash unrelated work

### Problem: Can't group changes logically
**Solution**:
- Changes might be too mixed
- Consider refactoring approach
- Split into multiple branches

### Problem: Commit messages too long
**Solution**:
- Move details to body
- Keep subject line under 72 chars
- Use bullet points in body

### Problem: Unsure about commit order
**Solution**:
- Think about dependencies
- Infrastructure/config first
- Tests last
- Ask if unsure

---

## Integration with Other Workflows

Works with:
- `/plan-task-g` - Planning creates context for commits
- `/code-review-g` - Review before creating commits
- `/release-g` - After commits, push and release

All workflows use the same:
- Project context detection
- YAML configuration
- Issue key extraction
- Standards from `.ai/rules/`

---

**Last Updated:** 2025-11-17
**Version:** 1.0 (Initial version with multi-project support)
