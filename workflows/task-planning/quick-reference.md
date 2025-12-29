# Task Planning Workflow - Quick Reference

**Full Documentation**: See `~/.claude/workflows/task-planning/`

---

## Quick Start

### New Task
```bash
# User provides issue key or uses slash command
/plan-task {ISSUE_KEY}

# Agent will:
# 1. Fetch from YouTrack (get issue summary for slug)
# 2. Check for existing branch: git branch --list "*{ISSUE_KEY}*"
# 3. Check for existing task folder: find ${PROJECT_TASK_DOCS_DIR} -name "{ISSUE_KEY}*"
# 4. Create ${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/ folder (if not exists)
# 5. Read project rules (.ai/rules/)
# 6. Search codebase - populate findings in task docs
# 7. Ask clarifying questions - document in task docs
# 8. Create implementation plan - document in task docs
# 9. Get approval before proceeding

# After approval (WRITE-ENABLED for project code):
# 10. Finalize task docs
# 11. Create git branch and start coding
```

### Resume Existing Task
```bash
# Agent searches ${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}* (glob pattern)
# Uses gather-context.sh to find and read task folder
# Reads 00-status.md for current state
# Presents next actions
```

---

## Document Structure

Every task has these documents in `${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/`:

**Root documents:**
1. **00-status.md** ← Start here (central index)
2. **01-task-description.md** ← Task description (high-level overview)
3. **02-functional-requirements.md** ← Functional requirements (detailed)
4. **03-implementation-plan.md** ← Technical plan
5. **04-todo.md** ← Implementation checklist

**Logs subfolder:**
- **logs/decisions.md** ← Decision log (ADR-style)
- **logs/review.md** ← External review feedback

---

## Workflow Phases

| Phase | Status | Key Actions |
|-------|--------|-------------|
| **1. Discovery** | Planning | Fetch from YouTrack, create docs, search STAR-A docs |
| **2. Requirements** | Planning | Clarify questions, document business rules |
| **3. Planning** | Planning | Create technical plan, document decisions |
| **4. Approval** | Ready for Implementation | Get user approval, create branch |
| **5. Implementation** | In Progress | Code, test, update docs, track progress |
| **6. Completion** | Review → Complete | Code review, merge, deploy |

---

## Status Values

- `Planning` - Gathering requirements
- `Ready for Implementation` - Plan approved, ready to code
- `In Progress` - Active development
- `Blocked` - Waiting on dependency
- `Review` - Code complete, in review
- `Complete` - Merged and deployed

---

## Key Rules

✅ **DO**:
- Always create `${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/` (issue key + slug from YouTrack)
- Always start with `00-status.md`
- Always check for existing branch: `git branch --list "*{ISSUE_KEY}*"`
- Always read relevant .ai/rules documents per phase
- Always search YouTrack docs Table of Contents
- Always ask questions before coding
- Always get approval before creating branch
- Update timestamps (`Last Updated`)
- Document obvious decisions
- Use Docker commands (never host commands)

❌ **DON'T**:
- Don't start implementation without approval
- Don't skip requirements phase
- Don't make assumptions - ask questions
- Don't work directly on develop/main
- Don't use host php/composer/npm commands

---

## Integration Points

### Git Workflow
- Branch creation: Phase 4 (after approval)
- Format: `{type}/{ISSUE_KEY}-{slug}`
- Base: `develop` (or `master` for hotfix)

### TodoWrite Tool
- Used during Phase 5 (implementation)
- Parallel to `04-todo.md` but more granular
- Real-time work-in-progress tracking

### Single Step Rule
- Applies during implementation
- Report → Describe → Ask → Wait

### YouTrack Docs
- Check `storage/app/youtrack_docs/000 Table of Contents.md`
- Reference STAR-A articles in requirements
- Link to specific sections

---

## Common Commands

### Start Planning
```bash
/plan-task {ISSUE_KEY}
```

### Check for Existing Branch
```bash
git branch --list "*{ISSUE_KEY}*"
```

