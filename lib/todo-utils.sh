#!/bin/bash
# Standardized TodoWrite patterns and utilities
# Version: 2.0.0

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# ============================================================================
# TODO GENERATION FUNCTIONS
# ============================================================================

# Generate JSON for a single todo item
# Args: content, status (pending/in_progress/completed), active_form
generate_todo_item() {
  local content="$1"
  local status="${2:-pending}"
  local active_form="$3"

  cat <<EOF
{"content": "$content", "status": "$status", "activeForm": "$active_form"}
EOF
}

# Generate JSON array of todos
# Args: todo items (output from generate_todo_item)
generate_todos_json() {
  local items=("$@")
  local json="["

  for i in "${!items[@]}"; do
    json+="${items[$i]}"
    if [[ $i -lt $((${#items[@]} - 1)) ]]; then
      json+=", "
    fi
  done

  json+="]"
  echo "$json"
}

# ============================================================================
# PREDEFINED WORKFLOW TODOS
# ============================================================================

# Get task planning todos (Default Mode)
get_task_planning_todos() {
  local todos=(
    "$(generate_todo_item "Load project context and fetch YouTrack issue" "pending" "Loading context")"
    "$(generate_todo_item "Create task folder and initialize documents" "pending" "Creating task folder")"
    "$(generate_todo_item "Gather requirements and identify questions" "pending" "Gathering requirements")"
    "$(generate_todo_item "Present questions to user for clarification" "pending" "Presenting questions")"
    "$(generate_todo_item "Create technical implementation plan" "pending" "Creating implementation plan")"
    "$(generate_todo_item "Present plan for approval" "pending" "Presenting plan for approval")"
  )

  generate_todos_json "${todos[@]}"
}

# Get code review todos (Report Mode)
get_code_review_todos() {
  local todos=(
    "$(generate_todo_item "Load project context and standards" "pending" "Loading context")"
    "$(generate_todo_item "Analyze all changed files" "pending" "Analyzing changed files")"
    "$(generate_todo_item "Check against architecture standards" "pending" "Checking architecture")"
    "$(generate_todo_item "Verify test coverage" "pending" "Verifying test coverage")"
    "$(generate_todo_item "Run test suite" "pending" "Running tests")"
    "$(generate_todo_item "Generate comprehensive review report" "pending" "Generating report")"
  )

  generate_todos_json "${todos[@]}"
}

# Get release todos (Full Pipeline)
get_release_todos() {
  local todos=(
    "$(generate_todo_item "Verify feature branch tests pass" "pending" "Verifying feature tests")"
    "$(generate_todo_item "Merge to develop and push" "pending" "Merging to develop")"
    "$(generate_todo_item "Verify staging deployment" "pending" "Verifying staging")"
    "$(generate_todo_item "Merge to master and tag release" "pending" "Merging to master")"
    "$(generate_todo_item "Verify production deployment" "pending" "Verifying production")"
  )

  generate_todos_json "${todos[@]}"
}

# Get commit planning todos
get_commit_planning_todos() {
  local todos=(
    "$(generate_todo_item "Extract issue key from branch name" "pending" "Extracting issue key")"
    "$(generate_todo_item "Analyze all changes (staged, unstaged, untracked)" "pending" "Analyzing changes")"
    "$(generate_todo_item "Create logical commit groupings" "pending" "Creating commit groups")"
    "$(generate_todo_item "Generate clear commit messages" "pending" "Generating commit messages")"
    "$(generate_todo_item "Present commit plan for approval" "pending" "Presenting commit plan")"
  )

  generate_todos_json "${todos[@]}"
}

# ============================================================================
# TODO INITIALIZATION
# ============================================================================

# Initialize todos with first item in_progress
# Args: workflow_type (task_planning, code_review, release, commit_planning)
init_workflow_todos() {
  local workflow_type="$1"

  local todos_json
  case "$workflow_type" in
    task_planning)
      todos_json=$(get_task_planning_todos)
      ;;
    code_review)
      todos_json=$(get_code_review_todos)
      ;;
    release)
      todos_json=$(get_release_todos)
      ;;
    commit_planning)
      todos_json=$(get_commit_planning_todos)
      ;;
    *)
      log_error "Unknown workflow type: $workflow_type"
      return 1
      ;;
  esac

  # Set first item to in_progress using jq if available
  if command_exists jq; then
    echo "$todos_json" | jq '.[0].status = "in_progress"'
  else
    # Simple replacement without jq
    echo "$todos_json" | sed 's/"pending"/"in_progress"/' | sed '2,$s/"in_progress"/"pending"/'
  fi
}

# ============================================================================
# TODO MANIPULATION
# ============================================================================

