#!/bin/bash
# Project context detection and YAML configuration loading
# Version: 2.0.0

# Source common utilities
if [ -n "${BASH_SOURCE[0]:-}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  SCRIPT_DIR="$HOME/.claude/lib"
fi
source "$SCRIPT_DIR/common.sh"

# ============================================================================
# CONFIGURATION
# ============================================================================

# Projects directory
PROJECTS_DIR="${CLAUDE_PROJECTS_DIR:-$HOME/.claude/config/projects}"

# ============================================================================
# YAML PARSING HELPERS
# ============================================================================

# Simple YAML value extraction (works without yq)
# Args: yaml_file, key_path (e.g., "project.name")
# Returns: value if found
yaml_get_simple() {
  local file="$1"
  local key_path="$2"

  if ! file_exists "$file"; then
    log_error "YAML file not found: $file"
    return 1
  fi

  # Split key path into parts
  IFS='.' read -ra PARTS <<< "$key_path"
  local indent=0
  local current_section=""
  local value=""

  while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$(trim "$line")" ]] && continue

    # Get indentation level
    local line_indent=$(echo "$line" | sed 's/^\([[:space:]]*\).*/\1/' | wc -c)

    # Check if this is a key-value pair (contains :)
    if [[ "$line" == *":"* ]]; then
      # Extract key (everything before first :, trimmed)
      local key=$(echo "$line" | sed 's/^[[:space:]]*//' | cut -d':' -f1)
      # Extract value (everything after first :, trimmed)
      local val=$(echo "$line" | cut -d':' -f2- | sed 's/^[[:space:]]*//')

      # Build current path
      if [[ $line_indent -le 1 ]]; then
        current_section="$key"
      elif [[ "${PARTS[0]}" == "$current_section" ]] && [[ "${PARTS[1]}" == "$key" ]]; then
        # Found the key we're looking for
        # Remove quotes if present
        val=$(echo "$val" | sed 's/^["'"'"']\(.*\)["'"'"']$/\1/')
        echo "$val"
        return 0
      fi
    fi
  done < "$file"

  return 1
}

# Check if yq is available for complex YAML parsing
has_yq() {
  command_exists yq
}

# Get YAML value (uses yq if available, falls back to simple parser)
yaml_get() {
  local file="$1"
  local key_path="$2"

  if has_yq; then
    yq eval ".${key_path}" "$file" 2>/dev/null
  else
    yaml_get_simple "$file" "$key_path"
  fi
}

# ============================================================================
# PROJECT DETECTION
# ============================================================================

# Detect current project based on directory and git remote
# Returns: project config filename (e.g., "starship", "alephbeis", "generic")
detect_project() {
  local cwd=$(pwd)
  local git_remote=""

  # Try to get git remote
  if command_exists git && git rev-parse --git-dir >/dev/null 2>&1; then
    git_remote=$(git remote get-url origin 2>/dev/null || echo "")
  fi

  log_debug "Detecting project for: cwd=$cwd, remote=$git_remote"

  # Check each YAML file in projects directory
  for yaml_file in "$PROJECTS_DIR"/*.yaml; do
    if ! file_exists "$yaml_file"; then
      continue
    fi

    local project_name=$(basename "$yaml_file" .yaml)

    # Skip generic for now (fallback)
    if [[ "$project_name" == "generic" ]]; then
      continue
    fi

    # Get path pattern from YAML
    local path_pattern=$(yaml_get "$yaml_file" "project.path")
    local remote_pattern=$(yaml_get "$yaml_file" "project.git_remote_pattern")

    log_debug "Checking $project_name: path_pattern=$path_pattern, remote_pattern=$remote_pattern"

    # Check if path matches
    if is_not_empty "$path_pattern" && [[ "$cwd" == *"$path_pattern"* ]]; then
      log_debug "Matched project $project_name by path"
      echo "$project_name"
      return 0
    fi

    # Check if git remote matches
    if is_not_empty "$remote_pattern" && is_not_empty "$git_remote" && [[ "$git_remote" == *"$remote_pattern"* ]]; then
      log_debug "Matched project $project_name by git remote"
      echo "$project_name"
      return 0
    fi
  done

  # No match found, use generic
  log_debug "No specific project matched, using generic"
  echo "generic"
}

# ============================================================================
# PROJECT CONTEXT LOADING
# ============================================================================

# Load project configuration and export as environment variables
# Returns: 0 on success, 1 on failure
load_project_context() {
  local project_name
  project_name=$(detect_project)

  local yaml_file="$PROJECTS_DIR/${project_name}.yaml"

  if ! file_exists "$yaml_file"; then
    log_error "Project config file not found: $yaml_file"
    return 1
  fi

  log_info "Loading project context: $project_name"

  # Export basic project info
  export PROJECT_NAME=$(yaml_get "$yaml_file" "project.name" || echo "$project_name")
  export PROJECT_TYPE=$(yaml_get "$yaml_file" "project.type" || echo "Unknown")
  export PROJECT_CONFIG_FILE="$yaml_file"

  # Export issue tracking config
  export PROJECT_ISSUE_PATTERN=$(yaml_get "$yaml_file" "issue_tracking.pattern" || echo "PROJ-####")
  export PROJECT_ISSUE_REGEX=$(yaml_get "$yaml_file" "issue_tracking.regex" || echo "[A-Z]+-[0-9]+")
  export PROJECT_ISSUE_SYSTEM=$(yaml_get "$yaml_file" "issue_tracking.system" || echo "Generic")
  export PROJECT_YOUTRACK_URL=$(yaml_get "$yaml_file" "issue_tracking.url_template" || echo "")

  # Export branching config
  export PROJECT_BASE_BRANCH=$(yaml_get "$yaml_file" "branching.base_branch" || echo "develop")
  export PROJECT_BRANCH_PATTERN=$(yaml_get "$yaml_file" "branching.pattern" || echo "{type}/{ISSUE_KEY}-{description}")

  # Export standards config
  export PROJECT_STANDARDS_DIR=$(yaml_get "$yaml_file" "standards.location" || echo ".ai/rules/")

  # Export citation formats
  export PROJECT_CITATION_ARCHITECTURE=$(yaml_get "$yaml_file" "citation_format.architecture" || echo '[ARCH: "{quote}"]')
  export PROJECT_CITATION_STYLE=$(yaml_get "$yaml_file" "citation_format.style" || echo '[STYLE: "{quote}"]')

  # Export storage config
  local task_docs_raw=$(yaml_get "$yaml_file" "storage.task_docs_dir" || echo "./.task-docs")
  # Expand ~ to $HOME
  export PROJECT_TASK_DOCS_DIR="${task_docs_raw/#\~/$HOME}"

  # Export test commands
  export PROJECT_TEST_CMD_ALL=$(yaml_get "$yaml_file" "test_commands.all" || echo "")
  export PROJECT_TEST_CMD_UNIT=$(yaml_get "$yaml_file" "test_commands.unit" || echo "")

  # Export documentation config
  export PROJECT_KB_DIR=$(yaml_get "$yaml_file" "documentation.knowledge_base.location" || echo "")
  export PROJECT_KB_SOURCE=$(yaml_get "$yaml_file" "documentation.knowledge_base.source" || echo "none")
  export PROJECT_KB_ACCESS_METHOD=$(yaml_get "$yaml_file" "documentation.knowledge_base.access_method" || echo "none")

  # Export MCP tools availability
  export PROJECT_MCP_YOUTRACK=$(yaml_get "$yaml_file" "mcp_tools.youtrack.enabled" || echo "false")
  export PROJECT_MCP_LARAVEL_BOOST=$(yaml_get "$yaml_file" "mcp_tools.laravel_boost.enabled" || echo "false")

  # Export YouTrack-specific config (CRITICAL: MCP tools need project_id, NOT project_key)
  export PROJECT_YOUTRACK_PROJECT_ID=$(yaml_get "$yaml_file" "mcp_tools.youtrack.project_id" || echo "")
  export PROJECT_YOUTRACK_PROJECT_KEY=$(yaml_get "$yaml_file" "issue_tracking.project_key" || echo "")

  # Export linting preferences (team decisions per project)
  export PROJECT_LINTING_ALLOW_BASELINES=$(yaml_get "$yaml_file" "linting.allow_baselines" || echo "false")
  export PROJECT_LINTING_ALLOW_INLINE_IGNORES=$(yaml_get "$yaml_file" "linting.allow_inline_ignores" || echo "false")
  export PROJECT_LINTING_PREFER_CONFIG=$(yaml_get "$yaml_file" "linting.prefer_config_over_inline" || echo "true")
  export PROJECT_LINTING_REQUIRE_JUSTIFICATION=$(yaml_get "$yaml_file" "linting.require_justification" || echo "true")

  log_success "Loaded project context: $PROJECT_NAME ($PROJECT_TYPE)"
  log_debug "  Issue pattern: $PROJECT_ISSUE_PATTERN"
  log_debug "  Base branch: $PROJECT_BASE_BRANCH"
  log_debug "  Standards: $PROJECT_STANDARDS_DIR"
  log_debug "  Task docs: $PROJECT_TASK_DOCS_DIR"

  return 0
}

# ============================================================================
# CONVENIENCE FUNCTIONS
# ============================================================================

# Print current project context summary
show_project_context() {
  if is_empty "${PROJECT_NAME:-}"; then
    log_error "Project context not loaded. Run load_project_context first."
    return 1
  fi

  cat <<EOF

${COLOR_BLUE}Project Context${COLOR_RESET}
${COLOR_GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}

${COLOR_GREEN}Project:${COLOR_RESET}        $PROJECT_NAME ($PROJECT_TYPE)
${COLOR_GREEN}Config:${COLOR_RESET}         $PROJECT_CONFIG_FILE

${COLOR_GREEN}Issue Tracking:${COLOR_RESET}
  Pattern:      $PROJECT_ISSUE_PATTERN
  Regex:        $PROJECT_ISSUE_REGEX
  System:       $PROJECT_ISSUE_SYSTEM

${COLOR_GREEN}Branching:${COLOR_RESET}
  Base branch:  $PROJECT_BASE_BRANCH
  Pattern:      $PROJECT_BRANCH_PATTERN

${COLOR_GREEN}Standards:${COLOR_RESET}      $PROJECT_STANDARDS_DIR
${COLOR_GREEN}Task Docs:${COLOR_RESET}      $PROJECT_TASK_DOCS_DIR

${COLOR_GREEN}Knowledge Base:${COLOR_RESET}
  Directory:    $PROJECT_KB_DIR
  Source:       $PROJECT_KB_SOURCE
  Access:       $PROJECT_KB_ACCESS_METHOD

${COLOR_GREEN}Citations:${COLOR_RESET}
  Architecture: $PROJECT_CITATION_ARCHITECTURE
  Style:        $PROJECT_CITATION_STYLE

${COLOR_GREEN}YouTrack MCP:${COLOR_RESET}
  Enabled:      $PROJECT_MCP_YOUTRACK
  Project ID:   $PROJECT_YOUTRACK_PROJECT_ID (use for MCP calls)
  Project Key:  $PROJECT_YOUTRACK_PROJECT_KEY (display only)

${COLOR_GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}

EOF
}

# Check if project context is loaded
is_project_context_loaded() {
  is_not_empty "${PROJECT_NAME:-}"
}

# Ensure project context is loaded (load if not)
ensure_project_context() {
  if ! is_project_context_loaded; then
    load_project_context || error_exit "Failed to load project context"
  fi
}

# ============================================================================
# INITIALIZATION
# ============================================================================

log_debug "Loaded project-context.sh"

# Note: Auto-loading disabled to give users control
# Call load_project_context() explicitly when needed
