---
description: Evaluate external code review - paste review first, no waiting (global)
---

# External Review

Evaluate an external code review (from AI tools, developers, linters) against project standards.

**⚠️ USER-FIRST:** Get the review text immediately so user isn't waiting.

---

## YOUR FIRST RESPONSE MUST INCLUDE:

1. **TodoWrite** - Create todo list:
   - "Detect context" status=in_progress activeForm="Detecting context"
   - "Get external review text" status=pending activeForm="Getting review"
   - "Evaluate each suggestion" status=pending activeForm="Evaluating"
   - "Present verdict" status=pending activeForm="Presenting verdict"
   - "Apply changes if approved" status=pending activeForm="Applying changes"
   - "Update review log" status=pending activeForm="Updating review log"

2. **Bash** - Run: `~/.claude/lib/detect-mode.sh --pretty`

**CALL BOTH TOOLS NOW.**

---

## After Detection Runs

**Present context and immediately ask for review:**

```markdown
| Property | Value |
|----------|-------|
| Issue Key | {ISSUE_KEY} |
| Branch | {BRANCH} |
| Task Folder | {TASK_FOLDER} |

**Is this the correct context?** If so, paste the external review text below.
```

Mark "Detect context" complete, "Get external review text" in_progress.

**Wait for user to paste review text.**

---

## Step 2: Load Standards (While Processing)

**After receiving review text, load in background:**
- Project standards from `$PROJECT_STANDARDS_DIR`
- Previous review history (if exists): `$TASK_FOLDER/logs/review.md`

---

## Step 3: Parse & Check History

### 3.1 Parse External Review

Extract from the pasted text:
- Individual suggestions/issues
- File/line references
- Severity indicators
- Suggested fixes

### 3.2 Check for Duplicates

```bash
TASK_FOLDER=$(~/.claude/lib/detect-mode.sh --json | grep -o '"task_folder":"[^"]*"' | cut -d'"' -f4)
if [ -f "$TASK_FOLDER/logs/review.md" ]; then
  cat "$TASK_FOLDER/logs/review.md"
fi
```

**For each suggestion, check if it was already evaluated:**

| If... | Then... |
|-------|---------|
| Same as past review | SKIP - cite past decision |
| Similar to past | REFERENCE for consistency |
| New suggestion | EVALUATE normally |

---

## Step 4: Evaluate Each Suggestion

**For each suggestion:**

### 4.1 Verify the Issue
- Read actual code at referenced location
- Does issue actually exist?
- Is it accurately described?

### 4.2 Check Against Standards
- Reference project standards
- Is this actually a violation?
- Use citation format: `[ARCH §section]` or `[STYLE: "quote"]`

### 4.3 Determine Verdict

| Verdict | When |
|---------|------|
| **ACCEPT** | Issue real, fix correct |
| **MODIFY** | Issue real, different fix needed |
| **REJECT** | Not an issue, or intentional pattern |

---

## Step 5: Present Verdict (Chat Only)

**Output evaluation summary to chat:**

```markdown
# External Review Evaluation

**Source:** {reviewer/tool name}
**Suggestions:** {count}

## Summary

| # | Suggestion | Verdict | Reason |
|---|------------|---------|--------|
| 1 | {title} | ACCEPT | {brief reason} |
| 2 | {title} | MODIFY | {brief reason} |
| 3 | {title} | REJECT | {brief reason} |

## Verdicts

### ACCEPT ({count})
{For each:}
- **{title}**: {reason} → `{file:line}`

### MODIFY ({count})
{For each:}
- **{title}**: Issue valid, but {different fix} → `{file:line}`

### REJECT ({count})
{For each:}
- **{title}**: {rejection reason}

---

**Actionable:** {count} suggestions to apply
```

**⚠️ DO NOT create any files at this step.**

---

## Step 6: Ask About Changes

```javascript
AskUserQuestion({
  questions: [{
    question: "How would you like to proceed?",
    header: "Action",
    multiSelect: false,
    options: [
      {label: "Apply all accepted", description: "Apply ACCEPT and MODIFY suggestions"},
      {label: "Apply critical only", description: "Apply only critical/major issues"},
      {label: "Show me the patches", description: "Show code changes without applying"},
      {label: "Done", description: "Evaluation complete, no changes needed"}
    ]
  }]
})
```

---

## Step 7: Apply Changes (If Approved)

**Only if user chooses to apply:**

1. Apply code changes using Edit tool
2. Run verification (lint/tests if quick)
3. **Then** create session record:

{{MODULE: ~/.claude/modules/code-review/session-review-file.md}}

---

## Step 7b: Log Rejected Findings

**ALWAYS log rejected findings — regardless of whether changes were applied.**

{{MODULE: ~/.claude/modules/code-review/append-review-log.md}}

**Source field:** `external:{reviewer/tool name}`

Skip only if: ISSUE_KEY is "none" or no TASK_FOLDER exists.

---

## Step 8: Final Summary

```markdown
## External Review Complete

**Applied:** {count} changes
**Files modified:** {list}

{If files created:}
**Record saved:** `{TASK_FOLDER}/logs/review-{timestamp}.md`

**Next:** Review changes, run tests, commit if satisfied.
```

---

## Key Principles

### User-First
- Get review text IMMEDIATELY
- Don't make user wait for context loading
- Load context AFTER receiving input

### Chat Output
- Verdicts go to chat, not files
- Session record only created when changes applied
- Rejection log always written if there are rejections

### Independence
- I am NOT a rubber stamp
- I evaluate against PROJECT standards
- External review may be wrong

---

## Quick Reference

**Session record** (only if changes applied):
- `${TASK_FOLDER}/logs/review-{timestamp}.md`

**Rejection log** (always, if any rejections):
- `${TASK_FOLDER}/logs/review.md` — append rejected findings only

**No files created if:**
- No ISSUE_KEY or TASK_FOLDER
- Zero rejections and no changes applied
