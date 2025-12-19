# Git Safety Checks Module

**Module:** Branch protection and safe git operations
**Version:** 1.0.0

## Purpose
Define safety checks for git operations to prevent accidental damage to protected branches.

## Scope
SHARED - Used by: commit-planning, release workflows

---

## Protected Branches

The following branches are **protected** and require special handling:

| Branch | Protection Level | Operations Allowed |
|--------|-----------------|-------------------|
| `main` | Critical | Merge via PR only |
| `master` | Critical | Merge via PR only |
| `develop` | High | Merge via PR only |
| `production` | Critical | Deploy pipeline only |
| `staging` | High | Merge via PR only |

---

## Pre-Operation Safety Checks

### Check 1: Verify Not on Protected Branch

**Run before:** Commits, rebases, resets, branch operations

```bash
CURRENT_BRANCH=$(git branch --show-current)
PROTECTED_BRANCHES=("main" "master" "develop" "production" "staging")

for protected in "${PROTECTED_BRANCHES[@]}"; do
  if [[ "$CURRENT_BRANCH" == "$protected" ]]; then
    echo "❌ ERROR: Cannot perform this operation on protected branch: $CURRENT_BRANCH"
    echo "Please switch to a feature branch first"
    exit 1
  fi
done
echo "✅ Safe: On branch $CURRENT_BRANCH"
```

### Check 2: Verify Target Branch Exists

**Run before:** Merges, PRs, rebases onto another branch

```bash
TARGET_BRANCH="develop"  # or master/main

# Fetch latest refs
git fetch --all --quiet

# Check remote exists
if ! git show-ref --verify --quiet "refs/remotes/origin/$TARGET_BRANCH"; then
  echo "❌ ERROR: Branch '$TARGET_BRANCH' does not exist on remote"
  echo "Available branches:"
  git branch -r | head -10
  exit 1
fi
echo "✅ Target branch exists: origin/$TARGET_BRANCH"
```

### Check 3: Verify Feature Branch Pattern

**Run before:** Releases, PRs

```bash
CURRENT_BRANCH=$(git branch --show-current)

# Check if branch follows feature branch naming
if [[ ! "$CURRENT_BRANCH" =~ ^(feature|bugfix|hotfix|release)/ ]]; then
  echo "⚠️ WARNING: Branch doesn't follow naming convention"
  echo "Expected: feature/ISSUE-123-description"
  echo "Actual: $CURRENT_BRANCH"
  # Continue but warn
fi
```

---

## Safe Git Commands

### Branch Operations

| Unsafe | Safe Alternative |
|--------|-----------------|
| `git branch -D` | `git branch -d` (refuses if not merged) |
| `git checkout -B` | `git checkout -b` (refuses if exists) |
| `git push --force` | `git push --force-with-lease` |
| `git reset --hard` | `git stash` first, then reset |

### Delete Branch Safely

```bash
BRANCH_TO_DELETE="feature/old-branch"

# Never delete protected branches
PROTECTED_BRANCHES=("main" "master" "develop" "production" "staging")
for protected in "${PROTECTED_BRANCHES[@]}"; do
  if [[ "$BRANCH_TO_DELETE" == "$protected" ]]; then
    echo "❌ REFUSED: Cannot delete protected branch: $BRANCH_TO_DELETE"
    exit 1
  fi
done

# Use -d (safe delete) not -D (force delete)
git branch -d "$BRANCH_TO_DELETE"
```

### Push with Verification

```bash
# Always verify branch before push
CURRENT_BRANCH=$(git branch --show-current)

# Refuse to push directly to protected branches
if [[ "$CURRENT_BRANCH" =~ ^(main|master|develop)$ ]]; then
  echo "❌ ERROR: Direct push to $CURRENT_BRANCH not allowed"
  echo "Use a PR instead"
  exit 1
fi

# Safe push with lease (prevents overwriting others' work)
git push --force-with-lease origin "$CURRENT_BRANCH"
```

---

## Merge Safety

### Pre-Merge Checklist

Before merging to develop/main:

```bash
# 1. Ensure branch is up to date
git fetch origin develop
git merge origin/develop --no-edit || {
  echo "❌ Merge conflicts detected"
  echo "Resolve conflicts before proceeding"
  exit 1
}

# 2. Verify no uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
  echo "❌ ERROR: Uncommitted changes present"
  git status --short
  exit 1
fi

# 3. Verify tests pass (if required)
# $PROJECT_TEST_CMD_ALL || exit 1
```

