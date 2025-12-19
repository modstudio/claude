# Module: finalize-documentation

## Purpose
Consolidate all discussion outcomes into final documentation before implementation.

## Scope
TASK-PLANNING specific

## Mode
WRITE-ENABLED

---

## Inputs
- `TASK_FOLDER`: Task docs folder
- `APPROVED_PLAN`: Approved implementation plan
- `USER_FEEDBACK`: Any feedback from approval discussion

---

## When to Run
**After approval gate passed, before implementation begins.**

---

## Instructions

### Step 1: Update Status
**Edit `00-status.md`:**
```markdown
**Status:** Ready for Implementation
**Approved:** {date}
**Approach:** {summary of approved approach}
```

### Step 2: Finalize Requirements
**Edit `02-functional-requirements.md`:**
- All questions moved to "Resolved" section
- Final acceptance criteria confirmed
- Edge cases clarified
- Out-of-scope items documented

### Step 3: Finalize Implementation Plan
**Edit `03-implementation-plan.md`:**
- Approved approach documented
- Any user feedback incorporated
- Final file list confirmed
- Phases ordered correctly

### Step 4: Update Decision Log
**Edit `logs/decisions.md`:**
- Mark decisions as "Accepted"
- Add any decisions from approval discussion
- Note user preferences

### Step 5: Create Todo Checklist
**Edit `04-todo.md`:**
```markdown
# Implementation Checklist

## Phase 1: {Name}
- [ ] {Step from plan}
- [ ] {Step from plan}

## Phase 2: {Name}
- [ ] {Step from plan}

## Testing
- [ ] Unit tests
- [ ] Feature tests
- [ ] Manual testing

## Completion
- [ ] Code review requested
- [ ] PR merged
- [ ] Status updated to Complete
```

### Step 6: Finalize Task Description (LAST)
**Edit `01-task-description.md`:**
- **Only after scope is fully settled**
- Final summary incorporating all discussions
- Clear scope statement
- This syncs to YouTrack - avoid stale info

---

## Verification

- [ ] `00-status.md` shows "Ready for Implementation"
- [ ] All questions in `02-functional-requirements.md` resolved
- [ ] `03-implementation-plan.md` has approved approach
- [ ] `04-todo.md` has implementation checklist
- [ ] `logs/decisions.md` has all decisions marked Accepted
- [ ] `01-task-description.md` has final scope

---

## Outputs
- All task docs finalized
- Ready for implementation phase
