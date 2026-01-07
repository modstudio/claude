---
description: Start planning a new task - ignores current branch state (global)
---

# New Task

Plan a NEW task, ignoring any in-progress work on the current branch.

**⚠️ IMPORTANT:** This is for planning a NEW, UNRELATED task. Current branch state is irrelevant.

---

## YOUR FIRST RESPONSE MUST INCLUDE:

1. **TodoWrite** - Create todo list:
   - "Get task details from user" status=in_progress activeForm="Getting task details"
   - "Create/find YouTrack issue" status=pending activeForm="Setting up issue"
   - "Create task documentation" status=pending activeForm="Creating docs"
   - "Plan implementation" status=pending activeForm="Planning"
   - "Ask about worktree for implementation" status=pending activeForm="Asking about worktree"

2. **AskUserQuestion** - Get task details:
   ```javascript
   AskUserQuestion({
     questions: [{
       question: "What task do you want to plan?",
       header: "Task",
       multiSelect: false,
       options: [
         {label: "New feature", description: "Plan a new feature implementation"},
         {label: "Bug fix", description: "Plan a bug fix"},
         {label: "Technical/refactor", description: "Plan technical improvement or refactoring"},
         {label: "Enhancement", description: "Plan enhancement to existing feature"}
       ]
     }]
   })
   ```

**CALL BOTH TOOLS NOW.**

---

## ⚠️ CRITICAL: Ignore Current State

**DO NOT:**
- Run `detect-mode.sh` (we don't care about current branch)
- Check for uncommitted changes
- Reference current branch or task folder
- Suggest reconciling existing work

**DO:**
- Treat this as a completely fresh start
- Focus only on the NEW task being planned
- Create new branch when ready to implement

---

## Step 2: Get Task Details

After user selects type, ask:

```javascript
AskUserQuestion({
  questions: [{
    question: "Do you have a YouTrack issue for this task?",
    header: "Issue",
    multiSelect: false,
    options: [
      {label: "Yes, I have an issue key", description: "I'll provide the STAR-XXXX issue key"},
      {label: "No, create one", description: "Create a new YouTrack issue for me"},
      {label: "No issue needed", description: "Plan without YouTrack (local docs only)"}
    ]
  }]
})
```

**If user has issue key:** Ask for it, then fetch details from YouTrack
**If creating new:** Gather title/description, create via MCP
**If no issue:** Proceed with user-provided description only

---

## Step 3: Create Task Documentation

**Create new task folder:**

```bash
# Get task docs directory
source ~/.claude/lib/project-context.sh
load_project_context

# Create folder
TASK_FOLDER="${PROJECT_TASK_DOCS_DIR}/${ISSUE_KEY}-${SLUG}"
mkdir -p "$TASK_FOLDER/logs"
```

{{MODULE: ~/.claude/modules/task-planning/create-task-folder.md}}

---

## Step 4: Plan Implementation

{{MODULE: ~/.claude/modules/task-planning/technical-planning.md}}

**Create:**
- `00-status.md` - Status: Planning
- `01-task-description.md` - Task scope
- `02-functional-requirements.md` - Requirements
- `03-implementation-plan.md` - Technical approach
- `04-todo.md` - Implementation checklist

---

## Step 5: Ask About Worktree

**After planning is complete, present options:**

```javascript
AskUserQuestion({
  questions: [{
    question: "Planning complete! How do you want to implement this task?",
    header: "Implementation",
    multiSelect: false,
    options: [
      {label: "Create worktree (Recommended)", description: "Create git worktree to work on this task without disturbing current work"},
      {label: "Switch branch now", description: "Stash current changes and switch to new branch (will interrupt current work)"},
      {label: "Just save the plan", description: "Keep the plan, I'll implement later"}
    ]
  }]
})
```

---

## Worktree Implementation

**If user chooses worktree:**

```bash
# Determine worktree location
WORKTREE_BASE="${HOME}/Projects/worktrees"
PROJECT_NAME=$(basename $(git rev-parse --show-toplevel))
WORKTREE_PATH="${WORKTREE_BASE}/${PROJECT_NAME}-${ISSUE_KEY}"

# Create branch first (from base branch)
git branch "${BRANCH_TYPE}/${ISSUE_KEY}-${SLUG}" "${PROJECT_BASE_BRANCH:-develop}"

# Create worktree
git worktree add "$WORKTREE_PATH" "${BRANCH_TYPE}/${ISSUE_KEY}-${SLUG}"

echo "Worktree created at: $WORKTREE_PATH"
echo "To work on this task: cd $WORKTREE_PATH"
```

**Present result:**

```markdown
## Worktree Created

**Location:** `{WORKTREE_PATH}`
**Branch:** `{BRANCH_TYPE}/{ISSUE_KEY}-{SLUG}`

### To start working:
\`\`\`bash
cd {WORKTREE_PATH}
\`\`\`

### Task documentation:
`{TASK_FOLDER}`

Your current work remains untouched in the main directory.
```

---

## Switch Branch Implementation

**If user chooses to switch:**

```bash
# Stash current work
git stash push -m "WIP: Before starting ${ISSUE_KEY}"

# Create and checkout new branch
git checkout -b "${BRANCH_TYPE}/${ISSUE_KEY}-${SLUG}" "${PROJECT_BASE_BRANCH:-develop}"
```

**Remind user:**
```markdown
Switched to new branch. Your previous work is stashed.

To return to previous work:
\`\`\`bash
git checkout {PREVIOUS_BRANCH}
git stash pop
\`\`\`
```

---

## Save Plan Only

**If user chooses to save plan:**

```markdown
## Plan Saved

**Task docs:** `{TASK_FOLDER}`
**Issue:** {ISSUE_KEY}

When ready to implement:
1. Run `/new-task-g` and select this issue, OR
2. Create branch manually: `git checkout -b {BRANCH_TYPE}/{ISSUE_KEY}-{SLUG} {BASE_BRANCH}`
```

---

## Key Reminders

1. **This is NEW task planning** - ignore all current state
2. **Worktrees preserve current work** - recommended for multitasking
3. **Task docs are independent** - stored in PROJECT_TASK_DOCS_DIR
4. **No commits to current branch** - all new work goes to new branch/worktree
