#!/bin/bash
# Task docs folder utilities - PROJECT-LOCAL operations only
# Version: 2.0.0

# Source common utilities
# Use BASH_SOURCE if available, otherwise fallback to known location
if [ -n "${BASH_SOURCE[0]:-}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  SCRIPT_DIR="$HOME/.claude/lib"
fi
source "$SCRIPT_DIR/common.sh"

# ============================================================================
# CONFIGURATION
# ============================================================================

# Task docs folder is ALWAYS project-local
TASK_DOCS_DIR="./.task-docs"

# ============================================================================
# TASK DOCS FOLDER OPERATIONS
# ============================================================================

# Get the task docs root directory (project-local)
# Returns: absolute path to task docs dir if it exists, empty string otherwise
get_task_docs_dir() {
  local docs_path="$(pwd)/${TASK_DOCS_DIR#./}"

  if dir_exists "$docs_path"; then
    echo "$docs_path"
    return 0
  else
    log_debug "Task docs folder not found at $docs_path"
    return 1
  fi
}

# Check if .task-docs folder exists in current project
task_docs_exists() {
  dir_exists "$TASK_DOCS_DIR"
}

# Ensure .task-docs folder exists (create if necessary)
ensure_task_docs_exists() {
  if ! task_docs_exists; then
    log_info "Creating .task-docs folder in current project"
    mkdir -p "$TASK_DOCS_DIR" || error_exit "Failed to create .task-docs folder"

    # Add to .gitignore if not already there
    if file_exists ".gitignore"; then
      if ! grep -q "^\.task-docs$" .gitignore 2>/dev/null; then
        echo ".task-docs" >> .gitignore
        log_success "Added .task-docs to .gitignore"
      fi
    else
      echo ".task-docs" > .gitignore
      log_success "Created .gitignore with .task-docs entry"
    fi
  fi
}

# Get absolute path to .task-docs (ensures it exists)
get_task_docs_dir_abs() {
  ensure_task_docs_exists
  abs_path "$TASK_DOCS_DIR"
}

# ============================================================================
# TASK FOLDER OPERATIONS
# ============================================================================

# Find a task folder by issue key
# Args: issue_key (e.g., "STAR-1234")
# Returns: path to folder if found, empty string otherwise
find_task_dir() {
  local issue_key="$1"
  local task_docs_dir
  task_docs_dir=$(basename "$TASK_DOCS_DIR")

  validate_not_empty "$issue_key" "Issue key"

  local folder=""

  # Strategy 1: Check root task-docs first (most common case)
  if task_docs_exists; then
    folder=$(find "$TASK_DOCS_DIR" -maxdepth 3 -type d -name "${issue_key}*" 2>/dev/null | head -1)
    if is_not_empty "$folder"; then
      echo "$folder"
      return 0
    fi
  fi

  # Strategy 2: Search for task-docs in nested subdirectories (up to 3 levels)
  # This handles cases where task-docs is in a subfolder (e.g., subproject/.task-docs/)
  while IFS= read -r task_docs_path; do
    # Skip empty lines and root task-docs (already checked above)
    [ -z "$task_docs_path" ] && continue
    [[ "$task_docs_path" == "$TASK_DOCS_DIR" ]] && continue

    folder=$(find "$task_docs_path" -maxdepth 3 -type d -name "${issue_key}*" 2>/dev/null | head -1)
    if is_not_empty "$folder"; then
      echo "$folder"
      return 0
    fi
  done < <(find . -maxdepth 3 -type d -name "$task_docs_dir" 2>/dev/null)

  log_debug "No task folder found for $issue_key in root or nested $task_docs_dir directories"
  return 1
}

# Check if task folder exists for given issue key
task_exists() {
  local issue_key="$1"
  find_task_dir "$issue_key" >/dev/null 2>&1
}

# Create a new task folder with templates
# Args: issue_key (e.g., "STAR-1234"), slug (e.g., "Feature-Name")
# Returns: path to created folder
create_task_folder() {
  local issue_key="$1"
  local slug="$2"

  validate_not_empty "$issue_key" "Issue key"
  validate_not_empty "$slug" "Slug"

  ensure_task_docs_exists

  local folder_name="${issue_key}-${slug}"
  local task_folder="$TASK_DOCS_DIR/$folder_name"

  if dir_exists "$task_folder"; then
    log_warning "Task folder already exists: $task_folder"
  else
    mkdir -p "$task_folder" || error_exit "Failed to create task folder: $task_folder"
    log_success "Created task folder: $task_folder"

    # Render templates if template-utils is available
    if command -v render_task_planning_docs &>/dev/null; then
      render_task_planning_docs "$task_folder" "$issue_key"
    elif [ -f "$SCRIPT_DIR/template-utils.sh" ]; then
      source "$SCRIPT_DIR/template-utils.sh"
      render_task_planning_docs "$task_folder" "$issue_key"
    else
      log_debug "Template utils not available, skipping template rendering"
    fi
  fi

  echo "$task_folder"
}

# Get task folder (find existing or create new)
# Args: issue_key, slug (optional, only used if creating new)
# Returns: path to folder
get_task_folder() {
  local issue_key="$1"
  local slug="${2:-}"

  # Try to find existing folder first
  local folder
  if folder=$(find_task_dir "$issue_key"); then
    echo "$folder"
    return 0
  fi

  # If not found and slug provided, create new
  if is_not_empty "$slug"; then
    create_task_folder "$issue_key" "$slug"
    return 0
  fi

  # Not found and no slug provided
  log_error "Task folder not found for $issue_key and no slug provided to create new"
  return 1
}

# List all task folders in task-docs (root and nested)
list_all_tasks() {
  local task_docs_dir nested_results
  task_docs_dir=$(basename "$TASK_DOCS_DIR")

  # Collect results from all task-docs directories
  local results=""

  # Check root task-docs
  if task_docs_exists; then
    results=$(find "$TASK_DOCS_DIR" -maxdepth 3 -type d -name "[A-Z]*-[0-9]*" 2>/dev/null)
  fi

  # Check nested task-docs directories
  while IFS= read -r task_docs_path; do
    [ -z "$task_docs_path" ] && continue
    [[ "$task_docs_path" == "$TASK_DOCS_DIR" ]] && continue
    nested_results=$(find "$task_docs_path" -maxdepth 3 -type d -name "[A-Z]*-[0-9]*" 2>/dev/null)
    if is_not_empty "$nested_results"; then
      results="${results}"$'\n'"${nested_results}"
    fi
  done < <(find . -maxdepth 3 -type d -name "$task_docs_dir" 2>/dev/null)

  if is_empty "$results"; then
    log_info "No task folders found in $task_docs_dir directories"
    return 0
  fi

  echo "$results" | sort | uniq
}

# Count tasks in .task-docs folder
count_tasks() {
  list_all_tasks | wc -l | trim
}

# ============================================================================
# TASK DOCUMENT OPERATIONS
# ============================================================================

# Get path to a specific document in task folder
# Args: issue_key, document_name (e.g., "00-status.md")
# Returns: path to document if task folder exists
get_task_document() {
  local issue_key="$1"
  local document_name="$2"

  validate_not_empty "$issue_key" "Issue key"
  validate_not_empty "$document_name" "Document name"

  local folder
  if ! folder=$(find_task_dir "$issue_key"); then
    log_error "Task folder not found for $issue_key"
    return 1
  fi

  echo "$folder/$document_name"
}

# Check if a task document exists
task_document_exists() {
  local issue_key="$1"
  local document_name="$2"

  local doc_path
  if doc_path=$(get_task_document "$issue_key" "$document_name"); then
    file_exists "$doc_path"
  else
    return 1
  fi
}

# List all documents in a task folder
list_task_documents() {
  local issue_key="$1"

  local folder
  if ! folder=$(find_task_dir "$issue_key"); then
    log_error "Task folder not found for $issue_key"
    return 1
  fi

  find "$folder" -maxdepth 1 -type f -name "*.md" 2>/dev/null | sort
}

# ============================================================================
# CLEANUP OPERATIONS
# ============================================================================

# Archive a task folder (move to .task-docs/archive/)
archive_task() {
  local issue_key="$1"

  local folder
  if ! folder=$(find_task_dir "$issue_key"); then
    log_error "Task folder not found for $issue_key"
    return 1
  fi

  local archive_dir="$TASK_DOCS_DIR/archive"
  ensure_dir "$archive_dir"

  local folder_name=$(basename "$folder")
  local archive_path="$archive_dir/$folder_name"

  if dir_exists "$archive_path"; then
    log_warning "Archive destination already exists: $archive_path"
    return 1
  fi

  mv "$folder" "$archive_path" || error_exit "Failed to archive task folder"
  log_success "Archived task $issue_key to $archive_path"
}

# Delete a task folder (with confirmation)
delete_task() {
  local issue_key="$1"
  local force="${2:-false}"

  local folder
  if ! folder=$(find_task_dir "$issue_key"); then
    log_error "Task folder not found for $issue_key"
    return 1
  fi

  if [[ "$force" != "true" ]]; then
    log_warning "This will permanently delete: $folder"
    read -p "Are you sure? (yes/no): " confirm
    if [[ "$confirm" != "yes" ]]; then
      log_info "Delete cancelled"
      return 1
    fi
  fi

  rm -rf "$folder" || error_exit "Failed to delete task folder"
  log_success "Deleted task folder: $folder"
}

# ============================================================================
# INITIALIZATION
# ============================================================================

log_debug "Loaded task-docs-utils.sh"
