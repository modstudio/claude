#!/bin/bash
# Git operations and utilities
# Version: 2.0.0

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# ============================================================================
# GIT ENVIRONMENT CHECKS
# ============================================================================

# Check if git is installed
has_git() {
  command_exists git
}

# Check if current directory is a git repository
is_git_repo() {
  has_git && git rev-parse --git-dir >/dev/null 2>&1
}

# Require git to be installed
require_git() {
  if ! has_git; then
    error_exit "Git is not installed. Please install git to use this feature."
  fi
}

# Require current directory to be a git repository
require_git_repo() {
  require_git

  if ! is_git_repo; then
    error_exit "Not in a git repository. Please run this command from within a git repository."
  fi
}

# ============================================================================
# BRANCH OPERATIONS
# ============================================================================

# Get current branch name
get_current_branch() {
  require_git_repo

  local branch
  branch=$(git branch --show-current 2>/dev/null)

  if is_empty "$branch"; then
    log_error "Could not determine current branch (detached HEAD?)"
    return 1
  fi

  echo "$branch"
}

# Check if a branch exists (local or remote)
branch_exists() {
  local branch_name="$1"
  local location="${2:-all}"  # all, local, or remote

  require_git_repo

  case "$location" in
    local)
      git show-ref --verify --quiet "refs/heads/$branch_name"
      ;;
    remote)
      git show-ref --verify --quiet "refs/remotes/origin/$branch_name"
      ;;
    all)
      git show-ref --verify --quiet "refs/heads/$branch_name" || \
      git show-ref --verify --quiet "refs/remotes/origin/$branch_name"
      ;;
    *)
      log_error "Invalid location: $location (must be 'local', 'remote', or 'all')"
      return 1
      ;;
  esac
}

# List all local branches matching a pattern
list_branches() {
  local pattern="${1:-*}"

  require_git_repo

  git branch --list "$pattern" | sed 's/^[* ] //'
}

# Check if on a feature branch (contains issue key)
is_feature_branch() {
  local pattern="${1:-${PROJECT_ISSUE_REGEX:-[A-Z]+-[0-9]+}}"

  local branch
  if ! branch=$(get_current_branch); then
    return 1
  fi

  [[ "$branch" =~ $pattern ]]
}

# ============================================================================
# COMMIT OPERATIONS
# ============================================================================

# Get number of commits on current branch vs base branch
count_commits_ahead() {
  local base_branch="${1:-${PROJECT_BASE_BRANCH:-develop}}"

  require_git_repo

  # Check if base branch exists
  if ! branch_exists "$base_branch" local; then
    log_warning "Base branch '$base_branch' not found locally"
    return 1
  fi

  git log "$base_branch..HEAD" --oneline 2>/dev/null | wc -l | trim
}

# Check if there are uncommitted changes
has_uncommitted_changes() {
  require_git_repo

  # Check both staged and unstaged changes
  ! git diff --quiet || ! git diff --cached --quiet
}

# Check if there are untracked files
has_untracked_files() {
  require_git_repo

  [[ -n $(git ls-files --others --exclude-standard) ]]
}

# Get count of uncommitted changes
count_uncommitted_changes() {
  require_git_repo

  git status --porcelain | wc -l | trim
}

# ============================================================================
# REMOTE OPERATIONS
# ============================================================================

# Get git remote URL
get_remote_url() {
  local remote="${1:-origin}"

  require_git_repo

  git remote get-url "$remote" 2>/dev/null
}

# Check if remote exists
has_remote() {
  local remote="${1:-origin}"

  require_git_repo

  git remote get-url "$remote" >/dev/null 2>&1
}

# Extract repository name from remote URL
get_repo_name_from_remote() {
  local remote="${1:-origin}"

  local url
  if ! url=$(get_remote_url "$remote"); then
    return 1
  fi

  # Extract repo name from URL (handle both SSH and HTTPS)
  # SSH: git@github.com:user/repo.git -> repo
  # HTTPS: https://github.com/user/repo.git -> repo
  local repo_name
  repo_name=$(echo "$url" | sed 's/.*[:/]\([^/]*\)\/\([^/]*\)\.git$/\2/')

  echo "$repo_name"
}

# ============================================================================
# STATUS CHECKS
# ============================================================================

# Get git status summary
get_git_status_summary() {
  require_git_repo

  local branch
  branch=$(get_current_branch)

  local commits_ahead=0
  if base_branch="${PROJECT_BASE_BRANCH:-develop}"; then
    if branch_exists "$base_branch" local; then
      commits_ahead=$(count_commits_ahead "$base_branch")
    fi
  fi

  local uncommitted=$(count_uncommitted_changes)
  local has_untracked="no"
  if has_untracked_files; then
    has_untracked="yes"
  fi

  cat <<EOF
Branch: $branch
Commits ahead of base: $commits_ahead
Uncommitted changes: $uncommitted
Untracked files: $has_untracked
EOF
}

# Check if working directory is clean (no uncommitted or untracked files)
is_working_directory_clean() {
  require_git_repo

  ! has_uncommitted_changes && ! has_untracked_files
}

# ============================================================================
# WORKFLOW DETECTION
# ============================================================================

# Detect current git workflow state
# Returns: "clean", "uncommitted", "commits", "both"
detect_git_state() {
  require_git_repo

  local has_commits=false
  local has_changes=false

  # Check for commits ahead of base branch
  local base_branch="${PROJECT_BASE_BRANCH:-develop}"
  if branch_exists "$base_branch" local; then
    local commits_ahead
    commits_ahead=$(count_commits_ahead "$base_branch")
    if [[ "$commits_ahead" -gt 0 ]]; then
      has_commits=true
    fi
  fi

  # Check for uncommitted changes
  if has_uncommitted_changes || has_untracked_files; then
    has_changes=true
  fi

  # Determine state
  if $has_commits && $has_changes; then
    echo "both"
  elif $has_commits; then
    echo "commits"
  elif $has_changes; then
    echo "uncommitted"
  else
    echo "clean"
  fi
}

# Suggest planning mode based on git state
suggest_planning_mode() {
  require_git_repo

  local git_state
  git_state=$(detect_git_state)

  case "$git_state" in
    both|commits|uncommitted)
      echo "in_progress"
      ;;
    clean)
      # Check if on feature branch
      if is_feature_branch; then
        echo "default"
      else
        echo "greenfield"
      fi
      ;;
    *)
      echo "default"
      ;;
  esac
}

# ============================================================================
# INFORMATION EXTRACTION
# ============================================================================

# Get repository root directory
get_repo_root() {
  require_git_repo

  git rev-parse --show-toplevel
}

# Get current commit hash
get_current_commit() {
  local short="${1:-false}"

  require_git_repo

  if [[ "$short" == "true" ]]; then
    git rev-parse --short HEAD
  else
    git rev-parse HEAD
  fi
}

# Get commit message for a specific commit
get_commit_message() {
  local commit="${1:-HEAD}"

  require_git_repo

  git log -1 --format=%s "$commit" 2>/dev/null
}

# ============================================================================
# INITIALIZATION
# ============================================================================

log_debug "Loaded git-utils.sh"
