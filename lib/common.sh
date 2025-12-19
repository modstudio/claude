#!/bin/bash
# Common utilities, error handling, and logging for Claude Code workflows
# Version: 2.0.0

set -euo pipefail  # Exit on error, undefined var, pipe failure

# ============================================================================
# CONFIGURATION
# ============================================================================

# Directory paths (can be overridden via environment variables)
CLAUDE_ROOT="${CLAUDE_ROOT:-$HOME/.claude}"
CLAUDE_LIB_DIR="${CLAUDE_LIB_DIR:-$CLAUDE_ROOT/lib}"
CLAUDE_MODULES_DIR="${CLAUDE_MODULES_DIR:-$CLAUDE_ROOT/modules}"
CLAUDE_TEMPLATES_DIR="${CLAUDE_TEMPLATES_DIR:-$CLAUDE_ROOT/templates}"
CLAUDE_PROJECTS_DIR="${CLAUDE_PROJECTS_DIR:-$CLAUDE_ROOT/config/projects}"
CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$CLAUDE_ROOT/config}"

# Colors for output (if terminal supports it)
if [[ -t 1 ]]; then
  COLOR_RESET='\033[0m'
  COLOR_RED='\033[0;31m'
  COLOR_YELLOW='\033[0;33m'
  COLOR_GREEN='\033[0;32m'
  COLOR_BLUE='\033[0;34m'
  COLOR_GRAY='\033[0;90m'
else
  COLOR_RESET=''
  COLOR_RED=''
  COLOR_YELLOW=''
  COLOR_GREEN=''
  COLOR_BLUE=''
  COLOR_GRAY=''
fi

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

# Log an info message
log_info() {
  echo -e "${COLOR_BLUE}ℹ${COLOR_RESET} $*" >&2
}

# Log a success message
log_success() {
  echo -e "${COLOR_GREEN}✓${COLOR_RESET} $*" >&2
}

# Log a warning message
log_warning() {
  echo -e "${COLOR_YELLOW}⚠${COLOR_RESET} $*" >&2
}

# Log an error message
log_error() {
  echo -e "${COLOR_RED}✗${COLOR_RESET} $*" >&2
}

# Log a debug message (only if DEBUG=1)
log_debug() {
  if [[ "${DEBUG:-0}" == "1" ]]; then
    echo -e "${COLOR_GRAY}DEBUG:${COLOR_RESET} $*" >&2
  fi
}

# ============================================================================
# ERROR HANDLING
# ============================================================================

# Exit with error message
error_exit() {
  local message="$1"
  local exit_code="${2:-1}"

  log_error "$message"
  log_info "See $CLAUDE_ROOT/docs/troubleshooting.md for help"
  exit "$exit_code"
}

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Require a command to exist
require_command() {
  local cmd="$1"
  local install_hint="${2:-}"

  if ! command_exists "$cmd"; then
    if [[ -n "$install_hint" ]]; then
      error_exit "Required command '$cmd' not found. Install with: $install_hint"
    else
      error_exit "Required command '$cmd' not found"
    fi
  fi
}

# Check if a file exists
file_exists() {
  [[ -f "$1" ]]
}

# Check if a directory exists
dir_exists() {
  [[ -d "$1" ]]
}

# Require a file to exist
require_file() {
  local file="$1"
  local error_msg="${2:-File not found: $file}"

  if ! file_exists "$file"; then
    error_exit "$error_msg"
  fi
}

# Require a directory to exist
require_dir() {
  local dir="$1"
  local error_msg="${2:-Directory not found: $dir}"

  if ! dir_exists "$dir"; then
    error_exit "$error_msg"
  fi
}

# ============================================================================
# PATH HELPERS
# ============================================================================

# Get absolute path (resolve relative paths, ~, etc.)
abs_path() {
  local path="$1"

  # Expand ~ if present
  path="${path/#\~/$HOME}"

  # Resolve to absolute path
  if [[ "$path" = /* ]]; then
    echo "$path"
  else
    echo "$(pwd)/$path"
  fi
}

# Get directory of current script (useful for sourcing other scripts)
script_dir() {
  local source="${BASH_SOURCE[0]}"
  local dir
  while [[ -L "$source" ]]; do
    dir="$(cd -P "$(dirname "$source")" && pwd)"
    source="$(readlink "$source")"
    [[ $source != /* ]] && source="$dir/$source"
  done
  cd -P "$(dirname "$source")" && pwd
}

# ============================================================================
# FILE OPERATIONS
# ============================================================================

# Create directory if it doesn't exist
ensure_dir() {
  local dir="$1"

  if ! dir_exists "$dir"; then
    mkdir -p "$dir" || error_exit "Failed to create directory: $dir"
    log_debug "Created directory: $dir"
  fi
}

# Safely read a file (returns content or empty string if file doesn't exist)
safe_read_file() {
  local file="$1"

  if file_exists "$file"; then
    cat "$file"
  else
    echo ""
  fi
}

# ============================================================================
# STRING UTILITIES
# ============================================================================

# Trim whitespace from string (supports both arguments and stdin)
trim() {
  local var
  # Read from arguments if provided, otherwise from stdin
  if [[ $# -gt 0 ]]; then
    var="$*"
  else
    read -r var
  fi
  # Remove leading whitespace
  var="${var#"${var%%[![:space:]]*}"}"
  # Remove trailing whitespace
  var="${var%"${var##*[![:space:]]}"}"
  echo "$var"
}

# Convert string to lowercase
lowercase() {
  echo "$*" | tr '[:upper:]' '[:lower:]'
}

# Convert string to uppercase
uppercase() {
  echo "$*" | tr '[:lower:]' '[:upper:]'
}

# Check if string is empty
is_empty() {
  [[ -z "${1:-}" ]]
}

# Check if string is not empty
is_not_empty() {
  [[ -n "${1:-}" ]]
}

# ============================================================================
# VALIDATION
# ============================================================================

# Validate that a value is not empty
validate_not_empty() {
  local value="$1"
  local field_name="${2:-Value}"

  if is_empty "$value"; then
    error_exit "$field_name cannot be empty"
  fi
}

# Validate that a value matches a regex pattern
validate_pattern() {
  local value="$1"
  local pattern="$2"
  local field_name="${3:-Value}"

  if ! [[ "$value" =~ $pattern ]]; then
    error_exit "$field_name does not match expected pattern: $pattern"
  fi
}

# ============================================================================
# DATE/TIME
# ============================================================================

# Get current date in YYYY-MM-DD format
current_date() {
  date +%Y-%m-%d
}

# Get current datetime in ISO 8601 format
current_datetime() {
  date +%Y-%m-%dT%H:%M:%S%z
}

# ============================================================================
# INITIALIZATION
# ============================================================================

# Source this file to make all functions available
# Usage: source ~/.claude/lib/common.sh

log_debug "Loaded common.sh from $CLAUDE_LIB_DIR"
