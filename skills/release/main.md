# Release Skill

You are a release management agent. Your job is to guide the release process through CI/CD pipelines with appropriate validation checks.

---

## Phase 0: Project Context

{{MODULE: ~/.claude/modules/docs/project-variables.md}}

{{MODULE: ~/.claude/modules/shared/todo-patterns.md}}

---

## Initial Setup

1. **Use extracted issue key**
   - Issue key was extracted by `/release-g` using: `PROJECT_CONTEXT.issue_tracking.regex`
   - Example: `feature/STAR-123-Add-feature` → Issue key: `STAR-123`
   - Issue key available as `ISSUE_KEY` variable

2. **CI Monitoring Mode** (set by `/release-g`)
   - `CI_MODE="monitor"` - Wait for CI and verify success (recommended)
   - `CI_MODE="quick"` - Skip CI waiting, proceed immediately (faster)

   **Quick Mode Behavior:**
   - Pushes/merges proceed without waiting for CI
   - No verification of test results
   - User assumes responsibility for CI failures
   - Still performs safety checks (branch verification, etc.)

## Safety Guards

{{MODULE: ~/.claude/modules/shared/git-safety-checks.md}}

**CRITICAL:** Run safety checks before ANY git operations in this skill.

---

## Deployment Flow Overview

**CRITICAL: Levels are SEQUENTIAL and CUMULATIVE**

The release process follows this exact order:

```
Level 1: Feature Branch
   ↓ Push & Test (NO PR at this stage)

Level 2: Feature → Develop
   ↓ 🚨 CREATE PR (REQUIRED)
   ↓ MERGE PR to develop (via GitHub)
   ↓ Deploy to Staging

Level 3: Develop → Master
   ↓ CREATE PR from develop to master
   ↓ Merge PR & Deploy to Production
```

**🚨 PR REQUIREMENTS:**
- **Level 2**: MUST create and merge PR from feature → develop
- **Level 3**: MUST create and merge PR from develop → master
- **NEVER** merge directly without a PR
- **ALWAYS** use `gh pr create` and `gh pr merge`

**Selection Options:**
- **Level 1 only**: Push feature, run tests (no merge) → **End on develop**
  - No YouTrack status update at this level
- **Level 1 + 2**: Push feature, merge to develop, deploy staging → **End on develop**
  - Optional: Update to "Waiting for QA" (if YouTrack enabled)
- **Level 1 + 2 + 3**: Full release (Feature → Develop → Master) → **End on develop**
  - Optional: Update to "Waiting for QA" or "Complete" (if YouTrack enabled)

**CI Monitoring Mode:**
- **Quick (No Wait)**: Push/merge immediately, skip CI monitoring (faster)
- **Monitor CI**: Wait for CI to complete at each stage (recommended)

**⚠️  IMPORTANT:**
- Level 3 REQUIRES Level 2 to complete first
- Level 3 merges **develop → master** (NOT feature → master)
- Cannot skip levels (e.g., cannot do Level 1 then Level 3)
- **ALL levels end with checkout develop** (your main working branch)
- **YouTrack status updates** only if MCP is configured in project

---

## Skill Steps

### Level 1: Feature Branch Release

**Purpose:** Push and test your feature branch

**⚠️  IMPORTANT: Level 1 does NOT create a PR - only pushes the branch for testing**

---

**📋 LEVEL 1: CREATE TODO LIST**

Use TodoWrite to create checklist:

```javascript
TodoWrite({
  todos: [
    {content: "Run safety checks (verify not on protected branch)", status: "pending", activeForm: "Running safety checks"},
    {content: "Push feature branch to remote", status: "pending", activeForm: "Pushing feature branch"},
    {content: "Monitor CI tests on feature branch", status: "pending", activeForm: "Monitoring CI tests"},
    {content: "Verify tests passed", status: "pending", activeForm: "Verifying tests passed"},
    {content: "Ask user about YouTrack status update", status: "pending", activeForm: "Asking about YouTrack update"},
    {content: "Checkout develop branch", status: "pending", activeForm: "Checking out develop branch"}
  ]
})
```

---

**EXECUTION:**

**Step 1: Safety Checks**

Mark todo as in_progress: "Run safety checks"

1. Run safety guards (see above)
2. Verify current branch is feature/fix/hotfix/etc.
3. Store current branch name: `FEATURE_BRANCH=$(git branch --show-current)`
4. **CRITICAL**: Verify NOT on protected branch (master/main/develop)
5. Echo: "✓ On feature branch: $FEATURE_BRANCH"

Mark todo as completed: "Run safety checks"

---

**Step 2: Push Feature Branch**

Mark todo as in_progress: "Push feature branch to remote"

1. Push current branch: `git push origin HEAD`
2. Verify push succeeded (check exit code)
3. Echo: "✅ Pushed $FEATURE_BRANCH to remote"
4. **NOTE**: NO PR creation at this stage

Mark todo as completed: "Push feature branch to remote"

