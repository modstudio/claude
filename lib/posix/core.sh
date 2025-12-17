#!/bin/sh
# Core utilities for POSIX-compliant scripts
# Version: 1.0.0
# Shell compatibility: POSIX sh (works in bash, zsh, dash, sh)

# ============================================================================
# CONFIGURATION
# ============================================================================

TASK_DOCS_DIR="${TASK_DOCS_DIR:-.task-docs}"
DEFAULT_ISSUE_PATTERN='[A-Z][A-Z]*-[0-9][0-9]*'
DEFAULT_BASE_BRANCH="${DEFAULT_BASE_BRANCH:-develop}"

# ============================================================================
# ISSUE KEY FUNCTIONS
# ============================================================================

# Extract issue key from text
# Args: text, [pattern]
extract_issue_key() {
  echo "$1" | grep -oE "${2:-$DEFAULT_ISSUE_PATTERN}" | head -1
}

# Get issue key from argument or git branch
# Args: [provided_key]
get_issue_key() {
  if [ -n "$1" ]; then
    echo "$1"
    return 0
  fi

  branch=$(get_git_branch)
  if [ -n "$branch" ]; then
    key=$(extract_issue_key "$branch")
    if [ -n "$key" ]; then
      echo "$key"
      return 0
    fi
  fi

  return 1
}

# ============================================================================
# GIT FUNCTIONS
# ============================================================================

# Check if in git repo
is_git_repo() {
  command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1
}

# Get current git branch
get_git_branch() {
  is_git_repo && {
    git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null
  }
}

# Count commits ahead of base branch
count_commits_ahead() {
  base="${1:-$DEFAULT_BASE_BRANCH}"
  is_git_repo && git rev-parse --verify "$base" >/dev/null 2>&1 && {
    git rev-list --count "$base..HEAD" 2>/dev/null || echo "0"
  } || echo "0"
}

# Count uncommitted changes
count_uncommitted() {
  is_git_repo && git status --porcelain 2>/dev/null | wc -l | tr -d ' ' || echo "0"
}

# Get project name from git remote
get_project_name() {
  is_git_repo && {
    remote=$(git remote get-url origin 2>/dev/null)
    [ -n "$remote" ] && basename "$remote" .git 2>/dev/null && return 0
  }
  echo "unknown"
}

# ============================================================================
# TASK DOCS FUNCTIONS
# ============================================================================

# Find task folder for issue key
# Args: issue_key
# Searches up to 3 levels deep to support organized subdirectories
find_task_dir() {
  [ -d "$TASK_DOCS_DIR" ] || return 1
  folder=$(find "$TASK_DOCS_DIR" -maxdepth 3 -type d -name "${1}*" 2>/dev/null | head -1)
  [ -n "$folder" ] && [ -d "$folder" ] && echo "$folder" && return 0
  return 1
}

# Check if task docs exist for issue
task_docs_exist() {
  find_task_dir "$1" >/dev/null 2>&1
}

# Count task doc files
count_task_docs() {
  folder=$(find_task_dir "$1") && find "$folder" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "0"
}
