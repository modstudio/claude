# Module: session-review-file

## Purpose
Create a NEW session review file for interface display with key points summary.

## Scope
CODE-REVIEW - External review workflow

## Mode
WRITE-ENABLED

---

## Output File

**Location:** `${TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/logs/review-{YYYYMMDD-HHMMSS}.md`

**Purpose:** Clean display in interface, easy reference for current review session

---

## Template

```markdown
# External Review Evaluation

**Issue:** {ISSUE_KEY}
**Date:** {YYYY-MM-DD HH:MM}
**External Reviewer:** {source - AI tool/human/linter}
**Evaluator:** Claude Code

---

## Key Points Summary

> **Quick reference for this review session**

### ACCEPTED ({count})
{For each accepted suggestion:}
- **{Title}**: {1-line reason} → Applied at `{file:line}`

### MODIFIED ({count})
{For each modified suggestion:}
- **{Title}**: Issue real, but {why different fix} → Applied at `{file:line}`

### REJECTED ({count})
{For each rejected suggestion:}
- **{Title}**: {1-line rejection reason}

---

## Statistics

| Metric | Value |
|--------|-------|
| Total Suggestions | {count} |
| Accepted | {count} ({%}) |
| Modified | {count} ({%}) |
| Rejected | {count} ({%}) |
| Critical Issues | {count} |

---

## Detailed Analysis

### Suggestion #N: {Title}

**External Review Says:**
> {quote}

**My Analysis:**
- Issue Verification: CONFIRMED / PARTIALLY VALID / NOT AN ISSUE
- Violation: [STANDARD §section] (if applicable)
- Impact: [description]

**Final Decision:** ACCEPT / MODIFY / REJECT

**Reasoning:** {explanation}

{If ACCEPT: code change applied}
{If MODIFY: alternative solution applied}
{If REJECT: why not needed}

---

## Next Steps

- [ ] {Action item 1}
- [ ] {Action item 2}
```

---

## Instructions

1. Generate timestamp: `date +%Y%m%d-%H%M%S`
2. Create file at: `${TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/logs/review-{timestamp}.md`
3. Populate template with evaluation results
4. Ensure Key Points Summary is filled with 1-line summaries

---

## Key Points Summary Rules

**ACCEPTED items must include:**
- Brief title
- 1-line reason why accepted
- File:line where change was applied

**MODIFIED items must include:**
- Brief title
- Why the fix was different
- File:line where alternative was applied

**REJECTED items must include:**
- Brief title
- 1-line rejection reason (no file reference needed)

---

## Outputs
- `SESSION_REVIEW_FILE`: Path to created file
