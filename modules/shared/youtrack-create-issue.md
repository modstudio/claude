# Module: youtrack-create-issue

## Purpose
Create a new issue in YouTrack.

## Scope
SHARED - Used by: task-planning (new task), other skills

## Mode
WRITE-ENABLED

---

## Inputs
- `SUMMARY`: Issue title/summary (required)
- `PROJECT_YOUTRACK_PROJECT_ID`: Numeric project ID (from project config)

---

## ⚠️ CRITICAL RULES

### 1. Use Project ID, NOT Project Key
```javascript
// CORRECT - Use numeric project_id
project_id: "$PROJECT_YOUTRACK_PROJECT_ID"  // e.g., "0-0"

// WRONG - Do NOT use project key
project_id: "STAR"  // ❌ Will fail!
```

### 2. Only Provide Summary
```javascript
// CORRECT - Summary only
mcp__youtrack__create_issue({
  project_id: "$PROJECT_YOUTRACK_PROJECT_ID",
  summary: "Issue title from user"
})

// WRONG - Do NOT include description
mcp__youtrack__create_issue({
  project_id: "...",
  summary: "...",
  description: "..."  // ❌ Do NOT include!
})
```

### 3. Let User Add Description
- User adds description via YouTrack UI after creation
- This ensures proper formatting and attachments

---

## Instructions

### Step 1: Verify Project ID Available
```bash
echo $PROJECT_YOUTRACK_PROJECT_ID
# Must be numeric like "0-0", "0-6"
# If empty, ask user or check project config
```

### Step 2: Get Summary from User
```
Ask: "What should the issue title be?"
SUMMARY = user input
```

### Step 3: 🚨 SHOW ISSUE PREVIEW AND GET APPROVAL

**STOP - Present issue to user before creating:**

```markdown
## YouTrack Issue Preview

**Project:** {PROJECT_NAME} ({PROJECT_YOUTRACK_PROJECT_ID})
**Summary:** {SUMMARY}

Ready to create this issue in YouTrack?
```

Ask user: "Does this look correct? Should I create it?"

**DO NOT proceed until user explicitly approves.**

### Step 4: Create Issue
```javascript
mcp__youtrack__create_issue({
  project_id: "$PROJECT_YOUTRACK_PROJECT_ID",
  summary: "$SUMMARY"
})
```

### Step 5: Report Result
```markdown
✅ Created issue: **{NEW_ISSUE_KEY}**

Link: {PROJECT_YOUTRACK_URL}/issue/{NEW_ISSUE_KEY}

You can now add a description in YouTrack.
```

---

## Error Handling

**Invalid project ID:**
→ Error: "Project not found"
→ Check: Are you using project_id (numeric) not project_key?
→ Fix: Use `$PROJECT_YOUTRACK_PROJECT_ID` from project config

**Missing summary:**
→ Ask user for issue title

**Creation failed:**
→ Report error details
→ Ask user to create manually if needed

---

## Outputs
- `NEW_ISSUE_KEY`: Created issue key (e.g., STAR-1234)
