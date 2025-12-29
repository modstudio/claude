# Release Workflow

CI/CD release workflow with multi-level validation and automatic project detection.

## Quick Start

```bash
# Invoke release workflow
/release-g

# Select release level:
# - Feature Branch Only (Level 1)
# - Feature + Develop (Levels 1-2)
# - Full Release to Production (Levels 1-3)
```

---

## File Structure

```
~/.claude/
├── commands/
│   └── release-g.md          ← Orchestrator (level selection)
│
└── workflows/
    └── release/
        ├── README.md          ← This file (reference docs)
        └── main.md            ← Release workflow implementation
```

---

## How It Works

### 1. Project Detection

Workflow automatically detects which project you're in:

```bash
cd ~/Projects/starship
# Detects: Starship (from YAML: starship.yaml)
# Issue pattern: STAR-####
# Test commands: Docker + PHPUnit
# Branch conventions: feature/STAR-####-{slug}

cd ~/Projects/alephbeis-app
# Detects: Alephbeis (from YAML: alephbeis.yaml)
# Issue pattern: AB-####
# Test commands: Docker + PHPUnit
# Branch conventions: feature/AB-####-{slug}
```

### 2. Configuration Loading

Loads project-specific settings from `~/.claude/config/projects/{project}.yaml`:

- Issue tracking pattern (for extracting issue key from branch)
- Test commands (unit, feature, all tests)
- Git workflow and branch conventions
- MCP tool availability (YouTrack for status updates)

### 3. Level Selection

```
User → /release-g
    ↓
Phase 0: Load project context (from YAML)
Step 1: Extract issue key from branch name
Step 2: Ask user to select release level
    ↓
  [Feature Only] → Execute Level 1
  [+ Develop] → Execute Levels 1-2
  [+ Production] → Execute Levels 1-3
```

---

## Release Levels

### Level 1: Feature Branch Only

**When to use**: Early validation, not ready to merge

**Steps**:
1. Safety checks (verify not on protected branch)
2. Push feature branch to remote
3. Wait for CI/CD to pass
4. Report results

**Use cases**:
- Testing CI/CD pipeline
- Getting early feedback
- Validating tests pass before PR

---

### Level 2: Feature + Develop (Staging)

**When to use**: Feature complete, ready for staging

**Steps**:
1. Execute Level 1 (feature branch validation)
2. Create or update PR to develop
3. Merge to develop (after approval)
4. Wait for staging deployment
5. Verify staging CI/CD passes
6. Report results

**Use cases**:
- Standard feature completion workflow
- Deploy to staging environment
- Team review and testing

---

### Level 3: Full Release (Production)

**When to use**: Ready for production deployment

**Steps**:
1. Execute Levels 1-2 (feature → develop)
2. Create or update PR from develop to master
3. Merge to master (after approval)
4. Wait for production deployment
5. Verify production CI/CD passes
6. Optional: Update YouTrack issue status
7. Report results

**Use cases**:
- Production release
- Critical bug fixes (hotfix)
- Scheduled releases

---

## Safety Guards

The workflow includes multiple safety checks:

### Pre-Flight Checks
- ✅ Verify not on protected branch (master/main/develop)
- ✅ Verify protected branches exist on remote
- ✅ Verify feature branch is up to date with base
- ✅ Verify no uncommitted changes (for clean state)

### During Execution
- ✅ Wait for CI/CD validation at each level
- ✅ Verify tests pass before proceeding
- ✅ Confirm merges completed successfully
- ✅ Check deployment status

### Error Handling
- ✅ Retry logic for network issues
- ✅ Clear error messages
- ✅ Rollback guidance if issues occur
- ✅ Stop execution on critical failures

---

## Pull Request Handling

### PR Creation

The workflow automatically:
- Creates PR if it doesn't exist
- Updates PR if it already exists
- Removes AI attribution from commit messages
- Uses project-specific PR templates (if configured)

### PR Title Format

```
{ISSUE_KEY}: {Brief Description}

Examples:
- STAR-2233: Add warehouse queue functionality
- AB-1378: Fix TypeError in GenerateWordCharacterSet
```

### PR Body

Includes:
- Link to YouTrack issue (if YouTrack enabled)
- Summary of changes
- Testing notes
- Deployment notes (if applicable)

---

## CI/CD Integration

### Waiting for CI/CD

The workflow polls for CI/CD completion:

```bash
# Wait for feature branch CI
Wait for: feature/{ISSUE_KEY}-{slug} checks to pass
Timeout: 10 minutes
Poll interval: 30 seconds

# Wait for develop deployment
Wait for: develop branch deployment to staging
Timeout: 15 minutes
Poll interval: 1 minute

# Wait for production deployment
Wait for: master branch deployment to production
Timeout: 20 minutes
Poll interval: 1 minute
```

### Test Commands

Uses project-specific test commands from YAML:

```yaml
test_commands:
  unit: "docker compose exec app ./vendor/bin/phpunit --testsuite=unit"
  feature: "docker compose exec app ./vendor/bin/phpunit --testsuite=feature"
  all: "docker compose exec app ./vendor/bin/phpunit"
```

---

## YouTrack Integration

