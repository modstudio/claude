# Article Mode - Direct Article Updates

**Mode**: Update specific knowledge base article(s) directly
**When to use**: When user knows exactly which article needs updating, no task context required

---

## Phase 0: Project Context

{{MODULE: ~/.claude/modules/docs/project-variables.md}}

---

## Assumptions

- User has identified specific article(s) to update
- Knowledge base location is configured in project YAML (`PROJECT_KB_LOCATION`)
- Update may or may not be related to a specific task
- Changes are known or can be determined by reviewing current implementation

---

## 📋 MANDATORY: Initialize Todo List

{{MODULE: ~/.claude/modules/shared/todo-patterns.md}}

**IMMEDIATELY create a todo list for article mode phases:**

```javascript
TodoWrite({
  todos: [
    {content: "Article selection - identify article(s) to update", status: "in_progress", activeForm: "Selecting articles"},
    {content: "Article fetch - read current content", status: "pending", activeForm: "Fetching article content"},
    {content: "Change analysis - determine what needs updating", status: "pending", activeForm: "Analyzing changes needed"},
    {content: "Update creation - create updated version", status: "pending", activeForm: "Creating updated version"},
    {content: "Summary - document changes made", status: "pending", activeForm: "Generating summary"}
  ]
})
```

**Update the todo list as you progress through each phase. Mark tasks complete immediately upon finishing them.**

---

## Step 1: Article Selection

### A) Get Article Input

**Option 1: User provides article name**
```
User: "Update the Warehouse-Queue-Management article"
```

**Option 2: User provides article path**
```
User: "Update storage/app/youtrack_docs/Warehouse-Queue-Management.md"
```

**Option 3: Browse available articles**
```bash
# List all articles in knowledge base
ls -la "$PROJECT_KB_LOCATION/"
```

### B) Resolve Article Location

```bash
# Knowledge base from project config
KB_LOCATION="$PROJECT_KB_LOCATION"

# Find article by name
ARTICLE_PATH="$KB_LOCATION/{article-name}.md"

# Verify exists
if [ ! -f "$ARTICLE_PATH" ]; then
  echo "ERROR: Article not found: $ARTICLE_PATH"
  ls "$KB_LOCATION/"*.md
  exit 1
fi
```

### C) Handle Multiple Articles

If user specifies multiple articles:

```markdown
## Articles Selected for Update

1. [ ] Warehouse-Queue-Management.md
2. [ ] Order-Processing-Flow.md
3. [ ] Inventory-Management.md

Process each article sequentially through remaining phases.
```

---

## Step 2: Article Fetch

### A) Read Current Content

```bash
# Read full article
ARTICLE_CONTENT=$(cat "$ARTICLE_PATH")
```

### B) Extract Article Structure

```markdown
## Article Analysis: {Article Name}

### Metadata
- **Location:** {full path}
- **Last Modified:** {file date}
- **Size:** {file size}

### Structure
- Title: {article title}
- Sections: {list of H2/H3 headers}
- Code blocks: {count}
- Images/Screenshots: {count}

### Current Content Summary
{Brief summary of what the article covers}
```

### C) Present to User

```markdown
# Current Article: {Article Name}

## Structure

1. Overview
2. Prerequisites
3. Process Flow
4. Examples
5. Troubleshooting

---

## Content Preview

{First 50 lines or so of content}

---

What would you like to update in this article?
```

---

## Step 3: Change Analysis

{{MODULE: ~/.claude/modules/shared/approval-gate.md}}

### A) Determine Update Scope

- Use **AskUserQuestion** tool
- Question: "What type of update does this article need?"
- Allow multiple selections
- Options:
  1. **Fix errors** - Correct inaccurate information
  2. **Add content** - Add new sections or expand existing
  3. **Update examples** - Refresh code samples or workflows
  4. **Remove outdated** - Delete deprecated content
  5. **Restructure** - Reorganize article layout

**Wait for user to confirm update scope before proceeding to Step 4.**

### B) Get Specific Changes

Based on update type, gather details:

**For "Fix errors":**
- Which section has the error?
- What is incorrect?
- What should it say?

**For "Add content":**
- What new content is needed?
- Where should it go?
- What is the source (code, feature, process)?

**For "Update examples":**
- Which examples are outdated?
- What's the current correct approach?

**For "Remove outdated":**
- What content is no longer relevant?
- Why is it deprecated?
- Should anything replace it?

**For "Restructure":**
- How should it be reorganized?
- What's the new logical flow?

### C) Analyze Current Implementation (if needed)

If user isn't sure what's wrong, analyze current implementation:

```bash
# Search codebase for related functionality
grep -r "{feature_keyword}" app/
```

Compare implementation with article content to identify gaps.

---

## Step 4: Update Creation

### Prerequisites: Load Style Guide

{{MODULE: ~/.claude/modules/docs/style-guide-loading.md}}

