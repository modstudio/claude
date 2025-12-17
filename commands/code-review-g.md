---
description: Code review - multi-mode with interactive/quick/report/external (global)
---

# Code Review

I'll help you review code changes using project-specific standards and test commands.

**Workflow Documentation**: `~/.claude/workflows/code-review/`

---

## Execution Steps

### Step 1: Initialize Progress Tracking (MUST DO FIRST)

**Create todo list with ALL steps before doing anything else:**

```javascript
TodoWrite({
  todos: [
    {content: "Detect context (issue key, branch, git state)", status: "pending", activeForm: "Detecting context"},
    {content: "Select review mode", status: "pending", activeForm: "Selecting review mode"},
    {content: "Execute selected review workflow", status: "pending", activeForm: "Executing review workflow"}
  ]
})
```

**Mark each todo as in_progress when starting, completed when done.**

---

### Step 2: Detect Context

Mark todo as in_progress: "Detect context"

Run quick context detection:

```bash
~/.claude/lib/bin/detect-mode --json
```

This provides issue key (if on feature branch) and current git state.

Mark todo as completed: "Detect context"

---

### Step 3: Select Review Mode

Mark todo as in_progress: "Select review mode"

**MANDATORY: You MUST use the AskUserQuestion tool to present ALL 4 options below.**
**Do NOT auto-select a mode. Do NOT skip this step. ALWAYS ask the user.**

```javascript
AskUserQuestion({
  questions: [{
    question: "Which code review mode do you need?",
    header: "Review Mode",
    multiSelect: false,
    options: [
      {label: "Report Review (Recommended)", description: "Comprehensive automated review with detailed report. Best for feature branches."},
      {label: "Quick Review", description: "Fast checklist for small PRs (<500 lines). Checks critical issues and runs modified tests."},
      {label: "Interactive Review", description: "Manual step-by-step with STOP points. Best for complex changes."},
      {label: "External Review Evaluation", description: "Evaluate external review against project standards."}
    ]
  }]
})
```

**ALL 4 OPTIONS MUST BE PRESENTED. Never omit any option.**

Mark todo as completed: "Select review mode"

---

### Step 4: Execute Selected Mode

Mark todo as in_progress: "Execute selected review workflow"

Follow the appropriate workflow based on user selection:

#### Report Review (Recommended)
**Workflow:** `~/.claude/workflows/code-review/report.md`
**Process:** Full context → check standards → run all tests → detailed report
**Best for:** Feature branches, regular PR reviews

**Report generation (optional):**
```bash
source ~/.claude/lib/template-utils.sh
render_template ~/.claude/templates/code-review/review-report.md \
  ./review-report.md PROJECT_NAME="$PROJECT_NAME" ...
```

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

#### Interactive Review
**Workflow:** `~/.claude/workflows/code-review/interactive.md`
**Process:** Manual step-by-step with user approval at each stage (Steps A, 0-8)
**Best for:** Complex multi-commit changes, need full control

#### External Review Evaluation
**Workflow:** `~/.claude/workflows/code-review/external.md`
**Process:** Parse suggestions → verify against standards → accept/reject with reasoning
**Best for:** Evaluating AI or developer review feedback

---

## Mode Comparison

| Mode | Automated | Lines Changed | Output |
|------|-----------|---------------|--------|
| Report | ✅ Yes | Any | Comprehensive report |
| Quick | ✅ Yes | <500 | Pass/Fail report |
| Interactive | ❌ Manual | Any | Step-by-step findings |
| External | ✅ Yes | Any | Accept/Reject analysis |

---

## Resources Available

**Standards:** `$PROJECT_STANDARDS_DIR` (cite with `$PROJECT_CITATION_ARCHITECTURE`)  
**Tests:** `$PROJECT_TEST_CMD_ALL` (all), `$PROJECT_TEST_CMD_UNIT` (unit only)  
**Context:** YouTrack issue, knowledge base (`$PROJECT_KB_DIR`), task docs (`$PROJECT_TASK_DOCS_DIR`)  
**MCP Tools:** Check `PROJECT_*` vars for YouTrack, Laravel Boost, Playwright

---

## Code Style: Run Fixer Before Review

**ALWAYS run auto-fixer on changed files before reviewing code style:**

```bash
# PHP projects - fix all changed files
git diff --name-only $PROJECT_BASE_BRANCH...HEAD -- '*.php' | xargs -I {} php-cs-fixer fix {}
```

**Review flow:**
1. **Run fixer on all changed PHP files first**
2. Stage and commit fixer changes (separate "style fix" commit)
3. Then proceed with code review
4. Only report style issues that fixer couldn't resolve

| Code Location | Action |
|---------------|--------|
| **Files we changed** | ✅ Run fixer first, then review |
| **Pre-existing issues fixer can't resolve** | ⚠️ Note in review, don't block |
| **Files we didn't change** | ❌ Ignore |

**Never:** Report fixable code style issues without running fixer first.

---

## Key Reminders

1. **FIRST:** Create TodoWrite with all steps (this enforces the workflow order)
2. **Follow todos in order** - mark in_progress → completed for each
3. **Context loading happens in the workflow** - each mode loads only what it needs
4. Reference standards from `$PROJECT_STANDARDS_DIR` with proper citations
5. Run tests using `$PROJECT_TEST_CMD_*`
6. CI quality failures: only fix code we actually changed (see above)

---

Begin: **Create TodoWrite with all 3 steps**, then execute each step in order.
