# Module: create-task-folder

## Purpose
Create task documentation folder with all standard templates.

## Scope
TASK-PLANNING specific

## Mode
WRITE-ENABLED

---

## Inputs
- `ISSUE_KEY`: Issue key (e.g., STAR-1234)
- `SUMMARY`: Issue summary (for slug generation)

---

## Prerequisites
- Must have ISSUE_KEY
- Must have SUMMARY (from YouTrack or user)

---

## Instructions

### Step 1: Generate Slug
```bash
source ~/.claude/lib/issue-utils.sh
SLUG=$(generate_slug "$SUMMARY")
# "Fix Login Error" → "Fix-Login-Error"
```

### Step 2: Create Folder
```bash
source ~/.claude/lib/task-docs-utils.sh
TASK_FOLDER=$(create_task_folder "$ISSUE_KEY" "$SLUG")
# Creates: ${TASK_DOCS_DIR}/{ISSUE_KEY}-{SLUG}/
```

### Step 3: Render All Templates
```bash
source ~/.claude/lib/template-utils.sh
render_task_planning_docs "$TASK_FOLDER" "$ISSUE_KEY" \
  TASK_SUMMARY="$SUMMARY" \
  STATUS="Discovery"
```

### Step 4: VERIFY (MANDATORY)
```bash
ls -la "$TASK_FOLDER"
```

**Expected structure:**
```
{ISSUE_KEY}-{SLUG}/
├── 00-status.md
├── 01-task-description.md
├── 02-functional-requirements.md
├── 03-implementation-plan.md
├── 04-todo.md
└── logs/
    ├── decisions.md
    └── review.md
```

---

## Verification Checklist

- [ ] Folder exists at `${TASK_DOCS_DIR}/{ISSUE_KEY}-{SLUG}/`
- [ ] `00-status.md` exists
- [ ] `01-task-description.md` exists
- [ ] `02-functional-requirements.md` exists
- [ ] `03-implementation-plan.md` exists
- [ ] `04-todo.md` exists
- [ ] `logs/` directory exists
- [ ] `logs/decisions.md` exists
- [ ] `logs/review.md` exists

**⚠️ Do NOT mark todo complete until ALL files verified!**

---

## Error Handling

**Folder creation failed:**
→ Check: Does `${TASK_DOCS_DIR}` exist?
→ Check: Write permissions?
→ Try: `mkdir -p "${TASK_DOCS_DIR}"`
→ Report error and ask user

**Templates not rendered:**
→ Check: Do templates exist in `~/.claude/templates/task-planning/`?
→ Report missing templates

---

## Outputs
- `TASK_FOLDER`: Full path to created folder
