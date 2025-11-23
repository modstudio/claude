# Task Planning Workflow - Quick Reference

**Full Documentation**: See `.ai/workflows/task-planning.md`

---

## Quick Start

### New Task
```bash
# User provides issue key or uses slash command
/plan-task {PROJECT_KEY}-2235

# Agent will:
# 1. Fetch from YouTrack
# 2. Check for existing branch: git branch --list "*{PROJECT_KEY}-2235*"
# 3. Read project rules (.ai/rules/)
# 4. Create .wip/{PROJECT_KEY}-2235/ folder
# 5. Create 6 standard documents
# 6. Search YouTrack docs Table of Contents for STAR-A articles
# 7. Ask clarifying questions
# 8. Create implementation plan
# 9. Get approval before coding
```

### Resume Existing Task
```bash
# Agent checks .wip/{PROJECT_KEY}-2235/ automatically
# Reads 00-status.md for current state
# Presents next actions
```

---

## Document Structure

Every task has these 6 documents in `.wip/{PROJECT_KEY}-XXXX/`:

1. **00-status.md** ← Start here (central index)
2. **01-functional-requirements.md** ← Business requirements
3. **02-decision-log.md** ← Decision log (ADR-style)
4. **03-implementation-plan.md** ← Technical plan
5. **04-task-description.md** ← Summary for YouTrack
6. **05-todo.md** ← Implementation checklist

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
- Always create `.wip/{PROJECT_KEY}-XXXX/` (issue key only)
- Always start with `00-status.md`
- Always check for existing branch: `git branch --list "*{PROJECT_KEY}-XXXX*"`
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
- Format: `{type}/{PROJECT_KEY}-XXXX-{slug}`
- Base: `develop` (or `master` for hotfix)

### TodoWrite Tool
- Used during Phase 5 (implementation)
- Parallel to `05-todo.md` but more granular
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
/plan-task {PROJECT_KEY}-2235
```

### Check for Existing Branch
```bash
git branch --list "*{PROJECT_KEY}-2235*"
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
# Agent reads .wip/{PROJECT_KEY}-2235/00-status.md automatically
```

### Update YouTrack Description
```bash
# After planning complete, use content from:
# .wip/{PROJECT_KEY}-2235/04-task-description.md
```

---

## Special Cases

### Existing Non-Standard Docs
1. Read all existing docs
2. Offer reorganization options
3. Archive old docs to `.wip/{PROJECT_KEY}-XXXX/archive/`
4. Create standard structure

### Complex Task with Subtasks
- Document parent task in `.wip/{PROJECT_KEY}-XXXX/`
- Link to subtasks in `00-status.md`
- Optional: Create `.wip/{PROJECT_KEY}-YYYY/` for complex subtasks

### Task with Dependencies
- Document in `03-implementation-plan.md` Dependencies section
- Track in `00-status.md` if blocking
- Update status to "Blocked" if needed

---

## Folder Naming

**Standard**: `.wip/{PROJECT_KEY}-XXXX/` (issue key only)

✅ Correct:
- `.wip/{PROJECT_KEY}-2228/`
- `.wip/{PROJECT_KEY}-2233/`

❌ Incorrect:
- `.wip/{PROJECT_KEY}-2228-Warehouse-Queue/`
- `.wip/technical/STAR-2233/`

---

## Templates Location

Templates: `.ai/templates/task-planning/`

Contains all 6 document templates ready to copy.

---

## Example Flow

1. User: "Let's work on {PROJECT_KEY}-2235"
2. Agent: Fetches from YouTrack, creates `.wip/{PROJECT_KEY}-2235/`
3. Agent: "This is a bug fix in authentication. I found these questions..."
4. User: Answers questions
5. Agent: Creates implementation plan, gets approval
6. Agent: Creates branch `fix/{PROJECT_KEY}-2235-Login-timeout-error`
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
- [ ] Fetch from YouTrack
- [ ] Check for existing branch
- [ ] Read project rules (01-core-workflow.md, dev-processes.md)
- [ ] Create `.wip/{PROJECT_KEY}-XXXX/`
- [ ] Create 6 standard documents
- [ ] Search YouTrack docs Table of Contents
- [ ] Ask questions
- [ ] Create plan
- [ ] Get approval

### Before Implementation
- [ ] All questions answered
- [ ] Decisions documented
- [ ] Plan approved
- [ ] Branch created
- [ ] Status: "In Progress"

### During Implementation
- [ ] Update `05-todo.md`
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

**Full Documentation**: `.ai/workflows/task-planning.md`
**Templates**: `.ai/templates/task-planning/`
**Slash Command**: `/plan-task [{PROJECT_KEY}-XXXX]`
