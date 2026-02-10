---
description: Interactive manual code review with step-by-step approval
---

# Interactive Code Review

**Mode:** Interactive (Manual step-by-step with approvals)
**Use for:** Complex reviews, multi-commit changes, requiring manual control

---

## ⛔ STOP - MANDATORY FIRST ACTION

**YOU MUST CALL TodoWrite RIGHT NOW before reading any other files or running any commands.**

**Do NOT proceed to "Mode" or "Phase 0" until you have called TodoWrite.**

```javascript
TodoWrite({
  todos: [
    {content: "Specification check", status: "in_progress", activeForm: "Checking specification"},
    {content: "Context gathering", status: "pending", activeForm: "Gathering context"},
    {content: "Pre-flight diff intake & risk flags", status: "pending", activeForm: "Running pre-flight"},
    {content: "Requirements compliance", status: "pending", activeForm: "Checking requirements"},
    {content: "Architecture review", status: "pending", activeForm: "Reviewing architecture"},
    {content: "Code quality review", status: "pending", activeForm: "Reviewing code quality"},
    {content: "Testing review", status: "pending", activeForm: "Reviewing tests"},
    {content: "Performance & security review", status: "pending", activeForm: "Reviewing performance/security"},
    {content: "Documentation & deployment check", status: "pending", activeForm: "Checking documentation"},
    {content: "Final summary report", status: "pending", activeForm: "Generating report"}
  ]
})
```

**⛔ DO NOT CONTINUE READING THIS FILE until TodoWrite has been called.**

---

## Mode
READ-ONLY (review phases)

Each step ends with a **STOP** for user approval (Single Step Rule).

---

## Phase 0: Project Context Detection

{{MODULE: ~/.claude/modules/shared/quick-context.md}}

**Severity Levels:** {{MODULE: ~/.claude/modules/code-review/severity-levels.md}}

**Citation Format:** {{MODULE: ~/.claude/modules/code-review/citation-standards.md}}

**Principles:**
- Be fast, respectful, and precise
- Comment on code, not people
- Classify findings by severity
- Each step ends with STOP for user approval

---

## Step 1: Specification Check (STOP)

- If valid Task Spec exists, briefly validate (objective, acceptance criteria, DoD)
- If missing or inadequate, request task specification

**Output:** Approved "Task Spec"
**STOP.**

---

## Step 2: Context Gathering (STOP)

{{MODULE: ~/.claude/modules/shared/full-context.md}}

**Use "For Code Review Mode" section.**

**Output:** Context summary with issue, branch, files
**STOP.**

---

## Step 3: Pre-flight Diff Intake & Risk Flags (STOP)

{{MODULE: ~/.claude/modules/shared/standards-loading.md}}

1. Load standards and cache section headings
2. Compute diff for commit range
3. Summarize changed files by type
4. Flag **risk areas:** DB migrations, shared models, public APIs, performance paths

**Output:** Scope Digest with risk flags
**STOP.**

---

## Step 4: Requirements Compliance (STOP)

{{MODULE: ~/.claude/modules/code-review/correctness-review.md}}

**Focus on:** Requirements Verification section (if task docs available)

**Output:** AC matrix + comments (BLOCKER/MAJOR/MINOR)
**STOP.**

---

## Step 5: Architecture Review (STOP)

{{MODULE: ~/.claude/modules/code-review/architecture-review.md}}

**Output:** Architecture findings by severity
**STOP.**

---

## Step 6: Code Quality Review (STOP)

{{MODULE: ~/.claude/modules/code-review/code-quality-review.md}}

**Output:** Quality findings by severity
**STOP.**

---

## Step 7: Testing Review (STOP)

{{MODULE: ~/.claude/modules/code-review/test-review.md}}

**Output:** Test results + coverage findings
**STOP.**

---

## Step 8: Performance & Security (STOP)

{{MODULE: ~/.claude/modules/code-review/performance-security.md}}

**Output:** Performance & security findings by severity
**STOP.**

---

## Step 9: Documentation & Deployment (STOP)

**Documentation checks:**
- [ ] Task docs aligned with implementation
- [ ] YouTrack references accurate
- [ ] Code comments sufficient (when non-obvious)
- [ ] Breaking changes documented
- [ ] Environment variables documented

**Deployment checks:**
- [ ] Migration rollback tested
- [ ] Feature flags considered for risky changes
- [ ] Cache clearing requirements noted
- [ ] Queue worker restart requirements noted

**Output:** Documentation findings
**STOP.**

---

## Step 10: Final Summary Report

{{MODULE: ~/.claude/modules/code-review/generate-report.md}}

---

**End of Interactive Review**

Use `/code-review-g` to return to mode selection.
