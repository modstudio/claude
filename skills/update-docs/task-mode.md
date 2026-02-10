# Task Mode - Update Docs from Task Implementation

**Mode**: Update knowledge base documentation based on task implementation changes
**When to use**: After completing a task, to ensure documentation reflects new/changed functionality

---

## Phase 0: Project Context

{{MODULE: ~/.claude/modules/docs/project-variables.md}}

---

## Assumptions

- Task has been implemented (code changes exist)
- `${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/` folder exists with planning docs
- Knowledge base location is configured in project YAML (`PROJECT_KB_LOCATION`)
- User wants to update docs to reflect implementation changes

---

## 📋 MANDATORY: Initialize Todo List

{{MODULE: ~/.claude/modules/shared/todo-patterns.md}}

**IMMEDIATELY create a todo list for task mode phases:**

```javascript
TodoWrite({
  todos: [
    {content: "Discovery - analyze task and implementation", status: "in_progress", activeForm: "Analyzing task context"},
    {content: "Article search - find relevant KB articles", status: "pending", activeForm: "Searching knowledge base"},
    {content: "Impact analysis - determine update needs", status: "pending", activeForm: "Analyzing impact"},
    {content: "Review list - present articles for confirmation", status: "pending", activeForm: "Presenting review list"},
    {content: "Article check - detailed comparison", status: "pending", activeForm: "Checking articles"},
    {content: "Update creation - create updated versions", status: "pending", activeForm: "Creating updates"},
    {content: "Summary - generate summary and checklist", status: "pending", activeForm: "Generating summary"}
  ]
})
```

**Update the todo list as you progress through each phase. Mark tasks complete immediately upon finishing them.**

---

## Step 1: Discovery

### A) Get Task Context

```bash
# Get issue key (from user input or branch)
ISSUE_KEY="${1:-$(extract_issue_key_from_branch)}"

# Validate issue key
if ! validate_issue_key "$ISSUE_KEY" "$PROJECT_ISSUE_REGEX"; then
  echo "ERROR: Invalid or missing issue key"
  exit 1
fi

# Find task folder
TASK_FOLDER=$(find_task_dir "$ISSUE_KEY")
if [ -z "$TASK_FOLDER" ]; then
  echo "ERROR: No task folder found for $ISSUE_KEY"
  exit 1
fi
```

### B) Analyze Implementation Changes

**Read task planning documents:**

1. `00-status.md` - Current status, what was completed
2. `01-task-description.md` - High-level summary
3. `02-functional-requirements.md` - What requirements were implemented
4. `03-implementation-plan.md` - Detailed implementation approach
5. `logs/decisions.md` - Technical decisions that affect documentation

**Extract key information:**
- What features were added/changed?
- What workflows were modified?
- What APIs/endpoints changed?
- What user-facing changes occurred?

### C) Get Code Changes Summary

```bash
# Get files changed in this task's branch
git diff --name-only $PROJECT_BASE_BRANCH..HEAD

# Get commit messages for context
git log --oneline $PROJECT_BASE_BRANCH..HEAD
```

---

## Step 2: Article Search

### A) Identify Search Terms

Based on implementation analysis, extract:
- **Feature names** (e.g., "Warehouse Queue", "Order Processing")
- **Domain terms** (e.g., "inventory", "shipment", "product matching")
- **Workflow names** (e.g., "fulfillment flow", "receiving process")

### B) Search Knowledge Base

```bash
# Knowledge base location from project config
KB_LOCATION="$PROJECT_KB_LOCATION"

# Search for articles matching feature terms
find "$KB_LOCATION" -name "*.md" -type f | while read article; do
  if grep -l -i "search_term" "$article" 2>/dev/null; then
    echo "$article"
  fi
done
```

### C) Build Candidate List

```markdown
## Candidate Articles for Review

Based on implementation of {ISSUE_KEY} - {Task Summary}:

### Likely Affected (search term matches)
1. [ ] **Warehouse-Queue-Management.md** - Contains "warehouse", "queue"
2. [ ] **Order-Processing-Flow.md** - Contains "order", "processing"

### Possibly Affected (related topics)
3. [ ] **Shipment-Workflows.md** - Related to fulfillment

### User-Suggested
4. [ ] {Add any articles user specifically mentions}
```

---

## Step 3: Impact Analysis

### A) Read Each Candidate Article

For each article:
1. Read full article content using Read tool
2. Extract key sections
3. Compare with implementation

### B) Determine Update Need

Classify each article as:
- **No Update Needed** - Article is still accurate
- **Minor Update** - Small corrections or additions
- **Major Update** - Significant sections need rewriting
- **New Section Needed** - Add new content for new features

### C) Document Impact

```markdown
## Impact Analysis: {Article Name}

**Current State:** {Brief summary}

**Implementation Changes:**
- {Change 1 that affects this article}
- {Change 2 that affects this article}

**Specific Sections Affected:**
- Section "XYZ": Describes old workflow, needs update

**Update Classification:** Minor Update / Major Update / etc.
```

---

## Step 4: Review List

{{MODULE: ~/.claude/modules/shared/approval-gate.md}}

### Present Review Checklist to User

```markdown
# Documentation Review Checklist

**Task:** {ISSUE_KEY} - {Task Summary}

## Articles to Update

| # | Article | Update Type | Sections Affected | Action |
|---|---------|-------------|-------------------|--------|
| 1 | Warehouse-Queue-Management.md | Major | Process Flow | Update |
| 2 | Order-Processing-Flow.md | Minor | Example code | Update |
| 3 | Inventory-Management.md | None | N/A | Skip |

## Summary
- **Total articles reviewed:** 5
- **Articles needing updates:** 2
- **No updates needed:** 3
```

