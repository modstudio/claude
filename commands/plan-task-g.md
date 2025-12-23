---
description: Task planning with YouTrack integration - multi-project support (global)
---

You are helping the user with task planning following the Task Planning Workflow.

## Documentation

**Workflows:** `~/.claude/workflows/task-planning/`
- `default-mode.md` - Planning workflow (handles both YouTrack and greenfield scenarios)
- `in-progress-mode.md` - Reconciliation workflow (sync docs with implementation reality)

**Modules:** `~/.claude/modules/`
- `shared/` - Cross-workflow modules (youtrack, approval-gate, quick-context)
- `task-planning/` - Task-planning specific modules (planning-core, get-user-context, etc.)

---

## ⛔ CRITICAL: Your FIRST Action

**Before ANYTHING else - before TodoWrite, before ANY git command - run this:**

```bash
~/.claude/lib/detect-mode.sh --pretty
```

**DO NOT run `git branch`, `git status`, `git diff`, or ANY other git commands.**
**DO NOT create TodoWrite until AFTER you have run the detect-mode script.**

The script output will show:
- Mode (default or in_progress)
- Branch name
- Issue key
- **Task Folder** (shows if docs exist!)
- Git state (commits ahead, uncommitted)

**Only proceed after you see the formatted output from the script.**

---

## Execution Steps

### Step 1: Run Detection Script (MANDATORY FIRST ACTION)

**Your very first action must be:**

```bash
~/.claude/lib/detect-mode.sh --pretty
```

**After running, confirm these values from the output:**

| Field | Value |
|-------|-------|
| Mode | {from script} |
| Issue Key | {from script} |
| Task Folder | {path or "none"} |
| Docs Exist | ✓ Yes / ✗ No |

---

### Step 2: Initialize Progress Tracking

**Now create todo list:**

```javascript
TodoWrite({
  todos: [
    {content: "Detect context and suggest planning mode", status: "completed", activeForm: "Context detected"},
    {content: "Confirm planning mode with user", status: "pending", activeForm: "Confirming planning mode"},
    {content: "Execute selected planning workflow", status: "pending", activeForm: "Executing planning workflow"}
  ]
})
```

Note: First todo is already "completed" because you ran detect-mode.sh in Step 1.

---

### Step 3: Confirm Planning Mode

**MANDATORY: Always ask user to confirm mode.**

```javascript
AskUserQuestion({
  questions: [{
    question: "Which planning mode would you like to use?",
    header: "Planning Mode",
    multiSelect: false,
    options: [
      {label: "Default (Recommended)", description: "Plan a task - supports YouTrack issues, greenfield, and resume scenarios"},
      {label: "In Progress", description: "Reconciliation - sync existing docs with implementation reality"}
    ]
  }]
})
```

Add "(Recommended)" to the suggested mode based on context scan.

---

### Step 4: Execute Selected Mode

**Based on user selection, load the workflow controller:**

#### Default Mode (Planning)
→ **Controller:** `~/.claude/workflows/task-planning/default-mode.md`

Handles all planning scenarios with two branch points:

**Branch 1: Context Source**
- Has issue key → fetch from YouTrack
- No issue key → get context from user (greenfield)

**Branch 2: Docs State**
- Folder exists → resume existing task
- No folder → create new task folder

**Key modules used:**
| Step | Module |
|------|--------|
| Quick context | `modules/shared/quick-context.md` |
| Fetch issue | `modules/shared/youtrack-fetch-issue.md` |
| Get user context | `modules/task-planning/get-user-context.md` |
| Resume existing | `modules/task-planning/resume-existing-task.md` |
| Create folder | `modules/task-planning/create-task-folder.md` |
| Planning core | `modules/task-planning/planning-core.md` |
| Approval gate | `modules/shared/approval-gate.md` |

#### In Progress Mode (Reconciliation)
→ **Controller:** `~/.claude/workflows/task-planning/in-progress-mode.md`

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

For each todo in the workflow:

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

**Location:** `${TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/`

---

Begin: **Create TodoWrite with initial 3 steps**, then execute each step in order.
