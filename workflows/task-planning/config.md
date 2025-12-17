# Task Planning Configuration

**Central configuration for task planning workflows**

---

## Storage Configuration

### `.task-docs` Folder Location

**IMPORTANT**: The `.task-docs` folder is PROJECT-LOCAL and stored in the project directory.

```bash
# Location
TASK_DOCS_DIR="./.task-docs"  # Or use: $(get_task_docs_dir)

# Usage examples
TASK_FOLDER="./.task-docs/${ISSUE_KEY}-${slug}"

# Search command
find "./.task-docs" -type d -name "${ISSUE_KEY}*"
```

### Why Project-Local?

- **Project-Specific**: Task documentation stays with the relevant project
- **Gitignored**: Add `.task-docs` to `.gitignore` to keep it out of version control
- **Context-Aware**: Tasks are automatically associated with their codebase
- **Independent**: Each project has its own task workspace

### Setup Requirements

**Each project must have a `.task-docs` folder:**

```bash
# Create .task-docs folder in project root
mkdir .task-docs

# Add to .gitignore
echo '.task-docs' >> .gitignore
```

If the `.task-docs` folder is missing, workflows will report an error and ask for guidance.

---

## How to Use in Workflows

### In Bash Scripts

**Always use the helper function and check for errors:**

```bash
# Load configuration using helper
TASK_DOCS_DIR=$(get_task_docs_dir)

# Check if .task-docs folder exists
if [ -z "$TASK_DOCS_DIR" ]; then
  echo "ERROR: No .task-docs folder found in project directory"
  echo "Please create one: mkdir .task-docs && echo '.task-docs' >> .gitignore"
  exit 1
fi

# Create new task folder
mkdir -p "$TASK_DOCS_DIR/${ISSUE_KEY}-${slug}"

# Search for existing task
TASK_FOLDER=$(find "$TASK_DOCS_DIR" -type d -name "${ISSUE_KEY}*" 2>/dev/null | head -1)

# List all tasks
ls -la "$TASK_DOCS_DIR/"
```

### In Documentation

When referencing `.task-docs` folders in workflow docs:
- Use: `.task-docs/{ISSUE_KEY}-{slug}/` (project-local)
- Use: `$(get_task_docs_dir)/{ISSUE_KEY}-{slug}/` (using helper)
- Don't use: `~/.task-docs/` or `$HOME/.task-docs/` (implies global location)

### In Commands

Use the helper function for portability:

```bash
# Good ✅
TASK_DOCS_DIR=$(get_task_docs_dir)
find "$TASK_DOCS_DIR" -type d -name "STAR-*"

# Also acceptable ✅
find .task-docs -type d -name "AB-*"

# Bad ❌
find ~/.task-docs -type d -name "STAR-*"         # Wrong location
find /Users/shmuel/.task-docs -type d -name "*"  # Hardcoded path
```

---

## Project-Specific Configuration

Each project can specify its storage location in its YAML file:

```yaml
# ~/.claude/config/projects/myproject.yaml
storage:
  location: ".task-docs/{ISSUE_KEY}/"  # Default: project-local
  # This will be resolved to: {PROJECT_ROOT}/.task-docs/{ISSUE_KEY}/
```

The `get_task_docs_dir()` helper function automatically detects the project-local `.task-docs` folder.

---

## Migration Notes

**If moving from global to project-local:**

```bash
# For each project, create .task-docs folder
cd ~/Projects/myproject
mkdir .task-docs
echo '.task-docs' >> .gitignore

# Move relevant tasks from global location (if any)
# Example: Move STAR-* tasks to starship project
rsync -av ~/.task-docs/STAR-* ~/Projects/starship/.task-docs/

# Verify
ls -la .task-docs/
```

---

## Best Practices

1. **Always use `get_task_docs_dir()`** - Don't hardcode paths
2. **Check for errors** - Verify `.task-docs` folder exists before operations
3. **Use find command** - More reliable than glob for searching
4. **Add to .gitignore** - Keep `.task-docs` out of version control
5. **Report missing folder** - If `.task-docs` doesn't exist, inform user and ask for guidance

---

**Last Updated**: 2025-11-17
**Purpose**: Single source of truth for `.task-docs` storage location
