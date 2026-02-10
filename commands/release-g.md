---
description: CI/CD release with feature/develop/production levels (global)
---

# Release

I'll help you guide a release through the CI/CD pipeline.

**Skill:** `~/.claude/skills/release/main.md`

---

## Execution Steps

### Step 1: Initialize Progress Tracking (MUST DO FIRST)

**Create todo list with ALL steps before doing anything else:**

```javascript
TodoWrite({
  todos: [
    {content: "Detect context (issue key, branch, git state)", status: "pending", activeForm: "Detecting context"},
    {content: "Select release level and CI mode", status: "pending", activeForm: "Selecting options"},
    {content: "Execute release skill", status: "pending", activeForm: "Executing release skill"}
  ]
})
```

**Mark each todo as in_progress when starting, completed when done.**

---

### Step 2: Detect Context

Mark todo as in_progress: "Detect context"

```bash
~/.claude/lib/bin/detect-mode
```

Provides issue key and git state.

Mark todo as completed: "Detect context"

---

### Step 3: Select Release Level and CI Mode

Mark todo as in_progress: "Select release level and CI mode"

**MANDATORY: You MUST use the AskUserQuestion tool to present BOTH questions below.**
**Do NOT auto-select options. ALWAYS ask the user.**

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Which release level do you want to execute?",
      header: "Release Level",
      multiSelect: false,
      options: [
        {label: "Feature + Develop (Recommended)", description: "Merge to develop, verify staging. Standard feature completion."},
        {label: "Feature Branch Only", description: "Push feature and verify tests. Early validation."},
        {label: "Full Release (Production)", description: "Complete release with production deployment."}
      ]
    },
    {
      question: "How should CI/CD be handled?",
      header: "CI Mode",
      multiSelect: false,
      options: [
        {label: "Monitor CI (Recommended)", description: "Wait for CI to complete and verify success at each stage."},
        {label: "Quick (No Wait)", description: "Push/merge and continue without waiting for CI. Faster but no verification."}
      ]
    }
  ]
})
```

**ALL OPTIONS MUST BE PRESENTED FOR BOTH QUESTIONS. Never skip this step.**

Store CI selection as `CI_MODE` ("quick" or "monitor").

Mark todo as completed: "Select release level and CI mode"

---

### Step 4: Execute Release Skill

Mark todo as in_progress: "Execute release skill"

Follow: `~/.claude/skills/release/main.md`

**Levels based on selection:**
- **Feature Only:** Level 1
- **Feature + Develop:** Levels 1-2
- **Full Release:** Levels 1-3

**Process:**
- Run tests: `$PROJECT_TEST_CMD_ALL`
- Verify CI/CD: `gh pr checks`
- Merge to `$PROJECT_BASE_BRANCH`
- Tag for production (Level 3)
- Update YouTrack (optional)

---

## Code Style: Run Fixer Before Release

**ALWAYS run auto-fixer on branch files before releasing:**

```bash
# PHP projects - fix all files changed in this branch
git diff --name-only $PROJECT_BASE_BRANCH...HEAD -- '*.php' | xargs -I {} php-cs-fixer fix {}
```

**Pre-release flow:**
1. **Run fixer on all changed PHP files** before pushing
2. Commit fixer changes (separate "style fix" commit or amend)
3. Push and proceed with release
4. If CI still fails on pre-existing issues → continue release, document

| Issue Type | Action |
|------------|--------|
| **Style issues in our files** | ✅ Run fixer first |
| **Pre-existing issues fixer can't resolve** | ⚠️ Document, continue release |
| **Functional test failures** | ❌ MUST fix - cannot release broken code |

**When to use `--no-verify`:**
- Pre-existing issues that fixer couldn't resolve
- Document in PR: "CI style failures are pre-existing, not from this branch"

**Never:** Delay release for fixable style issues - run fixer instead.

---

## Key Reminders

1. **FIRST:** Create TodoWrite with all 3 steps (this enforces the skill order)
2. **Follow todos in order** - mark in_progress → completed for each
3. **Both questions (level + CI mode) asked together** - cannot skip either
4. CI quality failures: only fix code we actually changed (see above)

---

Begin: **Create TodoWrite with all 3 steps**, then execute each step in order.
