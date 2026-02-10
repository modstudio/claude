---
description: Comprehensive code review of all git changes
---

# Full Code Review

Executing comprehensive code review of **ALL git changes** (staged, unstaged, and untracked files).

---

## ⛔ STOP - MANDATORY FIRST ACTION

**YOU MUST CALL TodoWrite RIGHT NOW before reading any other files or running any commands.**

**Do NOT proceed to "Mode" or "Phase 0" until you have called TodoWrite.**

```javascript
TodoWrite({
  todos: [
    {content: "Gather review context (issue, git state, task docs)", status: "in_progress", activeForm: "Gathering context"},
    {content: "Extract requirements from task docs", status: "pending", activeForm: "Extracting requirements"},
    {content: "Auto-fix simple issues (linter, debug statements)", status: "pending", activeForm: "Running auto-fix"},
    {content: "Architecture review", status: "pending", activeForm: "Reviewing architecture"},
    {content: "Correctness & robustness analysis", status: "pending", activeForm: "Analyzing correctness"},
    {content: "Requirements verification", status: "pending", activeForm: "Verifying requirements"},
    {content: "Code quality review", status: "pending", activeForm: "Reviewing code quality"},
    {content: "Laravel standards check", status: "pending", activeForm: "Checking Laravel standards"},
    {content: "Test coverage verification", status: "pending", activeForm: "Verifying test coverage"},
    {content: "Test execution", status: "pending", activeForm: "Executing tests"},
    {content: "Generate report", status: "pending", activeForm: "Generating report"}
  ]
})
```

**⛔ DO NOT CONTINUE READING THIS FILE until TodoWrite has been called.**

---

## Mode
READ-ONLY (review phases) WRITE-ENABLED (auto-fix phase only)

---

## Phase 0: Project Context Detection

{{MODULE: ~/.claude/modules/shared/quick-context.md}}

**Severity Levels:** {{MODULE: ~/.claude/modules/code-review/severity-levels.md}}

**Citation Format:** {{MODULE: ~/.claude/modules/code-review/citation-standards.md}}

---

## Step 1: Gather Review Context

{{MODULE: ~/.claude/modules/shared/full-context.md}}

**Use "For Code Review Mode" section.**

**Mark todo complete when done.**

---

## Step 2: Auto-Fix Phase

{{MODULE: ~/.claude/modules/code-review/auto-fix-phase.md}}

**Mark todo complete when done.**

---

## Step 3: Architecture Review

{{MODULE: ~/.claude/modules/code-review/architecture-review.md}}

**Mark todo complete when done.**

---

## Step 4: Correctness & Robustness

{{MODULE: ~/.claude/modules/code-review/correctness-review.md}}

**Mark todo complete when done.**

---

## Step 5: Code Quality

{{MODULE: ~/.claude/modules/code-review/code-quality-review.md}}

**Mark todo complete when done.**

---

## Step 6: Test Review & Execution

{{MODULE: ~/.claude/modules/code-review/test-review.md}}

**Mark todo complete when done.**

---

## Step 7: Generate Report

{{MODULE: ~/.claude/modules/code-review/generate-report.md}}

**Mark todo complete when done.**

---

## Execution Constraints

**You MUST:**
- Load full business context using full-context module (Code Review section)
- Review ALL files (staged, unstaged, AND untracked)
- Auto-fix simple issues before detailed review
- Track all phases with TodoWrite
- Read actual file contents (never assume)
- Run ALL affected tests
- Provide specific line numbers and file paths
- Cite specific standards from `$PROJECT_STANDARDS_DIR`
- Give code examples for issues
- Provide bash commands for fixes

**Auto-Fix Allowed (Step 2 only):**
- Remove debug statements
- Run project linter/fixer
- Fix obvious formatting issues

**You MUST NOT:**
- Make logic or behavioral code changes
- Rename variables or functions
- Add or modify type hints
- Restructure code
- Skip test execution

---

Begin review now.
