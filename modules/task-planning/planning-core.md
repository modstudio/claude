# Module: planning-core

## Purpose
Shared planning steps used by Default Mode after context is gathered and docs folder exists.

## Scope
TASK-PLANNING - Called after branch points converge

## Mode
READ-ONLY + WRITE (task docs) for steps 1-3 → APPROVAL GATE → WRITE-ENABLED (all) for steps 5-6

**Note:** Steps 1-3 write findings to task docs folder (created in default-mode Step 3). This is intentional - task docs track planning progress. The approval gate controls git branches and project source code changes.

---

## Prerequisites

Before calling this module, you must have:
- `TASK_FOLDER` - Path to task docs folder (created or found)
- `ISSUE_KEY` - Issue key (from YouTrack or user-provided)
- `SUMMARY` - Task summary
- Initial context documented in `01-task-description.md`

---

## Steps

### Step 1: Search Codebase
→ Module: `~/.claude/modules/task-planning/search-codebase.md`

- Find similar patterns
- Identify reusable components
- Document in `02-functional-requirements.md`

### Step 2: Analyze Requirements
→ Module: `~/.claude/modules/task-planning/analyze-requirements.md`

- Analyze task description
- Generate questions
- Document in `02-functional-requirements.md`
- Present questions to user
- Update docs with answers

### Step 3: Technical Planning
→ Module: `~/.claude/modules/task-planning/technical-planning.md`

- Consider multiple approaches
- Design implementation plan
- Document in `03-implementation-plan.md`
- Document decisions in `logs/decisions.md`

### Step 4: Approval Gate
→ Module: `~/.claude/modules/shared/approval-gate.md`

- Present complete plan
- Wait for explicit approval
- **Do NOT proceed without approval**

---

## [APPROVAL GATE - Mode switches to WRITE-ENABLED]

---

### Step 5: Finalize Documentation
→ Module: `~/.claude/modules/task-planning/finalize-documentation.md`

- Update `00-status.md` to "Ready for Implementation"
- Finalize all docs with discussion outcomes
- Create `04-todo.md` checklist

### Step 6: Start Implementation
→ Module: `~/.claude/modules/task-planning/start-implementation.md`

- Create git branch
- Update status to "In Progress"
- Initialize TodoWrite with implementation steps
- Begin coding

---

## TodoWrite for Planning Core

When entering planning-core, replace todos with:

```javascript
TodoWrite({
  todos: [
    {content: "Search codebase for patterns", status: "in_progress", activeForm: "Searching codebase"},
    {content: "Analyze requirements", status: "pending", activeForm: "Analyzing requirements"},
    {content: "Technical planning", status: "pending", activeForm: "Planning implementation"},
    {content: "Present plan for approval", status: "pending", activeForm: "Getting approval"},
    {content: "Finalize documentation", status: "pending", activeForm: "Finalizing docs"},
    {content: "Start implementation", status: "pending", activeForm: "Starting implementation"}
  ]
})
```

---

## Outputs
- Complete task documentation
- Approved implementation plan
- Git branch created
- Ready to implement
