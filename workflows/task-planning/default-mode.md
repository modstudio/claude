# Default Mode - Planning Workflow

**Purpose:** Plan a task before implementation

**When to use:** Any task that needs planning (new or resuming)

---

## ⛔ STOP - MANDATORY FIRST ACTION

**YOU MUST CALL TodoWrite RIGHT NOW before reading any other files or running any commands.**

**Do NOT proceed to "Phase 0" until you have called TodoWrite.**

```javascript
TodoWrite({
  todos: [
    {content: "Quick context scan", status: "in_progress", activeForm: "Scanning context"},
    {content: "Get context (YouTrack or user)", status: "pending", activeForm: "Getting context"},
    {content: "Handle docs folder (resume or create)", status: "pending", activeForm: "Handling docs folder"},
    {content: "Search codebase for patterns", status: "pending", activeForm: "Searching codebase"},
    {content: "Analyze requirements", status: "pending", activeForm: "Analyzing requirements"},
    {content: "Technical planning", status: "pending", activeForm: "Planning implementation"},
    {content: "Present plan for approval", status: "pending", activeForm: "Getting approval"},
    {content: "Finalize documentation", status: "pending", activeForm: "Finalizing docs"},
    {content: "Start implementation", status: "pending", activeForm: "Starting implementation"}
  ]
})
```

**⛔ DO NOT CONTINUE READING THIS FILE until TodoWrite has been called.**

---

## Phase 0: Project Context

{{MODULE: ~/.claude/modules/docs/project-variables.md}}

{{MODULE: ~/.claude/modules/shared/todo-patterns.md}}

---

## Workflow Overview

```
1. quick-context → ISSUE_KEY?, FOLDER_EXISTS?

2. [BRANCH: Context source]
   ├─ ISSUE_KEY exists → youtrack-fetch-issue (existing task)
   └─ No issue key     → get-user-context (new task)

3. [BRANCH: Docs state]
   ├─ FOLDER_EXISTS → resume-existing-task
   └─ No folder     → create-task-folder

4-9. planning-core (shared steps)
```

---

## Mode Rules

| Step | Mode | Description |
|------|------|-------------|
| 1 | READ-ONLY | Quick context scan |
| 2 | READ-ONLY | Get context (YouTrack fetch or user input) |
| 3 | WRITE (task docs) | Create docs folder and templates |
| 4-6 | READ + WRITE (task docs) | Research and populate task docs with findings |
| 7 | **APPROVAL GATE** | Present plan, wait for explicit approval |
| 8-9 | WRITE-ENABLED | Finalize docs, create branch, start implementation |

### Task Docs Exception

**Important:** Task docs folder is created early (Step 3) and populated during planning (Steps 4-6). This is intentional:
- Task docs track planning progress and decisions
- Templates are populated as the planning unfolds
- The **approval gate** approves the implementation plan content
- Only after approval do we create git branches and modify project code

**What the approval gate controls:**
- ✓ Creating git branches
- ✓ Modifying project source code
- ✓ Installing dependencies
- ✗ Task docs folder (created before approval to track planning)

---

## Step 1: Quick Context Scan

{{MODULE: ~/.claude/modules/shared/quick-context.md}}

---

## Step 2: Get Context (BRANCH)

### If ISSUE_KEY exists:

{{MODULE: ~/.claude/modules/shared/youtrack-fetch-issue.md}}

- Fetch issue details from YouTrack
- Get SUMMARY, DESCRIPTION, related issues

### If NO issue key (new task):

{{MODULE: ~/.claude/modules/task-planning/get-user-context.md}}

- Ask user for task overview
- Get SUMMARY from user input
- May create YouTrack issue later

**After this step:** Have ISSUE_KEY (real or placeholder) and SUMMARY

---

## Step 3: Handle Docs Folder (BRANCH)

### If FOLDER_EXISTS:

{{MODULE: ~/.claude/modules/task-planning/resume-existing-task.md}}

- Read existing documentation
- Assess completeness
- Determine current phase
- May skip ahead in planning-core

### If NO folder:

{{MODULE: ~/.claude/modules/task-planning/create-task-folder.md}}

- Create `${TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/`
- Render all templates
- **Verify creation with `ls -la`**

**After this step:** Have TASK_FOLDER with docs (new or existing)

---

## Steps 4-9: Planning Core

{{MODULE: ~/.claude/modules/task-planning/planning-core.md}}

{{MODULE: ~/.claude/modules/shared/approval-gate.md}}

Shared planning steps:
1. Search codebase for patterns
2. Analyze requirements
3. Technical planning
4. **Approval gate**
5. Finalize documentation
6. Start implementation

---

## Context Matrix

| Issue Key | Docs Folder | Scenario | Path |
|-----------|-------------|----------|------|
| YES | YES | Resume with YouTrack | fetch → resume → core |
| YES | NO | New from YouTrack | fetch → create → core |
| NO | YES | Resume orphan docs | user → resume → core |
| NO | NO | New task | user → create → core |

---

## Key Reminders

### Module Execution
1. Read the module file
2. Follow its instructions exactly
3. Verify outputs before marking complete

### Verification
- After create-task-folder: `ls -la "$TASK_FOLDER"`
- Only mark complete after verification

### Approval Gate
- Do NOT proceed without explicit approval
- Questions are NOT approval
- See `approval-gate.md` for valid responses

---

## Quick Reference

**Modules used:**
- `shared/quick-context.md`
- `shared/youtrack-fetch-issue.md`
- `task-planning/get-user-context.md`
- `task-planning/resume-existing-task.md`
- `task-planning/create-task-folder.md`
- `task-planning/planning-core.md`

**Docs location:**
- `${TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/`

**Standard docs:**
→ See: `~/.claude/modules/task-planning/standard-docs-structure.md`
