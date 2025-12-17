#!/bin/bash
# Issue key extraction and validation utilities
# Version: 2.0.0

# Source common utilities
if [ -n "${BASH_SOURCE[0]:-}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  SCRIPT_DIR="$HOME/.claude/lib"
fi
source "$SCRIPT_DIR/common.sh"

# ============================================================================
# ISSUE KEY EXTRACTION
# ============================================================================

# Extract issue key from string (branch name, commit message, etc.)
# Args: text (optional, defaults to current branch name)
#       pattern (optional, uses PROJECT_ISSUE_REGEX if available)
# Returns: issue key if found, empty string otherwise
extract_issue_key() {
  local text="${1:-}"
  local pattern="${2:-${PROJECT_ISSUE_REGEX:-[A-Z]+-[0-9]+}}"

  # If no text provided, try to get from current git branch
  if is_empty "$text"; then
    if command_exists git && git rev-parse --git-dir >/dev/null 2>&1; then
      text=$(git branch --show-current 2>/dev/null || echo "")
    fi
  fi

  if is_empty "$text"; then
    log_debug "No text provided and not in git repository"
    return 1
  fi

  # Extract first match of pattern
  if [[ "$text" =~ ($pattern) ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  else
    log_debug "No issue key found in: $text (pattern: $pattern)"
    return 1
  fi
}

# Extract issue key from current git branch
extract_issue_key_from_branch() {
  local pattern="${1:-${PROJECT_ISSUE_REGEX:-[A-Z]+-[0-9]+}}"

  if ! command_exists git; then
    log_error "Git not installed"
    return 1
  fi

  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    log_error "Not in a git repository"
    return 1
  fi

  local branch
  branch=$(git branch --show-current 2>/dev/null)

  if is_empty "$branch"; then
    log_error "Could not determine current branch"
    return 1
  fi

  extract_issue_key "$branch" "$pattern"
}

# Extract issue key from commit message
extract_issue_key_from_commit() {
  local commit="${1:-HEAD}"
  local pattern="${2:-${PROJECT_ISSUE_REGEX:-[A-Z]+-[0-9]+}}"

  if ! command_exists git; then
    log_error "Git not installed"
    return 1
  fi

  local message
  message=$(git log -1 --format=%s "$commit" 2>/dev/null)

  if is_empty "$message"; then
    log_error "Could not get commit message for $commit"
    return 1
  fi

  extract_issue_key "$message" "$pattern"
}

# ============================================================================
# ISSUE KEY VALIDATION
# ============================================================================

# Validate issue key format
# Args: issue_key, pattern (optional, uses PROJECT_ISSUE_REGEX if available)
# Returns: 0 if valid, 1 if invalid
validate_issue_key() {
  local issue_key="$1"
  local pattern="${2:-${PROJECT_ISSUE_REGEX:-[A-Z]+-[0-9]+}}"

  if is_empty "$issue_key"; then
    log_error "Issue key is empty"
    return 1
  fi

  if [[ "$issue_key" =~ ^${pattern}$ ]]; then
    return 0
  else
    log_error "Invalid issue key format: $issue_key (expected pattern: $pattern)"
    return 1
  fi
}

# Check if string contains an issue key
contains_issue_key() {
  local text="$1"
  local pattern="${2:-${PROJECT_ISSUE_REGEX:-[A-Z]+-[0-9]+}}"

  [[ "$text" =~ $pattern ]]
}

# ============================================================================
# ISSUE KEY PARSING
# ============================================================================

# Get project prefix from issue key (e.g., "STAR" from "STAR-1234")
get_issue_prefix() {
  local issue_key="$1"

  if [[ "$issue_key" =~ ^([A-Z]+)- ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  else
    log_error "Could not extract prefix from: $issue_key"
    return 1
  fi
}

# Get issue number from issue key (e.g., "1234" from "STAR-1234")
get_issue_number() {
  local issue_key="$1"

  if [[ "$issue_key" =~ -([0-9]+)$ ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  else
    log_error "Could not extract number from: $issue_key"
    return 1
  fi
}

# ============================================================================
# SLUG OPERATIONS
# ============================================================================

# Generate slug from text (Title-Case-With-Hyphens)
# Args: text
# Returns: slugified text
generate_slug() {
  local text="$1"

  # Trim whitespace
  text=$(trim "$text")

  # Replace spaces and underscores with hyphens
  text=$(echo "$text" | tr ' _' '-')

  # Remove special characters except hyphens and alphanumeric
  text=$(echo "$text" | sed 's/[^a-zA-Z0-9-]//g')

  # Remove multiple consecutive hyphens
  text=$(echo "$text" | sed 's/-\+/-/g')

  # Remove leading/trailing hyphens
  text=$(echo "$text" | sed 's/^-//;s/-$//')

  # Title case each word
  text=$(echo "$text" | awk -F'-' '{
    for(i=1; i<=NF; i++) {
      $i = toupper(substr($i,1,1)) tolower(substr($i,2))
    }
    print
  }' OFS='-')

  echo "$text"
}

# Extract slug from task folder name
# Args: folder_path or folder_name
# Returns: slug portion (everything after "ISSUE-KEY-")
extract_slug_from_folder() {
  local folder="$1"

  # Get just the folder name if full path provided
  folder=$(basename "$folder")

  # Extract slug: everything after first dash-number-dash pattern
  if [[ "$folder" =~ ^[A-Z]+-[0-9]+-(.+)$ ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  else
    log_debug "Could not extract slug from folder: $folder"
    return 1
  fi
}

# ============================================================================
# CONVENIENCE FUNCTIONS
# ============================================================================

# Get issue key and slug from current context
# Returns: "ISSUE-KEY:slug" or just "ISSUE-KEY" if slug not found
get_current_issue_context() {
  local issue_key
  if ! issue_key=$(extract_issue_key_from_branch); then
    log_error "Could not determine issue key from current branch"
    return 1
  fi

  # Try to find task folder and extract slug
  source "$SCRIPT_DIR/task-docs-utils.sh"
  local folder
  if folder=$(find_task_folder "$issue_key"); then
    local slug
    if slug=$(extract_slug_from_folder "$folder"); then
      echo "$issue_key:$slug"
      return 0
    fi
  fi

  # Just return issue key if no slug found
  echo "$issue_key"
}

# Format issue key for display with project name
# Args: issue_key
# Returns: formatted string (e.g., "STAR-1234 (Starship)")
format_issue_key() {
  local issue_key="$1"

  if is_not_empty "${PROJECT_NAME:-}"; then
    echo "$issue_key ($PROJECT_NAME)"
  else
    echo "$issue_key"
  fi
}

# ============================================================================
# INITIALIZATION
# ============================================================================

log_debug "Loaded issue-utils.sh"