---

**Step 3: Monitor CI Tests (if CI_MODE="monitor")**

Mark todo as in_progress: "Monitor CI tests on feature branch"

**If CI_MODE="quick":**
- Echo: "⚡ Quick mode: Skipping CI monitoring"
- Echo: "ℹ️  CI will run in background - check manually if needed"
- Mark todo as completed and skip to Step 5

**If CI_MODE="monitor":**
1. Get the most recent run for this branch:
   ```bash
   RUN_ID=$(gh run list --branch $FEATURE_BRANCH --limit 1 --json databaseId -q '.[0].databaseId')
   ```

2. Watch the run until it completes:
   ```bash
   gh run watch $RUN_ID
   ```
   OR poll every 30 seconds if gh run watch unavailable

3. Echo: "⏳ Waiting for CI tests to complete on $FEATURE_BRANCH..."

Mark todo as completed: "Monitor CI tests on feature branch"

---

**Step 4: Verify Tests Passed (if CI_MODE="monitor")**

Mark todo as in_progress: "Verify tests passed"

**If CI_MODE="quick":**
- Echo: "⚡ Quick mode: Skipping test verification"
- Mark todo as completed and skip to Step 5

**If CI_MODE="monitor":**
1. Get test results:
   ```bash
   gh run view $RUN_ID --json conclusion,jobs
   ```

2. Check results:
   - ✅ Backend Tests (must pass)
   - ✅ Frontend Tests (must pass)
   - ⏭️ Code Quality (can ignore)

3. If tests failed:
   - Echo: "❌ Tests failed on $FEATURE_BRANCH"
   - Report failure details to user
   - STOP (do not proceed)

4. If tests passed:
   - Echo: "✅ All tests passed on $FEATURE_BRANCH"

Mark todo as completed: "Verify tests passed"

---

**Step 5: Ask About YouTrack Status Update**

Mark todo as in_progress: "Ask user about YouTrack status update"

1. If YouTrack MCP enabled AND ISSUE_KEY exists:
   - Ask user: "Feature branch tested successfully. Update YouTrack status?"
   - Suggested status: "In Progress" or "Waiting for QA"
   - If yes → Update issue status via YouTrack MCP
   - Echo confirmation: "✅ YouTrack status updated"

2. If YouTrack not available:
   - Echo: "ℹ️  YouTrack not configured, skipping status update"

Mark todo as completed: "Ask user about YouTrack status update"

---

**Step 6: Checkout Develop Branch**

Mark todo as in_progress: "Checkout develop branch"

**This step is MANDATORY - always end on develop**

1. Fetch latest develop:
   ```bash
   git fetch origin develop
   ```

2. Checkout develop:
   ```bash
   git checkout develop
   ```

3. Pull latest:
   ```bash
   git pull origin develop
   ```

4. Verify on develop:
   ```bash
   CURRENT=$(git branch --show-current)
   if [ "$CURRENT" != "develop" ]; then
     echo "❌ ERROR: Failed to checkout develop"
     exit 1
   fi
   ```

5. Echo: "✅ Switched to develop branch"
6. Echo: "✅ Feature branch tested and ready for merge"
7. Echo: "ℹ️  Run /release-g again and select Level 2 when ready to merge"

Mark todo as completed: "Checkout develop branch"

---

**LEVEL 1 COMPLETE ✅**

All todos should now be marked as completed.
Feature branch tested successfully. You're on develop, ready for next work.

### Level 2: Merge to Develop + Staging Deployment

**Purpose:** Create PR and merge your feature branch into develop, then deploy to staging

**🚨 CRITICAL - PR REQUIRED:**
- **YOU MUST CREATE A PR** to merge to develop
- **NEVER merge directly** to develop without a PR
- **PR is the ONLY way** to merge feature → develop
- GitHub PR merge is the mechanism for this level

**⚠️  PREREQUISITE:** Level 1 must have completed successfully (tests passed)

---

**📋 BEFORE STARTING: CREATE TODO LIST**

Use the TodoWrite tool to create a checklist for Level 2:

```javascript
TodoWrite({
  todos: [
    {content: "Run safety checks (verify not on protected branch)", status: "pending", activeForm: "Running safety checks"},
    {content: "Check for existing PR (feature → develop)", status: "pending", activeForm: "Checking for existing PR"},
    {content: "Create PR if needed (REQUIRED)", status: "pending", activeForm: "Creating PR"},
    {content: "Merge PR to develop (CRITICAL STEP)", status: "pending", activeForm: "Merging PR to develop"},
    {content: "Monitor staging deployment on develop branch", status: "pending", activeForm: "Monitoring staging deployment"},
    {content: "Verify all changes are in develop", status: "pending", activeForm: "Verifying changes in develop"},
    {content: "Ask user about YouTrack status update", status: "pending", activeForm: "Asking about YouTrack update"},
    {content: "Checkout develop branch", status: "pending", activeForm: "Checking out develop branch"}
  ]
})
```

