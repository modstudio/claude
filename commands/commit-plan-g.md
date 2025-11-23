---
description: Create focused commit plan with clear messages (global)
---

# Commit Planning

I'll help you create a focused commit plan with clear, structured commit messages.

**Workflow:** `~/.claude/workflows/commit-planning/main.md`

---

## Execution Steps

### Step 1: Initialize Progress Tracking

```bash
source ~/.claude/lib/todo-utils.sh
TODOS=$(init_workflow_todos "commit_planning")
```

Use **TodoWrite** tool with `$TODOS`.

---

### Step 2: Load Project Context

{{MODULE: ~/.claude/modules/load-project-context.md}}

Provides: `PROJECT_ISSUE_REGEX`, `PROJECT_STANDARDS_DIR` (commit message format).

---

### Step 3: Extract Issue Key

```bash
source ~/.claude/lib/issue-utils.sh
ISSUE_KEY=$(extract_issue_key_from_branch "$PROJECT_ISSUE_REGEX")
```

---

### Step 4: Execute Commit Planning

Follow: `~/.claude/workflows/commit-planning/main.md`

**Process:**
1. Analyze changes: `git status --porcelain`, diffs
2. Group by logical units
3. Generate messages per standards (`$PROJECT_STANDARDS_DIR`)
4. Include `$ISSUE_KEY` in messages
5. Present plan → get approval → execute

---

## Key Requirements

- ✅ Include issue key in all messages
- ❌ NEVER include AI attribution
- ❌ DO NOT COMMIT until approved

---

Begin: Initialize TodoWrite, load context, extract issue key, analyze changes.
