# Module: sync-docs-with-implementation

## Purpose
Update documentation files to match implementation reality after user confirms discrepancies.

## Scope
TASK-PLANNING - In Progress Mode (Step 5)

## Mode
WRITE-ENABLED (only after user confirmation)

---

## When to Use
After presenting findings to user and receiving confirmation to proceed with updates.

---

## Prerequisites

**Must have user confirmation before proceeding!**

You need:
- `DISCREPANCIES` list from compare-and-sync module
- User answers to clarifying questions
- `TASK_FOLDER` path
- Confirmation to update specific documents

---

## Instructions

### Step 1: Update Status Document

**Update `00-status.md`:**

```markdown
## Status Updates

**Previous status**: {from doc}
**Updated status**: {actual status based on implementation}

### Progress
- Phase: {current phase based on code}
- Completion: {estimated % based on requirements met}

### Last Updated
{current date}
```

**Status values:**
- "Discovery" → if still gathering requirements
- "Planning" → if planning incomplete
- "In Progress" → if actively coding
- "Review" → if ready for code review
- "Testing" → if in QA
- "Complete" → if merged/deployed

### Step 2: Update Implementation Plan

**Update `03-implementation-plan.md`:**

For each discrepancy where code differs from plan:

```markdown
### {Section}

**Original plan:**
{what was planned}

**Actual implementation:**
{what was actually built}

**Reason for deviation:**
{from user clarification or inferred}
```

**Add new sections for unplanned work:**
```markdown
### {New Feature/Change} (Added during implementation)

{Description of what was built and why}
```

### Step 3: Update Functional Requirements

**Update `02-functional-requirements.md`:**

For each requirement:
- Mark as implemented if code confirms it
- Add implementation notes
- Flag requirements that changed

```markdown
### REQ-{N}: {Title}

**Status**: Implemented / Partial / Not Started
**Implementation**: {file:line reference}
**Notes**: {any deviations or clarifications}
```

**Add new requirements discovered during implementation:**
```markdown
### REQ-{N}: {New Requirement} (Added)

{Description}
**Reason**: Discovered during implementation
**Implementation**: {file:line}
```

### Step 4: Update Todo Checklist

**Update `04-todo.md`:**

```markdown
## Implementation Checklist

### Completed
- [x] {item} - {date or commit}
- [x] {item} - {date or commit}

### In Progress
- [ ] {item} - {current state}

### Remaining
- [ ] {item}
- [ ] {item}

### Added During Implementation
- [x] {new item discovered} - {date}
```

### Step 5: Update Decision Log

**Append to `logs/decisions.md`:**

```markdown
## ADR-{N}: {Decision Title}

**Date**: {current date}
**Status**: Accepted
**Context**: Discovered during reconciliation - {context}

**Decision**: {what was decided}

**Rationale**: {why this approach}

**Consequences**: {impact}
```

### Step 6: Update Task Description (Last)

**Update `01-task-description.md`:**

This is updated last because it may sync to YouTrack.

```markdown
## Summary
{Updated summary reflecting actual scope}

## Current State
{Accurate description of what's been built}

## Remaining Work
{What's left to do}
```

---

## Update Order

**Critical: Update in this specific order:**

1. `00-status.md` - Status first (quick reference)
2. `03-implementation-plan.md` - Technical details
3. `02-functional-requirements.md` - Requirements alignment
4. `04-todo.md` - Checklist accuracy
5. `logs/decisions.md` - Record decisions made
6. `01-task-description.md` - Last (for YouTrack sync)

---

## Output Summary

```markdown
## Documentation Sync Complete

### Documents Updated
| Document | Changes Made |
|----------|--------------|
| 00-status.md | Status: {old} → {new} |
| 03-implementation-plan.md | {N} sections updated, {M} added |
| 02-functional-requirements.md | {N} requirements updated |
| 04-todo.md | {N} items checked, {M} added |
| logs/decisions.md | {N} ADRs added |
| 01-task-description.md | Summary updated |

### Sync Summary
- **Discrepancies resolved**: {count}
- **New items documented**: {count}
- **Status updated to**: {new status}

### Verification
Run `ls -la "{TASK_FOLDER}"` to confirm all files updated.
```

---

## Outputs
- `DOCS_UPDATED`: List of documents modified
- `CHANGES_MADE`: Summary of changes per document
- `NEW_STATUS`: Updated task status
- `SYNC_COMPLETE`: Boolean confirmation
