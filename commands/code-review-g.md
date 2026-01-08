---
description: Code review - multi-mode with interactive/quick/report/external (global)
---

# Code Review

I'll help you review code changes using project-specific standards and test commands.

**Workflow Documentation**: `~/.claude/workflows/code-review/`

---

## YOUR FIRST RESPONSE MUST INCLUDE THESE TWO TOOL CALLS:

1. **TodoWrite** - Create a todo list with 3 items:
   - "Detect context (run detect-mode.sh)" status=in_progress activeForm="Detecting context"
   - "Select review mode" status=pending activeForm="Selecting review mode"
   - "Execute selected review workflow" status=pending activeForm="Executing review workflow"

2. **Bash** - Run: `~/.claude/lib/detect-mode.sh --pretty`

**CALL BOTH TOOLS NOW. Do not read any other files first. Do not run git commands directly.**

---

## After Detection Script Runs

Update the todo list:
- First item → completed
- Second item → in_progress

Present the detected context as a table.

---

### Step 2: Select Review Mode

**MANDATORY: Use AskUserQuestion to present ALL 5 options:**

```javascript
AskUserQuestion({
  questions: [{
    question: "Which code review mode do you need?",
    header: "Review Mode",
    multiSelect: false,
    options: [
      {label: "Report Review (Recommended)", description: "Comprehensive automated review with detailed report. Best for feature branches."},
      {label: "Bug Zapper", description: "Hunt for actual bugs - traces dependencies, verifies existence, finds type mismatches. Not about style."},
      {label: "Quick Review", description: "Fast checklist for small PRs (<500 lines). Checks critical issues and runs modified tests."},
      {label: "Interactive Review", description: "Manual step-by-step with STOP points. Best for complex changes."},
      {label: "External Review Evaluation", description: "Evaluate external review against project standards."}
    ]
  }]
})
```

Mark todo as completed: "Select review mode"

---

### Step 3: Execute Selected Mode

**After reading the workflow file, your FIRST action must be to call TodoWrite with the workflow's todo list (shown at top of file). Then follow the workflow steps.**

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

#### Bug Zapper
**Workflow:** `~/.claude/workflows/code-review/bug-zapper.md`

**Modules used:**
- `shared/quick-context.md` - Quick context detection
- `bugs-review.md` - Bug hunting patterns

**Focus areas:**
- Dependency chain tracing (up and down)
- Existence verification (classes, methods, properties)
- Type mismatch detection
- Null safety analysis
- Logic error detection
- Copy-paste bug detection

**NOT about:** Architecture, style, standards, requirements

**Best for:** Finding actual bugs before they crash in production

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
      ├── workflows/code-review/bug-zapper.md    <- Bug hunting mode
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
              ├── modules/code-review/bugs-review.md           <- Bug detection patterns
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

| Mode | Automated | Focus | Output |
|------|-----------|-------|--------|
| Report | Yes | Everything | Comprehensive report |
| Bug Zapper | Yes | Actual bugs only | Bug list with fixes |
| Quick | Yes | Critical issues | Pass/Fail report |
| Interactive | Manual | Everything | Step-by-step findings |
| External | Yes | Evaluating feedback | Accept/Reject analysis |

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
