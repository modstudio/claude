# In Progress Mode - Reconciliation Skill

**Purpose:** Sync documentation with implementation reality

**When to use:** Code exists, docs may be out of sync, need to reconcile

---

## ⛔ STOP - MANDATORY FIRST ACTION

**YOU MUST CALL TodoWrite RIGHT NOW before reading any other files or running any commands.**

**Do NOT proceed to "Phase 0" until you have called TodoWrite.**

```javascript
TodoWrite({
  todos: [
    {content: "Gather implementation state", status: "in_progress", activeForm: "Gathering state"},
    {content: "Verify/create task docs structure", status: "pending", activeForm: "Verifying docs structure"},
    {content: "Read existing documentation", status: "pending", activeForm: "Reading docs"},
    {content: "Compare and identify discrepancies", status: "pending", activeForm: "Comparing"},
    {content: "Present findings to user", status: "pending", activeForm: "Presenting findings"},
    {content: "Update docs with user confirmation", status: "pending", activeForm: "Syncing docs"},
    {content: "Present updated state", status: "pending", activeForm: "Presenting result"}
  ]
})
```

**⛔ DO NOT CONTINUE READING THIS FILE until TodoWrite has been called.**

---

## Phase 0: Project Context

{{MODULE: ~/.claude/modules/docs/project-variables.md}}

{{MODULE: ~/.claude/modules/shared/todo-patterns.md}}

---

## Skill Overview

```
1. gather-implementation-state → commits, changed files, git state
2. ensure-docs-structure → verify/create all docs exist
3. read-existing-docs → current documentation state
4. compare-and-sync → identify discrepancies
5. present-findings → show user what's misaligned
6. update-docs → sync docs with reality (user confirms)
7. present-updated-state → final reconciled state
```

**Key difference from Default Mode:**
- Default: Plan → then implement
- In-Progress: Already implemented → sync docs with reality

---

## When to Use This Mode

### Entry Criteria (suggests In Progress mode)
- Branch has commits ahead of base branch
- Uncommitted changes present
- User says "sync", "reconcile", "update docs", "where am I?"
- Code was written without documentation
- Returning after extended break

### Use Default Mode Instead When
- Starting a new task (no code yet)
- Planning before implementation
- Issue exists but work hasn't started
- Need to create task documentation from scratch

### Comparison Matrix

| Aspect | Default Mode | In Progress Mode |
|--------|--------------|------------------|
| **Starting point** | Issue/idea | Existing code |
| **Goal** | Create plan → implement | Sync docs with implementation |
| **Primary action** | Research → plan → approve → build | Gather → compare → reconcile |
| **User confirmation** | Approve plan before coding | Confirm discrepancies before sync |
| **Output** | New documentation + code | Updated documentation |

---

## Mode Rules

| Phase | Mode | Steps |
|-------|------|-------|
| 1-4 | READ-ONLY | Gather state, read docs, compare, present |
| 5-6 | WRITE-ENABLED | Update docs (after user confirms) |

---

## Step 1: Gather Implementation State

{{MODULE: ~/.claude/modules/task-planning/gather-implementation-state.md}}

**Gather:**
- Current branch name
- Issue key (from branch or ask user)
- Commits on branch (vs base branch)
- Changed files summary
- Staged/unstaged changes
- Uncommitted work

**Output:** `IMPLEMENTATION_STATE` summary

---

## Step 2: Verify/Create Docs Structure

**MANDATORY: Ensure complete docs structure exists before reading**

{{MODULE: ~/.claude/modules/task-planning/ensure-docs-structure.md}}

---

## Step 3: Read Existing Docs

{{MODULE: ~/.claude/modules/task-planning/resume-existing-task.md}}

**Output:** `DOCS_STATE` summary

---

## Step 4: Compare and Sync

{{MODULE: ~/.claude/modules/task-planning/compare-and-sync.md}}

**Compare:**
- Implementation vs `03-implementation-plan.md`
- Code vs `02-functional-requirements.md`
- Current state vs `00-status.md`
- Completed work vs `04-todo.md`

**Identify discrepancies:**
- Code changes not in docs
- Planned items not implemented
- Status mismatches
- Requirements drift

**Output:** `DISCREPANCIES` list with impact assessment

---

## Step 5: Present Findings

**Present to user:**

```markdown
## Reconciliation Review: {ISSUE_KEY}

### Implementation State
- Branch: {branch}
- Commits: {count} ahead of {base}
- Changed files: {count}

### Documentation State
- Folder: {exists/created}
- Last updated: {date}
- Completeness: {X/6 docs}

### Discrepancies Found

**Code not in docs:**
- {file} - {description}

**Docs not in code:**
- {planned item} - not implemented

**Status mismatch:**
- Docs say: {status}
- Reality: {actual status}

### Questions for You
1. {Question about discrepancy}
2. {Question about intent}
```

---

## Step 6: Update Docs (User Confirms)

{{MODULE: ~/.claude/modules/shared/approval-gate.md}}

{{MODULE: ~/.claude/modules/task-planning/sync-docs-with-implementation.md}}

**After user confirms:**
- Update `00-status.md` with actual status
- Update `03-implementation-plan.md` with actual implementation
- Update `02-functional-requirements.md` with actual features
- Update `04-todo.md` with actual completion state
- Update `logs/decisions.md` with decisions made
- Update `01-task-description.md` (last - for YouTrack sync)

---

## Step 7: Present Updated State

```markdown
## Reconciliation Complete

### What was synced:
- {doc} - {what changed}

### Current accurate state:
- Status: {status}
- Phase: {phase}
- Remaining work: {list}

### Next steps:
1. {next action}
2. {next action}
```

---

## Key Reminders

### This is Reconciliation, Not Planning
- Don't re-plan what's already implemented
- Document what IS, not what SHOULD BE
- Sync docs to match reality

### User Confirmation Required
- Don't update docs without user confirming discrepancies
- Ask about intent for unexpected code
- Clarify what should be kept vs removed

### Standards Check (Optional)
If user wants a code review alongside reconciliation, suggest using the `/code-review-g` command separately.

Primary goal of In Progress mode is doc sync, not code review.

---

## Quick Reference

**Modules used:**
- `task-planning/gather-implementation-state.md`
- `task-planning/ensure-docs-structure.md`
- `task-planning/resume-existing-task.md`
- `task-planning/compare-and-sync.md`
- `task-planning/sync-docs-with-implementation.md`

**Docs location:**
- `${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/`