# Mark current todo complete and advance to next
# This is a helper to generate the updated JSON
# Args: current_index (0-based), total_todos
advance_todo() {
  local current_index="$1"
  local workflow_type="$2"

  local todos_json
  case "$workflow_type" in
    task_planning)
      todos_json=$(get_task_planning_todos)
      ;;
    code_review)
      todos_json=$(get_code_review_todos)
      ;;
    release)
      todos_json=$(get_release_todos)
      ;;
    commit_planning)
      todos_json=$(get_commit_planning_todos)
      ;;
    *)
      log_error "Unknown workflow type: $workflow_type"
      return 1
      ;;
  esac

  if command_exists jq; then
    # Use jq for precise manipulation
    echo "$todos_json" | jq \
      --argjson idx "$current_index" \
      --argjson next "$(($current_index + 1))" \
      '.[$ idx].status = "completed" |
       if .[$ next] then .[$ next].status = "in_progress" else . end'
  else
    # Without jq, just return the JSON and let calling code handle it
    echo "$todos_json"
  fi
}

# ============================================================================
# TODO FORMATTING FOR MARKDOWN
# ============================================================================

# Format todos as markdown checklist
# Args: json_todos
format_todos_markdown() {
  local json_todos="$1"

  if command_exists jq; then
    echo "$json_todos" | jq -r '.[] |
      if .status == "completed" then
        "- [x] \(.content)"
      elif .status == "in_progress" then
        "- [ ] **\(.content)** (in progress)"
      else
        "- [ ] \(.content)"
      end'
  else
    # Basic parsing without jq
    echo "$json_todos" | sed 's/{"content": "\([^"]*\)", "status": "completed"[^}]*}/- [x] \1/g' | \
      sed 's/{"content": "\([^"]*\)", "status": "in_progress"[^}]*}/- [ ] **\1** (in progress)/g' | \
      sed 's/{"content": "\([^"]*\)", "status": "pending"[^}]*}/- [ ] \1/g' | \
      grep "^- \["
  fi
}

# ============================================================================
# WORKFLOW-SPECIFIC HELPERS
# ============================================================================

# Get phase-specific todos for task planning
# Args: phase (1-5)
get_task_planning_phase_todos() {
  local phase="$1"

  case "$phase" in
    1)
      # Discovery & Context Gathering
      local todos=(
        "$(generate_todo_item "Fetch issue from YouTrack" "pending" "Fetching issue")"
        "$(generate_todo_item "Check for existing task folder" "pending" "Checking for existing folder")"
        "$(generate_todo_item "Create or update task folder" "pending" "Creating task folder")"
        "$(generate_todo_item "Load project standards" "pending" "Loading standards")"
        "$(generate_todo_item "Search knowledge base for related docs" "pending" "Searching knowledge base")"
      )
      ;;
    2)
      # Requirements Analysis
      local todos=(
        "$(generate_todo_item "Analyze task description" "pending" "Analyzing description")"
        "$(generate_todo_item "Extract acceptance criteria" "pending" "Extracting acceptance criteria")"
        "$(generate_todo_item "Identify uncertainties and questions" "pending" "Identifying questions")"
        "$(generate_todo_item "Draft functional requirements doc" "pending" "Drafting requirements")"
      )
      ;;
    3)
      # Technical Planning
      local todos=(
        "$(generate_todo_item "Design technical approach" "pending" "Designing approach")"
        "$(generate_todo_item "Identify files to create/modify" "pending" "Identifying files")"
        "$(generate_todo_item "Plan database changes" "pending" "Planning database changes")"
        "$(generate_todo_item "Define testing strategy" "pending" "Defining testing strategy")"
        "$(generate_todo_item "Create implementation plan" "pending" "Creating implementation plan")"
      )
      ;;
    4)
      # Review & Approval
      local todos=(
        "$(generate_todo_item "Update status document" "pending" "Updating status")"
        "$(generate_todo_item "Present plan to user" "pending" "Presenting plan")"
        "$(generate_todo_item "Get user approval" "pending" "Getting approval")"
        "$(generate_todo_item "Create git branch" "pending" "Creating branch")"
      )
      ;;
    5)
      # Implementation
      local todos=(
        "$(generate_todo_item "Implement changes step-by-step" "pending" "Implementing changes")"
        "$(generate_todo_item "Write tests" "pending" "Writing tests")"
        "$(generate_todo_item "Run test suite" "pending" "Running tests")"
        "$(generate_todo_item "Update documentation" "pending" "Updating documentation")"
      )
      ;;
    *)
      log_error "Invalid phase: $phase (must be 1-5)"
      return 1
      ;;
  esac

  generate_todos_json "${todos[@]}"
}

# ============================================================================
# INITIALIZATION
# ============================================================================

log_debug "Loaded todo-utils.sh"