**Then follow these steps, marking each todo as you complete it:**

---

**📋 LEVEL 2 EXECUTION - FOLLOW EVERY STEP:**

**Prerequisites:**
- [ ] Level 1 completed successfully (tests passed on feature branch)
- [ ] Currently on feature branch (not on develop/master)
- [ ] Feature branch is up to date with remote

**Step 1: Safety Checks**

Mark todo as in_progress: "Run safety checks"

1. Get current branch: `FEATURE_BRANCH=$(git branch --show-current)`
2. Verify NOT on protected branch (master/main/develop)
   - If on protected branch → ABORT with error
3. Fetch remote: `git fetch origin develop`
4. Verify develop exists on remote
   - If develop doesn't exist → ABORT with error
5. Echo confirmation: "✓ Feature branch: {branch-name}"
6. Echo confirmation: "✓ Will merge: {feature} → develop"

Mark todo as completed: "Run safety checks"

---

**Step 2: Check for Existing PR**

Mark todo as in_progress: "Check for existing PR"

1. Run: `gh pr list --head $FEATURE_BRANCH --base develop --json number -q '.[0].number' 2>/dev/null`
2. If PR exists:
   - Get PR number
   - Echo "✅ PR already exists for this feature branch"
   - Skip to Step 4
3. If PR doesn't exist:
   - Echo "❌ No PR found - will create one"
   - Continue to Step 3

Mark todo as completed: "Check for existing PR"

---

**Step 3: Create PR (REQUIRED IF NO PR EXISTS)**

Mark todo as in_progress: "Create PR if needed"

**🚨 STOP**: You MUST create a PR to proceed

1. Get commit list: `git log develop..HEAD --oneline`
2. Generate PR title: `{ISSUE_KEY}: {Brief description}`
3. Generate PR body with:
   - Summary section
   - Changes list
   - Link to YouTrack issue (if available)
   - **STRIP ALL AI ATTRIBUTION** from body

4. **🚨 STOP - SHOW PR TO USER FOR APPROVAL:**

   Present the PR content in a clear format:
   ```markdown
   ## PR Preview

   **Title:** {title}
   **Base:** develop ← **Head:** {FEATURE_BRANCH}

   ### Body:
   {PR body content}
   ```

   Ask user: "Does this PR look correct? Should I create it?"

   **DO NOT proceed until user explicitly approves.**

5. Create PR: `gh pr create --title "{title}" --body "{body}" --base develop --head $FEATURE_BRANCH`
6. Verify PR created successfully (check exit code)
7. Get PR number: `PR_NUMBER=$(gh pr list --head $FEATURE_BRANCH --base develop --json number -q '.[0].number')`
8. Echo confirmation: "✅ Created PR #{number}: {feature} → develop"
9. **🚨 VERIFY**: PR number is not empty (if empty, ABORT)

Mark todo as completed: "Create PR if needed"

---

**Step 4: Merge PR to Develop (REQUIRED)**

Mark todo as in_progress: "Merge PR to develop"

**🚨 CRITICAL STEP**: This is where feature → develop merge happens

1. Verify PR number exists
   - If no PR number → ABORT with error "You MUST create a PR first"
2. Echo: "🚀 Merging PR #{number}: {feature} → develop"
3. Execute merge: `gh pr merge $PR_NUMBER --merge --delete-branch=false`
4. Check exit code
   - If merge failed → ABORT with error
5. If merge succeeded → Echo "✅ PR merged successfully!"
6. Verify merge: `gh pr view $PR_NUMBER --json state,mergedAt`
7. Confirm state is "MERGED"
   - If not merged → ABORT with error
8. Echo: "✅ Your changes are now in develop branch"
9. **🚨 VERIFY**: Code is actually in develop

Mark todo as completed: "Merge PR to develop"

---

**Step 5: Monitor Staging Deployment (if CI_MODE="monitor")**

Mark todo as in_progress: "Monitor staging deployment"

**If CI_MODE="quick":**
- Echo: "⚡ Quick mode: Skipping staging deployment monitoring"
- Echo: "ℹ️  Deployment will run in background - check manually if needed"
- Mark todo as completed and skip to Step 6

**If CI_MODE="monitor":**
1. Echo: "⏳ Waiting for staging deployment on develop branch..."
2. Get latest run on develop: `RUN_ID=$(gh run list --branch develop --limit 1 --json databaseId -q '.[0].databaseId')`
3. Watch deployment: `gh run watch $RUN_ID` OR poll every 30 seconds
4. Wait for deployment to complete
5. Check deployment status
   - If deployment failed → Report error to user, mark todo as failed
   - If deployment succeeded → Echo "✅ Staging deployment complete!"

Mark todo as completed: "Monitor staging deployment"

---

**Step 6: Verify All Changes in Develop**

Mark todo as in_progress: "Verify all changes are in develop"

**Final verification checks:**

