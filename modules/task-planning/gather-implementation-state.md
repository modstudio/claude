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

## ⚠️ MANDATORY: Run Detection Script FIRST

**Before running any individual git commands, you MUST run:**

```bash
~/.claude/lib/detect-mode.sh --pretty
```

This gives you the basic context (branch, issue key, task folder, commits ahead, uncommitted count).

**Verify you see this output format:**
```
Mode Detection Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Mode:         {mode}
Issue Key:    {key or none}
Branch:       {branch}
Task Folder:  {path or none}   ← Shows if docs exist!
Git State:
  Commits ahead: {N}
  Uncommitted:   {N}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Only proceed after running the script and confirming the output.**

---

## Instructions

### Step 1: Run Detection Script (MANDATORY)

```bash
~/.claude/lib/detect-mode.sh --pretty
```

This provides: Branch, Issue Key, Task Folder, Commits ahead, Uncommitted count.

### Step 2: Get Additional Details (after script)

Once you have the base context from the script, get additional details:

```bash
# Base branch (usually develop or main)
BASE_BRANCH="${PROJECT_BASE_BRANCH:-develop}"

# Staged changes count
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
