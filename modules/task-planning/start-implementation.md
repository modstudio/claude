# Module: start-implementation

## Purpose
Set up for implementation: create branch, update status, begin coding.

## Scope
TASK-PLANNING specific

## Mode
WRITE-ENABLED

---

## Inputs
- `ISSUE_KEY`: Issue key
- `TASK_FOLDER`: Task docs folder
- `APPROVED_PLAN`: From finalize-documentation

---

## Instructions

### Step 1: Check for Existing Branch
```bash
EXISTING_BRANCH=$(git branch --list "*${ISSUE_KEY}*" | head -1 | tr -d ' *')
```

**If branch exists:**
```markdown
Found existing branch: `{branch_name}`

Options:
1. Use existing branch
2. Create new branch (will need different name)
```
→ Ask user which option

### Step 2: Create Branch (if needed)
```bash
# Get branch name from project config
BRANCH_PREFIX="${PROJECT_BRANCH_PREFIX:-feature}"
BRANCH_NAME="${BRANCH_PREFIX}/${ISSUE_KEY}-$(echo $SLUG | tr '[:upper:]' '[:lower:]')"

git checkout -b "$BRANCH_NAME"
```

### Step 3: Update Status
**Edit `00-status.md`:**
```markdown
**Status:** In Progress
**Branch:** `{BRANCH_NAME}`
**Started:** {date}
```

### Step 4: Initialize TodoWrite
```javascript
// Load implementation todos from 04-todo.md
TodoWrite({
  todos: [
    // Phase 1 items from plan
    {content: "{Step 1}", status: "pending", activeForm: "{Doing step 1}"},
    {content: "{Step 2}", status: "pending", activeForm: "{Doing step 2}"},
    // ... etc
  ]
})
```

### Step 5: Present Ready State
```markdown
## Ready to Implement

**Branch:** `{BRANCH_NAME}`
**Task Docs:** `{TASK_FOLDER}`

### First Steps (from plan)
1. {First implementation step}
2. {Second implementation step}

Shall I begin with step 1?
```

---

## Implementation Rules

**Single-step approach:**
1. Report what you will do
2. Do it
3. Report what was done
4. Ask permission for next step

**Update docs as you go:**
- Mark items complete in `04-todo.md`
- Add decisions to `logs/decisions.md`
- Update status in `00-status.md`

---

## Outputs
- `BRANCH_NAME`: Created/checked-out branch
- Updated `00-status.md`
- TodoWrite initialized with implementation items