1. Check: Did you create a PR? (Must be YES)
2. Check: Did you merge the PR? (Must be YES)
3. Check: Is code in develop? (Must be YES)
4. Check: Did deployment succeed? (Must be YES)

**If ANY check above is NO → ABORT, Level 2 is NOT complete**

Mark todo as completed: "Verify all changes are in develop"

---

**Step 7: Ask About YouTrack Status Update**

Mark todo as in_progress: "Ask user about YouTrack status update"

1. If YouTrack MCP enabled AND ISSUE_KEY exists:
   - Ask user: "PR merged to develop successfully. Update YouTrack status?"
   - Suggested status: "Waiting for QA", "Test" or "Complete"
   - If yes → Update issue status via YouTrack MCP
   - Echo confirmation: "✅ YouTrack status updated"

2. If YouTrack not available:
   - Echo: "ℹ️  YouTrack not configured, skipping status update"

Mark todo as completed: "Ask user about YouTrack status update"

---

**Step 8: Checkout Develop Branch**

Mark todo as in_progress: "Checkout develop branch"

**This step is MANDATORY - always end on develop**

1. Fetch latest develop:
   ```bash
   git fetch origin develop
   ```

2. Checkout develop:
   ```bash
   git checkout develop
   ```

3. Pull latest:
   ```bash
   git pull origin develop
   ```

4. Verify on develop:
   ```bash
   CURRENT=$(git branch --show-current)
   if [ "$CURRENT" != "develop" ]; then
     echo "❌ ERROR: Failed to checkout develop"
     exit 1
   fi
   ```

5. Verify local develop has your changes (check git log)
6. Echo: "✅ Switched to develop branch"
7. Echo: "✅ Local develop is up to date with your changes"
8. Echo: "✅ Ready for next work"

Mark todo as completed: "Checkout develop branch"

---

**LEVEL 2 COMPLETE ✅**

All todos should now be marked as completed.
Your code is in develop, deployed to staging, and you're on develop branch ready for next work.

---

**SAFETY CHECK BEFORE LEVEL 2:**
```bash
# Verify develop exists
git fetch origin develop
if [ $? -ne 0 ]; then
  echo "❌ ERROR: Cannot fetch develop branch from remote"
  echo "Please verify develop branch exists"
  exit 1
fi

# Verify we're on a feature branch (not on protected branch)
FEATURE_BRANCH=$(git branch --show-current)
if [[ "$FEATURE_BRANCH" == "master" || "$FEATURE_BRANCH" == "main" || "$FEATURE_BRANCH" == "develop" ]]; then
  echo "❌ ERROR: Cannot merge from protected branch: $FEATURE_BRANCH"
  echo "You must be on a feature branch to merge to develop"
  exit 1
fi

echo "✓ Feature branch: $FEATURE_BRANCH"
echo "✓ Will merge: $FEATURE_BRANCH → develop"
```

6. **🚨 STEP 6: CREATE AND MERGE PR TO DEVELOP (REQUIRED)**

   **This is NOT optional - PR is MANDATORY for merging to develop**

   **A) Check if PR exists:**
   ```bash
   FEATURE_BRANCH=$(git branch --show-current)
   echo "🔍 Checking for existing PR from $FEATURE_BRANCH to develop..."

   gh pr list --head $FEATURE_BRANCH --base develop --json number,title,state -q '.[0]' 2>/dev/null

   if [ $? -eq 0 ]; then
     echo "✅ PR already exists for this feature branch"
   else
     echo "❌ No PR found - will create one"
   fi
   ```

   **B) If no PR exists, CREATE ONE (REQUIRED):**

   **🚨 YOU CANNOT PROCEED WITHOUT A PR**

   Steps to create PR:
   1. Follow "PR Creation" section below to generate PR title and body
   2. **CRITICAL**: Strip all AI attribution from commit messages
   3. Get user approval for PR message
   4. Create PR to develop (NOT to master):
      ```bash
      gh pr create --title "..." --body "..." --base develop --head $FEATURE_BRANCH
      ```
   5. Verify PR was created:
      ```bash
      PR_NUMBER=$(gh pr view --json number -q .number)
      echo "✅ Created PR #$PR_NUMBER: $FEATURE_BRANCH → develop"
      ```

   **C) MERGE THE PR TO DEVELOP:**

   **🚨 THIS IS THE CRITICAL STEP - PR MERGE IS REQUIRED**

   ```bash
   # Get PR number
   PR_NUMBER=$(gh pr list --head $FEATURE_BRANCH --base develop --json number -q '.[0].number')

   if [ -z "$PR_NUMBER" ]; then
     echo "❌ ERROR: No PR found to merge!"
     echo "You MUST create a PR before merging to develop"
     exit 1
   fi

   echo "🚀 Merging PR #$PR_NUMBER: $FEATURE_BRANCH → develop"

   # Merge the PR (this is the actual merge to develop)
   gh pr merge $PR_NUMBER --merge --delete-branch=false

   if [ $? -eq 0 ]; then
     echo "✅ PR #$PR_NUMBER merged successfully!"
     echo "✅ Your changes are now in develop branch"
   else
     echo "❌ ERROR: Failed to merge PR"
     exit 1
   fi
   ```

   **What this does:**
   - **Merges**: `Feature Branch → Develop Branch` (via GitHub PR)
   - **Mechanism**: GitHub PR merge (NOT direct git merge)
   - **Result**: Your changes are now in develop
   - **Branch**: Feature branch is kept (not deleted)

   **DO NOT:**
   - ❌ Use `git merge` directly
   - ❌ Push directly to develop
   - ❌ Skip PR creation
   - ❌ Delete feature branch

