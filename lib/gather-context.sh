#!/bin/bash
# Gather all task context for agent consumption (bash-enhanced version)
# Version: 2.0.0
# Features: Colored output, rich error handling, project context integration

set -euo pipefail

# Source bash utilities
if [ -n "${BASH_SOURCE[0]:-}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  SCRIPT_DIR="$HOME/.claude/lib"
fi
source "$SCRIPT_DIR/common.sh"
source "$SCRIPT_DIR/git-utils.sh"
source "$SCRIPT_DIR/issue-utils.sh"
source "$SCRIPT_DIR/task-docs-utils.sh"

# ============================================================================
# OUTPUT MODES
# ============================================================================

mode_list() {
  local issue_key="$1"
  local task_folder

  if ! task_folder=$(find_task_folder "$issue_key"); then
    echo "NO_TASK_FOLDER"
    return 1
  fi

  find "$task_folder" -maxdepth 1 -name "*.md" -type f 2>/dev/null | sort
  [[ -d "$task_folder/logs" ]] && find "$task_folder/logs" -name "*.md" -type f 2>/dev/null | sort
  return 0
}

mode_quick() {
  local issue_key="$1"
  local task_folder
  local count=0

  if task_folder=$(find_task_folder "$issue_key"); then
    count=$(find "$task_folder" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo "ISSUE:$issue_key FOLDER:$task_folder DOCS:$count"
  else
    echo "ISSUE:$issue_key FOLDER:NONE DOCS:0"
  fi
}

mode_full() {
  local issue_key="$1"
  local task_folder=""
  local doc_count=0
  local commit_count=0
  local project_name=""

  # Pre-compute key findings
  if has_remote; then
    project_name="$(get_repo_name_from_remote)"
  else
    project_name="$(basename "$(pwd)")"
  fi

  task_folder=$(find_task_folder "$issue_key" 2>/dev/null) || task_folder=""
  if [[ -n "$task_folder" ]]; then
    doc_count=$(find "$task_folder" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
  fi

  if is_git_repo; then
    commit_count=$(git log --all --grep="$issue_key" --oneline 2>/dev/null | wc -l | tr -d ' ')
  fi

  # ============================================================================
  # KEY FINDINGS (print first for immediate visibility)
  # ============================================================================
  echo "================================================================================"
  echo "KEY FINDINGS: $issue_key"
  echo "================================================================================"
  echo ""
  echo "  Project:    $project_name"
  if [[ -n "$task_folder" ]]; then
    echo "  Task Docs:  ✓ FOUND ($doc_count files)"
    echo "  Location:   $task_folder"
  else
    echo "  Task Docs:  ✗ NOT FOUND"
    echo "  Searched:   .task-docs/**/${issue_key}*/ (up to 3 levels deep)"
  fi
  echo "  Commits:    $commit_count commits mentioning $issue_key"
  echo ""
  echo "================================================================================"
  echo ""

  # ============================================================================
  # DETAILED CONTEXT (below the fold)
  # ============================================================================

  # Project info
  echo "PROJECT INFORMATION"
  echo "-------------------"
  echo "Project: $project_name"
  echo "Working Directory: $(pwd)"
  echo ""

  # Git info
  if is_git_repo; then
    echo "GIT INFORMATION"
    echo "---------------"
    echo "Branch: $(get_current_branch 2>/dev/null || echo 'unknown')"
    echo ""
    echo "Recent commits for $issue_key:"
    git log --all --grep="$issue_key" --oneline 2>/dev/null | head -10 || echo "(none found)"
    echo ""
    echo "Current changes:"
    git status --short 2>/dev/null || echo "(none)"
    echo ""
  fi

  # Task documentation
  echo "TASK DOCUMENTATION"
  echo "------------------"

  if [[ -n "$task_folder" ]]; then
    echo "Folder: $task_folder"
    echo ""
    echo "Files:"
    for doc in "$task_folder"/*.md; do
      [[ -f "$doc" ]] && echo "  - $(basename "$doc") ($(wc -c < "$doc" | tr -d ' ') bytes)"
    done
    [[ -d "$task_folder/logs" ]] && for doc in "$task_folder/logs"/*.md; do
      [[ -f "$doc" ]] && echo "  - logs/$(basename "$doc") ($(wc -c < "$doc" | tr -d ' ') bytes)"
    done

    echo ""
    echo "================================================================================"
    echo "DOCUMENT CONTENTS"
    echo "================================================================================"
    echo ""

    for num in 00 01 02 03 04; do
      for doc in "$task_folder"/${num}*.md; do
        [[ -f "$doc" ]] && {
          echo "--------------------------------------------------------------------------------"
          echo "FILE: $(basename "$doc")"
          echo "--------------------------------------------------------------------------------"
          cat "$doc"
          echo ""
        }
      done
    done

    [[ -d "$task_folder/logs" ]] && for doc in "$task_folder/logs"/*.md; do
      [[ -f "$doc" ]] && {
        echo "--------------------------------------------------------------------------------"
        echo "FILE: logs/$(basename "$doc")"
        echo "--------------------------------------------------------------------------------"
        cat "$doc"
        echo ""
      }
    done

    echo "================================================================================"
    echo "END OF CONTEXT"
    echo "================================================================================"
    return 0
  fi

  echo "Folder: NOT FOUND"
  echo "Searched: .task-docs/**/${issue_key}*/ (up to 3 levels deep)"
  echo ""
  echo "No task documentation exists for this issue."
  echo ""
  echo "================================================================================"
  echo "END OF CONTEXT"
  echo "================================================================================"
}

show_help() {
  cat << 'EOF'
Usage: gather-context [OPTIONS] [ISSUE_KEY]

Gather task context for AI agent consumption.

Options:
  --list, -l    List task doc file paths only
  --quick, -q   One-line summary
  --help, -h    Show this help

If ISSUE_KEY is not provided, it will be extracted from the current git branch.

This is the bash-enhanced version with colored output and rich error handling.
EOF
}

# ============================================================================
# MAIN
# ============================================================================

main() {
  local mode="full"
  local issue_key=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --list|-l) mode="list"; shift ;;
      --quick|-q) mode="quick"; shift ;;
      --help|-h) show_help; exit 0 ;;
      -*) log_error "Unknown option: $1"; exit 1 ;;
      *) issue_key="$1"; shift ;;
    esac
  done

  # Get issue key from argument or branch
  if is_empty "$issue_key"; then
    if ! issue_key=$(extract_issue_key_from_branch 2>/dev/null); then
      log_error "Could not determine issue key from branch"
      exit 1
    fi
  fi

  case "$mode" in
    list) mode_list "$issue_key" ;;
    quick) mode_quick "$issue_key" ;;
    full) mode_full "$issue_key" ;;
  esac
}

main "$@"
