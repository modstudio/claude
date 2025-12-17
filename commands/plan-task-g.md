---
description: Task planning with YouTrack integration - multi-project support (global)
---

You are helping the user with task planning following the Task Planning Workflow.

**Workflow Documentation**: `~/.claude/workflows/task-planning/`
- `README.md` - Overview
- `default-mode.md` - Standard YouTrack-driven workflow
- `greenfield-mode.md` - Exploratory/prototype workflow
- `in-progress-mode.md` - Resume & sync workflow

**Plan Mode Discipline**: `~/.claude/modules/plan-mode-discipline.md`
**Context Strategy**: `~/.claude/modules/context-strategy.md`

---

## CRITICAL: Two-Phase Context Gathering

**Problem**: Full context is hundreds of lines, hidden by default, user can't verify key findings.

**Solution**: Gather context in two phases, always present summaries.

### Phase 1: Light Context (Mode Detection)
- **Purpose**: Just enough to suggest a mode
- **Time**: < 5 seconds
- **Gather**: Branch, issue key, folder exists (yes/no), git state counts
- **Output**: Quick scan table + suggested mode
- **Do NOT**: Read file contents, fetch from YouTrack, search codebase

### Phase 2: Full Context (After Mode Confirmed)
- **Purpose**: Everything needed for the selected mode
- **Time**: As needed, use parallel research
- **Gather**: YouTrack details, task docs contents, codebase patterns
- **Output**: Structured summary with key findings highlighted

### Summary Format (Always)
- Tables for status checks
- Bullet points for key findings
- Highlight blockers/concerns
- Use `<details>` for full content (expandable)
- User must see important info WITHOUT expanding

---

## CRITICAL: Plan Mode Discipline

**You MUST follow Claude's Plan Mode discipline throughout this workflow.**

### Two Phases

| Phase | Mode | What You Can Do |
|-------|------|-----------------|
| Planning (Phases 1-4) | **READ-ONLY** | Read, Grep, Glob, WebSearch, AskUserQuestion, MCP lookups |
| Implementation (Phase 5) | **WRITE-ENABLED** | Edit, Write, Bash, git operations |

### During Planning (Phases 1-4)

**You MUST NOT:**
- Edit or create any files
- Run Bash commands that modify state
- Create `.task-docs` folder or documents
- Create git branches
- Make ANY changes to the system

**You MAY:**
- Read files to understand code
- Search with Grep/Glob
- Fetch from YouTrack (MCP tools)
- Ask user questions
- Use TodoWrite for tracking
- Run read-only Bash: `git status`, `git log`, `git diff`, `ls`

### Parallel Research

**Run multiple research tools in parallel, then synthesize:**

1. Launch independent searches in a single message (multiple tool calls)
2. Wait for all results
3. Synthesize findings
4. Present summary to user

Example: Search for patterns, find related files, read configs, check tests - all in parallel.

### The Approval Gate (End of Phase 4)

**Before ANY implementation:**
1. Present complete plan with specific files to create/modify
2. Wait for **explicit approval** ("Yes", "Go ahead", "Approved")
3. Do NOT interpret questions as approval
4. Only then proceed to Phase 5

---

## Execution Steps

### Step 1: Initialize Progress Tracking (MUST DO FIRST)

**Create todo list with initial steps before doing anything else:**

```javascript
TodoWrite({
  todos: [
    {content: "Detect context and suggest planning mode", status: "pending", activeForm: "Detecting context"},
    {content: "Confirm planning mode with user", status: "pending", activeForm: "Confirming planning mode"},
    {content: "Execute selected planning workflow", status: "pending", activeForm: "Executing planning workflow"}
  ]
})
```

**Mark each todo as in_progress when starting, completed when done.**

---

### Step 2: Light Context Scan (Mode Detection)

Mark todo as in_progress: "Detect context and suggest planning mode"

**This is Phase 1 - Light Context Only!**

Run the mode detection script:

```bash
~/.claude/lib/bin/detect-mode
```

