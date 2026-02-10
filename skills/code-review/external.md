---
description: Evaluate an external code review independently
---

# External Code Review Evaluation

Evaluate an external code review and independently determine what changes are actually needed.

**Purpose:** Critical evaluation of external reviews (from developers, AI tools, linters)

**Approach:**
1. Detect project context and available tools
2. Load relevant standards and history
3. Analyze current code independently
4. Evaluate each suggestion critically
5. Record evaluation for circular review

---

## ⛔ STOP - MANDATORY FIRST ACTION

**YOU MUST CALL TodoWrite RIGHT NOW before reading any other files or running any commands.**

**Do NOT proceed to "Mode" or "Output Files" until you have called TodoWrite.**

```javascript
TodoWrite({
  todos: [
    {content: "Load project standards", status: "in_progress", activeForm: "Loading standards"},
    {content: "Load current code state", status: "pending", activeForm: "Loading code state"},
    {content: "Wait for external review text", status: "pending", activeForm: "Waiting for review"},
    {content: "Parse external review and check history", status: "pending", activeForm: "Parsing review"},
    {content: "Perform independent analysis", status: "pending", activeForm: "Analyzing independently"},
    {content: "Output evaluation to chat", status: "pending", activeForm: "Outputting evaluation"},
    {content: "Ask user about applying changes", status: "pending", activeForm: "Asking about changes"},
    {content: "Apply changes and record (if approved)", status: "pending", activeForm: "Applying changes"},
    {content: "Generate final summary", status: "pending", activeForm: "Generating summary"}
  ]
})
```

**⛔ DO NOT CONTINUE READING THIS FILE until TodoWrite has been called.**

---

## Mode
READ-ONLY (analysis) + WRITE (to review files)

---

## Output Files

**⚠️ FILES ARE ONLY CREATED WHEN CHANGES ARE APPLIED**

| Scenario | Output |
|----------|--------|
| Evaluating only (no changes) | Chat output only - NO files |
| Applying changes | Create files (see below) |

**When user chooses to apply changes, create:**

1. **Session Review File** (NEW):
   - Location: `${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/logs/review-{YYYYMMDD-HHMMSS}.md`
   - Purpose: Record of what was changed and why

2. **Cumulative Review Log** (APPEND):
   - Location: `${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/logs/review.md`
   - Purpose: Historical record preventing re-evaluation of same suggestions

**DO NOT create files if:**
- User just wants evaluation/opinion
- No changes are applied
- User says "just review" or "what do you think"

---

## Phase 0: Project Context Detection

{{MODULE: ~/.claude/modules/shared/quick-context.md}}

**Severity Levels:** {{MODULE: ~/.claude/modules/code-review/severity-levels.md}}

**Citation Format:** {{MODULE: ~/.claude/modules/code-review/citation-standards.md}}

---

## Step 1: Load Project Standards

{{MODULE: ~/.claude/modules/shared/standards-loading.md}}

**Load business context:**
1. Run `~/.claude/lib/bin/gather-context` for task docs
2. Use YouTrack MCP if available
3. Ask user for context if needed

**STOP - Standards loaded, ready for external review**

---

## Step 2: Load Current Code State

{{MODULE: ~/.claude/modules/shared/full-context.md}}

**Use "For Code Review Mode" section.**

**STOP - Context loaded, ready for review text**

---

## Step 3: User Pastes External Review

**Now please paste the external code review text below:**

*Waiting for you to paste the review...*

---

## Step 4: Parse External Review

### 4.1 Extract Suggestions
- Parse review text
- Identify individual suggestions
- Extract file/line references
- Categorize by severity
- Note reviewer source/tool

### 4.2 Load Previous Review History (CIRCULAR REVIEW PREVENTION)

**CRITICAL: Read cumulative log BEFORE evaluating new suggestions**

