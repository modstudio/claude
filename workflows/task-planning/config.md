# Task Planning Configuration

**Central configuration for task planning workflows**

---

## Storage Configuration

### `.wip` Folder Location

**IMPORTANT**: The `.wip` folder is PROJECT-LOCAL and stored in the project directory.

```bash
# Location
WIP_ROOT="./.wip"  # Or use: $(get_wip_root)

# Usage examples
WIP_FOLDER="./.wip/${ISSUE_KEY}-${slug}"

# Search command
find "./.wip" -type d -name "${ISSUE_KEY}*"
```

### Why Project-Local?

- **Project-Specific**: Task documentation stays with the relevant project
- **Gitignored**: Add `.wip` to `.gitignore` to keep it out of version control
- **Context-Aware**: Tasks are automatically associated with their codebase
- **Independent**: Each project has its own task workspace

### Setup Requirements

**Each project must have a `.wip` folder:**

```bash
# Create .wip folder in project root
mkdir .wip

# Add to .gitignore
echo '.wip' >> .gitignore
```

If the `.wip` folder is missing, workflows will report an error and ask for guidance.

---

## How to Use in Workflows

### In Bash Scripts

**Always use the helper function and check for errors:**

```bash
# Load configuration using helper
WIP_ROOT=$(get_wip_root)

# Check if .wip folder exists
if [ -z "$WIP_ROOT" ]; then
  echo "ERROR: No .wip folder found in project directory"
  echo "Please create one: mkdir .wip && echo '.wip' >> .gitignore"
  exit 1
fi

# Create new task folder
mkdir -p "$WIP_ROOT/${ISSUE_KEY}-${slug}"

# Search for existing task
WIP_FOLDER=$(find "$WIP_ROOT" -type d -name "${ISSUE_KEY}*" 2>/dev/null | head -1)

# List all tasks
ls -la "$WIP_ROOT/"
```

### In Documentation

When referencing `.wip` folders in workflow docs:
- Use: `.wip/{ISSUE_KEY}-{slug}/` (project-local)
- Use: `$(get_wip_root)/{ISSUE_KEY}-{slug}/` (using helper)
- Don't use: `~/.wip/` or `$HOME/.wip/` (implies global location)

### In Commands

Use the helper function for portability:

```bash
# Good ✅
WIP_ROOT=$(get_wip_root)
find "$WIP_ROOT" -type d -name "STAR-*"

# Also acceptable ✅
find .wip -type d -name "AB-*"

# Bad ❌
find ~/.wip -type d -name "STAR-*"         # Wrong location
find /Users/shmuel/.wip -type d -name "*"  # Hardcoded path
```

---

## Project-Specific Configuration

Each project can specify its storage location in its YAML file:

```yaml
# ~/.claude/config/projects/myproject.yaml
storage:
  location: ".wip/{ISSUE_KEY}/"  # Default: project-local
  # This will be resolved to: {PROJECT_ROOT}/.wip/{ISSUE_KEY}/
```

The `get_wip_root()` helper function automatically detects the project-local `.wip` folder.

---

## Migration Notes

**If moving from global to project-local:**

```bash
# For each project, create .wip folder
cd ~/Projects/myproject
mkdir .wip
echo '.wip' >> .gitignore

# Move relevant tasks from global location (if any)
# Example: Move STAR-* tasks to starship project
rsync -av ~/.wip/STAR-* ~/Projects/starship/.wip/

# Verify
ls -la .wip/
```

---

## Best Practices

1. **Always use `get_wip_root()`** - Don't hardcode paths
2. **Check for errors** - Verify `.wip` folder exists before operations
3. **Use find command** - More reliable than glob for searching
4. **Add to .gitignore** - Keep `.wip` out of version control
5. **Report missing folder** - If `.wip` doesn't exist, inform user and ask for guidance

---

**Last Updated**: 2025-11-17
**Purpose**: Single source of truth for `.wip` storage location
