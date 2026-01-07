# Module: generate-report

## Purpose
Compile all review findings into comprehensive final report.

## Scope
CODE-REVIEW - Used by report mode, summary phase of all modes

## Mode
READ-ONLY (compilation only)

---

## Inputs
- Context from gather-review-context
- Auto-fix results from auto-fix-phase
- Findings from all review modules
- Test results from test-review

## Instructions

### Step 1: Compile Executive Summary

```markdown
## Executive Summary

**Review Status:** [PASS / NEEDS WORK / FAIL]
**Requirements:** [N/N implemented] (if task docs available)
**Tests:** [X of Y passing]
**Critical Issues:** [N]
**Auto-Fixed:** [N] issues
**Recommendation:** [APPROVE / NEEDS CHANGES / REJECT]
```

### Step 2: Compile Overview

```markdown
## Overview

**Issue Information:**
- Issue Key: [ISSUE-KEY]
- Summary: [from YouTrack]
- Type: [Feature/Enhancement/Fix]
- Priority: [if available]

**Change Summary:**
- Branch: [branch name]
- Files Changed: [total] ([N] staged, [N] unstaged)
- Lines +/-: [added/removed]
- Migrations: [count]
- Components: [backend/frontend/both]

**Context Sources:**
- [ ] YouTrack issue reviewed
- [ ] Task documentation reviewed
- [ ] Knowledge base articles: [list IDs]
```

### Step 3: Compile Requirements Compliance (if available)

```markdown
## Requirements Compliance

| ID | Requirement | Status | Evidence |
|----|-------------|--------|----------|
| AC1 | [desc] | PASS/PARTIAL/MISSING | file:line |

**Summary:**
- Fully Implemented: [N] of [Total]
- Partially Implemented: [N]
- Missing: [N]
```

### Step 4: Compile Auto-Fixed Section

```markdown
## Auto-Fixed Issues

**{N} issues auto-fixed** - no action required:

| Type | Count | Details |
|------|-------|---------|
| Linter | [N] files | PHP CS Fixer / Prettier |
| Debug statements | [N] | dd(), console.log() |
| **Total** | **[N]** | |
```

### Step 5: Compile What Was Done Well

```markdown
## What Was Done Well

**Architecture & Design:**
- [Good decisions]

**Code Quality:**
- [Well-written examples]

**Testing:**
- [Good practices]
```

### Step 6: Compile Issues Found

Group by severity with full details:

```markdown
## Issues Found

### CRITICAL (Blocking Merge)

**Issue:** [description]
**Location:** `file:line`
**Violation:** [STANDARD §section]
**Current Code:**
\`\`\`
[code]
\`\`\`
**Problem:** [why it blocks]
**Fix Required:**
\`\`\`
[solution]
\`\`\`

### MAJOR (Should Fix Before Merge)
[Same format]

### MINOR (Nice to Have)
[Same format]
```

### Step 7: Create Summary Table

```markdown
## Suggestions Summary Table

| # | Severity | Issue | Suggestion |
|---|----------|-------|------------|
| 1 | CRITICAL | [title] | [fix] |
| 2 | MAJOR | [title] | [fix] |
| 3 | MINOR | [title] | [fix] |

**Totals:** X Critical | X Major | X Minor
```

### Step 8: Create Action Plan

```markdown
## Action Plan

**REQUIRED Before Merge:**
- [ ] [Critical fix 1]
- [ ] [Critical fix 2]

**RECOMMENDED:**
- [ ] [Major fix 1]

**OPTIONAL:**
- [ ] [Minor improvement]
```

### Step 9: Risk Assessment

```markdown
## Risk Assessment

**Overall Risk:** [LOW / MEDIUM / HIGH]

**Risk Factors:**
- Test Coverage: [X%] - [risk level]
- Migration Safety: [Safe/Risky]
- Breaking Changes: [None/Minor/Major]
- Code Complexity: [Low/Medium/High]
```

### Step 10: Final Recommendation

```markdown
## Final Recommendation

**Decision:** [APPROVE / REQUEST CHANGES / REJECT]

**Justification:**
[2-3 sentence summary]

**Next Steps:**
1. [First step]
2. [Second step]
```

---

## GitHub-Ready Comments (optional)

Include formatted comments for PR:

### Inline Code Suggestion
````markdown
**File:** `app/Services/Foo.php:45-48`

```suggestion
// Improved version
[code]
```
````

### Architectural Issue
```markdown
**Architecture — [Title]** (MAJOR)
Path: `file:line`

**Issue:** [what's wrong]
**Violation:** [ARCH §section]
**Fix:** [solution]
```

---

## Output Destination

**⚠️ CRITICAL: Output to CHAT ONLY**

- **DO NOT create a file** - output the report directly in chat
- **DO NOT save to any folder** (no artifacts, no .wip, no task-docs)
- The user will copy/save the report if needed

**Why:** Report reviews are for immediate feedback. File creation clutters the workspace and causes confusion about where reports live.

---

**End of Module**
