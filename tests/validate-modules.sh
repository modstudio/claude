#!/bin/bash
# Validate all module references in workflows and commands
# Version: 1.0.0
#
# Checks that all {{MODULE: path}} references point to existing files.

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# ============================================================================
# CONFIGURATION
# ============================================================================

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
EXIT_CODE=0
TOTAL_REFS=0
BROKEN_REFS=0

# ============================================================================
# VALIDATION
# ============================================================================

validate_module_refs() {
  local search_dirs=("$CLAUDE_DIR/workflows" "$CLAUDE_DIR/commands")

  log_info "Validating module references in workflows and commands"
  echo ""

  for dir in "${search_dirs[@]}"; do
    if [[ ! -d "$dir" ]]; then
      log_warning "Directory not found: $dir"
      continue
    fi

    # Find all markdown files
    while IFS= read -r -d '' file; do
      validate_file "$file"
    done < <(find "$dir" -name "*.md" -type f -print0)
  done
}

validate_file() {
  local file="$1"
  local file_has_errors=false

  # Extract all {{MODULE: path}} references
  while IFS= read -r line; do
    # Extract the path from {{MODULE: path}}
    if [[ "$line" =~ \{\{MODULE:[[:space:]]*([^}]+)\}\} ]]; then
      local module_path="${BASH_REMATCH[1]}"
      # Trim whitespace
      module_path=$(echo "$module_path" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

      # Expand ~ to $HOME
      local expanded_path="${module_path/#\~/$HOME}"

      ((TOTAL_REFS++))

      if [[ ! -f "$expanded_path" ]]; then
        if [[ "$file_has_errors" == false ]]; then
          echo ""
          log_error "In file: $file"
          file_has_errors=true
        fi
        echo "  ✗ Missing module: $module_path"
        ((BROKEN_REFS++))
        EXIT_CODE=1
      fi
    fi
  done < "$file"
}

# ============================================================================
# SUMMARY
# ============================================================================

print_summary() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Module Reference Validation Summary"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Total references checked: $TOTAL_REFS"
  echo "Broken references:        $BROKEN_REFS"
  echo ""

  if [[ $EXIT_CODE -eq 0 ]]; then
    log_success "All module references are valid!"
  else
    log_error "Found $BROKEN_REFS broken module reference(s)"
    echo ""
    echo "To fix: Update the {{MODULE: path}} references to point to existing files."
  fi
  echo ""
}

# ============================================================================
# MAIN
# ============================================================================

main() {
  echo ""
  validate_module_refs
  print_summary
  exit $EXIT_CODE
}

main "$@"
