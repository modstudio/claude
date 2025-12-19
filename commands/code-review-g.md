---
description: Code review - multi-mode with interactive/quick/report/external (global)
---

# Code Review

I'll help you review code changes using project-specific standards and test commands.

**Workflow Documentation**: `~/.claude/workflows/code-review/`

---

## Execution Steps

### Step 1: Initialize Progress Tracking

**Create todo list with initial steps:**

```javascript
TodoWrite({
  todos: [
    {content: "Detect context (issue key, branch, git state)", status: "pending", activeForm: "Detecting context"},
    {content: "Select review mode", status: "pending", activeForm: "Selecting review mode"},
    {content: "Execute selected review workflow", status: "pending", activeForm: "Executing review workflow"}
  ]
})
```

---

### Step 2: Detect Context

Mark todo as in_progress: "Detect context"

**Run quick context detection:**

{{MODULE: ~/.claude/modules/shared/quick-context.md}}

This provides issue key (if on feature branch) and current git state.

Mark todo as completed: "Detect context"

---

### Step 3: Select Review Mode

Mark todo as in_progress: "Select review mode"

**MANDATORY: Use AskUserQuestion to present ALL 4 options:**

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

Mark todo as completed: "Select review mode"

---

### Step 4: Execute Selected Mode

Mark todo as in_progress: "Execute selected review workflow"

Follow the appropriate workflow based on user selection:

#### Report Review (Recommended)
**Workflow:** `~/.claude/workflows/code-review/report.md`

**Modules used:**
- `shared/full-context.md` - Context gathering (Code Review Mode)
- `auto-fix-phase.md` - Linter and debug cleanup
- `architecture-review.md` - Architecture compliance
- `correctness-review.md` - Logic and robustness
- `code-quality-review.md` - Style and quality
- `test-review.md` - Test quality and execution
- `generate-report.md` - Final report compilation

**Best for:** Feature branches, regular PR reviews

#### Quick Review
**Workflow:** `~/.claude/workflows/code-review/quick.md`

**Modules used:**
- `critical-checks.md` - Quick checks for critical file types
- `auto-fix-phase.md` - Linter and debug cleanup
- `test-review.md` - Test execution only

**Best for:** Small PRs, bug fixes (<500 lines)

#### Interactive Review
**Workflow:** `~/.claude/workflows/code-review/interactive.md`

**Modules used:**
- All review modules with STOP points between each
- `performance-security.md` - Performance and security checks

**Best for:** Complex multi-commit changes, need full control

#### External Review Evaluation
**Workflow:** `~/.claude/workflows/code-review/external.md`

**Modules used:**
- `shared/full-context.md` - Context gathering (Code Review Mode)
- Standards loading for verification

**Best for:** Evaluating AI or developer review feedback

---

## Module Architecture

```
commands/code-review-g.md (entry point)
  │
  ├── modules/shared/quick-context.md
  │
  └── Select Mode:
      ├── workflows/code-review/report.md
      ├── workflows/code-review/quick.md
      ├── workflows/code-review/interactive.md
      └── workflows/code-review/external.md
          │
          └── Each calls shared modules:
              ├── modules/shared/full-context.md (Code Review Mode)
              ├── modules/code-review/auto-fix-phase.md
              ├── modules/code-review/architecture-review.md
              ├── modules/code-review/correctness-review.md
              ├── modules/code-review/code-quality-review.md
              ├── modules/code-review/test-review.md
              ├── modules/code-review/generate-report.md
              ├── modules/code-review/critical-checks.md
              ├── modules/code-review/performance-security.md
              │
              └── Shared standards:
                  ├── modules/code-review/review-rules.md
                  ├── modules/code-review/severity-levels.md
                  └── modules/code-review/citation-standards.md
```

---

## Mode Comparison

| Mode | Automated | Lines Changed | Output |
|------|-----------|---------------|--------|
| Report | Yes | Any | Comprehensive report |
| Quick | Yes | <500 | Pass/Fail report |
| Interactive | Manual | Any | Step-by-step findings |
| External | Yes | Any | Accept/Reject analysis |

---

## Resources Available

**Standards:** `$PROJECT_STANDARDS_DIR` (cite with `$PROJECT_CITATION_ARCHITECTURE`)
**Tests:** `$PROJECT_TEST_CMD_ALL` (all), `$PROJECT_TEST_CMD_UNIT` (unit only)
**Context:** YouTrack issue, knowledge base, task docs
**MCP Tools:** Check `PROJECT_*` vars for YouTrack, Laravel Boost, Playwright

---

## Code Style: Run Fixer Before Review

**ALWAYS run auto-fixer on changed files before reviewing:**

```bash
# PHP projects
git diff --name-only $PROJECT_BASE_BRANCH...HEAD -- '*.php' | xargs -I {} php-cs-fixer fix {}
```

**Review flow:**
1. Run fixer on all changed files first
2. Stage and commit fixer changes (separate commit)
3. Then proceed with code review
4. Only report style issues fixer couldn't resolve

---

## Key Reminders

1. **FIRST:** Create TodoWrite with all steps
2. **Follow todos in order** - mark in_progress → completed
3. **Context loading happens in the workflow** - each mode loads what it needs
4. Reference standards with proper citations
5. Run tests using project test commands

---

Begin: **Create TodoWrite**, then execute each step in order.
