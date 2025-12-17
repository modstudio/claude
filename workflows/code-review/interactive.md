---
description: Interactive manual code review with step-by-step approval
---

# Interactive Code Review

**Mode:** Interactive (Manual step-by-step with approvals)
**Use for:** Complex reviews, multi-commit changes, requiring manual control

---

## Phase 0: Project Context

{{MODULE: ~/.claude/modules/phase-0-context.md}}

---

**Severity Levels:** {{MODULE: ~/.claude/modules/severity-levels.md}}

**Citation Format:** {{MODULE: ~/.claude/modules/citation-standards.md}}

**Principles**
- Be fast, respectful, and precise; comment on code, not on people. Explain reasons and guide solutions.
- Classify findings by severity and propose concrete, minimal changes. Prefer auto-fix patches for low-risk items.
- Each step ends with a **STOP** for user approval (Single Step Rule).

---

## 📋 MANDATORY: Initialize Todo List

**IMMEDIATELY after loading context, create a todo list to track review progress:**

```javascript
TodoWrite({
  todos: [
    {content: "Step A: Specification check", status: "in_progress", activeForm: "Checking specification"},
    {content: "Step 0: Inputs, business context & range", status: "pending", activeForm: "Gathering inputs and context"},
    {content: "Step 1: Pre-flight diff intake & risk flags", status: "pending", activeForm: "Running pre-flight checks"},
    {content: "Step 2: Requirements compliance", status: "pending", activeForm: "Checking requirements compliance"},
    {content: "Step 3: Architecture review", status: "pending", activeForm: "Reviewing architecture"},
    {content: "Step 4: Code quality review", status: "pending", activeForm: "Reviewing code quality"},
    {content: "Step 5: Testing review", status: "pending", activeForm: "Reviewing tests"},
    {content: "Step 6: Performance & security review", status: "pending", activeForm: "Reviewing performance & security"},
    {content: "Step 7: Documentation & deployment check", status: "pending", activeForm: "Checking documentation & deployment"},
    {content: "Step 8: Generate final summary report", status: "pending", activeForm: "Generating final report"}
  ]
})
```

**Update todo list as you progress through each step. Mark tasks complete immediately upon finishing.**

---

## Step A — Specification Check (STOP for approval)
- If a valid Task Spec exists, briefly validate it (objective, acceptance criteria, DoD, constraints).
- If missing or inadequate, run `/issue-specification` and obtain approval.
**Output:** Approved "Task Spec".
**STOP.**

---

## Step 0 — Inputs, Business Context & Range (STOP for approval)

### Step 0.1: Issue Key & Branch Discovery
If the branch name is not provided yet, request it — or at least the issue key (STAR-{n}).
If only the issue key is provided:
- Find all commits that contain the issue key.
  - Find a branch that contains the last matching commit.
  - If found, list all commits on that branch (this becomes the commit range to review).

If no commits or branch are found, inform the user and ask how to proceed.

**Terminal helpers (optional):**
```bash
# 0) Set the issue key
KEY='STAR-2163'  # replace with STAR-{n}

# 1) Find commits that contain the issue key (most recent first)
git log --all --grep="$KEY" --oneline | head -n 50

# 2) Take the most recent matching commit (if any)
LAST=$(git log --all --grep="$KEY" -n 1 --pretty=%H)

# 3) List branches that contain that commit
[ -n "$LAST" ] && git branch -a --contains "$LAST" --format="%(refname:short)"

# 4) Pick one of the listed branches (local or remote) and list its commits
BRANCH="<paste-one-from-above>"
[ -n "$BRANCH" ] && git log --oneline --decorate --graph "$BRANCH"

# 5) (Optional) Show only commits on that branch mentioning the issue key
[ -n "$BRANCH" ] && git log --oneline "$BRANCH" --grep="$KEY"
```

### Step 0.2: Load Task Documentation (MANDATORY)

**STOP - Execute this command before continuing:**

```bash
~/.claude/lib/bin/gather-context
```

This outputs all task context including project info, git status, and all task documentation.

**If YouTrack MCP available**, also fetch issue details.

### Step 0.3: Enumerate Change Set

Validate accessibility and enumerate the change set.
**Output:**
- Issue summary and business context
- Commit range
- Short summary of diff scope (files by type: backend/frontend/migrations/configs)
- Relevant business documentation reviewed

**STOP.**

---

## Step 1 — Pre‑flight: Diff Intake & Risk Flags (STOP for approval)
1) Open rule files and cache key headings for citation:
   - `.ai/rules/20-architecture.md`
2) Open the target branch and compute the diff for the provided commit range.
3) Summarize changed files grouped by Backend/Frontend/Shared (added/modified/deleted).
4) Flag potential **risk areas**: DB migrations, shared models/resources, public APIs, global middleware, performance‑sensitive paths, feature flags.

**Terminal helpers (optional):**
```bash
git diff --name-status <first>..<last>
git log --oneline <first>..<last>
```

**Output:** "Scope Digest" with risk flags.
**STOP.**

---

## Step 2 — Requirements Compliance
Verify the code implements the **Acceptance Criteria** from the Spec.
- Build a matrix: *Criterion* ↔ *Evidence in code/tests/manual notes*.
- List missing/partial items.

