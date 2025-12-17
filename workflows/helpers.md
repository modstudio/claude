# Workflow Helpers

**Common functions and variables used across all workflows**

---

## Configuration Loading

### Load Global Config

```bash
# Load global configuration
GLOBAL_CONFIG="$HOME/.claude/config/global.yaml"

# If you need to parse YAML in bash (basic extraction)
# Note: For complex YAML parsing, use a proper YAML parser

# Extract task docs root location
TASK_DOCS_DIR="./.task-docs"  # Default from global.yaml: storage.task_docs_dir
```

---

## Storage Helpers

### Task Docs Folder Management

**IMPORTANT**: The `.task-docs` folder is PROJECT-LOCAL and stored in `{PROJECT_ROOT}/.task-docs/`.

- Add `.task-docs` to your `.gitignore` to prevent committing task artifacts
- The folder must exist in your project directory for workflows to function
- If no `.task-docs` folder is found, the agent will report and ask for guidance

#### Get Task Docs Root

```bash
# Get the task docs root directory (PROJECT-LOCAL location)
get_task_docs_dir() {
  local project_docs="./.task-docs"

  if [ -d "$project_docs" ]; then
    echo "$(pwd)/.task-docs"
  else
    # No .task-docs folder found - return empty and let caller handle
    echo ""
  fi
}

# Usage
TASK_DOCS_DIR=$(get_task_docs_dir)
if [ -z "$TASK_DOCS_DIR" ]; then
  echo "ERROR: No .task-docs folder found in project directory"
  echo "Please create one: mkdir .task-docs"
  echo "And add to .gitignore: echo '.task-docs' >> .gitignore"
  exit 1
fi
```

#### Find Task Folder

```bash
# Find a task folder by issue key
# Usage: find_task_folder "STAR-1234"
find_task_folder() {
  local issue_key="$1"
  local docs_root=$(get_task_docs_dir)

  # Check if .task-docs folder exists
  if [ -z "$docs_root" ]; then
    echo "ERROR: No .task-docs folder found in project directory" >&2
    echo "Please create one: mkdir .task-docs && echo '.task-docs' >> .gitignore" >&2
    return 1
  fi

  # Search for task folder
  find "$docs_root" -type d -name "${issue_key}*" 2>/dev/null | head -1
}

# Usage
TASK_FOLDER=$(find_task_folder "STAR-1234")
if [ $? -eq 0 ] && [ -n "$TASK_FOLDER" ]; then
  echo "Found: $TASK_FOLDER"
elif [ $? -ne 0 ]; then
  echo "ERROR: Cannot search for tasks - .task-docs folder missing"
else
  echo "No folder found for STAR-1234 in .task-docs/"
fi
```

#### Create Task Folder

```bash
# Create a new task folder
# Usage: create_task_folder "STAR-1234" "Feature-Name"
create_task_folder() {
  local issue_key="$1"
  local slug="$2"
  local docs_root=$(get_task_docs_dir)

  # Check if .task-docs folder exists
  if [ -z "$docs_root" ]; then
    echo "ERROR: No .task-docs folder found in project directory" >&2
    echo "Please create one: mkdir .task-docs && echo '.task-docs' >> .gitignore" >&2
    return 1
  fi

  local task_folder="$docs_root/${issue_key}-${slug}"
  mkdir -p "$task_folder"
  echo "$task_folder"
}

# Usage
TASK_FOLDER=$(create_task_folder "STAR-1234" "My-Feature")
if [ $? -eq 0 ]; then
  echo "Created: $TASK_FOLDER"
else
  echo "ERROR: Cannot create task folder - .task-docs folder missing"
fi
```

#### List All Tasks

```bash
# List all task folders
list_all_tasks() {
  local docs_root=$(get_task_docs_dir)

  # Check if .task-docs folder exists
  if [ -z "$docs_root" ]; then
    echo "ERROR: No .task-docs folder found in project directory" >&2
    echo "Please create one: mkdir .task-docs && echo '.task-docs' >> .gitignore" >&2
    return 1
  fi

  ls -1 "$docs_root/" 2>/dev/null | grep -E "^[A-Z]+-[0-9]+"
}

# Usage
echo "All tasks:"
if ! list_all_tasks; then
  echo "Cannot list tasks - .task-docs folder missing"
fi
```

---

## Issue Key Extraction

### Extract from Branch Name

```bash
# Extract issue key from git branch name
# Supports formats: feature/STAR-1234-..., STAR-1234-..., etc.
extract_issue_key_from_branch() {
  local branch="$1"
  if [[ "$branch" =~ ([A-Z]+-[0-9]+) ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    echo ""
  fi
}

# Usage
BRANCH=$(git branch --show-current)
ISSUE_KEY=$(extract_issue_key_from_branch "$BRANCH")
if [ -n "$ISSUE_KEY" ]; then
  echo "Issue key: $ISSUE_KEY"
else
  echo "No issue key found in branch: $BRANCH"
fi
```

### Check if on Feature Branch

