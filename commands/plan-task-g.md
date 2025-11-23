---
description: Task planning with YouTrack integration - multi-project support (global)
---

You are helping the user with task planning following the Task Planning Workflow.

**Workflow Documentation**: `~/.claude/workflows/task-planning/`
- `README.md` - Overview
- `default-mode.md` - Standard YouTrack-driven workflow
- `greenfield-mode.md` - Exploratory/prototype workflow
- `in-progress-mode.md` - Resume & sync workflow

---

## Execution Steps

### Step 1: Initialize Progress Tracking

```bash
source ~/.claude/lib/todo-utils.sh
TODOS=$(init_workflow_todos "task_planning")
```

Use **TodoWrite** tool with `$TODOS` to initialize tracking. Update after each phase.

---

### Step 2: Load Project Context

{{MODULE: ~/.claude/modules/load-project-context.md}}

This provides all `PROJECT_*` variables:
- `PROJECT_NAME`, `PROJECT_TYPE`, `PROJECT_ISSUE_PATTERN`, `PROJECT_ISSUE_REGEX`
- `PROJECT_STANDARDS_DIR`, `PROJECT_CITATION_ARCHITECTURE`, `PROJECT_CITATION_STYLE`
- `PROJECT_WIP_ROOT` (always `./.wip`), `PROJECT_BASE_BRANCH`
- `PROJECT_TEST_CMD_ALL`, `PROJECT_TEST_CMD_UNIT`
- `PROJECT_KB_LOCATION`, `PROJECT_KB_SOURCE`, `PROJECT_KB_ACCESS_METHOD`
- And more...

---

### Step 3: Detect Planning Mode

{{MODULE: ~/.claude/modules/mode-detection.md}}

Analyzes current context (branch, git state, existing work) and suggests the appropriate planning mode with reasoning.

---

### Step 4: Confirm Planning Mode

Use **AskUserQuestion** tool:

**Question:** "Which planning mode would you like to use?"
**Header:** "Planning Mode"
**multiSelect:** false

**Options:**
1. Label: "Default" | Description: "Standard planning - fetch from YouTrack, create folder, gather requirements, plan"
2. Label: "Greenfield" | Description: "Exploratory - start fresh, no assumptions, user-driven context gathering"
3. Label: "In Progress" | Description: "Resume work - analyze changes, review docs, sync implementation with plan"

---

### Step 5: Execute Selected Mode

Follow the appropriate workflow based on user selection:

#### Default Mode (`~/.claude/workflows/task-planning/default-mode.md`)

**Standard 5-phase workflow:**

1. **Discovery** - Get issue key, fetch from YouTrack, check existing context
2. **Requirements** - Analyze, identify questions, present to user
3. **Technical Planning** - Design approach, create implementation plan
4. **Review & Approval** - Present plan, get approval
5. **Implementation** - Implement (only after approval)

**Key Operations:**
```bash
# Load libraries
source ~/.claude/lib/wip-utils.sh
source ~/.claude/lib/issue-utils.sh
source ~/.claude/lib/template-utils.sh

# Get issue key (from command arg or ask user)
ISSUE_KEY="STAR-1234"  # or extract/ask

# Check existing context
TASK_FOLDER=$(find_task_folder "$ISSUE_KEY")
BRANCH=$(git branch --list "*${ISSUE_KEY}*")

# Create task folder if new
if [ -z "$TASK_FOLDER" ]; then
  SLUG=$(generate_slug "$SUMMARY")
  TASK_FOLDER=$(create_task_folder "$ISSUE_KEY" "$SLUG")
fi

# Render documents
render_task_planning_docs "$TASK_FOLDER" "$ISSUE_KEY" \
  TASK_SUMMARY="$SUMMARY" \
  TASK_DESCRIPTION="$DESCRIPTION"
```

**Resources:**
- YouTrack MCP: Use if `PROJECT_*` indicates availability
- Knowledge Base: `$PROJECT_KB_LOCATION` (access via `$PROJECT_KB_ACCESS_METHOD`)
- Standards: `$PROJECT_STANDARDS_DIR`
- Citation: `$PROJECT_CITATION_ARCHITECTURE`

