---
description: Quick code review checklist for small changes
---

# Quick Code Review

Running fast checklist review for small changes. This review focuses on critical issues only.

**Use for:** Small PRs, bug fixes, minor refactors (<500 lines)

---

## ⛔ STOP - MANDATORY FIRST ACTION

**YOU MUST CALL TodoWrite RIGHT NOW before reading any other files or running any commands.**

**Do NOT proceed to "Mode" or "Phase 0" until you have called TodoWrite.**

```javascript
TodoWrite({
  todos: [
    {content: "Check scope (decide quick vs full)", status: "in_progress", activeForm: "Checking scope"},
    {content: "Check critical files", status: "pending", activeForm: "Checking critical files"},
    {content: "Run auto-fix phase", status: "pending", activeForm: "Running auto-fix"},
    {content: "Verify and run tests", status: "pending", activeForm: "Running tests"},
    {content: "Generate quick report", status: "pending", activeForm: "Generating report"}
  ]
})
```

**⛔ DO NOT CONTINUE READING THIS FILE until TodoWrite has been called.**

---

## Mode
READ-ONLY (review) + WRITE-ENABLED (auto-fix only)

---

## Phase 0: Project Context Detection

{{MODULE: ~/.claude/modules/shared/quick-context.md}}

**Severity Levels:** {{MODULE: ~/.claude/modules/code-review/severity-levels.md}}

**Citation Format:** {{MODULE: ~/.claude/modules/code-review/citation-standards.md}}

---

## Step 1: Scope Check

```bash
git status --short
git diff ${PROJECT_BASE_BRANCH} --stat
```

**Record:**
- Files changed: _____
- Lines +/-: _____
- Type: [Backend/Frontend/Both/Migrations/Tests]

**Decision:**
- If >500 lines changed → Switch to **Report Review**
- If complex architectural changes → Switch to **Report Review**
- Otherwise → Continue with Quick Review

---

## Step 2: Critical File Checks

{{MODULE: ~/.claude/modules/code-review/critical-checks.md}}

**Apply relevant sections based on files changed.**

---

## Step 3: Auto-Fix Phase

{{MODULE: ~/.claude/modules/code-review/auto-fix-phase.md}}

---

## Step 4: Test Verification & Execution

{{MODULE: ~/.claude/modules/code-review/test-review.md}}

**For quick review, focus on:**
- Test execution only (skip detailed quality review)
- Verify all tests pass
- Note any missing tests for new code

---

## Step 5: Generate Quick Report

{{MODULE: ~/.claude/modules/code-review/generate-report.md}}

**For quick review, output simplified version:**

```markdown
## Quick Review Status

**Overall:** [PASS / NEEDS WORK / FAIL]

### Scope
- Files changed: [count]
- Lines +/-: [added/removed]
- Tests: [X/Y passing]

### Auto-Fixed
- Linter fixes: [count]
- Debug statements removed: [count]

### Critical Issues
[List or "None found"]

### Major Issues
[List or "None found"]

### Quick Wins (Optional)
- [ ] [Optional improvement]

### Final Decision
**Recommendation:** [APPROVE / FIX REQUIRED / REJECT]
**Justification:** [One sentence]
```

---

## Constraints

**This quick review checks:**
- Critical file issues (via critical-checks module)
- Forbidden code patterns
- Test execution
- Basic standards compliance

**This quick review DOES NOT check:**
- Full architecture compliance
- Detailed code quality
- Complex business logic validation
- Performance optimization

**For comprehensive review, use:** Report Review mode

---

Begin quick review now.