### Safe Merge Pattern

```bash
TARGET="develop"
SOURCE=$(git branch --show-current)

# Verify we're not on target
if [[ "$SOURCE" == "$TARGET" ]]; then
  echo "❌ ERROR: Already on $TARGET, cannot merge into itself"
  exit 1
fi

# Create PR instead of direct merge
echo "Creating PR: $SOURCE → $TARGET"
gh pr create --base "$TARGET" --head "$SOURCE"
```

---

## Commit Safety

### Pre-Commit Checks

```bash
# Verify not on protected branch
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" =~ ^(main|master|develop)$ ]]; then
  echo "❌ ERROR: Cannot commit directly to $CURRENT_BRANCH"
  exit 1
fi

# Check for sensitive files
SENSITIVE_PATTERNS=(".env" "credentials" "secret" "password" "*.pem" "*.key")
for pattern in "${SENSITIVE_PATTERNS[@]}"; do
  if git diff --cached --name-only | grep -q "$pattern"; then
    echo "⚠️ WARNING: Potentially sensitive file staged: $pattern"
    echo "Review before committing"
  fi
done
```

### Amend Safety

```bash
# Before amending, verify:
# 1. Commit is yours
AUTHOR=$(git log -1 --format='%ae')
if [[ "$AUTHOR" != "$(git config user.email)" ]]; then
  echo "❌ ERROR: Cannot amend commit by $AUTHOR"
  exit 1
fi

# 2. Commit is not pushed (or push --force-with-lease if it is)
if git log origin/$(git branch --show-current)..HEAD | grep -q "^commit"; then
  echo "⚠️ Commit not yet pushed - safe to amend"
else
  echo "⚠️ WARNING: Commit already pushed"
  echo "Amending will require force push"
fi
```

---

## Reset and Revert Safety

### Safe Reset

```bash
# Always stash before hard reset
if [[ -n $(git status --porcelain) ]]; then
  echo "Stashing uncommitted changes..."
  git stash push -m "Auto-stash before reset $(date +%Y%m%d-%H%M%S)"
fi

# Use soft reset when possible (preserves changes)
git reset --soft HEAD~1

# Only use hard reset with confirmation
read -p "⚠️ Hard reset will lose changes. Continue? [y/N] " confirm
if [[ "$confirm" == "y" ]]; then
  git reset --hard HEAD~1
fi
```

### Revert (Safer than Reset for Pushed Commits)

```bash
COMMIT_TO_UNDO="abc123"

# Revert creates a new commit (safe for pushed branches)
git revert "$COMMIT_TO_UNDO" --no-edit

# Better than:
# git reset --hard $COMMIT_TO_UNDO  # Dangerous for pushed commits!
```

---

## Emergency Recovery

### If You Committed to Wrong Branch

```bash
# 1. Save the commit hash
COMMIT=$(git rev-parse HEAD)

# 2. Undo commit (keep changes)
git reset --soft HEAD~1

# 3. Stash changes
git stash

# 4. Switch to correct branch
git checkout -b correct-branch

# 5. Apply changes
git stash pop
git add . && git commit -m "Moved from wrong branch"
```

### If You Pushed to Protected Branch

```bash
# STOP - Contact team lead
# Do NOT force push to fix
# Use revert instead:
git revert HEAD --no-edit
git push origin develop
```

---

## Quick Reference

### Safe Commands

```bash
# Check current branch
git branch --show-current

# Check if branch exists
git show-ref --verify --quiet refs/heads/branch-name

# Safe delete (merged only)
git branch -d branch-name

# Safe push
git push --force-with-lease

# Safe reset (soft)
git reset --soft HEAD~1

# Undo pushed commit
git revert HEAD
```

### Dangerous Commands (Avoid)

```bash
# Force delete (loses work)
git branch -D branch-name  # ❌

# Force push (overwrites history)
git push --force  # ❌ Use --force-with-lease

# Hard reset (loses work)
git reset --hard  # ⚠️ Stash first

# Push to protected branch
git push origin main  # ❌ Use PR
```

---

**End of Module**
