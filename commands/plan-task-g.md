---
description: Task planning with YouTrack integration - multi-project support (global)
---

You are helping the user with task planning following the Task Planning Skill.

## Documentation

**Skills:** `~/.claude/skills/task-planning/`
- `default-mode.md` - Planning skill (handles both existing tasks and new tasks)
- `in-progress-mode.md` - Reconciliation skill (sync docs with implementation reality)

**Modules:** `~/.claude/modules/`
- `shared/` - Cross-skill modules (youtrack, approval-gate, quick-context)
- `task-planning/` - Task-planning specific modules (planning-core, get-user-context, etc.)

---

## ⛔ MANDATORY FIRST ACTIONS (DO BOTH)

**You MUST do BOTH of these actions IMMEDIATELY - in your FIRST response:**

### Action A: Initialize Progress Tracking

**IMMEDIATELY call TodoWrite:**

```javascript
TodoWrite({
  todos: [
    {content: "Detect context (run detect-mode.sh)", status: "in_progress", activeForm: "Detecting context"},
    {content: "Confirm planning mode with user", status: "pending", activeForm: "Confirming planning mode"},
    {content: "Execute selected planning skill", status: "pending", activeForm: "Executing planning skill"}
  ]
})
```

### Action B: Run Detection Script

**In the SAME response, run:**

```bash
~/.claude/lib/detect-mode.sh --pretty
```

**DO NOT run `git branch`, `git status`, `git diff`, or ANY other git commands - the script does this.**

The script output will show:
- Mode (default or in_progress)
- Branch name
- Issue key
- **Task Folder** (shows if docs exist!)
- Git state (commits ahead, uncommitted)

---

## Execution Steps

### Step 1: Initialize and Detect (DONE ABOVE)

After running both actions above, confirm these values from the output:

| Field | Value |
|-------|-------|
| Mode | {from script} |
| Issue Key | {from script} |
| Task Folder | {path or "none"} |
| Docs Exist | ✓ Yes / ✗ No |

**Mark first todo complete, second in_progress:**

```javascript
TodoWrite({
  todos: [
    {content: "Detect context (run detect-mode.sh)", status: "completed", activeForm: "Context detected"},
    {content: "Confirm planning mode with user", status: "in_progress", activeForm: "Confirming planning mode"},
    {content: "Execute selected planning skill", status: "pending", activeForm: "Executing planning skill"}
  ]
})
```

---

### Step 2: Confirm Planning Path

**MANDATORY: Always show all three options. Add "(Recommended)" based on detection.**

```javascript
AskUserQuestion({
  questions: [{
    question: "What's your starting point?",
    header: "Planning Path",
    multiSelect: false,
    options: [
      {label: "Existing task", description: "I have an issue key or task docs folder"},
      {label: "New task", description: "Brand new - no issue or docs yet"},
      {label: "In Progress", description: "Already implementing - sync docs with code"}
    ]
  }]
})
```

**Recommendation logic:**

| Detection Result | Recommended Option |
|------------------|-------------------|
| Commits ahead > 0 OR uncommitted > 0 | In Progress |
| ISSUE_KEY found OR TASK_FOLDER exists | Existing task |
| No issue key, no folder, no changes | New task |

---

### Step 3b: Get Task Reference (if "Existing task" selected)

**Only if user selected "Existing task":**

```javascript
AskUserQuestion({
  questions: [{
    question: "Provide the issue key or task folder:",
    header: "Task Reference",
    multiSelect: false,
    options: [
      {label: `${ISSUE_KEY}`, description: "Detected from current branch"},  // Only show if detected
      {label: "Enter different key", description: "Specify another issue key"}
    ]
  }]
})
```

If detect-mode found an ISSUE_KEY, show it as first option. Otherwise only show "Enter different key".

---

### Step 4: Execute Selected Path

**Map user selection to skill:**

| Selection | ISSUE_KEY | Skill |
|-----------|-----------|----------|
| Existing task | From Step 3b (detected or user-provided) | `default-mode.md` |
| New task | `none` (get context from user) | `default-mode.md` → get-user-context |
| In Progress | From detection | `in-progress-mode.md` |

---

#### Existing Task / New Task → Default Mode
→ **Controller:** `~/.claude/skills/task-planning/default-mode.md`

**Branch 1: Context Source**
- Existing task (has issue key) → fetch from YouTrack
- New task (no issue key) → get context from user

**Branch 2: Docs State**
- Folder exists → resume existing task
- No folder → create new task folder

**Key modules used:**
| Step | Module |
|------|--------|
| Fetch issue | `modules/shared/youtrack-fetch-issue.md` |
| Get user context | `modules/task-planning/get-user-context.md` |
| Resume existing | `modules/task-planning/resume-existing-task.md` |
| Create folder | `modules/task-planning/create-task-folder.md` |
| Planning core | `modules/task-planning/planning-core.md` |
| Approval gate | `modules/shared/approval-gate.md` |

---

#### In Progress → Reconciliation Mode
→ **Controller:** `~/.claude/skills/task-planning/in-progress-mode.md`

Syncs documentation with implementation reality (code-first scenarios).

**Key modules used:**
| Step | Module |
|------|--------|
| Gather state | `modules/task-planning/gather-implementation-state.md` |
| Read docs | `modules/task-planning/resume-existing-task.md` |
| Compare & sync | `modules/task-planning/compare-and-sync.md` |
| Sync docs | `modules/task-planning/sync-docs-with-implementation.md` |

---

## Module Execution Pattern

For each todo in the skill:

1. **Read** the module file
2. **Follow** its instructions exactly
3. **Verify** outputs before marking complete
4. **Handle errors** as module specifies
5. **Mark todo complete** only after verification

---

## Key Reminders

### Mode Rules
→ See: `~/.claude/modules/shared/approval-gate.md`

| Phase | Mode |
|-------|------|
| Planning | READ-ONLY |
| Approval Gate | CHECKPOINT |
| Implementation | WRITE-ENABLED |

### YouTrack Issue Creation
→ See: `~/.claude/modules/shared/youtrack-create-issue.md`

**Critical rules:**
1. Use `PROJECT_YOUTRACK_PROJECT_ID` (numeric: "0-0"), NOT project key
2. Only provide `summary` - NO description parameter
3. Verify creation and report issue key

### Folder/Template Verification
→ See: `~/.claude/modules/task-planning/create-task-folder.md`

**Critical rules:**
1. Always run `ls -la "$TASK_FOLDER"` after creation
2. Only mark complete AFTER verifying files exist

### Context Presentation
- Use tables for status checks
- Bullet points for key findings
- `<details>` for expandable full content
- User must see important info WITHOUT expanding

### Don'ts
- ❌ Don't dump raw output - synthesize
- ❌ Don't skip approval gate
- ❌ Don't mark todos complete without verification
- ❌ Don't hardcode project values (use PROJECT_* vars)

---

## Libraries

All in `~/.claude/lib/`:
- `task-docs-utils.sh` - Folder operations
- `issue-utils.sh` - Issue key operations
- `git-utils.sh` - Git operations
- `template-utils.sh` - Template rendering
- `project-context.sh` - Project detection

---

## Storage

→ See: `~/.claude/modules/task-planning/standard-docs-structure.md`

**Location:** `${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/`

---

Begin: **Create TodoWrite with initial 3 steps**, then execute each step in order.