If YouTrack MCP is enabled, the workflow can:

- Extract issue key from branch name using project pattern
- Update issue status after successful release
- Add comment with deployment details
- Link to PR and commit

**Optional**: User is asked if they want to update YouTrack status

---

## Issue Key Extraction

The workflow extracts the issue key from the current branch:

```bash
# Branch examples:
feature/STAR-2233-Add-Feature → STAR-2233
hotfix/AB-1378-Fix-Bug → AB-1378
feature/STAR-2250-Auth-Prototype → STAR-2250

# Uses project-specific regex from YAML:
ISSUE_KEY=$(git branch --show-current | grep -oE "${PROJECT_CONTEXT.issue_tracking.regex}")
```

**Patterns supported**:
- Starship: `STAR-[0-9]+`
- Alephbeis: `AB-[0-9]+`
- Generic: Auto-detected from branch naming

---

## Error Scenarios

### CI/CD Fails

```
❌ Feature branch CI failed
→ Check test results
→ Fix issues
→ Push again
→ Restart /release-g
```

### Merge Conflicts

```
❌ Merge conflicts detected
→ Pull latest changes
→ Resolve conflicts locally
→ Push resolution
→ Restart /release-g
```

### Protected Branch Issues

```
❌ Currently on protected branch
→ Switch to feature branch
→ Restart /release-g
```

### Deployment Timeout

```
❌ Deployment timed out
→ Check deployment logs
→ Verify infrastructure status
→ Retry or escalate
```

---

## Best Practices

1. **Always start from feature branch**
   - Never run from develop or master
   - Create feature branch first if needed

2. **Run Level 1 early**
   - Validate CI passes before creating PR
   - Catch issues early

3. **Review staging before production**
   - Use Level 2 to deploy to staging
   - Test thoroughly
   - Then run Level 3 for production

4. **Clean state before releasing**
   - Commit or stash changes
   - Pull latest from base branch
   - Resolve any conflicts

5. **Monitor CI/CD output**
   - Watch for test failures
   - Check deployment logs
   - Verify services started correctly

---

## Troubleshooting

### Problem: Issue key not extracted
**Solution**: Check branch naming follows pattern `{type}/{PROJECT_KEY}-XXXX-{slug}`

### Problem: CI keeps failing
**Solution**:
- Run tests locally first
- Check for environment-specific issues
- Verify dependencies are up to date

### Problem: Can't merge to develop
**Solution**:
- Pull latest develop
- Resolve merge conflicts
- Push resolution

### Problem: Production deployment failed
**Solution**:
- Check deployment logs
- Verify infrastructure status
- May need to rollback (manual process)
- Escalate to DevOps if needed

---

## Integration with Other Workflows

The release workflow integrates with:
- `/plan-task-g` - Task planning creates task docs (in `$PROJECT_TASK_DOCS_DIR`) referenced in PRs
  - Storage location configured in `~/.claude/config/global.yaml`
- `/code-review-g` - Code review before release
- Project-specific test suites
- YouTrack for issue tracking (optional)

All workflows use the same:
- Project context detection
- YAML configuration
- Issue key extraction
- Storage conventions

---

## Project Configuration

### Starship (starship.yaml)

```yaml
issue_tracking:
  pattern: "STAR-####"
  regex: "STAR-[0-9]+"

test_commands:
  unit: "docker compose ... exec starship_server ./vendor/bin/phpunit --testsuite=unit"
  feature: "docker compose ... exec starship_server ./vendor/bin/phpunit --testsuite=feature"
  all: "docker compose ... exec starship_server ./vendor/bin/phpunit"

branching:
  base_branch: "develop"
  pattern: "{type}/{ISSUE_KEY}-{slug}"
  types:
    - feature
    - bugfix
    - hotfix

mcp_tools:
  youtrack:
    enabled: true
```

### Alephbeis (alephbeis.yaml)

```yaml
issue_tracking:
  pattern: "AB-####"
  regex: "AB-[0-9]+"

test_commands:
  all: "docker compose exec alephbeis_app ./vendor/bin/phpunit"

branching:
  base_branch: "develop"

mcp_tools:
  youtrack:
    enabled: true
```

---

## Workflow Details

**Entry point**: `commands/release-g.md` (orchestrator)

**Implementation**: `workflows/release/main.md`

**The workflow is sequential** (not multi-mode like code-review):
- User selects level (1, 2, or 3)
- Workflow executes that level and all prerequisite levels
- Levels build on each other (1 → 2 → 3)

**Why one workflow file**:
- Levels are sequential steps, not independent modes
- Each level depends on previous level
- Shared state throughout execution
- Single linear flow with branching at level selection

---

## Level Selection Table

| Level | Feature Branch | Develop | Master/Production | Use Case |
|-------|---------------|---------|-------------------|----------|
| **1** | ✅ Push + CI | ❌ | ❌ | Early validation |
| **2** | ✅ Push + CI | ✅ Merge + Deploy | ❌ | Standard workflow |
| **3** | ✅ Push + CI | ✅ Merge + Deploy | ✅ Merge + Deploy | Production release |

---

**Last Updated:** 2025-11-17
**Version:** 1.0 (Multi-project support with YAML configuration)