Before creating any updated articles, ensure documentation style guide is loaded and understood.

### A) Determine Output Location

**If task context exists:**
```bash
# Use task folder
DOCS_FOLDER="$TASK_FOLDER/docs-updates"
mkdir -p "$DOCS_FOLDER"
OUTPUT_FILE="$DOCS_FOLDER/{article-name}.md"
```

**If no task context (standalone):**
```bash
# Create standalone docs-updates folder
STANDALONE_FOLDER="${TASK_DOCS_DIR}/docs-updates-$(date +%Y%m%d)"
mkdir -p "$STANDALONE_FOLDER"
OUTPUT_FILE="$STANDALONE_FOLDER/{article-name}.md"
```

### B) Create Updated Article

1. **Start with original** - Copy current article content
2. **Verify code alignment** - Review ALL related code implementing features
3. **Apply changes** - Make requested updates based on code reality
4. **Write in present tense** - All implemented features in present tense
5. **Add Summary of Changes** - REQUIRED at end of every updated document

**Updated Article Format:**

```markdown
---
original_article: "{article-name}.md"
update_mode: "article"
update_date: "{current-date}"
update_reason: "{user-provided reason}"
related_task: "{ISSUE_KEY if applicable, otherwise 'standalone'}"
---

# {Article Title}

{Updated article content...}

---

## Summary of Changes

**Date:** {current-date}
**Type:** {fix errors|add content|update examples|remove outdated|restructure}

### Changes Made
1. {Change 1}
2. {Change 2}
3. {Change 3}

### Sections Modified
| Section | Change Type | Description |
|---------|-------------|-------------|
| {Section 1} | {type} | {what changed} |

### Code Alignment Verification
**Files Reviewed:**
- `{file1}` - {verification notes}

### Reason for Update
{Why this update was needed}
```

---

## Step 5: Summary

### A) Present Updated Article

```markdown
# Updated Article: {Article Name}

## Changes Summary

| Section | Change Type | Description |
|---------|-------------|-------------|
| Overview | Edit | Fixed incorrect description |
| Process Flow | Addition | Added Step 4 |
| Examples | Update | New API endpoint |

---

## Updated Content

{Full updated article content}

---

## Next Steps

1. [ ] Review the updated article above
2. [ ] Request revisions if needed
3. [ ] Sync to knowledge base when approved

Would you like to make any changes?
```

### B) Create Summary File (if multiple articles)

If multiple articles were updated, create `_summary.md`:

```markdown
# Article Mode Update Summary

**Date:** {current-date}
**Mode:** Article Mode (direct update)

## Articles Updated

### 1. {Article Name 1}
- **Update Type:** {type}
- **Changes:** {summary}
- **Output:** `{path to updated file}`

### 2. {Article Name 2}
- **Update Type:** {type}
- **Changes:** {summary}
- **Output:** `{path to updated file}`

## Sync Instructions
{Instructions for syncing to knowledge base}
```

---

## Checklist

### Step 1: Article Selection
- [ ] Get article name/path from user
- [ ] Resolve full article path
- [ ] Verify article exists

### Step 2: Article Fetch
- [ ] Read current article content
- [ ] Parse article structure
- [ ] Present to user

### Step 3: Change Analysis
- [ ] Determine update type(s)
- [ ] Get specific change details
- [ ] Analyze implementation if needed

### Step 4: Update Creation
- [ ] Determine output location
- [ ] Create updated article
- [ ] Add Summary of Changes

### Step 5: Summary
- [ ] Present updated article
- [ ] Create summary file if multiple
- [ ] Get user approval

---

## Standalone Mode

When no task context and user just wants to fix docs:

### Create Standalone Output Folder

```bash
# Date-stamped folder for ad-hoc updates
STANDALONE_FOLDER="${TASK_DOCS_DIR}/docs-updates-$(date +%Y%m%d)"
mkdir -p "$STANDALONE_FOLDER"
```

### Standalone Summary

```markdown
# Standalone Documentation Update

**Date:** {current-date}
**Articles Updated:** {count}

## Updates

1. **{Article 1}** - {changes summary}
2. **{Article 2}** - {changes summary}

## Output Location
All updated articles are in: `${TASK_DOCS_DIR}/docs-updates-{date}/`
```

---

## Best Practices

### When to Use Article Mode

**Use when:**
- User knows exactly which article needs updating
- Quick fix for obvious error
- Adding missing information
- Documentation improvement outside task context

**Don't use when:**
- Major feature implementation (use Task Mode)
- Not sure which articles are affected (use Task Mode)
- Want comprehensive review (use Task Mode)

### Tips

1. **Read the whole article** - Understand context before changes
2. **Keep voice consistent** - Match existing writing style
3. **Preserve formatting** - Don't change structure unnecessarily
4. **Document why** - Always explain reason for update

---

**Return to**: [Update Docs README](./README.md)
