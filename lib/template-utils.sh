#!/bin/bash
# Template rendering with variable substitution
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

TEMPLATES_DIR="${CLAUDE_TEMPLATES_DIR:-$HOME/.claude/templates}"

# ============================================================================
# VARIABLE SUBSTITUTION
# ============================================================================

# Render template with variable substitution
# Args: template_file, output_file, [var_name=value ...]
# Variables are passed as additional arguments: VAR_NAME=value
render_template() {
  local template_file="$1"
  local output_file="$2"
  shift 2

  require_file "$template_file" "Template file not found: $template_file"

  log_debug "Rendering template: $template_file -> $output_file"

  # Read template content
  local content
  content=$(cat "$template_file")

  # Parse variable assignments from arguments and perform substitution
  # Bash 3.2 compatible (no associative arrays)
  for arg in "$@"; do
    if [[ "$arg" =~ ^([A-Z_][A-Z0-9_]*)=(.*)$ ]]; then
      local var_name="${BASH_REMATCH[1]}"
      local var_value="${BASH_REMATCH[2]}"
      log_debug "  Variable: $var_name = $var_value"

      # Escape forward slashes and special chars for sed
      local escaped_value=$(echo "$var_value" | sed 's/[\/&]/\\&/g')
      # Replace ${VAR_NAME} with value
      content=$(echo "$content" | sed "s/\${$var_name}/$escaped_value/g")
    fi
  done

  # Also substitute PROJECT_ environment variables automatically
  for var_name in $(compgen -v PROJECT_ 2>/dev/null || echo ""); do
    if [ -n "${!var_name:-}" ]; then
      local var_value="${!var_name}"
      local escaped_value=$(echo "$var_value" | sed 's/[\/&]/\\&/g')
      content=$(echo "$content" | sed "s/\${$var_name}/$escaped_value/g")
    fi
  done

  # Write to output file
  ensure_dir "$(dirname "$output_file")"
  echo "$content" > "$output_file"

  log_success "Rendered template to: $output_file"
}

# Render template to stdout (useful for previewing)
render_template_stdout() {
  local template_file="$1"
  shift

  require_file "$template_file" "Template file not found: $template_file"

  # Read template content
  local content
  content=$(cat "$template_file")

  # Parse variable assignments from arguments and perform substitution
  # Bash 3.2 compatible (no associative arrays)
  for arg in "$@"; do
    if [[ "$arg" =~ ^([A-Z_][A-Z0-9_]*)=(.*)$ ]]; then
      local var_name="${BASH_REMATCH[1]}"
      local var_value="${BASH_REMATCH[2]}"

      # Escape forward slashes and special chars for sed
      local escaped_value=$(echo "$var_value" | sed 's/[\/&]/\\&/g')
      # Replace ${VAR_NAME} with value
      content=$(echo "$content" | sed "s/\${$var_name}/$escaped_value/g")
    fi
  done

  # Also substitute PROJECT_ environment variables automatically
  for var_name in $(compgen -v PROJECT_ 2>/dev/null || echo ""); do
    if [ -n "${!var_name:-}" ]; then
      local var_value="${!var_name}"
      local escaped_value=$(echo "$var_value" | sed 's/[\/&]/\\&/g')
      content=$(echo "$content" | sed "s/\${$var_name}/$escaped_value/g")
    fi
  done

  echo "$content"
}

# ============================================================================
# TASK PLANNING TEMPLATES
# ============================================================================