### Search YouTrack Docs
```bash
# Check Table of Contents
cat storage/app/youtrack_docs/000\ Table\ of\ Contents.md

# Search for keywords
grep -i "inventory" storage/app/youtrack_docs/000\ Table\ of\ Contents.md
```

### Check Task Status
```bash
# Agent reads ${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}/00-status.md automatically
```

### Update YouTrack Description
```bash
# After planning complete, use content from:
# ${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}/01-task-description.md
```

---

## Special Cases

### Existing Non-Standard Docs
1. Read all existing docs
2. Offer reorganization options
3. Archive old docs to `${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}/archive/`
4. Create standard structure

### Complex Task with Subtasks
- Document parent task in `${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}/`
- Link to subtasks in `00-status.md`
- Optional: Create `${PROJECT_TASK_DOCS_DIR}/{SUBTASK_KEY}/` for complex subtasks

### Task with Dependencies
- Document in `03-implementation-plan.md` Dependencies section
- Track in `00-status.md` if blocking
- Update status to "Blocked" if needed

---

## Folder Naming

**Standard**: `${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/` (issue key + slug from YouTrack)

✅ Correct:
- `${PROJECT_TASK_DOCS_DIR}/STAR-2228-Warehouse-Queue/`
- `${PROJECT_TASK_DOCS_DIR}/AB-2233-Fix-Login-Error/`

❌ Incorrect:
- `${PROJECT_TASK_DOCS_DIR}/STAR-2228/` (missing slug - no context)
- `${PROJECT_TASK_DOCS_DIR}/technical/STAR-2233/` (wrong nesting)

---

## Templates Location

Templates: `~/.claude/templates/task-planning/`

Contains all 6 document templates ready to copy.

---

## Example Flow

1. User: "Let's work on STAR-2235"
2. Agent: Fetches from YouTrack, creates `${PROJECT_TASK_DOCS_DIR}/STAR-2235/`
3. Agent: "This is a bug fix in authentication. I found these questions..."
4. User: Answers questions
5. Agent: Creates implementation plan, gets approval
6. Agent: Creates branch `fix/STAR-2235-Login-timeout-error`
7. Agent: Implements following single-step rule
8. Agent: Updates status as phases complete
9. Complete: Merge, deploy, mark as Complete

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Can't find YouTrack docs | Check `storage/app/youtrack_docs/000 Table of Contents.md` |
| Existing docs are messy | Offer reorganization, archive old docs |
| Task changed in YouTrack | Update requirements and status, notify user |
| Blocked during implementation | Update status to "Blocked", document blocker |
| User wants to skip planning | Create minimal docs (at least `00-status.md`) |

---

## Quick Checklist

### Starting New Task
- [ ] Get issue key
- [ ] Fetch from YouTrack (get issue summary for slug)
- [ ] Check for existing task folder: `find ${PROJECT_TASK_DOCS_DIR} -name "{ISSUE_KEY}*"`
- [ ] Check for existing branch: `git branch --list "*{ISSUE_KEY}*"`
- [ ] Create `${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/` folder (tracks planning progress)
- [ ] Read project rules (.ai/rules/)
- [ ] Search codebase - document findings in task docs
- [ ] Ask clarifying questions - document in task docs
- [ ] Create implementation plan - document in task docs
- [ ] **Get user approval** (approval controls git branch + code changes)
- [ ] Finalize task docs
- [ ] Create git branch and start coding

### Before Implementation
- [ ] All questions answered
- [ ] Decisions documented
- [ ] Plan approved
- [ ] Branch created
- [ ] Status: "In Progress"

### During Implementation
- [ ] Update `04-todo.md`
- [ ] Use TodoWrite tool
- [ ] Follow single-step rule
- [ ] Update docs as needed
- [ ] Mark phases complete

### Completion
- [ ] All acceptance criteria met
- [ ] Tests passing
- [ ] Code reviewed
- [ ] Merged
- [ ] Status: "Complete"

---

**Full Documentation**: `~/.claude/workflows/task-planning/`
**Templates**: `~/.claude/templates/task-planning/`
**Slash Command**: `/plan-task [{ISSUE_KEY}]`
