#!/bin/bash
# Validate all YAML configuration files
# Version: 2.0.0

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# ============================================================================
# VALIDATION
# ============================================================================

validate_yaml_files() {
  local projects_dir="${CLAUDE_PROJECTS_DIR:-$HOME/.claude/config/projects}"
  local exit_code=0

  log_info "Validating YAML configuration files in $projects_dir"
  echo ""

  for yaml_file in "$projects_dir"/*.yaml; do
    if ! file_exists "$yaml_file"; then
      log_warning "No YAML files found in $projects_dir"
      continue
    fi

    local filename=$(basename "$yaml_file")
    echo -n "Validating $filename... "

    # Check if yq is available
    if command_exists yq; then
      # Use yq to validate YAML syntax
      if yq eval . "$yaml_file" > /dev/null 2>&1; then
        log_success "✓ Valid YAML syntax"
      else
        log_error "✗ Invalid YAML syntax"
        exit_code=1
        continue
      fi
    else
      # Basic validation without yq
      log_warning "⚠ yq not installed, skipping syntax validation"
    fi

    # Validate required fields
    local has_errors=false

    # Check project.name
    if ! grep -q "^project:" "$yaml_file" || ! grep -q "name:" "$yaml_file"; then
      log_error "  ✗ Missing required field: project.name"
      has_errors=true
    fi

    # Check issue_tracking
    if ! grep -q "^issue_tracking:" "$yaml_file"; then
      log_error "  ✗ Missing required section: issue_tracking"
      has_errors=true
    fi

    # Check knowledge base config if present
    if grep -q "knowledge_base:" "$yaml_file"; then
      # Validate source field
      local kb_source=$(grep -A 1 "knowledge_base:" "$yaml_file" | grep "source:" | awk '{print $2}' || echo "")
      if [[ -n "$kb_source" ]] && ! [[ "$kb_source" =~ ^(gitignored|git|external|none)$ ]]; then
        log_error "  ✗ Invalid knowledge_base.source: '$kb_source' (must be: gitignored, git, external, or none)"
        has_errors=true
      fi
    fi

    if ! $has_errors; then
      log_success "  ✓ All required fields present"
    else
      exit_code=1
    fi

    echo ""
  done

  return $exit_code
}

# ============================================================================
# MAIN
# ============================================================================

validate_yaml_files

if [[ $? -eq 0 ]]; then
  log_success "All YAML configurations valid!"
  exit 0
else
  log_error "YAML validation failed. Please fix errors above."
  exit 1
fi