# Render all standard task planning documents
# Args: task_folder, issue_key, [var_name=value ...]
render_task_planning_docs() {
  local task_folder="$1"
  local issue_key="$2"
  shift 2

  require_dir "$task_folder" "Task folder not found: $task_folder"
  validate_not_empty "$issue_key" "Issue key"

  log_info "Rendering task planning documents for $issue_key"

  local templates_dir="$TEMPLATES_DIR/task-planning"
  require_dir "$templates_dir" "Task planning templates not found"

  # Root templates to render (00-04)
  local root_templates=(
    "00-status.md"
    "01-task-description.md"
    "02-functional-requirements.md"
    "03-implementation-plan.md"
    "04-todo.md"
  )

  # Log templates to render
  local log_templates=(
    "logs/decisions.md"
    "logs/review.md"
  )

  # Add issue key to variables
  local all_args=("ISSUE_KEY=$issue_key" "$@")

  # Render root templates
  for template_name in "${root_templates[@]}"; do
    local template_file="$templates_dir/$template_name"
    local output_file="$task_folder/$template_name"

    if file_exists "$template_file"; then
      render_template "$template_file" "$output_file" "${all_args[@]}"
    else
      log_warning "Template not found: $template_name (skipping)"
    fi
  done

  # Create logs subfolder and render log templates
  mkdir -p "$task_folder/logs"
  for template_name in "${log_templates[@]}"; do
    local template_file="$templates_dir/$template_name"
    local output_file="$task_folder/$template_name"

    if file_exists "$template_file"; then
      render_template "$template_file" "$output_file" "${all_args[@]}"
    else
      log_warning "Template not found: $template_name (skipping)"
    fi
  done

  log_success "Rendered all task planning documents to: $task_folder"
}

# Render a single task document
# Args: task_folder, document_name, issue_key, [var_name=value ...]
render_task_document() {
  local task_folder="$1"
  local document_name="$2"
  local issue_key="$3"
  shift 3

  require_dir "$task_folder" "Task folder not found: $task_folder"
  validate_not_empty "$document_name" "Document name"
  validate_not_empty "$issue_key" "Issue key"

  local template_file="$TEMPLATES_DIR/task-planning/$document_name"
  local output_file="$task_folder/$document_name"

  require_file "$template_file" "Template not found: $document_name"

  local all_args=("ISSUE_KEY=$issue_key" "$@")
  render_template "$template_file" "$output_file" "${all_args[@]}"
}

# ============================================================================
# HELPER FUNCTIONS FOR COMMON VARIABLES
# ============================================================================

# Get standard template variables for a task
# Args: issue_key, task_summary, [task_description]
# Returns: Array of VAR=value strings ready for render_template
get_standard_task_vars() {
  local issue_key="$1"
  local task_summary="$2"
  local task_description="${3:-$task_summary}"

  # Ensure project context is loaded
  if is_empty "${PROJECT_NAME:-}"; then
    source "$SCRIPT_DIR/project-context.sh"
    load_project_context
  fi

  local vars=(
    "ISSUE_KEY=$issue_key"
    "TASK_SUMMARY=$task_summary"
    "TASK_DESCRIPTION=$task_description"
    "CURRENT_DATE=$(current_date)"
    "CURRENT_DATETIME=$(current_datetime)"
  )

  # Add git context if available
  if command_exists git && git rev-parse --git-dir >/dev/null 2>&1; then
    local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    local commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    vars+=("GIT_BRANCH=$branch")
    vars+=("GIT_COMMIT=$commit")
  fi

  # Return all variables
  printf '%s\n' "${vars[@]}"
}

# ============================================================================
# TEMPLATE DISCOVERY
# ============================================================================

# List available templates in a category
# Args: category (e.g., "task-planning", "code-review")
list_templates() {
  local category="$1"
  local category_dir="$TEMPLATES_DIR/$category"

  if ! dir_exists "$category_dir"; then
    log_error "Template category not found: $category"
    return 1
  fi

  find "$category_dir" -maxdepth 1 -name "*.md" -type f | sort
}

# Check if a template exists
# Args: category, template_name
template_exists() {
  local category="$1"
  local template_name="$2"
  local template_file="$TEMPLATES_DIR/$category/$template_name"

  file_exists "$template_file"
}

# Get path to a template
# Args: category, template_name
get_template_path() {
  local category="$1"
  local template_name="$2"
  echo "$TEMPLATES_DIR/$category/$template_name"
}

# ============================================================================
# INITIALIZATION
# ============================================================================

log_debug "Loaded template-utils.sh"
