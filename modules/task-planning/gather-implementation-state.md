# Module: gather-implementation-state

## Purpose
Gather current implementation state from git and filesystem for reconciliation.

## Scope
TASK-PLANNING - In Progress Mode (Step 1)

## Mode
READ-ONLY

---

## When to Use
First step of In Progress Mode - gathering facts about what has been implemented.

---

## Instructions

### Step 1: Get Branch Information

```bash
# Current branch
CURRENT_BRANCH=$(git branch --show-current)

# Base branch (usually develop or main)
BASE_BRANCH="${PROJECT_BASE_BRANCH:-develop}"

# Extract issue key from branch
ISSUE_KEY=$(echo "$CURRENT_BRANCH" | grep -oE '[A-Z]+-[0-9]+' | head -1)
```

### Step 2: Count Commits and Changes

```bash
# Commits ahead of base branch
COMMITS_AHEAD=$(git rev-list --count ${BASE_BRANCH}..HEAD 2>/dev/null || echo "0")

# Uncommitted changes
UNCOMMITTED=$(git status --porcelain | wc -l | tr -d ' ')

# Staged changes
STAGED=$(git diff --cached --name-only | wc -l | tr -d ' ')
```

### Step 3: Get Changed Files Summary

```bash
# Files changed vs base branch
CHANGED_FILES=$(git diff --name-only ${BASE_BRANCH}..HEAD 2>/dev/null)

# Get file change statistics
git diff --stat ${BASE_BRANCH}..HEAD 2>/dev/null
```

### Step 4: Get Recent Commits

```bash
# List commits on this branch (not on base)
git log ${BASE_BRANCH}..HEAD --oneline --no-merges
```

### Step 5: Check for Task Docs Folder

```bash
# Find task docs folder
TASK_FOLDER=$(find "${TASK_DOCS_DIR:-.task-docs}" -type d -name "${ISSUE_KEY}*" 2>/dev/null | head -1)

if [ -n "$TASK_FOLDER" ]; then
  FOLDER_EXISTS="yes"
else
  FOLDER_EXISTS="no"
fi
```

---

## Output Summary

Present gathered state:

```markdown
## Implementation State: {ISSUE_KEY}

### Git State
| Metric | Value |
|--------|-------|
| Branch | `{CURRENT_BRANCH}` |
| Base | `{BASE_BRANCH}` |
| Commits ahead | {COMMITS_AHEAD} |
| Uncommitted | {UNCOMMITTED} files |
| Staged | {STAGED} files |

### Changed Files ({count})
<details>
<summary>Click to expand file list</summary>

{CHANGED_FILES list}

</details>

### Recent Commits
```
{commit list from git log}
```

### Task Documentation
- Folder: {TASK_FOLDER or "not found"}
- Exists: {yes/no}
```

---

## Outputs
- `CURRENT_BRANCH`: Branch name
- `BASE_BRANCH`: Base branch name
- `ISSUE_KEY`: Extracted issue key
- `COMMITS_AHEAD`: Number of commits
- `UNCOMMITTED`: Uncommitted file count
- `CHANGED_FILES`: List of changed files
- `TASK_FOLDER`: Path to task docs (if found)
- `FOLDER_EXISTS`: yes/no
- `IMPLEMENTATION_STATE`: Complete summary object
