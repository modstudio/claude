#!/bin/bash
# Detect appropriate planning/workflow mode based on current state (bash-enhanced)
# Version: 2.0.0
# Features: Colored output, rich error handling, comprehensive git analysis

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
# MODE DETECTION
# ============================================================================

# Global state variables
BRANCH=""
ISSUE_KEY=""
TASK_FOLDER=""
COMMITS_AHEAD="0"
UNCOMMITTED="0"
MODE=""
REASON=""
CONFIDENCE=""

gather_state() {
  # Get branch
  if is_git_repo; then
    BRANCH=$(get_current_branch 2>/dev/null || echo "")
  fi

  # Get issue key from branch
  if is_not_empty "$BRANCH"; then
    ISSUE_KEY=$(extract_issue_key "$BRANCH" 2>/dev/null || echo "")
  fi

  # Find task folder
  if is_not_empty "$ISSUE_KEY"; then
    TASK_FOLDER=$(find_task_dir "$ISSUE_KEY" 2>/dev/null || echo "")
  fi

  # Get git stats
  if is_git_repo; then
    COMMITS_AHEAD=$(count_commits_ahead 2>/dev/null || echo "0")
    UNCOMMITTED=$(count_uncommitted_changes 2>/dev/null || echo "0")
  fi
}

determine_mode() {
  MODE="default"
  REASON=""
  CONFIDENCE="medium"

  # Two-mode architecture: Default (planning) vs In Progress (reconciliation)
  # Default mode handles all planning scenarios including greenfield (no issue key)

  if [[ "$COMMITS_AHEAD" -gt 0 ]] || [[ "$UNCOMMITTED" -gt 0 ]]; then
    # Code exists - suggest reconciliation mode
    MODE="in_progress"
    REASON="Found existing work: $COMMITS_AHEAD commits ahead, $UNCOMMITTED uncommitted changes - consider reconciling docs"
    CONFIDENCE="high"
  elif is_empty "$ISSUE_KEY"; then
    # No issue key - greenfield scenario, handled by Default mode
    MODE="default"
    REASON="No issue key found - Default mode will handle as greenfield scenario"
    CONFIDENCE="medium"
  elif is_not_empty "$TASK_FOLDER"; then
    MODE="default"
    REASON="Task docs exist at $TASK_FOLDER but no code changes yet - continue planning"
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
  local issue_key_json="${ISSUE_KEY:-null}"
  local branch_json="${BRANCH:-null}"
  local task_folder_json="${TASK_FOLDER:-null}"

  # Quote non-null values
  [[ "$issue_key_json" != "null" ]] && issue_key_json="\"$issue_key_json\""
  [[ "$branch_json" != "null" ]] && branch_json="\"$branch_json\""
  [[ "$task_folder_json" != "null" ]] && task_folder_json="\"$task_folder_json\""

  cat << EOF
{
  "mode": "$MODE",
  "issue_key": $issue_key_json,
  "branch": $branch_json,
  "task_folder": $task_folder_json,
  "commits_ahead": $COMMITS_AHEAD,
  "uncommitted": $UNCOMMITTED,
  "confidence": "$CONFIDENCE",
  "reason": "$REASON"
}
EOF
}

output_pretty() {
  echo ""
  echo -e "${COLOR_BLUE}Mode Detection Results${COLOR_RESET}"
  echo -e "${COLOR_GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
  echo ""

  local mode_color="$COLOR_GREEN"
  [[ "$MODE" == "in_progress" ]] && mode_color="$COLOR_YELLOW"

  echo -e "${COLOR_GREEN}Mode:${COLOR_RESET}         ${mode_color}$MODE${COLOR_RESET}"
  echo -e "${COLOR_GREEN}Confidence:${COLOR_RESET}   $CONFIDENCE"
  echo ""
  echo -e "${COLOR_GREEN}Issue Key:${COLOR_RESET}    ${ISSUE_KEY:-none}"
  echo -e "${COLOR_GREEN}Branch:${COLOR_RESET}       ${BRANCH:-none}"
  echo -e "${COLOR_GREEN}Task Folder:${COLOR_RESET}  ${TASK_FOLDER:-none}"
  echo ""
  echo -e "${COLOR_GREEN}Git State:${COLOR_RESET}"
  echo "  Commits ahead: $COMMITS_AHEAD"
  echo "  Uncommitted:   $UNCOMMITTED"
  echo ""
  echo -e "${COLOR_GREEN}Reason:${COLOR_RESET}       $REASON"
  echo ""
  echo -e "${COLOR_GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
  echo ""
}

show_help() {
  cat << 'EOF'
Usage: detect-mode [OPTIONS]

Detect appropriate planning/workflow mode based on current git state.

Options:
  --json, -j      Output in JSON format
  --pretty, -p    Output with colors and formatting
  --help, -h      Show this help

Modes:
  default       Planning workflow - handles YouTrack issues and greenfield scenarios
  in_progress   Reconciliation - sync docs with existing implementation

Output Fields:
  MODE          Suggested mode (default, in_progress)
  ISSUE_KEY     Extracted from branch name
  BRANCH        Current git branch
  TASK_FOLDER   Path to task docs if found
  COMMITS_AHEAD Number of commits ahead of base branch
  UNCOMMITTED   Number of uncommitted changes
  CONFIDENCE    Detection confidence (high, medium, low)
  REASON        Explanation for mode suggestion

This is the bash-enhanced version with colored output and rich error handling.
EOF
}

# ============================================================================
# MAIN
# ============================================================================

main() {
  local output_format="text"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --json|-j) output_format="json"; shift ;;
      --pretty|-p) output_format="pretty"; shift ;;
      --help|-h) show_help; exit 0 ;;
      -*) log_error "Unknown option: $1"; exit 1 ;;
      *) shift ;;
    esac
  done

  gather_state
  determine_mode

  case "$output_format" in
    json) output_json ;;
    pretty) output_pretty ;;
    *) output_text ;;
  esac
}

main "$@"
