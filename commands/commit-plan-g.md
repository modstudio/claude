---
description: Create focused commit plan with clear messages (global)
---

# Commit Planning

I'll help you create a focused commit plan with clear, structured commit messages.

**Workflow:** `~/.claude/workflows/commit-planning/main.md`

---

## Execution Steps

### Step 1: Initialize Progress Tracking (MUST DO FIRST)

**Create todo list with all steps before doing anything else:**

```javascript
TodoWrite({
  todos: [
    {content: "Detect context (issue key, branch, git state)", status: "pending", activeForm: "Detecting context"},
    {content: "Analyze changes and group by logical units", status: "pending", activeForm: "Analyzing changes"},
    {content: "Generate commit messages per standards", status: "pending", activeForm: "Generating commit messages"},
    {content: "Present commit plan for approval", status: "pending", activeForm: "Presenting commit plan"},
    {content: "Execute commits (after approval only)", status: "pending", activeForm: "Executing commits"}
  ]
})
```

**Mark each todo as in_progress when starting, completed when done.**

---

### Step 2: Detect Context

Mark todo as in_progress: "Detect context (issue key, branch, git state)"

```bash
~/.claude/lib/bin/detect-mode
```

Provides issue key, branch name, commits ahead, uncommitted changes.

Mark todo as completed: "Detect context (issue key, branch, git state)"

---

### Step 3: Analyze Changes

Mark todo as in_progress: "Analyze changes and group by logical units"

**Gather all changes:**
```bash
git status --porcelain
git diff --stat
git diff --cached --stat  # Staged changes
```

**Group by logical units:**
- Related file changes go together
- Single responsibility per commit
- Order commits logically (dependencies first)

Mark todo as completed: "Analyze changes and group by logical units"

---

### Step 4: Generate Commit Messages

Mark todo as in_progress: "Generate commit messages per standards"

Follow: `~/.claude/workflows/commit-planning/main.md`

**For each commit unit:**
1. Create message following `$PROJECT_STANDARDS_DIR` format
2. Include `$ISSUE_KEY` in message
3. Scope to single logical change

Mark todo as completed: "Generate commit messages per standards"

---

### Step 5: Present Commit Plan

Mark todo as in_progress: "Present commit plan for approval"

Present to user:
- List of commits in order
- Files included in each commit
- Commit messages

**Wait for user approval before proceeding.**

Mark todo as completed: "Present commit plan for approval"

---

### Step 6: Execute Commits

Mark todo as in_progress: "Execute commits (after approval only)"

**Only after approval:**
- Stage files for each commit
- Execute commits in order
- Verify each commit succeeds

Mark todo as completed: "Execute commits (after approval only)"

---

## Code Style: Run Fixer Before Commit

**ALWAYS run auto-fixer on files before committing:**

```bash
# PHP projects - fix files being committed
php-cs-fixer fix path/to/file.php

# Then stage the fixed files
git add path/to/file.php
```

**Per-commit flow:**
1. **Run fixer on all files in this commit** (before staging)
2. Review fixer changes (ensure no breaking changes)
3. Stage files and commit
4. If GrumPHP still fails on pre-existing issues → use `--no-verify`

| Code Location | Action |
|---------------|--------|
| **Files in this commit** | ✅ Run fixer, stage fixes |
| **Pre-existing issues fixer can't resolve** | ⚠️ Use `--no-verify` + document |
| **Files not in this commit** | ❌ Don't touch |

**When to use `--no-verify`:**
- Pre-existing issues that fixer couldn't resolve
- Legacy code requiring refactoring (not our scope)
- Document in commit message: "Note: --no-verify due to pre-existing [issue]"

**Never:** Commit without running fixer first.

---

## Key Requirements

- ✅ **Default to MULTIPLE commits** for any non-trivial work
- ✅ Include issue key in all messages
- ✅ Each commit's code must pass quality checks (for lines in that commit)
- ❌ NEVER recommend a single commit for features/refactors
- ❌ NEVER justify single commit with "changes are interdependent" (releases are atomic anyway)
- ❌ NEVER include AI attribution
- ❌ DO NOT COMMIT until approved
- ❌ DO NOT skip steps - follow the todo list

**Single commits are ONLY for:** simple bug fixes, typos, minor config tweaks.

---

Begin: **Create TodoWrite with all 5 steps**, then execute each step in order.
