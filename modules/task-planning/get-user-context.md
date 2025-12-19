# Module: get-user-context

## Purpose
Get task context directly from user when no issue key exists (greenfield scenario).

## Scope
TASK-PLANNING specific

## Mode
READ-ONLY (gathering info from user)

---

## When to Use
- No issue key found in branch
- User wants to plan something new
- Exploratory/prototype work

---

## Instructions

### Step 1: Ask for Task Overview

```javascript
AskUserQuestion({
  questions: [{
    question: "What task would you like to plan?",
    header: "Task Overview",
    multiSelect: false,
    options: [
      {label: "New feature", description: "Adding new functionality"},
      {label: "Bug fix", description: "Fixing an issue"},
      {label: "Refactoring", description: "Improving existing code"},
      {label: "Exploration", description: "Investigating/prototyping"}
    ]
  }]
})
```

### Step 2: Get Task Summary

Ask user: "Please describe the task in one sentence (this will be the title):"

```
SUMMARY = user response
```

### Step 3: Get Additional Context

Ask user:
- "What problem are you trying to solve?"
- "Any constraints or requirements I should know?"
- "Is this related to any existing code?"

### Step 4: Generate Placeholder Issue Key

```bash
# For exploratory work without YouTrack issue
ISSUE_KEY="EXPLORATORY"
SLUG=$(generate_slug "$SUMMARY")
# Result: EXPLORATORY-{slug}
```

### Step 5: Offer to Create YouTrack Issue

```markdown
I have enough context to start planning.

**Options:**
1. Continue with exploratory folder (can create YouTrack issue later)
2. Create YouTrack issue now and use that

Which would you prefer?
```

**If user wants YouTrack issue:**
→ Module: `~/.claude/modules/shared/youtrack-create-issue.md`
→ Use returned ISSUE_KEY instead of EXPLORATORY

---

## Output Summary

```markdown
## Task Context (from user)

**Summary:** {SUMMARY}
**Type:** {feature/bugfix/refactor/exploration}

### Context
{User's problem description}

### Constraints
{Any constraints mentioned}

### Related Code
{Any existing code mentioned}
```

---

## Outputs
- `ISSUE_KEY` - "EXPLORATORY" or real key if created
- `SUMMARY` - Task title from user
- `TASK_TYPE` - feature/bugfix/refactor/exploration
- `USER_CONTEXT` - Additional context gathered
