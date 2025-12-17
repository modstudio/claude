#!/bin/sh
# Detect appropriate planning/workflow mode based on current state
# Version: 1.1.0
# Shell compatibility: POSIX sh (works in bash, zsh, dash, sh)

set -e

# Source core utilities
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/core.sh"

# ============================================================================
# MODE DETECTION
# ============================================================================

gather_state() {
  # Set globals for state
  BRANCH=$(get_git_branch)
  ISSUE_KEY=""
  TASK_FOLDER=""
  COMMITS_AHEAD="0"
  UNCOMMITTED="0"

  [ -n "$BRANCH" ] && ISSUE_KEY=$(extract_issue_key "$BRANCH")
  [ -n "$ISSUE_KEY" ] && TASK_FOLDER=$(find_task_dir "$ISSUE_KEY") || true

  if is_git_repo; then
    COMMITS_AHEAD=$(count_commits_ahead)
    UNCOMMITTED=$(count_uncommitted)
  fi
}

determine_mode() {
  # Determine mode based on gathered state
  MODE="default"
  REASON=""
  CONFIDENCE="medium"

  if [ -z "$ISSUE_KEY" ]; then
    MODE="greenfield"
    REASON="No issue key found in branch name - exploratory or prototype work"
    CONFIDENCE="medium"
  elif [ "$COMMITS_AHEAD" -gt 0 ] || [ "$UNCOMMITTED" -gt 0 ]; then
    MODE="in_progress"
    REASON="Found existing work: $COMMITS_AHEAD commits ahead, $UNCOMMITTED uncommitted changes"
    CONFIDENCE="high"
  elif [ -n "$TASK_FOLDER" ]; then
    MODE="default"
    REASON="Task docs exist at $TASK_FOLDER but no code changes yet"
    CONFIDENCE="high"
  else
    MODE="default"
    REASON="Issue key $ISSUE_KEY found, no existing work - starting fresh"
    CONFIDENCE="high"
  fi
}

# ============================================================================
# OUTPUT MODES
# ============================================================================

output_text() {
  echo "MODE: $MODE"
  echo "ISSUE_KEY: ${ISSUE_KEY:-none}"
  echo "BRANCH: ${BRANCH:-none}"
  echo "TASK_FOLDER: ${TASK_FOLDER:-none}"
  echo "COMMITS_AHEAD: $COMMITS_AHEAD"
  echo "UNCOMMITTED: $UNCOMMITTED"
  echo "CONFIDENCE: $CONFIDENCE"
  echo "REASON: $REASON"
}

output_json() {
  cat << EOF
{
  "mode": "$MODE",
  "issue_key": "${ISSUE_KEY:-null}",
  "branch": "${BRANCH:-null}",
  "task_folder": "${TASK_FOLDER:-null}",
  "commits_ahead": $COMMITS_AHEAD,
  "uncommitted": $UNCOMMITTED,
  "confidence": "$CONFIDENCE",
  "reason": "$REASON"
}
EOF
}

show_help() {
  cat << 'EOF'
Usage: detect-mode.sh [OPTIONS]

Detect appropriate planning/workflow mode based on current git state.

Options:
  --json, -j    Output in JSON format
  --help, -h    Show this help

Modes:
  default       Normal workflow - issue exists, starting fresh
  greenfield    Exploratory work - no issue key, prototype
  in_progress   Resuming work - commits or changes exist

Output Fields:
  MODE          Suggested mode (default, greenfield, in_progress)
  ISSUE_KEY     Extracted from branch name
  BRANCH        Current git branch
  TASK_FOLDER   Path to task docs if found
  COMMITS_AHEAD Number of commits ahead of base branch
  UNCOMMITTED   Number of uncommitted changes
  CONFIDENCE    Detection confidence (high, medium, low)
  REASON        Explanation for mode suggestion
EOF
}

# ============================================================================
# MAIN
# ============================================================================

main() {
  output_format="text"

  while [ $# -gt 0 ]; do
    case "$1" in
      --json|-j) output_format="json"; shift ;;
      --help|-h) show_help; exit 0 ;;
      -*) echo "Unknown option: $1" >&2; exit 1 ;;
      *) shift ;;
    esac
  done

  gather_state
  determine_mode

  case "$output_format" in
    json) output_json ;;
    *) output_text ;;
  esac
}

main "$@"