```bash
# Check if current branch is a feature branch with issue key
is_feature_branch() {
  local branch=$(git branch --show-current)
  local issue_key=$(extract_issue_key_from_branch "$branch")

  if [ -n "$issue_key" ]; then
    return 0  # True - is feature branch
  else
    return 1  # False - not feature branch
  fi
}

# Usage
if is_feature_branch; then
  echo "On feature branch"
  ISSUE_KEY=$(extract_issue_key_from_branch "$(git branch --show-current)")
else
  echo "Not on feature branch - need to ask for issue key"
fi
```

---

## Workflow Documentation Patterns

### In Markdown Documentation

When referencing `.task-docs` in workflow documentation files:

**✅ Correct patterns:**
```markdown
- `.task-docs/{ISSUE_KEY}-{slug}/`            # Project-local location
- `$(get_task_docs_dir)/{ISSUE_KEY}-{slug}/` # Using helper function
- `{PROJECT_ROOT}/.task-docs/`                # Explicit project-local
```

**❌ Incorrect patterns (DO NOT USE):**
```markdown
- `~/.task-docs/{ISSUE_KEY}-{slug}/`  # Wrong - implies global location
- `$HOME/.task-docs/`                 # Wrong - global location
- `/Users/username/.task-docs/`       # Hardcoded path
```

### In Bash Scripts

**✅ Correct usage:**
```bash
TASK_DOCS_DIR=$(get_task_docs_dir)  # Always use helper function
if [ -z "$TASK_DOCS_DIR" ]; then
  echo "ERROR: No .task-docs folder found"
  exit 1
fi
TASK_FOLDER=$(find "$TASK_DOCS_DIR" -type d -name "STAR-1234*")
mkdir -p "$TASK_DOCS_DIR/STAR-1234-Feature"
```

**❌ Incorrect usage:**
```bash
TASK_DOCS_DIR=".task-docs"           # Wrong - hardcoded path
TASK_DOCS_DIR="$HOME/.task-docs"     # Wrong - global location
find .task-docs -type d               # Wrong - doesn't check if exists
```

---

## Common Operations

### Check if Task Exists

```bash
# Check if a task folder exists
task_exists() {
  local issue_key="$1"
  local folder=$(find_task_folder "$issue_key")
  [ -n "$folder" ]
}

# Usage
if task_exists "STAR-1234"; then
  echo "Task exists"
  FOLDER=$(find_task_folder "STAR-1234")
else
  echo "Task does not exist"
fi
```

### Get Task Documents

```bash
# List all markdown files in a task folder
get_task_documents() {
  local issue_key="$1"
  local folder=$(find_task_folder "$issue_key")

  if [ -n "$folder" ]; then
    find "$folder" -maxdepth 1 -name "*.md" -type f
  fi
}

# Usage
DOCS=$(get_task_documents "STAR-1234")
echo "Found documents:"
echo "$DOCS"
```

---

## Integration with Workflows

### Task Planning Workflow

```bash
# Phase 0: Load config
TASK_DOCS_DIR=$(get_task_docs_dir)

# Step 1: Auto-detect mode
BRANCH=$(git branch --show-current)
ISSUE_KEY=$(extract_issue_key_from_branch "$BRANCH")

if [ -n "$ISSUE_KEY" ]; then
  # Check for existing task
  if task_exists "$ISSUE_KEY"; then
    MODE="in_progress"
  else
    MODE="default"
  fi
fi
```

### Code Review Workflow

```bash
# Find task documentation for current branch
BRANCH=$(git branch --show-current)
ISSUE_KEY=$(extract_issue_key_from_branch "$BRANCH")

if [ -n "$ISSUE_KEY" ]; then
  TASK_FOLDER=$(find_task_folder "$ISSUE_KEY")
  if [ -n "$TASK_FOLDER" ]; then
    # Read specification
    cat "$TASK_FOLDER/02-functional-requirements.md"
  fi
fi
```

---

## Configuration Reference

All helpers use configuration from:
- **Global config**: `~/.claude/config/global.yaml`
- **Storage location**: `global.yaml → storage.task_docs_dir` (defaults to `./.task-docs`)
- **Task folder pattern**: `global.yaml → storage.task_folder_pattern`

---

## Benefits of Centralization

1. **Single Source of Truth**: Change `.task-docs` location in ONE place
2. **Consistency**: All workflows use the same patterns
3. **Easy Updates**: Modify config, not every workflow file
4. **Portability**: Easy to backup, sync, or migrate

---

## Migration Guide

### From Global to Project-Local

**Before (global location):**
```bash
find "$HOME/.task-docs" -type d -name "STAR-*"
mkdir -p "$HOME/.task-docs/STAR-1234-Feature"
```

**After (project-local with error handling):**
```bash
TASK_DOCS_DIR=$(get_task_docs_dir)
if [ -z "$TASK_DOCS_DIR" ]; then
  echo "ERROR: No .task-docs folder found. Create with: mkdir .task-docs"
  exit 1
fi
find "$TASK_DOCS_DIR" -type d -name "STAR-*"
TASK_FOLDER=$(create_task_folder "STAR-1234" "Feature")
```

### From Direct References

**Before in documentation:**
```markdown
Check `~/.task-docs/STAR-1234-*/` for documentation
```

**After:**
```markdown
Check `.task-docs/STAR-1234-*/` for documentation (project-local, see `~/.claude/workflows/helpers.md`)
```

---

**Last Updated**: 2025-12-10
**Configuration**: `~/.claude/config/global.yaml`
