# Module: compare-and-sync

## Purpose
Compare implementation state with documentation to identify discrepancies.

## Scope
TASK-PLANNING - In Progress Mode (Step 3)

## Mode
READ-ONLY

---

## When to Use
After gathering implementation state and reading existing docs - now compare them.

---

## Prerequisites

You must have:
- `IMPLEMENTATION_STATE` from gather-implementation-state module
- `DOCS_STATE` from resume-existing-task module
- `TASK_FOLDER` path

---

## Instructions

### Step 1: Compare Implementation vs Plan

**Read `03-implementation-plan.md` and compare:**

| Planned Item | In Code? | Notes |
|--------------|----------|-------|
| {planned file/feature} | Yes/No/Partial | {what's different} |

**Identify:**
- Code changes NOT in the plan (unplanned work)
- Planned items NOT in code (incomplete)
- Deviations from the plan (different approach)

### Step 2: Compare Code vs Requirements

**Read `02-functional-requirements.md` and compare:**

| Requirement | Implemented? | Evidence |
|-------------|--------------|----------|
| REQ-1: {desc} | Yes/No/Partial | {file:line or missing} |
| REQ-2: {desc} | Yes/No/Partial | {file:line or missing} |

**Identify:**
- Requirements met by code
- Requirements not yet implemented
- Code that doesn't map to any requirement (scope creep?)

### Step 3: Compare Status

**Read `00-status.md` and compare:**

| Doc Status | Actual Status | Match? |
|------------|---------------|--------|
| {status from doc} | {actual based on code} | Yes/No |

**Common mismatches:**
- Doc says "Planning" but code exists
- Doc says "In Progress" but no recent commits
- Doc says "Ready for Review" but tests failing

### Step 4: Compare Todo Checklist

**Read `04-todo.md` and compare:**

| Todo Item | Checked in Doc | Actually Done? | Match? |
|-----------|----------------|----------------|--------|
| {item} | [ ] or [x] | Yes/No | Yes/No |

**Identify:**
- Items checked but not actually done
- Items done but not checked
- Items missing from list

### Step 5: Assess Impact

**For each discrepancy, assess:**

| Discrepancy | Type | Impact | Action Needed |
|-------------|------|--------|---------------|
| {description} | Code>Docs / Docs>Code / Mismatch | High/Medium/Low | Update docs / Implement / Discuss |

**Impact levels:**
- **High**: Blocks progress or causes confusion
- **Medium**: Should be fixed but not blocking
- **Low**: Cosmetic or minor inconsistency

---

## Output Summary

```markdown
## Discrepancy Analysis: {ISSUE_KEY}

### Summary
- **Total discrepancies**: {count}
- **High impact**: {count}
- **Code not in docs**: {count}
- **Docs not in code**: {count}

### Code Not in Documentation
| File/Feature | Description | Impact |
|--------------|-------------|--------|
| {item} | {what was done} | {impact} |

### Documentation Not in Code
| Planned Item | Status | Impact |
|--------------|--------|--------|
| {item} | Not started / Partial | {impact} |

### Status Mismatches
| Document | Says | Reality |
|----------|------|---------|
| 00-status.md | {doc status} | {actual status} |

### Questions for User
1. {Question about unexpected code}
2. {Question about missing implementation}
3. {Question about changed requirements}
```

---

## Outputs
- `DISCREPANCIES`: List of all discrepancies found
- `CODE_NOT_IN_DOCS`: Features/code not documented
- `DOCS_NOT_IN_CODE`: Planned items not implemented
- `STATUS_MISMATCH`: Status inconsistencies
- `QUESTIONS`: List of clarifying questions for user
- `IMPACT_ASSESSMENT`: Summary of impact levels
