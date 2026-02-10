# Context Gathering Strategy

**Module:** Two-phase context gathering approach
**Version:** 1.0.0

## Purpose
Define the two-phase context gathering strategy: light scan for mode detection, full scan for skill execution.

## Scope
DOCS - Reference for: task-planning, update-docs skills

**Problem**: Full context is hundreds of lines, hidden by default, user can't see key findings.

**Solution**: Two-phase context gathering with clear summaries.

---

## Two Phases

### Phase 1: Light Context (Mode Detection)

**Purpose**: Just enough to suggest a planning mode.
**When**: Immediately when `/plan-task` is invoked.
**Duration**: Fast (< 5 seconds)

**Gather only:**
```bash
# 1. Current branch
git branch --show-current

# 2. Issue key (from branch or user input)
# Extract using regex from branch name

# 3. Task folder existence (yes/no, don't read contents)
ls -d "${PROJECT_TASK_DOCS_DIR}/${ISSUE_KEY}"* 2>/dev/null | head -1

# 4. Git state summary (counts only)
git status --porcelain | wc -l        # uncommitted changes count
git rev-list --count develop..HEAD    # commits ahead count

# 5. Branch age (optional)
git log -1 --format=%cr HEAD          # "3 days ago"
```

**Output**: One-line per finding, structured summary:

```markdown
## Quick Scan

| Check | Result |
|-------|--------|
| Branch | `feature/STAR-1234-login-fix` |
| Issue Key | STAR-1234 |
| Task Docs | Found ✓ |
| Uncommitted | 3 files |
| Commits Ahead | 5 |

**Suggested Mode**: Default (planning) / In Progress (reconciliation)
```

**What NOT to do in Phase 1:**
- Don't read file contents
- Don't fetch from YouTrack
- Don't search codebase
- Don't read task docs contents
- Don't run parallel searches

---

### Phase 2: Full Context (After Mode Selection)

**Purpose**: Everything needed to execute the selected mode.
**When**: Only after user confirms the planning mode.
**Duration**: Can take longer, uses parallel research.

**What to gather depends on mode:**

#### Default Mode - Full Context
```markdown
## Full Context Gathering

### From YouTrack (parallel)
- [ ] Issue details (summary, description, type, priority)
- [ ] Related issues (subtasks, links, blocked-by)
- [ ] Custom fields (sprint, assignee, etc.)

### From Task Docs (if exists)
- [ ] Read 00-status.md (current status, blockers)
- [ ] Read 02-functional-requirements.md (requirements)
- [ ] Read logs/decisions.md (decisions made)
- [ ] Check freshness (last modified dates)

### From Codebase (parallel)
- [ ] Search for similar patterns
- [ ] Read related files
- [ ] Check existing tests

### From Project Standards
- [ ] Read relevant .ai/rules files
```

#### In Progress Mode - Full Context
```markdown
## Full Context Gathering

### From Git (parallel)
- [ ] Full diff (develop..HEAD)
- [ ] Commit history with messages
- [ ] Changed files list

### From Task Docs
- [ ] Read ALL documents
- [ ] Compare with git state
- [ ] Identify stale docs

### From YouTrack
- [ ] Current issue state
- [ ] Any updates since last sync
```

#### Default Mode (New Task) - Full Context
```markdown
## Full Context Gathering

### From User (no issue key)
- [ ] Task overview (ask user)
- [ ] Goals and constraints
- [ ] Offer to create YouTrack issue

### From Codebase (parallel)
- [ ] Similar features/patterns
- [ ] Architecture overview
- [ ] Available services/components
```

---

## Context Summary Format

**Always present findings as a structured summary, not raw output.**

### Good: Summary with Key Findings

```markdown
## Context Summary

### Issue: STAR-1234
- **Summary**: Fix login timeout error
- **Type**: Bug | **Priority**: High | **Sprint**: Sprint 23
- **Status**: Open (not started)

### Task Documentation
- **Folder**: `${PROJECT_TASK_DOCS_DIR}/STAR-1234/` ✓ exists
- **Status**: Planning (from 00-status.md)
- **Last Updated**: 2 days ago
- **Completeness**: 4/6 docs exist

### Git State
- **Branch**: `fix/STAR-1234-login-timeout` ✓ exists
- **Commits**: 3 ahead of develop
- **Changes**: 2 uncommitted files

### Key Findings
1. Related issue STAR-1230 may have similar fix
2. Found similar timeout handling in `AuthService.php:142`
3. 2 unresolved questions in requirements doc

### Blockers/Concerns
- None identified

---

**Ready to proceed with [Default Mode]?**
```

### Bad: Raw Output Dump

```markdown
## Context

<details>
<summary>YouTrack Response (847 lines)</summary>
... hundreds of lines of JSON ...
</details>

<details>
<summary>Git Diff (1,203 lines)</summary>
... massive diff output ...
</details>
```

---

## Implementation Guidelines

### 1. Summarize, Don't Dump

```markdown
# Instead of:
Here's the full git diff:
[500 lines of diff]

# Do this:
### Changed Files (12 files)

**Modified:**
- `app/Services/AuthService.php` - Added timeout handling
- `app/Http/Controllers/LoginController.php` - Updated error messages
- `tests/Feature/LoginTest.php` - Added timeout tests

**Created:**
- `app/Exceptions/LoginTimeoutException.php`

<details>
<summary>View full diff</summary>
[diff content here]
</details>
```

### 2. Highlight Key Findings

Always call out:
- Blockers or concerns
- Related/similar code found
- Unresolved questions
- Stale documentation
- Missing required items

### 3. Use Tables for Quick Scanning

```markdown
| Item | Status | Notes |
|------|--------|-------|
| YouTrack Issue | ✓ Found | STAR-1234 |
| Task Docs | ✓ Found | 4/6 docs |
| Git Branch | ✓ Found | 3 commits ahead |
| Related Code | ✓ Found | 2 similar patterns |
| Blockers | ✗ None | - |
```

### 4. Expandable Details for Full Content

Use `<details>` for full content when needed:

```markdown
### Requirements Summary
- User must be able to login within 30 seconds
- Show clear error message on timeout
- Log timeout events for monitoring

<details>
<summary>Full requirements document</summary>

[Full content of 02-functional-requirements.md]

</details>
```

---

## Quick Reference

### Phase 1 (Mode Detection)
- **Time**: < 5 seconds
- **Tools**: git commands only (no file reads)
- **Output**: Quick scan table + suggested mode
- **User action**: Confirm mode

### Phase 2 (Full Context)
- **Time**: As needed
- **Tools**: All read-only tools, parallel where possible
- **Output**: Structured summary with key findings
- **User action**: Review and proceed

### Summary Format
- Tables for status checks
- Bullet points for key findings
- `<details>` for full content
- Always highlight blockers/concerns

---

## Checklist

Before presenting context to user:

- [ ] Is this a summary or a dump?
- [ ] Are key findings highlighted?
- [ ] Can user see important info without expanding?
- [ ] Is full content available if needed?
- [ ] Are blockers/concerns clearly called out?