7. **Monitor staging deployment until complete**

   **OPTION A - Recommended: Watch develop branch CI**
   ```bash
   # Get the most recent run on develop branch (triggered by merge)
   RUN_ID=$(gh run list --branch develop --limit 1 --json databaseId -q '.[0].databaseId')

   # Watch the deployment
   gh run watch $RUN_ID
   ```

   **OPTION B - Fallback: Poll deployment status**
   ```bash
   echo "⏳ Waiting for staging deployment to complete..."

   for i in {1..12}; do  # Max 6 minutes (12 x 30 seconds)
     sleep 30
     STATUS=$(gh run list --branch develop --limit 1 --json status,conclusion -q '.[0]')

     if [[ $(echo $STATUS | jq -r '.status') == "completed" ]]; then
       echo "✓ Deployment completed!"
       break
     fi

     echo "Still deploying... (${i}/12)"
   done
   ```

   **OPTION C - Simple wait**
   ```bash
   echo "⏳ Waiting 3 minutes for staging deployment..."
   sleep 180
   ```

8. **Check staging deployment status**
   - Get deployment results:
     ```bash
     gh run view --json conclusion,jobs
     ```
   - Verify deployment to staging succeeded
   - If deployment fails, report failure and STOP
   - If successful, proceed to next level or stop here based on user choice

**END OF LEVEL 2:**

If stopping at Level 2 (not proceeding to Level 3):
```bash
# Switch to develop branch (where your changes now live)
git fetch origin develop
git checkout develop
git pull origin develop

echo "✓ Switched to develop branch"
echo "✓ Your changes are now in develop and deployed to staging"
echo "✓ Ready for production release when you're ready (Level 3)"
```

**Optional: Update YouTrack Status (Level 2)**

If `PROJECT_CONTEXT.mcp_tools.youtrack.enabled` is true and `ISSUE_KEY` is available:

1. **Ask user:** "Would you like to update the YouTrack issue status?"
   - Use AskUserQuestion tool with Yes/No options

2. **If Yes, ask which status:**
   - Use AskUserQuestion tool with these options:
     - **"Waiting for QA"** - Recommended (changes are in staging, ready for QA testing)
     - **Keep current status** - No change

3. **If user selects "Waiting for QA":**
   ```bash
   # Update YouTrack issue status
   mcp__youtrack__update_issue(
     issueId: ISSUE_KEY,
     customFields: {
       "State": "Waiting for QA"
     }
   )
   ```
   - Confirm: "✓ Updated {ISSUE_KEY} status to 'Waiting for QA'"

### Level 3: Release to Master (Production)

{{MODULE: ~/.claude/modules/shared/approval-gate.md}}

**Purpose:** Merge develop into master/main and deploy to production

**⚠️  IMPORTANT: Level 3 uses direct merge commit (NO PR)**

**⚠️  CRITICAL PREREQUISITES:**
- ✅ Level 1 MUST be completed (feature tested)
- ✅ Level 2 MUST be completed (feature merged to develop via PR)
- ✅ Staging deployment MUST be verified
- ✅ **This merges DEVELOP → MASTER** (NOT feature → master)
- ✅ **Uses git merge with merge commit** (NOT pull request)

---

**📋 LEVEL 3: CREATE TODO LIST**

Use TodoWrite to create checklist:

```javascript
TodoWrite({
  todos: [
    {content: "Run safety checks and confirm production release", status: "pending", activeForm: "Running safety checks"},
    {content: "Prepare develop and master branches locally", status: "pending", activeForm: "Preparing branches"},
    {content: "Merge develop to master (direct merge commit)", status: "pending", activeForm: "Merging develop to master"},
    {content: "Monitor production deployment on master branch", status: "pending", activeForm: "Monitoring production deployment"},
    {content: "Verify production deployment succeeded", status: "pending", activeForm: "Verifying production deployment"},
    {content: "Ask user about YouTrack status update", status: "pending", activeForm: "Asking about YouTrack update"},
    {content: "Checkout develop branch", status: "pending", activeForm: "Checking out develop branch"}
  ]
})
```

---

**EXECUTION:**

**Step 1: Safety Checks and Confirmation**

Mark todo as in_progress: "Run safety checks and confirm production release"

