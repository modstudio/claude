---
description: CI/CD release with feature/develop/production levels (global)
---

# Release

I'll help you guide a release through the CI/CD pipeline.

**Workflow:** `~/.claude/workflows/release/main.md`

---

## Execution Steps

### Step 1: Initialize Progress Tracking

```bash
source ~/.claude/lib/todo-utils.sh
TODOS=$(init_workflow_todos "release")
```

Use **TodoWrite** tool with `$TODOS` to track progress through release levels.

---

### Step 2: Load Project Context

{{MODULE: ~/.claude/modules/load-project-context.md}}

Provides: `PROJECT_TEST_CMD_ALL`, `PROJECT_BASE_BRANCH`, `PROJECT_ISSUE_REGEX`, YouTrack availability.

---

### Step 3: Extract Issue Key

```bash
source ~/.claude/lib/issue-utils.sh
source ~/.claude/lib/git-utils.sh

ISSUE_KEY=$(extract_issue_key_from_branch "$PROJECT_ISSUE_REGEX")
```

---

### Step 4: Select Release Level

Use **AskUserQuestion** tool:

**Question:** "Which release level do you want to execute?"
**Header:** "Release Level"
**multiSelect:** false

**Options:**
1. Label: "Feature Branch Only" | Description: "Push feature and verify tests. Early validation."
2. Label: "Feature + Develop (Staging)" | Description: "Merge to develop, verify staging. Standard feature completion."
3. Label: "Full Release (Production)" | Description: "Complete release with production deployment."

---

### Step 5: Execute Release Workflow

Follow: `~/.claude/workflows/release/main.md`

**Levels based on selection:**
- **Feature Only:** Level 1
- **Feature + Develop:** Levels 1-2
- **Full Release:** Levels 1-3

**Process:**
- Run tests: `$PROJECT_TEST_CMD_ALL`
- Verify CI/CD: `gh pr checks`
- Merge to `$PROJECT_BASE_BRANCH`
- Tag for production (Level 3)
- Update YouTrack (optional)

---

## Key Reminders

- Initialize TodoWrite → Load context → Extract issue key → Select level → Execute
- Run tests before each merge
- Verify CI/CD passes at each stage
- Update TodoWrite after each level

---

Begin: Initialize TodoWrite, load context, extract issue key, present level selection.
