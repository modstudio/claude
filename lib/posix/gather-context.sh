#!/bin/sh
# Gather all task context for agent consumption
# Version: 1.1.0
# Shell compatibility: POSIX sh (works in bash, zsh, dash, sh)

set -e

# Source core utilities
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/core.sh"

# ============================================================================
# OUTPUT MODES
# ============================================================================

mode_list() {
  issue_key="$1"
  task_folder=$(find_task_dir "$issue_key") || { echo "NO_TASK_FOLDER"; return 1; }
  find "$task_folder" -maxdepth 1 -name "*.md" -type f 2>/dev/null | sort
  [ -d "$task_folder/logs" ] && find "$task_folder/logs" -name "*.md" -type f 2>/dev/null | sort
  return 0
}

mode_quick() {
  issue_key="$1"
  task_folder=$(find_task_dir "$issue_key") && {
    count=$(count_task_docs "$issue_key")
    echo "ISSUE:$issue_key FOLDER:$task_folder DOCS:$count"
    return 0
  }
  echo "ISSUE:$issue_key FOLDER:NONE DOCS:0"
}

mode_full() {
  issue_key="$1"
  task_folder=""
  doc_count=0
  commit_count=0

  # Pre-compute key findings
  project_name=$(get_project_name)
  task_folder=$(find_task_dir "$issue_key" 2>/dev/null) || task_folder=""
  if [ -n "$task_folder" ]; then
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
  if [ -n "$task_folder" ]; then
    echo "  Task Docs:  ✓ FOUND ($doc_count files)"
    echo "  Location:   $task_folder"
  else
    echo "  Task Docs:  ✗ NOT FOUND"
    echo "  Searched:   $TASK_DOCS_DIR/**/${issue_key}*/ (up to 3 levels deep)"
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
    echo "Branch: $(get_git_branch)"
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

  if [ -n "$task_folder" ]; then
    echo "Folder: $task_folder"
    echo ""
    echo "Files:"
    for doc in "$task_folder"/*.md; do
      [ -f "$doc" ] && echo "  - $(basename "$doc") ($(wc -c < "$doc" | tr -d ' ') bytes)"
    done
    [ -d "$task_folder/logs" ] && for doc in "$task_folder/logs"/*.md; do
      [ -f "$doc" ] && echo "  - logs/$(basename "$doc") ($(wc -c < "$doc" | tr -d ' ') bytes)"
    done

    echo ""
    echo "================================================================================"
    echo "DOCUMENT CONTENTS"
    echo "================================================================================"
    echo ""

    for num in 00 01 02 03 04; do
      for doc in "$task_folder"/${num}*.md; do
        [ -f "$doc" ] && {
          echo "--------------------------------------------------------------------------------"
          echo "FILE: $(basename "$doc")"
          echo "--------------------------------------------------------------------------------"
          cat "$doc"
          echo ""
        }
      done
    done

    [ -d "$task_folder/logs" ] && for doc in "$task_folder/logs"/*.md; do
      [ -f "$doc" ] && {
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
  echo "Searched: $TASK_DOCS_DIR/**/${issue_key}*/ (up to 3 levels deep)"
  echo ""
  echo "No task documentation exists for this issue."
  echo ""
  echo "================================================================================"
  echo "END OF CONTEXT"
  echo "================================================================================"
}

show_help() {
  cat << 'EOF'
Usage: gather-context.sh [OPTIONS] [ISSUE_KEY]

Gather task context for AI agent consumption.

Options:
  --list, -l    List task doc file paths only
  --quick, -q   One-line summary
  --help, -h    Show this help

If ISSUE_KEY is not provided, it will be extracted from the current git branch.
EOF
}

# ============================================================================
# MAIN
# ============================================================================

main() {
  mode="full"
  issue_key=""

  while [ $# -gt 0 ]; do
    case "$1" in
      --list|-l) mode="list"; shift ;;
      --quick|-q) mode="quick"; shift ;;
      --help|-h) show_help; exit 0 ;;
      -*) echo "Unknown option: $1" >&2; exit 1 ;;
      *) issue_key="$1"; shift ;;
    esac
  done

  issue_key=$(get_issue_key "$issue_key") || {
    echo "ERROR: Could not determine issue key" >&2
    exit 1
  }

  case "$mode" in
    list) mode_list "$issue_key" ;;
    quick) mode_quick "$issue_key" ;;
    full) mode_full "$issue_key" ;;
  esac
}

main "$@"