**⚠️  CRITICAL: PRODUCTION RELEASE - EXTRA SAFETY CHECKS**
```bash
# Fetch ALL remotes to ensure we have latest refs
git fetch --all --prune

# Determine production branch (master or main)
PROD_BRANCH=""
if git show-ref --verify --quiet refs/remotes/origin/master; then
  PROD_BRANCH="master"
elif git show-ref --verify --quiet refs/remotes/origin/main; then
  PROD_BRANCH="main"
else
  echo "❌ CRITICAL ERROR: Neither master nor main branch exists on remote"
  echo "Cannot proceed with production release"
  exit 1
fi

echo "✓ Production branch: $PROD_BRANCH"

# Verify develop exists
if ! git show-ref --verify --quiet refs/remotes/origin/develop; then
  echo "❌ CRITICAL ERROR: develop branch does not exist on remote"
  exit 1
fi

echo "✓ develop branch exists"

# Verify develop has recent changes (Level 2 should have merged to it)
DEVELOP_COMMITS=$(git log origin/$PROD_BRANCH..origin/develop --oneline | wc -l)
if [ "$DEVELOP_COMMITS" -eq 0 ]; then
  echo "⚠️  WARNING: develop has no new commits ahead of $PROD_BRANCH"
  echo "Did you complete Level 2 (merge to develop)?"
  echo "Press Ctrl+C to abort, or Enter to continue anyway..."
  read -r
fi

echo "✓ develop has $DEVELOP_COMMITS commit(s) ahead of $PROD_BRANCH"

# Store current branch to return to
CURRENT_BRANCH=$(git branch --show-current)
echo "✓ Current branch: $CURRENT_BRANCH"
echo "✓ Will return to: $CURRENT_BRANCH after production merge"

# Confirm with user
echo ""
echo "⚠️  WARNING: About to merge DEVELOP → $PROD_BRANCH (PRODUCTION)"
echo "This will deploy ALL changes from develop to production!"
echo "This is NOT merging your feature branch directly to production."
echo ""
```

**ASK USER FOR EXPLICIT CONFIRMATION:**
- "Are you ABSOLUTELY SURE you want to deploy to production?"
- "Confirm you have completed Level 2 (feature merged to develop)"
- "Type 'yes' to confirm production deployment:"
- If not "yes", ABORT immediately

9. **Prepare production merge (LOCAL TRACKING ONLY)**
   ```bash
   # Create local tracking branches if they don't exist
   # NEVER use -B (force create) - it can delete branches!

   # Develop tracking
   if ! git show-ref --verify --quiet refs/heads/develop; then
     git checkout -t origin/develop
   else
     git checkout develop
     git pull origin develop
   fi

   # Production branch tracking
   if ! git show-ref --verify --quiet refs/heads/$PROD_BRANCH; then
     git checkout -t origin/$PROD_BRANCH
   else
     git checkout $PROD_BRANCH
     git pull origin $PROD_BRANCH
   fi
   ```
   - **CRITICAL**: Use `-t` (track) NOT `-B` (force create)
   - **VERIFY**: `git branch -vv` to confirm tracking

10. **Merge and push to production (using merge commit)**
    ```bash
    # Ensure we're on production branch
    VERIFY_BRANCH=$(git branch --show-current)
    if [[ "$VERIFY_BRANCH" != "$PROD_BRANCH" ]]; then
      echo "❌ ERROR: Not on $PROD_BRANCH branch (on $VERIFY_BRANCH)"
      exit 1
    fi

    # Merge develop with merge commit (NO PR)
    git merge develop --no-ff -m "Release: Merge develop to $PROD_BRANCH"

    # Push to production
    git push origin $PROD_BRANCH
    ```
    - **IMPORTANT**: This is a direct git merge, NOT a pull request
    - Creates a merge commit in master/main
    - **NEVER** use `git branch -D` anywhere
    - **ALWAYS** switch to develop after production release

11. **Monitor and Verify Production Deployment (if CI_MODE="monitor")**

    **If CI_MODE="quick":**
    - Echo: "⚡ Quick mode: Skipping production deployment monitoring"
    - Echo: "ℹ️  Deployment will run in background - check manually if needed"
    - Echo: "⚠️  WARNING: Production changes pushed without verification!"
    - Skip to checkout develop step

    **If CI_MODE="monitor":**
    - Echo: "⏳ Waiting for production deployment on $PROD_BRANCH..."
    - Get latest run: `RUN_ID=$(gh run list --branch $PROD_BRANCH --limit 1 --json databaseId -q '.[0].databaseId')`
    - Watch deployment: `gh run watch $RUN_ID`
    - Check CI for production deployment status
    - Report final status
    - Confirm deployment succeeded

**END OF LEVEL 3 - MANDATORY CHECKOUT DEVELOP:**

**🚨 CRITICAL: You MUST checkout develop after production release**

This step is NON-NEGOTIABLE. Staying on master risks accidental commits to production.

