---
description: Code review - multi-mode with interactive/quick/report/external (global)
---

# Code Review

I'll help you review code changes using project-specific standards and test commands.

**Workflow Documentation**: `~/.claude/workflows/code-review/`

---

## Execution Steps

### Step 1: Initialize Progress Tracking

```bash
source ~/.claude/lib/todo-utils.sh
TODOS=$(init_workflow_todos "code_review")
```

Use **TodoWrite** tool with `$TODOS` to track progress.

---

### Step 2: Load Project Context

{{MODULE: ~/.claude/modules/load-project-context.md}}

Provides: `PROJECT_STANDARDS_DIR`, `PROJECT_TEST_CMD_*`, `PROJECT_CITATION_*`, `PROJECT_BASE_BRANCH`, `PROJECT_ISSUE_REGEX`, and MCP tool availability.

---

### Step 3: Extract Issue Key (if applicable)

```bash
source ~/.claude/lib/issue-utils.sh
source ~/.claude/lib/git-utils.sh

ISSUE_KEY=$(extract_issue_key_from_branch "$PROJECT_ISSUE_REGEX")
# Empty if not on feature branch - that's okay
```

---

### Step 4: Select Review Mode

Use **AskUserQuestion** tool:

**Question:** "Which code review mode do you need?"
**Header:** "Review Mode"
**multiSelect:** false

**Options:**
1. Label: "Interactive Review" | Description: "Manual step-by-step with STOP points. Best for complex changes."
2. Label: "Quick Review" | Description: "Fast checklist for small PRs (<500 lines). Checks critical issues and runs modified tests."
3. Label: "Report Review" | Description: "Comprehensive automated review with detailed report. Best for feature branches."
4. Label: "External Review Evaluation" | Description: "Evaluate external review against project standards."

---

### Step 5: Execute Selected Mode

Follow the appropriate workflow based on user selection:

#### Interactive Review
**Workflow:** `~/.claude/workflows/code-review/interactive.md`  
**Process:** Manual step-by-step with user approval at each stage (Steps A, 0-8)  
**Best for:** Complex multi-commit changes, need full control

#### Quick Review
**Workflow:** `~/.claude/workflows/code-review/quick.md`  
**Process:** Automated checklist → run modified tests → pass/fail report  
**Best for:** Small PRs, bug fixes (<500 lines)

**Key operations:**
```bash
LINES=$(git diff --stat "$PROJECT_BASE_BRANCH"...HEAD | tail -1)
FILES=$(git diff --name-only "$PROJECT_BASE_BRANCH"...HEAD)
# Use $PROJECT_TEST_CMD_* for tests
```

#### Report Review
**Workflow:** `~/.claude/workflows/code-review/report.md`  
**Process:** Full context → check standards → run all tests → detailed report  
**Best for:** Feature branches, regular PR reviews

**Report generation (optional):**
```bash
source ~/.claude/lib/template-utils.sh
render_template ~/.claude/templates/code-review/review-report.md \
  ./review-report.md PROJECT_NAME="$PROJECT_NAME" ...
```

#### External Review Evaluation
**Workflow:** `~/.claude/workflows/code-review/external.md`  
**Process:** Parse suggestions → verify against standards → accept/reject with reasoning  
**Best for:** Evaluating AI or developer review feedback

---

## Mode Comparison

| Mode | Automated | Lines Changed | Output |
|------|-----------|---------------|--------|
| Interactive | ❌ Manual | Any | Step-by-step findings |
| Quick | ✅ Yes | <500 | Pass/Fail report |
| Report | ✅ Yes | Any | Comprehensive report |
| External | ✅ Yes | Any | Accept/Reject analysis |

---

## Resources Available

**Standards:** `$PROJECT_STANDARDS_DIR` (cite with `$PROJECT_CITATION_ARCHITECTURE`)  
**Tests:** `$PROJECT_TEST_CMD_ALL` (all), `$PROJECT_TEST_CMD_UNIT` (unit only)  
**Context:** YouTrack issue, knowledge base (`$PROJECT_KB_LOCATION`), `.wip` docs  
**MCP Tools:** Check `PROJECT_*` vars for YouTrack, Laravel Boost, Playwright

---

## Key Reminders

1. Initialize TodoWrite → Load project context → Extract issue key → Select mode → Execute workflow
2. Reference standards from `$PROJECT_STANDARDS_DIR` with proper citations
3. Run tests using `$PROJECT_TEST_CMD_*`  
4. Update TodoWrite progress throughout
5. USE libraries (git-utils, issue-utils, template-utils) for operations

---

Begin: Initialize TodoWrite, load project context, extract issue key, present mode selection.