**Documents Created:**
- `00-status.md` - Status & overview (CREATE FIRST)
- `01-functional-requirements.md` - Requirements & questions
- `02-decision-log.md` - Architectural decisions
- `03-implementation-plan.md` - Detailed technical plan
- `04-task-description.md` - YouTrack issue snapshot
- `05-todo.md` - Implementation checklist

---

#### Greenfield Mode (`~/.claude/workflows/task-planning/greenfield-mode.md`)

**User-driven exploration:**

1. Ask user for task overview (no assumptions)
2. Create temporary folder: `.wip/exploratory-${name}/`
3. Document user's context
4. Proceed with planning phases
5. When ready, create YouTrack issue and migrate to Default Mode

**Key:** Start from user input, no pre-existing context assumed.

---

#### In Progress Mode (`~/.claude/workflows/task-planning/in-progress-mode.md`)

**Review & sync existing work:**

1. Extract issue key from branch or ask user
2. Gather current state (git, changes, commits)
3. Read existing docs from task folder
4. Compare implementation vs documentation
5. Identify discrepancies and gaps
6. Update docs to match reality
7. Present findings and get user input

**Key Operations:**
```bash
source ~/.claude/lib/issue-utils.sh
source ~/.claude/lib/git-utils.sh

# Extract issue key
ISSUE_KEY=$(extract_issue_key_from_branch "$PROJECT_ISSUE_REGEX")

# Gather state
GIT_STATE=$(detect_git_state)
COMMITS=$(count_commits_ahead "$PROJECT_BASE_BRANCH")
FILES=$(git diff --name-only "$PROJECT_BASE_BRANCH"...HEAD)

# Find task folder
TASK_FOLDER=$(find_task_folder "$ISSUE_KEY")
```

---

## Available Libraries

All libraries are in `~/.claude/lib/`:

**wip-utils.sh** - .wip folder operations
- `ensure_wip_exists`, `find_task_folder`, `create_task_folder`, `list_all_tasks`

**issue-utils.sh** - Issue key operations
- `extract_issue_key`, `extract_issue_key_from_branch`, `validate_issue_key`, `generate_slug`

**git-utils.sh** - Git operations
- `detect_git_state`, `count_commits_ahead`, `has_uncommitted_changes`, `get_current_branch`

**template-utils.sh** - Template rendering
- `render_template`, `render_template_stdout`, `render_task_planning_docs`

**todo-utils.sh** - TodoWrite patterns
- `init_workflow_todos`, `get_task_planning_todos`, `get_task_planning_phase_todos`

**project-context.sh** - Project detection & loading
- `detect_project`, `load_project_context`

---

## Storage & Naming

**Storage Location:** Project-local `.wip` (`./.wip` in project directory)

**Folder Naming:** `{ISSUE_KEY}-{slug}/`
- Example: `.wip/STAR-2228-Warehouse-Queue/`
- Slug from YouTrack summary (Title-Case-With-Hyphens)

**Always use library functions** - don't manually manipulate .wip

---

## Key Reminders

### Process
1. Initialize TodoWrite first
2. Load project context (provides all PROJECT_* vars)
3. Detect and confirm planning mode
4. Execute selected mode workflow
5. Update TodoWrite progress throughout
6. Create standard document structure
7. Present questions before technical planning
8. Get approval before implementation

### Libraries
- USE library functions (wip-utils, issue-utils, git-utils, template-utils)
- USE templates for document generation
- USE TodoWrite for progress tracking
- USE modules for common operations

### Don'ts
- ❌ Don't hardcode project-specific values (use PROJECT_* vars)
- ❌ Don't skip requirements phase
- ❌ Don't start implementation without approval
- ❌ Don't write manual bash when libraries exist

---

Begin by initializing TodoWrite, loading project context, detecting mode, and confirming with user.
