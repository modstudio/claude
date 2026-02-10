# Module: ensure-docs-structure

## Purpose
Verify all task docs exist, create any missing files/folders.

## Scope
TASK-PLANNING specific

## Mode
WRITE-ENABLED (only for creating missing docs)

---

## When to Use
- Before reading docs in any skill
- In-Progress mode (before reconciliation)
- Any time you need to ensure docs exist

---

## Required Structure

{{MODULE: ~/.claude/modules/task-planning/standard-docs-structure.md}}

---

## Instructions

### Step 1: Check Folder Exists

```bash
TASK_FOLDER=$(find "$PROJECT_TASK_DOCS_DIR" -type d -name "${ISSUE_KEY}*" 2>/dev/null | head -1)

if [ -z "$TASK_FOLDER" ]; then
  echo "FOLDER_MISSING"
else
  echo "FOLDER_EXISTS: $TASK_FOLDER"
fi
```

### Step 2: If Folder Missing → Create All

**Use create-task-folder module:**

{{MODULE: ~/.claude/modules/task-planning/create-task-folder.md}}

### Step 3: If Folder Exists → Verify Completeness

```bash
REQUIRED_FILES=(
  "00-status.md"
  "01-task-description.md"
  "02-functional-requirements.md"
  "03-implementation-plan.md"
  "04-todo.md"
  "logs/decisions.md"
  "logs/review.md"
)

MISSING=""
for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$TASK_FOLDER/$file" ]; then
    MISSING="$MISSING $file"
  fi
done

if [ -n "$MISSING" ]; then
  echo "MISSING:$MISSING"
else
  echo "ALL_FILES_PRESENT"
fi
```

### Step 4: Create Missing Files

**If logs/ directory missing:**
```bash
mkdir -p "$TASK_FOLDER/logs"
```

**If individual files missing → render from templates:**
```bash
source ~/.claude/lib/template-utils.sh
# Render only the missing templates
```

### Step 5: Verify (MANDATORY)

```bash
ls -la "$TASK_FOLDER"
ls -la "$TASK_FOLDER/logs"
```

**Do NOT proceed until verified:**
- [ ] All 5 main docs exist
- [ ] `logs/` directory exists
- [ ] `logs/decisions.md` exists
- [ ] `logs/review.md` exists

---

## Outputs
- `TASK_FOLDER`: Path to task docs folder
- `DOCS_VERIFIED`: true/false
