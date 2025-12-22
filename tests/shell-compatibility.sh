#!/bin/bash
# Shell Compatibility Test Suite
# Tests all lib scripts in both bash and zsh
# Usage: ./test-shell-compat.sh [bash|zsh|all]

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
LIB_DIR="$TESTS_DIR/../lib"
CLAUDE_ROOT="$TESTS_DIR/.."
PASSED=0
FAILED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

log_pass() { echo -e "${GREEN}✓${NC} $1"; ((PASSED++)) || true; }
log_fail() { echo -e "${RED}✗${NC} $1"; ((FAILED++)) || true; }
log_info() { echo -e "${YELLOW}→${NC} $1"; }

# Run test with timeout (background + wait)
run_test() {
  local shell="$1"
  local name="$2"
  local test_code="$3"
  local timeout_sec="${4:-5}"

  # Run in background
  local output
  output=$($shell -c "$test_code" 2>&1) &
  local pid=$!

  # Wait with timeout
  local count=0
  while kill -0 $pid 2>/dev/null && [ $count -lt $((timeout_sec * 10)) ]; do
    sleep 0.1
    ((count++)) || true
  done

  if kill -0 $pid 2>/dev/null; then
    kill $pid 2>/dev/null
    log_fail "[$shell] $name (timeout)"
    return 1
  fi

  wait $pid
  local exit_code=$?

  if [ $exit_code -eq 0 ]; then
    log_pass "[$shell] $name"
    return 0
  else
    log_fail "[$shell] $name"
    echo "    Exit: $exit_code"
    return 1
  fi
}

# ============================================================================
# TEST SUITES
# ============================================================================

test_loading() {
  local shell="$1"
  echo ""
  log_info "Testing script loading in $shell..."

  run_test "$shell" "common.sh loads" \
    "source $LIB_DIR/common.sh" 3

  run_test "$shell" "issue-utils.sh loads" \
    "source $LIB_DIR/issue-utils.sh" 3

  run_test "$shell" "git-utils.sh loads" \
    "source $LIB_DIR/git-utils.sh" 3

  run_test "$shell" "task-docs-utils.sh loads" \
    "source $LIB_DIR/task-docs-utils.sh" 3

  run_test "$shell" "template-utils.sh loads" \
    "source $LIB_DIR/template-utils.sh" 3

  run_test "$shell" "todo-utils.sh loads" \
    "source $LIB_DIR/todo-utils.sh" 3
}

test_common_functions() {
  local shell="$1"
  echo ""
  log_info "Testing common.sh functions in $shell..."

  run_test "$shell" "is_empty" \
    "source $LIB_DIR/common.sh && is_empty ''" 2

  run_test "$shell" "is_not_empty" \
    "source $LIB_DIR/common.sh && is_not_empty 'x'" 2

  run_test "$shell" "trim" \
    "source $LIB_DIR/common.sh && [[ \$(trim '  hi  ') == 'hi' ]]" 2

  run_test "$shell" "regex_extract" \
    "source $LIB_DIR/common.sh && [[ \$(regex_extract 'AB-123' '[A-Z]+-[0-9]+') == 'AB-123' ]]" 2

  run_test "$shell" "CURRENT_SHELL set" \
    "source $LIB_DIR/common.sh && [[ -n \$CURRENT_SHELL ]]" 2
}

test_issue_functions() {
  local shell="$1"
  echo ""
  log_info "Testing issue-utils.sh functions in $shell..."

  run_test "$shell" "extract_issue_key" \
    "source $LIB_DIR/issue-utils.sh && [[ \$(extract_issue_key 'STAR-1234-x') == 'STAR-1234' ]]" 2

  run_test "$shell" "get_issue_prefix" \
    "source $LIB_DIR/issue-utils.sh && [[ \$(get_issue_prefix 'AB-99') == 'AB' ]]" 2

  run_test "$shell" "get_issue_number" \
    "source $LIB_DIR/issue-utils.sh && [[ \$(get_issue_number 'AB-99') == '99' ]]" 2

  run_test "$shell" "generate_slug" \
    "source $LIB_DIR/issue-utils.sh && [[ \$(generate_slug 'Hi There') == 'Hi-There' ]]" 2
}

test_template_functions() {
  local shell="$1"
  echo ""
  log_info "Testing template-utils.sh functions in $shell..."

  # Create temp file
  local tmpfile="/tmp/test-tpl-$$.md"
  echo 'Hi ${X}!' > "$tmpfile"

  run_test "$shell" "render_template_stdout" \
    "source $LIB_DIR/template-utils.sh && [[ \$(render_template_stdout $tmpfile 'X=World') == 'Hi World!' ]]" 3

  rm -f "$tmpfile"
}

# ============================================================================
# MAIN
# ============================================================================

main() {
  local target="${1:-all}"

  echo "=============================================="
  echo "  Shell Compatibility Test Suite"
  echo "=============================================="

  local shells
  if [[ "$target" == "all" ]]; then
    shells=("bash" "zsh")
  else
    shells=("$target")
  fi

  for shell in "${shells[@]}"; do
    if ! command -v "$shell" >/dev/null 2>&1; then
      echo "Error: $shell not found"
      exit 1
    fi
    echo "Testing: $shell ($($shell --version 2>&1 | head -1))"
  done

  for shell in "${shells[@]}"; do
    echo ""
    echo "=============================================="
    echo "  $shell"
    echo "=============================================="

    test_loading "$shell"
    test_common_functions "$shell"
    test_issue_functions "$shell"
    test_template_functions "$shell"
  done

  echo ""
  echo "=============================================="
  echo "  Summary"
  echo "=============================================="
  echo -e "  ${GREEN}Passed:${NC} $PASSED"
  echo -e "  ${RED}Failed:${NC} $FAILED"

  if [[ $FAILED -gt 0 ]]; then
    echo -e "\n${RED}Some tests failed!${NC}"
    exit 1
  else
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
  fi
}

main "$@"