```bash
TASK_FOLDER=$(find "$PROJECT_TASK_DOCS_DIR" -type d -name "${ISSUE_KEY}*" 2>/dev/null | head -1)
REVIEW_FILE="$TASK_FOLDER/logs/review.md"

if [ -f "$REVIEW_FILE" ]; then
  echo "=== PREVIOUS REVIEW DECISIONS ==="
  cat "$REVIEW_FILE"
  echo "=== END PREVIOUS DECISIONS ==="
fi
```

### 4.3 Check for Duplicates (MANDATORY)

**For EACH new suggestion, check the cumulative log:**

| Check | Action |
|-------|--------|
| Same suggestion, same context | **SKIP** - reference past decision |
| Same suggestion, different context | **RE-EVALUATE** - note context change |
| Similar suggestion | **REFERENCE** - maintain consistency |
| New suggestion | **EVALUATE** - proceed normally |

**If duplicate found, output:**
```markdown
### Suggestion #N: {Title}

**Status:** DUPLICATE - See Review #{X} from {date}

**Past Decision:** {ACCEPT/MODIFY/REJECT}
**Past Reasoning:** {brief quote from past review}

**Current Action:** Skipping - past decision still applies
```

**This prevents:**
- Re-debating already-decided issues
- Inconsistent decisions across reviews
- Wasted evaluation time on resolved topics

---

## Step 5: Independent Analysis

For EACH suggestion from external review:

### 5.1 Verify the Issue
- Read actual code
- Does issue actually exist?
- Is it accurately described?
- What's the actual impact?

### 5.2 Check Against Standards
- Reference loaded standards
- Does it violate documented rules?
- Use project citation format

### 5.3 Evaluate Suggested Fix
- Is the proposed fix correct?
- Does it align with architecture?
- Are there better alternatives?

### 5.4 Determine Priority
- **CRITICAL:** Must fix (correctness, security)
- **MAJOR:** Should fix (substantial issues)
- **MINOR:** Nice to have
- **NOT AN ISSUE:** Reject

---

## Step 6: Output Evaluation to Chat

**Output evaluation summary directly to chat:**

```markdown
# External Review Evaluation

**Summary:**
- Analyzed: {count} suggestions
- Accepted: {count} (would apply)
- Modified: {count} (would apply differently)
- Rejected: {count} (not needed)

[For each suggestion: brief verdict and reasoning]
```

**DO NOT create any files at this step.**

---

## Step 7: Ask User About Changes

**Ask user:**
> "Evaluation complete. Would you like me to:
> - [ ] Apply all ACCEPTED changes
> - [ ] Apply CRITICAL changes only
> - [ ] Show patches for manual review
> - [ ] Skip implementation (done)"

---

## Step 8: Apply Changes (Only if user approves)

**If user chooses to apply changes:**

1. Apply changes using Edit tool
2. Run verification tests
3. Report results
4. **THEN create record files:**

{{MODULE: ~/.claude/modules/code-review/session-review-file.md}}

{{MODULE: ~/.claude/modules/code-review/append-review-log.md}}

**If user skips implementation:**
- Do NOT create any files
- Evaluation was chat-only

---

## Step 9: Final Summary

```markdown
# External Review Evaluation Complete

**Summary:**
- Analyzed: {count} suggestions
- Accepted: {count}
- Modified: {count}
- Rejected: {count}

**Changes Applied:** {Yes/No}
**Files Created:** {Only if changes were applied}

**Next Steps:**
[If changes applied: review, test, commit]
[If no changes: done - evaluation was informational only]
```

---

## Evaluation Principles

**ACCEPT when:**
- Real issue confirmed in actual code
- Violates documented project standards
- Creates security vulnerability
- Causes actual bugs

**REJECT when:**
- Issue doesn't exist in actual code
- It's an intentional project pattern
- External reviewer misunderstood architecture
- Change would violate standards

**MODIFY when:**
- Issue is real BUT proposed fix is wrong
- Better solution exists
- Fix needed but different approach required

**I am NOT:**
- A rubber stamp for external reviews
- Obligated to implement all suggestions

**I AM:**
- An independent evaluator
- Guardian of project standards
- Final decision maker on changes

---

**Now waiting for external code review text to evaluate...**
