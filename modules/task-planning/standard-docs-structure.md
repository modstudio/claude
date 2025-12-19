# Module: standard-docs-structure

## Purpose
Define the standard documentation structure for task planning.

## Scope
TASK-PLANNING - Used by all task-planning modes

---

## Folder Location

```
${TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/
```

- `TASK_DOCS_DIR`: Project-local `.task-docs/` directory
- `ISSUE_KEY`: YouTrack issue key (e.g., STAR-1234)
- `slug`: Title-cased summary (e.g., Fix-Login-Error)

**Example:** `.task-docs/STAR-1234-Fix-Login-Error/`

---

## Standard Documents

| File | Purpose | When Created | When Updated |
|------|---------|--------------|--------------|
| `00-status.md` | Status tracking, links to other docs | Phase 0 | Every phase |
| `01-task-description.md` | High-level task overview | Phase 0 | After scope finalized |
| `02-functional-requirements.md` | Detailed requirements, questions | Phase 0 | During analysis |
| `03-implementation-plan.md` | Technical plan, files to change | Phase 0 | During planning |
| `04-todo.md` | Implementation checklist | After approval | During implementation |
| `logs/decisions.md` | ADRs, key decisions | Phase 0 | When decisions made |
| `logs/review.md` | External review feedback | Phase 0 | During reviews |

---

## Document Purposes

### 00-status.md
**Central tracking document**
- Current status (Discovery, Planning, In Progress, Review, Complete)
- Current phase
- Links to all other docs
- Blockers and next actions
- Last updated timestamp

### 01-task-description.md
**High-level overview (syncs to YouTrack)**
- Issue summary
- Task context
- Scope statement
- Out-of-scope items
- **Update LAST** - only after scope is finalized

### 02-functional-requirements.md
**Detailed requirements**
- Business context
- User stories
- Acceptance criteria
- Edge cases
- Questions (unresolved → resolved)

### 03-implementation-plan.md
**Technical implementation details**
- Chosen approach
- Files to create/modify
- Implementation phases
- Testing strategy
- Risk assessment

### 04-todo.md
**Implementation checklist**
- Phase-by-phase checkboxes
- Tracks completion progress
- Created after approval

### logs/decisions.md
**Architectural Decision Records (ADRs)**
- Decision title and date
- Context
- Options considered
- Decision and rationale
- Consequences

### logs/review.md
**External feedback**
- Code review comments
- Stakeholder feedback
- Resolution status

---

## Template Location

Templates are in: `~/.claude/templates/task-planning/`

---

## Creation Order

1. Create folder
2. Create ALL templates (with placeholders)
3. Populate incrementally as you discover/decide
4. Finalize after approval

**Key principle:** Templates exist from the start, content fills in over time.

---

## Verification Checklist

After creating task folder, verify:
- [ ] Folder exists at correct path
- [ ] `00-status.md` exists
- [ ] `01-task-description.md` exists
- [ ] `02-functional-requirements.md` exists
- [ ] `03-implementation-plan.md` exists
- [ ] `04-todo.md` exists
- [ ] `logs/` directory exists
- [ ] `logs/decisions.md` exists
- [ ] `logs/review.md` exists