```bash
# MANDATORY: Switch to develop branch after production release
git fetch origin develop
git checkout develop
git pull origin develop

# Verify you're on develop
CURRENT=$(git branch --show-current)
if [ "$CURRENT" != "develop" ]; then
  echo "❌ CRITICAL ERROR: Failed to checkout develop!"
  echo "You are on: $CURRENT"
  echo "Manually run: git checkout develop && git pull origin develop"
  exit 1
fi

echo "✅ Switched to develop branch"
echo "✅ Production release complete!"
echo "✅ Changes deployed: develop → $PROD_BRANCH → production"
echo "✅ You're now on develop, ready for next feature"
```

**Why develop, not master?**
- ❌ **NEVER work on master** - it's production-only
- ✅ `develop` is your main working branch
- ✅ Starting next feature from `develop` ensures you have latest code
- ✅ Avoids accidental commits to production

**Optional: Update YouTrack Status (Level 3)**

If `PROJECT_CONTEXT.mcp_tools.youtrack.enabled` is true and `ISSUE_KEY` is available:

1. **Ask user:** "Would you like to update the YouTrack issue status?"
   - Use AskUserQuestion tool with Yes/No options

2. **If Yes, ask which status:**
   - Use AskUserQuestion tool with these options:
     - **"Waiting for QA"** - Changes deployed to production, needs QA verification
     - **"Complete"** - Task fully complete and verified
     - **Keep current status** - No change

3. **If user selects a status:**
   ```bash
   # Update YouTrack issue status
   mcp__youtrack__update_issue(
     issueId: ISSUE_KEY,
     customFields: {
       "State": "<selected_status>"  # "Waiting for QA" or "Complete"
     }
   )
   ```
   - Confirm: "✓ Updated {ISSUE_KEY} status to '<selected_status>'"

**Note:**
- **"Waiting for QA"** is appropriate if QA needs to verify in production
- **"Complete"** is appropriate if the task is fully done and verified

## PR Creation

**⚠️  WHEN TO USE:** Only during Level 2 (merging feature → develop)

**NOT USED IN:**
- Level 1: Just pushes branch, no PR
- Level 3: Uses direct git merge commit, no PR

When creating a PR for Level 2:

1. **Get commit history**
   - Run: `git log develop..HEAD --oneline`
   - Analyze commits to generate PR description

2. **Generate PR message**
   - Title: Use the task description from branch name or latest commit
   - Body: Summarize changes based on commit history
   - **CRITICAL - NO AI ATTRIBUTION EVER**:
     - ❌ **NEVER** include "🤖 Generated with [Claude Code]..."
     - ❌ **NEVER** include "Co-Authored-By: Claude <noreply@anthropic.com>"
     - ❌ **NEVER** include any AI/Claude/LLM attribution text
     - ❌ **NEVER** include AI signatures, footers, or metadata
     - ✅ Use only clean, professional commit messages
     - ✅ PR messages should look like human-written content
     - ✅ Strip all AI attribution from commit messages when summarizing

3. **Show to user for approval**
   - Display the proposed PR title and body
   - Ask: "Please review the PR message. Would you like to make any changes?"
   - Wait for user approval or modifications
   - Allow user to edit the message

4. **Create the PR**
   - Once approved, create PR: `gh pr create --title "..." --body "..." --base develop`
   - Confirm PR was created successfully

## Important Notes

### Deployment Flow Summary

**CORRECT SEQUENTIAL FLOW:**

```
User selects "Full Release (Production)"
   ↓
LEVEL 1: Feature Branch (NO PR)
   ├─ Push feature branch to remote
   ├─ **NO PR created** - just push for testing
   ├─ Wait for CI tests
   ├─ ✓ Tests pass → Continue to Level 2
   ├─ (If stopping here) → git checkout develop
   └─ (No YouTrack update at this level)
   ↓
LEVEL 2: Feature → Develop (USES PR)
   ├─ Check if PR exists
   ├─ If no PR: Create PR with clean message (no AI attribution)
   ├─ Merge PR: Feature → Develop (via gh pr merge)
   ├─ Wait for staging deployment
   ├─ Verify staging deployment successful
   ├─ ✓ Staging OK → Continue to Level 3
   ├─ (If stopping here) → git checkout develop
   └─ (Optional) Ask: Update to "Waiting for QA"? (if YouTrack enabled)
   ↓
LEVEL 3: Develop → Master (MERGE COMMIT, NO PR)
   ├─ Verify develop has new commits
   ├─ Ask explicit user confirmation
   ├─ **Direct git merge**: Develop → Master (no PR)
   ├─ Create merge commit: "Release: Merge develop to master"
   ├─ Push to production
   ├─ ✓ Production deployed
   ├─ 🚨 **MANDATORY**: git checkout develop && git pull (ALWAYS!)
   └─ (Optional) Ask: Update to "Waiting for QA" or "Complete"? (if YouTrack enabled)

🚨 FINAL STATE: You MUST be on develop branch, ready for next feature
   - NEVER stay on master after release
   - ALWAYS verify: git branch --show-current == "develop"
```

