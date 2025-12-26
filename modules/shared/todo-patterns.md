# Standardized TodoWrite Patterns

**Module:** TodoWrite Progress Tracking
**Version:** 2.1.0

## Purpose
Define standard patterns for using TodoWrite to track workflow progress consistently.

## Scope
SHARED - Used by: all workflows

---

## ⛔ CRITICAL: TodoWrite MUST Be First Action

**Every workflow MUST initialize TodoWrite as its VERY FIRST action.**

When entering any workflow:
1. **FIRST:** Call TodoWrite with the workflow's todo list (first item `in_progress`)
2. **THEN:** Load project context and begin execution

**Why:** Agents skip TodoWrite if it comes after other actions. Making it first ensures visibility.

---

## Workflow Transition Pattern

When transitioning from an entry point to a specific workflow:

1. Entry point creates initial 3-step todos (detect, select mode, execute)
2. When entering the selected workflow, **RELOAD** the todo list with that workflow's specific todos
3. The new todos replace the entry point todos entirely

**Example:** `/plan-task-g` → selects "Default Mode" → reloads with 9-step planning todos

---

## Initializing Progress Tracking

Use the **TodoWrite** tool to track workflow progress.

### Getting Standard Todos

```bash
# Source the todo utilities library
source ~/.claude/lib/todo-utils.sh

# Get predefined todos for this workflow type
TODOS_JSON=$(init_workflow_todos "task_planning")  # or code_review, release, commit_planning

# Initialize TodoWrite with first item in_progress
# (Use TodoWrite tool with the JSON from above)
```

---

## Standard Todo Patterns

### Task Planning (Default Mode)

**NOTE:** Phases 1-4 are READ-ONLY. File/folder creation happens AFTER approval in Phase 5.

```json
[
  {"content": "Load project context and fetch YouTrack issue", "status": "in_progress", "activeForm": "Loading context"},
  {"content": "Check for existing task folder and research codebase", "status": "pending", "activeForm": "Researching codebase"},
  {"content": "Gather requirements and identify questions", "status": "pending", "activeForm": "Gathering requirements"},
  {"content": "Present questions to user for clarification", "status": "pending", "activeForm": "Presenting questions"},
  {"content": "Create technical implementation plan", "status": "pending", "activeForm": "Creating implementation plan"},
  {"content": "Present plan for approval (then create docs)", "status": "pending", "activeForm": "Presenting plan for approval"}
]
```

### Code Review (Report Mode)

```json
[
  {"content": "Load project context and standards", "status": "in_progress", "activeForm": "Loading context"},
  {"content": "Analyze all changed files", "status": "pending", "activeForm": "Analyzing changed files"},
  {"content": "Check against architecture standards", "status": "pending", "activeForm": "Checking architecture"},
  {"content": "Verify test coverage", "status": "pending", "activeForm": "Verifying test coverage"},
  {"content": "Run test suite", "status": "pending", "activeForm": "Running tests"},
  {"content": "Generate comprehensive review report", "status": "pending", "activeForm": "Generating report"}
]
```

### Release (Full Pipeline)

```json
[
  {"content": "Verify feature branch tests pass", "status": "in_progress", "activeForm": "Verifying feature tests"},
  {"content": "Merge to develop and push", "status": "pending", "activeForm": "Merging to develop"},
  {"content": "Verify staging deployment", "status": "pending", "activeForm": "Verifying staging"},
  {"content": "Merge to master and tag release", "status": "pending", "activeForm": "Merging to master"},
  {"content": "Verify production deployment", "status": "pending", "activeForm": "Verifying production"}
]
```

---

## Usage Rules

### ✅ DO

1. **Initialize at workflow start**
   - Always create todo list at the beginning of workflow execution

2. **Keep ONE item in_progress**
   - Exactly one todo should be "in_progress" at any time
   - Others are either "pending" or "completed"

3. **Update immediately**
   - Mark completed as soon as step finishes
   - Advance to next step right away
   - Never batch updates

4. **Use proper forms**
   - `content`: Imperative form ("Load context", "Run tests")
   - `activeForm`: Present continuous ("Loading context", "Running tests")

### ❌ DON'T

1. **Don't skip initialization**
   - Every workflow needs progress tracking

2. **Don't have multiple in_progress**
   - Only ONE step at a time

3. **Don't batch completions**
   - Update after each step, not at the end

4. **Don't forget activeForm**
   - Both content and activeForm are required

---

## Advancing Progress

```bash
# After completing current step, update todos

# Example: Completing step 1, starting step 2
```

Use **TodoWrite** tool to mark step 1 as "completed" and step 2 as "in_progress".

The updated JSON should show:
- Step 1: `"status": "completed"`
- Step 2: `"status": "in_progress"`
- Remaining steps: `"status": "pending"`

---

## Phase-Specific Todos

For detailed phase work (e.g., Task Planning Phase 2), get phase-specific todos:

```bash
# Get Phase 2 (Requirements Analysis) todos
PHASE_TODOS=$(get_task_planning_phase_todos 2)

# Initialize with first item in_progress
# (Use TodoWrite tool with the JSON)
```

This provides more granular tracking within each major workflow phase.

---

## Benefits

- ✅ **Visibility** - User always knows current progress
- ✅ **Consistency** - Same pattern across all workflows
- ✅ **Clarity** - Clear what's done, what's current, what's next
- ✅ **Accountability** - Track every step explicitly
- ✅ **Debugging** - Easy to see where workflow stopped if error occurs

---

## Integration Example

In your workflow documentation:

```markdown
## Step 1: Load Project Context

Initialize progress tracking:

Use TodoWrite tool with:
```json
[generated by init_workflow_todos("task_planning")]
```

Execute step...

Mark step complete and advance:

Use TodoWrite tool with updated JSON (step 1 completed, step 2 in_progress).
```

---

**Remember:** TodoWrite provides real-time progress visibility to the user. Use it consistently!
