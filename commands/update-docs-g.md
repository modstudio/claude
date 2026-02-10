---
description: Update knowledge base documentation to reflect implementation changes (global)
---

You are helping the user update knowledge base documentation to reflect changes made during development.

**Skill Documentation**: `~/.claude/skills/update-docs/`
- `README.md` - Overview and quick reference
- `task-mode.md` - Update docs based on task implementation changes
- `article-mode.md` - Update specific articles directly

---

## Phase 0: Load Project Context

{{MODULE: ~/.claude/modules/docs/project-variables.md}}

This provides all `PROJECT_*` variables including:
- `PROJECT_KB_LOCATION` - Knowledge base location (e.g., `storage/app/youtrack_docs`)
- `STORAGE_LOCATION` - Project-local task docs folder location (`${PROJECT_TASK_DOCS_DIR}`)

---

## Step 1: Initialize Progress Tracking

**IMMEDIATELY create a todo list to track skill progress:**

```javascript
TodoWrite({
  todos: [
    {content: "Detect documentation update mode", status: "in_progress", activeForm: "Detecting update mode"},
    {content: "Confirm mode with user", status: "pending", activeForm: "Confirming mode"},
    {content: "Execute selected mode skill", status: "pending", activeForm: "Executing skill"},
    {content: "Generate summary and review checklist", status: "pending", activeForm: "Generating summary"}
  ]
})
```

**Update todo list as you progress through each step. Mark tasks complete immediately upon finishing.**

---

## Step 2: Detect Update Mode

Analyze user input and context to determine the appropriate mode:

### Input Analysis

```bash
# Get current git state
source ~/.claude/lib/git-utils.sh
BRANCH=$(get_current_branch)
ISSUE_KEY=$(extract_issue_key_from_branch "$PROJECT_ISSUE_REGEX")

# Check for task context
TASK_FOLDER=""
if [ -n "$ISSUE_KEY" ]; then
  source ~/.claude/lib/task-docs-utils.sh
  TASK_FOLDER=$(find_task_dir "$ISSUE_KEY")
fi

# Parse user input
USER_INPUT="${1:-}"
```

### Detection Logic

**Task Mode** - User provided issue key or on task branch with existing task folder:
- Input matches issue pattern (e.g., `STAR-1234`)
- On task branch with `${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-*/` folder

**Article Mode** - User provided specific article name/path:
- Input ends with `.md`
- Input contains "article" or specific article name

**Broad Mode** - User wants comprehensive scan:
- Input contains "broad", "scan", "all", "recent"
- Explicit `--broad` flag

---

## Step 3: Confirm Update Mode

Ask user to confirm the detected mode:

- Use **AskUserQuestion** tool
- Question: "Which documentation update mode would you like to use?"
- Options:
  1. **Task Mode** - Update docs based on changes from a specific task implementation
  2. **Article Mode** - Update specific article(s) directly without task context
  3. **Broad Mode** - Scan recent related tasks for outdated documentation

---

## Step 4: Execute Selected Mode

Follow the appropriate skill based on user selection:

### Task Mode (`~/.claude/skills/update-docs/task-mode.md`)

**Standard task-based documentation update:**

1. **Discovery** - Get task folder, analyze implementation changes
2. **Article Search** - Find relevant knowledge base articles
3. **Impact Analysis** - Determine which articles need updates
4. **Review List** - Present list of articles to review
5. **Article Check** - Check each article against implementation
6. **Update Creation** - Create updated versions of affected articles
7. **Summary** - Generate summary of all updates

**Key Operations:**
```bash
# Load libraries
source ~/.claude/lib/task-docs-utils.sh
source ~/.claude/lib/issue-utils.sh

# Get task folder
ISSUE_KEY="STAR-1234"  # From user or branch
TASK_FOLDER=$(find_task_dir "$ISSUE_KEY")

# Create docs subfolder in task folder
DOCS_FOLDER="$TASK_FOLDER/docs-updates"
mkdir -p "$DOCS_FOLDER"
```

**Outputs Created in `{TASK_FOLDER}/docs-updates/`:**
- `{article-name}.md` - Updated article content (one per article)
- `_summary.md` - Summary of all documentation updates
- `_review-checklist.md` - Checklist of articles reviewed

---

### Article Mode (`~/.claude/skills/update-docs/article-mode.md`)

**Direct article update:**

1. **Article Selection** - User specifies article(s) to update
2. **Article Fetch** - Read current article content
3. **Change Analysis** - Understand what needs updating
4. **Update Creation** - Create updated version
5. **Summary** - Document changes made

**Use when:**
- User knows exactly which article needs updating
- No specific task context needed
- Ad-hoc documentation improvements

---

### Broad Mode (Extension of Task Mode)

**Scan related tasks for documentation gaps:**

1. **Get Recent Tasks** - Find recently completed related tasks
2. **Cross-Reference** - Check if their changes affected shared documentation
3. **Aggregate Updates** - Combine all needed updates
4. **Execute Task Mode** - Run task mode for each affected area

---

## Available Libraries

All libraries are in `~/.claude/lib/`:

**task-docs-utils.sh** - Task docs folder operations
- `ensure_task_docs_exists`, `find_task_dir`, `create_task_folder`

**issue-utils.sh** - Issue key operations
- `extract_issue_key`, `extract_issue_key_from_branch`, `validate_issue_key`

**git-utils.sh** - Git operations
- `detect_git_state`, `count_commits_ahead`, `get_current_branch`

---

## Storage & Output

**Output Location:** `${TASK_FOLDER}/docs-updates/`

**File Naming:** Article files use the same name as the knowledge base article
- Example: `docs-updates/Warehouse-Queue-Management.md`
- Example: `docs-updates/Order-Processing-Flow.md`

**Summary File:** `docs-updates/_summary.md` - Overview of all updates made

---

## Knowledge Base Integration

The skill reads knowledge base configuration from project YAML:

```yaml
documentation:
  knowledge_base:
    location: "storage/app/youtrack_docs"  # Where docs are stored
    source: "gitignored"                    # gitignored, git, or external
    access_method: "bash"                   # bash, mcp, or git
```

---

## Key Reminders

### Process
1. Initialize TodoWrite first
2. Load project context (provides KB location)
3. Detect and confirm update mode
4. Execute selected mode skill
5. Create docs-updates folder in `${PROJECT_TASK_DOCS_DIR}`
6. Never overwrite original KB files - create copies
7. Generate summary when complete
8. Present for user review before any sync

### Important
- **Read before writing** - Always read current article content first
- **Preserve structure** - Keep article formatting consistent
- **Cite sources** - Reference implementation changes
- **Don't overwrite** - Create new files in docs-updates folder
- **Track progress** - Update TodoWrite throughout

### Don'ts
- Don't modify original knowledge base files directly
- Don't skip the review list step
- Don't create articles for unrelated topics
- Don't lose original article content

---

Begin by loading project context, initializing TodoWrite, detecting mode, and confirming with user.
