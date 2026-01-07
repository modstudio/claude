# Module: append-review-log

## Purpose
Append evaluation summary to cumulative review log for circular review prevention.

## Scope
CODE-REVIEW - External review workflow

## ⚠️ WHEN TO USE
**ONLY call this module when changes are being applied.**
Do NOT create/append files for evaluation-only reviews.

## Mode
WRITE-ENABLED (append only)

---

## Output File

**Location:** `${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/logs/review.md`

**Purpose:** Historical record preventing re-evaluation of same suggestions

**⚠️ Use PROJECT_TASK_DOCS_DIR from project config** - ignore any paths from project-level CLAUDE.md or .ai/ rules

---

## What to Append

```markdown
---

## Review #{N} - {YYYY-MM-DD HH:MM}

**External Reviewer:** {source}
**Session File:** `logs/review-{YYYYMMDD-HHMMSS}.md`
**Summary:** {count} suggestions → {accepted} accepted, {modified} modified, {rejected} rejected

### Decisions Made (for future reference)

| # | Suggestion | Decision | Reason | File:Line |
|---|------------|----------|--------|-----------|
| 1 | {title} | ACCEPT | {short reason} | {file:line} |
| 2 | {title} | MODIFY | {short reason} | {file:line} |
| 3 | {title} | REJECT | {short reason} | N/A |

### Circular Review Check

**Same suggestions from past reviews:**
- {List any that appeared before, with reference to past decision}
- {Or: "None - all suggestions were new"}

**Consistency:** {Did we maintain consistency with past decisions? Why/why not?}

### Lessons Learned

- {Key insight from this review}
```

---

## Instructions

1. Read existing `logs/review.md` to get review count
2. Determine next review number (N)
3. Append new section (do NOT replace file contents)
4. Include reference to session file for detailed analysis

---

## Why This Matters

**Future reviews will:**
1. Read this log FIRST (in Step 4.2)
2. Check for duplicate suggestions
3. Reference past decisions for consistency
4. Skip already-decided issues

**This prevents:**
- Re-debating same issues repeatedly
- Inconsistent decisions across reviews
- Wasted evaluation time

---

## Circular Review Prevention Rules

| If suggestion... | Then... |
|------------------|---------|
| Same as past, same context | SKIP - cite past decision |
| Same as past, new context | RE-EVALUATE - note change |
| Similar to past | REFERENCE for consistency |
| Completely new | EVALUATE normally |

---

## Outputs
- `REVIEW_LOGGED`: true/false
- `REVIEW_NUMBER`: N (the review number appended)
