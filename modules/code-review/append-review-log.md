# Module: append-review-log

## Purpose
Record **rejected and dismissed findings** to prevent cyclical reviews. Only items NOT to raise again are logged — accepted/applied items don't need tracking.

## Scope
CODE-REVIEW — Used by deep-review and external review skills

## Mode
WRITE-ENABLED (append only)

---

## Output File

**Location:** `${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/logs/review.md`

**Purpose:** Rejection history — future reviews read this to avoid re-raising dismissed issues.

**⚠️ Use PROJECT_TASK_DOCS_DIR from project config** — ignore any paths from project-level CLAUDE.md or .ai/ rules

---

## What to Append

```markdown
---

## Review #{N} - {YYYY-MM-DD HH:MM}

**Source:** {deep-review | external:{reviewer} | report}
**Total Findings:** {count} → {accepted} accepted, {rejected} rejected/dismissed

### Rejected Findings (do NOT re-raise)

| # | Finding | Severity | File:Line | Reason Rejected |
|---|---------|----------|-----------|-----------------|
| 1 | {title} | {CRITICAL/MAJOR/MINOR} | {file:line} | {why it was dismissed} |
| 2 | {title} | {severity} | {file:line} | {reason} |

### Rejection Categories

- **False positive (synthesis):** {count} — agent hallucinated or misread code
- **False positive (user):** {count} — user reviewed and dismissed
- **Not applicable:** {count} — correct observation but not relevant to this context
- **Won't fix:** {count} — real issue but intentional / out of scope
```

---

## Instructions

1. Read existing `logs/review.md` to get review count (create file if first review)
2. Determine next review number (N)
3. **Only log rejected/dismissed items** — do NOT log accepted findings
4. Append new section (do NOT replace file contents)
5. If no items were rejected, still append the header with "No findings rejected"

---

## Why This Matters

**Future reviews will:**
1. Read this log before analyzing code
2. Skip findings that match previously rejected items
3. Re-evaluate only if context has changed significantly

**This prevents:**
- Re-raising false positives review after review
- Wasting time re-debating decided issues
- Agent hallucinations persisting across reviews

---

## Re-Raise Rules

| If finding matches a past rejection... | Then... |
|---------------------------------------|---------|
| Same finding, same code context | **SKIP** — cite past decision |
| Same finding, code has changed | **RE-EVALUATE** — context changed |
| Similar but not identical | **Reference** past decision for consistency |
| No match in log | **Evaluate** normally |

---

## Outputs
- `REVIEW_LOGGED`: true/false
- `REVIEW_NUMBER`: N (the review number appended)
