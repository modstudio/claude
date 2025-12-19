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
# Returns: absolute path to .task-docs if it exists, empty string otherwise
get_task_docs_dir() {
  local docs_path="$(pwd)/.task-docs"

  if dir_exists "$docs_path"; then
    echo "$docs_path"
    return 0
  else
    log_debug ".task-docs folder not found at $docs_path"
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

  validate_not_empty "$issue_key" "Issue key"

  if ! task_docs_exists; then
    log_debug "No .task-docs folder found, cannot search for task $issue_key"
    return 1
  fi

  # Search for folder matching pattern: {ISSUE_KEY}* (e.g., STAR-1234-Feature-Name)
  # Search up to 3 levels deep to support organized subdirectories
  local folder
  folder=$(find "$TASK_DOCS_DIR" -maxdepth 3 -type d -name "${issue_key}*" 2>/dev/null | head -1)

  if is_not_empty "$folder"; then
    echo "$folder"
    return 0
  else
    log_debug "No task folder found for $issue_key"
    return 1
  fi
}

# Check if task folder exists for given issue key
task_exists() {
  local issue_key="$1"
  find_task_dir "$issue_key" >/dev/null 2>&1
}

# Create a new task folder
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

# List all task folders in .task-docs
list_all_tasks() {
  if ! task_docs_exists; then
    log_info "No .task-docs folder found in current project"
    return 0
  fi

  # Find all directories matching issue key pattern (up to 3 levels deep)
  find "$TASK_DOCS_DIR" -maxdepth 3 -type d -name "[A-Z]*-[0-9]*" 2>/dev/null | sort
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
