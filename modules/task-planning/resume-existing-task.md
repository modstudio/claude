# Module: resume-existing-task

## Purpose
Handle resuming an existing task - read docs, assess completeness, determine current phase.

## Scope
TASK-PLANNING specific

## Mode
READ-ONLY

---

## When to Use
When `CONTEXT_SIGNAL == "EXISTING_TASK"` (task folder exists)

---

## Step 1: Read Existing Documentation

```bash
# Read all docs in order
TASK_FOLDER="${PROJECT_TASK_DOCS_DIR}/${ISSUE_KEY}*"

# Read each file
cat "$TASK_FOLDER/00-status.md"
cat "$TASK_FOLDER/01-task-description.md"
cat "$TASK_FOLDER/02-functional-requirements.md"
cat "$TASK_FOLDER/03-implementation-plan.md"
cat "$TASK_FOLDER/04-todo.md"
cat "$TASK_FOLDER/logs/decisions.md"
```

---

## Step 2: Assess Documentation Completeness

**Check each document:**

| Doc | Check | Status |
|-----|-------|--------|
| 00-status.md | Has current status? | ✓/✗ |
| 01-task-description.md | Has summary beyond template? | ✓/✗ |
| 02-functional-requirements.md | Has requirements? Questions resolved? | ✓/✗ |
| 03-implementation-plan.md | Has approach? Files listed? | ✓/✗ |
| 04-todo.md | Has implementation steps? | ✓/✗ |
| logs/decisions.md | Has ADRs? | ✓/✗ |

**Completeness Assessment:**
- **Complete**: All docs populated, ready for implementation
- **Partial**: Some docs populated, continue from current phase
- **Minimal**: Only templates exist, essentially a new task

---

## Step 3: Determine Current Phase

**Read status from 00-status.md:**

| Status Value | Current Phase | Next Action |
|--------------|---------------|-------------|
| "Discovery" | Phase 1 | Continue discovery |
| "Requirements" | Phase 2 | Continue requirements analysis |
| "Planning" | Phase 3 | Continue technical planning |
| "Review" | Phase 4 | Present for approval |
| "Ready for Implementation" | Phase 5 | Start implementation |
| "In Progress" | Phase 6 | Continue implementation |

---

## Output Summary

Present to user:
```markdown
## Existing Task: {ISSUE_KEY}

**Status:** {from 00-status.md}
**Last Updated:** {date from file}

### Documentation Assessment
| Doc | Status |
|-----|--------|
| Task Description | {complete/partial/empty} |
| Requirements | {complete/partial/empty} |
| Implementation Plan | {complete/partial/empty} |
| Todo Checklist | {complete/partial/empty} |

### Current Phase: {phase}

**Recommended Action:** {continue from X / restart from Y}
```

---

## Outputs
- `CURRENT_STATUS`: Status from 00-status.md
- `DOC_COMPLETENESS`: Assessment of each doc
- `CURRENT_PHASE`: Which phase to resume from
- `RECOMMENDED_ACTION`: What to do next