### Ask User to Confirm

- Use **AskUserQuestion** tool
- Question: "I've identified articles that may need updating. Would you like to proceed?"
- Options:
  1. **Proceed with updates** - Create updated versions of identified articles
  2. **Let me review first** - Show detailed analysis before proceeding
  3. **Add more articles** - I have additional articles to include
  4. **Skip some articles** - Remove some from the update list

**STOP and wait for explicit approval before proceeding to Step 5.**

---

## Step 5: Article Check (Detailed Review)

For each article marked for update:

### A) Read Current Article

```bash
KB_ARTICLE="$PROJECT_KB_LOCATION/{article-name}.md"
```

### B) Create Comparison

```markdown
## Article Check: {Article Name}

### Current Content Summary
{Summary of what the article currently says}

### Implementation Reality
{Summary of what was actually implemented}

### Discrepancies Found

1. **Section: {Section Name}**
   - Current: "{Current text}"
   - Should be: "{Correct text based on implementation}"

2. **Section: {Section Name}**
   - Current: Missing
   - Should add: "{New content needed}"
```

---

## Step 6: Update Creation

### Prerequisites: Load Style Guide

{{MODULE: ~/.claude/modules/docs/style-guide-loading.md}}

Before creating any updated articles, ensure documentation style guide is loaded and understood.

### A) Create docs-updates Folder

```bash
DOCS_FOLDER="$TASK_FOLDER/docs-updates"
mkdir -p "$DOCS_FOLDER"
```

### B) Create Updated Article

For each article that needs updating:

1. **Start with original content** - Copy current article as base
2. **Verify code alignment** - Review ALL related code implementing features
3. **Apply changes** - Make identified updates based on code reality
4. **Write in present tense** - All implemented features in present tense
5. **Add Summary of Changes** - REQUIRED at end of every updated document

**Updated Article Format:**

```markdown
---
original_article: "{original-article-name}.md"
updated_for_task: "{ISSUE_KEY}"
update_date: "{current-date}"
update_type: "minor|major"
---

# {Article Title}

{Updated article content here...}

---

## Summary of Changes

**Task:** {ISSUE_KEY} - {Task Summary}
**Date:** {current-date}
**Update Type:** {Minor|Major}

### Changes Made
1. Updated "Process Flow" section to reflect new queue management
2. Added new section "Queue Priority Configuration"

### Sections Modified
| Section | Change Type | Description |
|---------|-------------|-------------|
| Overview | Minor edit | Clarified purpose statement |
| Process Flow | Major rewrite | Reflects new queue management |

### Code Alignment Verification
**Files Reviewed:**
- `app/Services/QueueManager.php` - Verified queue logic matches docs
```

### C) Write Updated Article

```bash
UPDATED_FILE="$DOCS_FOLDER/{article-name}.md"
```

**Important:**
- Do NOT overwrite original knowledge base files
- All updates go to `{TASK_FOLDER}/docs-updates/`
- User will review and manually sync to knowledge base

---

## Step 7: Summary Generation

### A) Create Review Checklist

Create `docs-updates/_review-checklist.md`:

```markdown
# Documentation Update Review Checklist

**Task:** {ISSUE_KEY} - {Task Summary}
**Generated:** {current-date}

## Articles Reviewed

| Article | Status | Update File |
|---------|--------|-------------|
| Warehouse-Queue-Management.md | Updated | `Warehouse-Queue-Management.md` |
| Order-Processing-Flow.md | Updated | `Order-Processing-Flow.md` |
| Inventory-Management.md | No change needed | N/A |

## Next Steps
1. [ ] Review each updated article in `docs-updates/` folder
2. [ ] Compare with original articles in knowledge base
3. [ ] Make any additional edits needed
4. [ ] Sync approved updates to knowledge base
```

### B) Create Summary Document

Create `docs-updates/_summary.md`:

```markdown
# Documentation Update Summary

**Task:** {ISSUE_KEY} - {Task Summary}
**Generated:** {current-date}

## Overview
This task implemented {brief description}. The following documentation updates ensure the knowledge base reflects these changes.

## Documentation Impact

### Articles Updated: 2
1. **Warehouse-Queue-Management.md** - Major update
2. **Order-Processing-Flow.md** - Minor update

### Articles Reviewed (No Update): 3
1. **Inventory-Management.md** - Still accurate

## Sync Instructions

### Option 1: Manual Copy
1. Navigate to `{TASK_FOLDER}/docs-updates/`
2. Copy content to corresponding knowledge base article
3. Update article's "Last Modified" date

## Completion Checklist
- [ ] All updated articles reviewed
- [ ] Updates synced to knowledge base
- [ ] docs-updates folder archived/deleted
```

---

## Checklist

### Step 1: Discovery
- [ ] Get issue key
- [ ] Find task folder
- [ ] Read planning documents
- [ ] Get code changes summary

### Step 2: Article Search
- [ ] Identify search terms
- [ ] Search knowledge base
- [ ] Build candidate list

### Step 3: Impact Analysis
- [ ] Read each candidate article
- [ ] Classify update need
- [ ] Document impact

### Step 4: Review List
- [ ] Present checklist to user
- [ ] Get user confirmation

### Step 5: Article Check
- [ ] Read current content
- [ ] Create comparison
- [ ] Document discrepancies

### Step 6: Update Creation
- [ ] Create docs-updates folder
- [ ] Create updated articles
- [ ] Include Summary of Changes

### Step 7: Summary
- [ ] Create review checklist
- [ ] Create summary document
- [ ] Present to user

---

**Return to**: [Update Docs README](./README.md)
