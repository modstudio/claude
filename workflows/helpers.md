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

# Extract .wip root location
WIP_ROOT="$HOME/.wip"  # Default from global.yaml: storage.wip_root
```

---

## Storage Helpers

### `.wip` Folder Management

**IMPORTANT**: The `.wip` folder is PROJECT-LOCAL and stored in `{PROJECT_ROOT}/.wip/`.

- Add `.wip` to your `.gitignore` to prevent committing task artifacts
- The folder must exist in your project directory for workflows to function
- If no `.wip` folder is found, the agent will report and ask for guidance

#### Get WIP Root

```bash
# Get the .wip root directory (PROJECT-LOCAL location)
get_wip_root() {
  local project_wip="./.wip"

  if [ -d "$project_wip" ]; then
    echo "$(pwd)/.wip"
  else
    # No .wip folder found - return empty and let caller handle
    echo ""
  fi
}

# Usage
WIP_ROOT=$(get_wip_root)
if [ -z "$WIP_ROOT" ]; then
  echo "ERROR: No .wip folder found in project directory"
  echo "Please create one: mkdir .wip"
  echo "And add to .gitignore: echo '.wip' >> .gitignore"
  exit 1
fi
```

#### Find Task Folder

```bash
# Find a task folder by issue key
# Usage: find_task_folder "STAR-1234"
find_task_folder() {
  local issue_key="$1"
  local wip_root=$(get_wip_root)

  # Check if .wip folder exists
  if [ -z "$wip_root" ]; then
    echo "ERROR: No .wip folder found in project directory" >&2
    echo "Please create one: mkdir .wip && echo '.wip' >> .gitignore" >&2
    return 1
  fi

  # Search for task folder
  find "$wip_root" -type d -name "${issue_key}*" 2>/dev/null | head -1
}

# Usage
TASK_FOLDER=$(find_task_folder "STAR-1234")
if [ $? -eq 0 ] && [ -n "$TASK_FOLDER" ]; then
  echo "Found: $TASK_FOLDER"
elif [ $? -ne 0 ]; then
  echo "ERROR: Cannot search for tasks - .wip folder missing"
else
  echo "No folder found for STAR-1234 in .wip/"
fi
```

#### Create Task Folder

```bash
# Create a new task folder
# Usage: create_task_folder "STAR-1234" "Feature-Name"
create_task_folder() {
  local issue_key="$1"
  local slug="$2"
  local wip_root=$(get_wip_root)

  # Check if .wip folder exists
  if [ -z "$wip_root" ]; then
    echo "ERROR: No .wip folder found in project directory" >&2
    echo "Please create one: mkdir .wip && echo '.wip' >> .gitignore" >&2
    return 1
  fi

  local task_folder="$wip_root/${issue_key}-${slug}"
  mkdir -p "$task_folder"
  echo "$task_folder"
}

# Usage
TASK_FOLDER=$(create_task_folder "STAR-1234" "My-Feature")
if [ $? -eq 0 ]; then
  echo "Created: $TASK_FOLDER"
else
  echo "ERROR: Cannot create task folder - .wip folder missing"
fi
```

#### List All Tasks

```bash
# List all task folders
list_all_tasks() {
  local wip_root=$(get_wip_root)

  # Check if .wip folder exists
  if [ -z "$wip_root" ]; then
    echo "ERROR: No .wip folder found in project directory" >&2
    echo "Please create one: mkdir .wip && echo '.wip' >> .gitignore" >&2
    return 1
  fi

  ls -1 "$wip_root/" 2>/dev/null | grep -E "^[A-Z]+-[0-9]+"
}

# Usage
echo "All tasks:"
if ! list_all_tasks; then
  echo "Cannot list tasks - .wip folder missing"
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

When referencing `.wip` in workflow documentation files:

**✅ Correct patterns:**
```markdown
- `.wip/{ISSUE_KEY}-{slug}/`            # Project-local location
- `$(get_wip_root)/{ISSUE_KEY}-{slug}/` # Using helper function
- `{PROJECT_ROOT}/.wip/`                # Explicit project-local
```

**❌ Incorrect patterns (DO NOT USE):**
```markdown
- `~/.wip/{ISSUE_KEY}-{slug}/`  # Wrong - implies global location
- `$HOME/.wip/`                 # Wrong - global location
- `/Users/username/.wip/`       # Hardcoded path
```

### In Bash Scripts

**✅ Correct usage:**
```bash
WIP_ROOT=$(get_wip_root)  # Always use helper function
if [ -z "$WIP_ROOT" ]; then
  echo "ERROR: No .wip folder found"
  exit 1
fi
TASK_FOLDER=$(find "$WIP_ROOT" -type d -name "STAR-1234*")
mkdir -p "$WIP_ROOT/STAR-1234-Feature"
```

**❌ Incorrect usage:**
```bash
WIP_ROOT=".wip"           # Wrong - hardcoded path
WIP_ROOT="$HOME/.wip"     # Wrong - global location
find .wip -type d         # Wrong - doesn't check if exists
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
WIP_ROOT=$(get_wip_root)

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
    cat "$TASK_FOLDER/01-functional-requirements.md"
  fi
fi
```

---

## Configuration Reference

All helpers use configuration from:
- **Global config**: `~/.claude/config/global.yaml`
- **Storage location**: `global.yaml → storage.wip_root` (defaults to `$HOME/.wip`)
- **Task folder pattern**: `global.yaml → storage.task_folder_pattern`

---

## Benefits of Centralization

1. **Single Source of Truth**: Change `.wip` location in ONE place
2. **Consistency**: All workflows use the same patterns
3. **Easy Updates**: Modify config, not every workflow file
4. **Portability**: Easy to backup, sync, or migrate

---

## Migration Guide

### From Global to Project-Local

**Before (global location):**
```bash
find "$HOME/.wip" -type d -name "STAR-*"
mkdir -p "$HOME/.wip/STAR-1234-Feature"
```

**After (project-local with error handling):**
```bash
WIP_ROOT=$(get_wip_root)
if [ -z "$WIP_ROOT" ]; then
  echo "ERROR: No .wip folder found. Create with: mkdir .wip"
  exit 1
fi
find "$WIP_ROOT" -type d -name "STAR-*"
TASK_FOLDER=$(create_task_folder "STAR-1234" "Feature")
```

### From Direct References

**Before in documentation:**
```markdown
Check `~/.wip/STAR-1234-*/` for documentation
```

**After:**
```markdown
Check `.wip/STAR-1234-*/` for documentation (project-local, see `~/.claude/workflows/helpers.md`)
```

---

**Last Updated**: 2025-11-17
**Configuration**: `~/.claude/config/global.yaml`