**⚠️  WHAT HAPPENED WHEN MASTER WAS DELETED:**

The old workflow tried to skip Level 2 or merge incorrectly:
- ❌ **WRONG**: Feature → Master (skipping develop)
- ❌ **WRONG**: Using force create (`git checkout -B master`)
- ❌ **WRONG**: Not verifying branches exist before operations

**✅ NOW FIXED:**

- ✅ **Enforces**: Feature → Develop → Master (sequential)
- ✅ **Verifies**: Each level completed before proceeding
- ✅ **Checks**: Branches exist before any operation
- ✅ **Guards**: Never use force delete/force create
- ✅ **Confirms**: Explicit user confirmation for production

---

### Critical Safety Rules (ALWAYS FOLLOW)

**POST-RELEASE: ALWAYS CHECKOUT DEVELOP**
- ✅ **MANDATORY**: After ANY release level, checkout and pull develop
- ✅ **Especially Level 3**: After production release, you MUST end on develop
- ✅ **NEVER stay on master/main** - it's production-only, not for development
- ✅ **Commands to run at end of every release:**
  ```bash
  git fetch origin develop
  git checkout develop
  git pull origin develop
  ```
- **Why?** Staying on master risks accidental commits to production

**PROTECTED BRANCHES - NEVER DELETE:**
- ❌ **NEVER** use `git branch -D` (force delete)
- ❌ **NEVER** use `git checkout -B` (force create - can delete existing branch)
- ❌ **NEVER** delete: `master`, `main`, `develop`, `production`, `staging`
- ✅ **ALWAYS** use `git checkout -t` (track) for remote branches
- ✅ **ALWAYS** verify branch exists before checkout: `git show-ref --verify --quiet refs/remotes/origin/BRANCH`
- ✅ **ALWAYS** fetch before operations: `git fetch --all`
- ✅ **ALWAYS** store current branch and return to it after operations

**BRANCH OPERATIONS:**
- ✅ Use `gh pr merge` for merges (safer than local git merge)
- ✅ Verify current branch before ANY operation
- ✅ Confirm production deployments explicitly
- ✅ Check branch existence before checkout/merge
- ✅ Return to original branch after Level 2/3

**GENERAL RULES:**
- **Always confirm** before pushing to master/main
- **Stop immediately** if any tests or deployments fail
- **Report status** after each major step
- **❌ NEVER INCLUDE AI ATTRIBUTION** - No "Generated with Claude", no "Co-Authored-By: Claude", no AI signatures in:
  - Pull request titles or bodies
  - Commit messages (strip them when reading commit history)
  - Any user-facing content or documentation
  - All content must appear human-written
- Use `gh` CLI for GitHub operations
- Use YouTrack MCP tools for task updates
- If waiting seems too long, offer to check CI status early
- Task ID is automatically extracted from branch name format: `{type}/{STAR-XXXX}-{Description}`

## Error Handling

If any step fails:
1. Report exactly what failed
2. Show relevant error messages
3. Suggest remediation steps
4. Ask if user wants to retry or abort

### Emergency Recovery: Branch Deleted Accidentally

**If a protected branch (master/main/develop) was deleted:**

1. **Check if branch exists on remote:**
   ```bash
   git fetch --all
   git branch -r | grep -E 'origin/(master|main|develop)'
   ```

2. **If branch exists on remote, restore local tracking:**
   ```bash
   # For master
   git checkout -t origin/master

   # For main
   git checkout -t origin/main

   # For develop
   git checkout -t origin/develop
   ```

3. **If branch deleted from remote (CRITICAL):**
   ```bash
   # Check reflog for last commit
   git reflog show origin/master

   # Restore from last known commit
   git checkout -b master <commit-hash>
   git push origin master
   ```

4. **Prevention going forward:**
   - Enable branch protection on GitHub/GitLab
   - Protect: `master`, `main`, `develop`
   - Require pull request reviews
   - Prevent force pushes

## CI Check Commands

**Auto-approved commands (no user permission needed):**
- `gh run view` - Always allowed, user should not need to approve
- `gh run list` - Always allowed for checking CI status
- `gh run watch` - Always allowed for monitoring runs in real-time
- `gh pr view` - Always allowed for checking PR status
- `gh pr checks` - Always allowed for checking PR checks

### Recommended: Use gh run watch

The best approach is to actively monitor runs instead of blind waiting:

```bash
# Get the most recent run for a branch
RUN_ID=$(gh run list --branch <branch-name> --limit 1 --json databaseId -q '.[0].databaseId')

# Watch it until completion (auto-approved, no permission needed)
gh run watch $RUN_ID
```

### Alternative: Check workflow status manually

```bash
gh run list --branch <branch-name> --limit 1
gh run view <run-id>  # Auto-approved, no user permission needed
```

### Check specific workflow

```bash
gh run list --workflow="Tests" --branch <branch-name>
```
