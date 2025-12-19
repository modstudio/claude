# Module: youtrack-fetch-issue

## Purpose
Fetch issue details from YouTrack.

## Scope
SHARED - Used by: task-planning, code-review, release workflows

## Mode
READ-ONLY

---

## Inputs
- `ISSUE_KEY`: Issue key (e.g., STAR-1234)

---

## Instructions

### Step 1: Fetch Issue
```javascript
mcp__youtrack__get_issue({
  issue_id: "$ISSUE_KEY"
})
```

### Step 2: Extract Key Fields
From response, extract:
- `summary`: Issue title
- `description`: Issue description
- `type`: Bug, Task, Feature
- `priority`: Critical, Normal, Low
- `state`: Open, In Progress, Done
- `assignee`: Assigned user
- `links`: Related issues

### Step 3: Fetch Related Issues (if needed)
```javascript
// For each linked issue
mcp__youtrack__get_issue({
  issue_id: "{LINKED_ISSUE_KEY}"
})
```

---

## Output Format

```markdown
## Issue: {ISSUE_KEY}

**{summary}**

| Field | Value |
|-------|-------|
| Type | {type} |
| Priority | {priority} |
| Status | {state} |
| Assignee | {assignee} |

### Description
{description}

### Related Issues
- {LINK-123}: {summary} ({relationship})
```

---

## Error Handling

**Issue not found:**
→ Report: "Issue {ISSUE_KEY} not found in YouTrack"
→ Ask user to verify issue key

**YouTrack unavailable:**
→ Report: "Cannot connect to YouTrack"
→ Ask: "Continue with manual input?"

---

## Outputs
- `SUMMARY`: Issue summary
- `DESCRIPTION`: Issue description
- `ISSUE_TYPE`: Bug/Task/Feature
- `PRIORITY`: Priority level
- `STATE`: Current state
- `LINKS`: Array of related issues