**Output:** AC matrix + comments (BLOCKER/MAJOR/MINOR/NIT).

**AC Matrix Template**
```md
| Criterion | Evidence (file:lines / tests / manual) | Status |
|-----------|----------------------------------------|--------|
| AC1: ... | `ScheinProduct.php:50-60`, `ScheinProductTest.php:testUomConversion()` | ✅ PASS |
| AC2: ... | Missing test for edge case | ⚠️ PARTIAL |
| AC3: ... | Not implemented | ❌ MISSING |
```

**STOP.**

---

## Step 3 — Architecture Review

Review against `.ai/rules/20-architecture.md` patterns.

**Reference:** {{MODULE: ~/.claude/modules/review-rules.md}}

Apply the following sections from the shared review rules:
- **Backend Architecture Rules** (Models, Services, Handlers, Repositories, Controllers, Migrations)
- **Frontend Architecture Rules** (Components, API Clients, State Management)
- **Vue 3 Readiness Rules** (Composition API, Deprecated APIs, Template Syntax)

**Output:** Findings by severity with file:line references.
**STOP.**

---

## Step 4 — Code Quality Review

Review against `.ai/rules/10-coding-style.md`.

**Reference:** {{MODULE: ~/.claude/modules/review-rules.md}}

Apply the **Code Quality Rules** section (Naming, Typing, Comments, Code Metrics).

**Output:** Findings by severity.
**STOP.**

---

## Step 5 — Testing Review

Review against `.ai/rules/30-testing.md`.

**Reference:** {{MODULE: ~/.claude/modules/review-rules.md}}

Apply the **Test Quality Rules** section (Test Class Structure, Test Quality, Test Coverage).

### Test Execution
Run all modified test files using project test commands:
```bash
${PROJECT_TEST_CMD_UNIT} {test-file}
```

**Output:** Test results + coverage findings by severity.
**STOP.**

---

## Step 6 — Performance & Security
Quick scan for:

### Performance
- N+1 query issues
- Missing indexes (if migrations)
- Large loops/collections
- Unnecessary eager loading

### Security
- SQL injection risks
- XSS vulnerabilities
- CSRF protection
- Authorization checks
- Input validation

**Output:** Findings by severity (focus on BLOCKER/MAJOR).
**STOP.**

---

## Step 7 — Documentation & Deployment
Check:
- Task docs (`$PROJECT_TASK_DOCS_DIR/{ISSUE_KEY}-{slug}/`) aligned with implementation
- YouTrack references accurate
- Breaking changes documented
- Migration rollback tested
- Environment variables documented

**Output:** Documentation findings.
**STOP.**

---

## Step 8 — Final Summary Report

Generate comprehensive report:

### Executive Summary
- **Overall Status:** APPROVE / REQUEST CHANGES / REJECT
- **Blockers:** [count]
- **Major Issues:** [count]
- **Minor Issues:** [count]
- **Tests:** [X/Y passing]

### Findings by Severity

**Format requirement:** All findings MUST include citation to rule reference.

**BLOCKERS:**
1. [Issue] - `file:line` - **Violation:** [ARCH §X.Y] - [Fix required]

**MAJOR:**
1. [Issue] - `file:line` - **Violation:** [STYLE §X.Y] - [Recommendation]

**MINOR:**
1. [Issue] - `file:line` - **Violation:** [TEST §X.Y] - [Suggestion]

**NITS:**
1. [Issue] - `file:line` - [Optional polish (citation optional for nits)]

### Action Plan

**Required Before Merge:**
```bash
# Commands or changes
```

**Recommended:**
- [ ] Change 1
- [ ] Change 2

**Optional:**
- [ ] Improvement 1

### Risk Assessment
- **Overall Risk:** LOW / MEDIUM / HIGH
- **Test Coverage:** [X%]
- **Migration Safety:** Safe / Risky
- **Breaking Changes:** None / Minor / Major

### GitHub-Ready Review Comments

For significant issues that should be posted as PR comments:

#### Inline Code Suggestions
````markdown
**File:** `app/Services/ProductService.php:45-48`

```suggestion
// Improved version
if (!empty($items)) {
    foreach ($items as $item) {
```
````

#### Architectural Issues
```markdown
**Architecture — [Issue Title]** (BLOCKER/MAJOR/MINOR)
Path: `app/Services/ProductService.php:45-60`

**Issue:** [What's wrong]
**Violation:** [ARCH §X.Y]
**Impact:** [Why it matters]
**Fix:** [Concrete solution]
```

#### Test Coverage Gaps
```markdown
**Testing — Missing Coverage** (MAJOR)
Path: `app/Handlers/UpdateProductHandler.php`

**Missing Tests:**
- [ ] `testHandlesEmptyInput()`
- [ ] `testThrowsExceptionOnInvalidData()`

**Violation:** [TEST §2.1]
```

### Final Recommendation
**Decision:** [APPROVE / REQUEST CHANGES / REJECT]

**Reasoning:** [2-3 sentences]

**Next Steps:**
1. [Step 1]
2. [Step 2]

---

**End of Interactive Review**

Use `/code-review` to return to mode selection, or continue with follow-up questions.