**What this does (fast, < 5 seconds):**
- Checks current branch name
- Extracts issue key from branch (if any)
- Checks if task folder EXISTS (doesn't read contents)
- Counts uncommitted changes and commits ahead

**What this does NOT do:**
- Read file contents
- Fetch from YouTrack
- Search codebase
- Read task docs

**Present results as Quick Scan table:**

```markdown
## Quick Scan

| Check | Result |
|-------|--------|
| Branch | `feature/STAR-1234-login-fix` |
| Issue Key | STAR-1234 (extracted from branch) |
| Task Docs | ✓ Found / ✗ Not found |
| Uncommitted | 3 files |
| Commits Ahead | 5 |

**Suggested Mode**: [Default / In Progress / Greenfield]
**Reason**: [Brief explanation]
```

Mark todo as completed: "Detect context and suggest planning mode"

---

### Step 3: Confirm Planning Mode

Mark todo as in_progress: "Confirm planning mode with user"

**MANDATORY: You MUST use the AskUserQuestion tool to present ALL 3 options below.**
**Do NOT auto-select a mode based on context. ALWAYS ask the user.**

**Add "(Recommended)" to the mode suggested by detect-mode output.**

```javascript
AskUserQuestion({
  questions: [{
    question: "Which planning mode would you like to use?",
    header: "Planning Mode",
    multiSelect: false,
    options: [
      // Put the recommended mode first, add "(Recommended)" to its label
      {label: "Default", description: "Standard planning - fetch from YouTrack, create folder, gather requirements, plan"},
      {label: "In Progress", description: "Resume work - analyze changes, review docs, sync implementation with plan"},
      {label: "Greenfield", description: "Exploratory - start fresh, no assumptions, user-driven context gathering"}
    ]
  }]
})
```

**Example with Default recommended:**
- `{label: "Default (Recommended)", description: "..."}`

**Example with In Progress recommended:**
- `{label: "In Progress (Recommended)", description: "..."}`

**ALL 3 OPTIONS MUST BE PRESENTED. Never skip this step.**

Mark todo as completed: "Confirm planning mode with user"

---

### Step 4: Full Context Gathering (Phase 2)

Mark todo as in_progress: "Execute selected planning workflow"

**This is Phase 2 - Full Context! Now we gather everything needed for the selected mode.**

**Based on user selection, REPLACE the todo list with mode-specific steps:**

#### If Default Mode selected:
```javascript
TodoWrite({
  todos: [
    {content: "Full Context: Fetch issue from YouTrack", status: "pending", activeForm: "Fetching from YouTrack"},
    {content: "Full Context: Read task docs (if exist)", status: "pending", activeForm: "Reading task docs"},
    {content: "Full Context: Search codebase for patterns", status: "pending", activeForm: "Searching codebase"},
    {content: "Present: Context summary with key findings", status: "pending", activeForm: "Presenting context summary"},
    {content: "Requirements: Identify questions for user", status: "pending", activeForm: "Identifying questions"},
    {content: "Planning: Design implementation approach", status: "pending", activeForm: "Designing approach"},
    {content: "Approval: Present plan for user approval", status: "pending", activeForm: "Presenting plan"}
  ]
})
```

**Full Context for Default Mode (run in parallel):**
1. Fetch from YouTrack (issue details, related issues)
2. Read task docs contents (if folder exists)
3. Search codebase for similar patterns
4. Read relevant project standards

**Then present Context Summary:**
```markdown
## Context Summary

### Issue: {ISSUE_KEY}
- **Summary**: [from YouTrack]
- **Type**: [type] | **Priority**: [priority]
- **Status**: [status]

### Task Documentation
- **Folder**: [exists/not found]
- **Status**: [from 00-status.md if exists]
- **Completeness**: [X/6 docs]

### Codebase
- **Similar patterns**: [found/none]
- **Related files**: [list key files]

### Key Findings
1. [Important finding 1]
2. [Important finding 2]

### Blockers/Concerns
- [Any blockers or concerns]
```

#### If Greenfield Mode selected:
```javascript
TodoWrite({
  todos: [
    {content: "Ask user for task overview", status: "pending", activeForm: "Gathering user context"},
    {content: "Full Context: Search codebase for patterns", status: "pending", activeForm: "Searching codebase"},
    {content: "Present: Context summary with findings", status: "pending", activeForm: "Presenting context summary"},
    {content: "Requirements: Document user requirements", status: "pending", activeForm: "Documenting requirements"},
    {content: "Planning: Design implementation approach", status: "pending", activeForm: "Designing approach"},
    {content: "Approval: Present plan for user approval", status: "pending", activeForm: "Presenting plan"}
  ]
})
```

#### If In Progress Mode selected:
```javascript
TodoWrite({
  todos: [
    {content: "Full Context: Gather complete git state", status: "pending", activeForm: "Gathering git state"},
    {content: "Full Context: Read ALL task documentation", status: "pending", activeForm: "Reading task docs"},
    {content: "Full Context: Fetch current YouTrack state", status: "pending", activeForm: "Fetching YouTrack"},
    {content: "Present: Context summary with key findings", status: "pending", activeForm: "Presenting context summary"},
    {content: "Analysis: Compare implementation vs docs", status: "pending", activeForm: "Analyzing gaps"},
    {content: "Present: Findings and recommendations", status: "pending", activeForm: "Presenting findings"}
  ]
})
```

**Full Context for In Progress Mode (run in parallel):**
1. Full git diff (develop..HEAD)
2. All commit messages on branch
3. Read ALL task docs
4. Current YouTrack issue state

**Then present Context Summary:**
```markdown
## Context Summary

### Git State
- **Branch**: [branch name]
- **Commits**: [X] ahead of develop
- **Changed files**: [count]
- **Uncommitted**: [count]

### Task Documentation
- **Status**: [from 00-status.md]
- **Last updated**: [date]
- **Completeness**: [assessment]

### Key Findings
1. [Docs say X but code shows Y]
2. [Missing documentation for Z]

### Sync Issues
- [List any doc/code mismatches]
```

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
source ~/.claude/lib/task-docs-utils.sh
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
- Knowledge Base: `$PROJECT_KB_DIR` (access via `$PROJECT_KB_ACCESS_METHOD`)
- Standards: `$PROJECT_STANDARDS_DIR`
- Citation: `$PROJECT_CITATION_ARCHITECTURE`

**Documents Created:**
- `00-status.md` - Status & overview (CREATE FIRST)
- `01-task-description.md` - Task description (high-level overview)
- `02-functional-requirements.md` - Functional requirements (detailed)
- `03-implementation-plan.md` - Technical implementation plan
- `04-todo.md` - Implementation checklist
- `logs/decisions.md` - Architectural decisions (ADR-style)
- `logs/review.md` - External review feedback

---

#### Greenfield Mode (`~/.claude/workflows/task-planning/greenfield-mode.md`)

**User-driven exploration:**

1. Ask user for task overview (no assumptions)
2. Create temporary folder: `${TASK_DOCS_DIR}/exploratory-${name}/`
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

**task-docs-utils.sh** - Task docs folder operations
- `ensure_task_docs_exists`, `find_task_folder`, `create_task_folder`, `list_all_tasks`

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

**Storage Location:** Project-local `${TASK_DOCS_DIR}` (defaults to `./.task-docs` in project directory)

**Folder Naming:** `{ISSUE_KEY}-{slug}/`
- Example: `${TASK_DOCS_DIR}/STAR-2228-Warehouse-Queue/`
- Slug from YouTrack summary (Title-Case-With-Hyphens)

**Always use library functions** - don't manually manipulate task docs folder

---

## Key Reminders

### Context Presentation (CRITICAL)
**User must see key findings WITHOUT expanding collapsed sections!**

1. **Always use structured summaries** - tables for status, bullets for findings
2. **Highlight key findings** - blockers, concerns, important discoveries
3. **Use `<details>` for full content** - keep summaries above the fold
4. **Never dump raw output** - synthesize, don't just show

```markdown
## Good: Summary with key findings visible
| Check | Result |
|-------|--------|
| Issue | STAR-1234 ✓ |
| Docs | 4/6 exist |

### Key Findings
1. Found similar pattern in AuthService.php
2. 2 unresolved questions

<details><summary>Full details</summary>
[Expandable content here]
</details>
```

### Two-Phase Context
1. **Phase 1 (Light)**: Branch, folder exists, git counts → suggest mode
2. **Phase 2 (Full)**: After mode confirmed → gather everything, present summary

### TodoWrite Pattern
1. **FIRST:** Create initial TodoWrite with 3 setup steps
2. **Follow todos in order** - mark in_progress → completed for each
3. **When mode is selected:** REPLACE todos with mode-specific steps
4. **Work through new todos** - each phase becomes a trackable item

### Process
- Light scan → Confirm mode → Full context → Present summary → Execute
- Present questions before technical planning
- Get approval before implementation

### Libraries
- USE library functions (task-docs-utils, issue-utils, git-utils, template-utils)
- USE templates for document generation
- USE TodoWrite for progress tracking

### Don'ts
- ❌ Don't dump raw output - always summarize
- ❌ Don't skip the context summary step
- ❌ Don't gather full context before mode is confirmed
- ❌ Don't hardcode project-specific values (use PROJECT_* vars)
- ❌ Don't skip requirements phase
- ❌ Don't start implementation without approval

---

Begin: **Create TodoWrite with initial 3 steps**, then execute each step in order.
