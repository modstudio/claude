# Troubleshooting Guide

**Version:** 2.1.0
**Last Updated:** 2025-12-10

---

## Common Issues

### Task Docs Folder Not Found

**Error:** `.task-docs folder not found in project directory`

**Cause:** Project doesn't have a `.task-docs/` folder yet (it's project-local, not global)

**Fix:**
```bash
# Create .task-docs folder in your project directory
cd /path/to/your/project
mkdir .task-docs

# Add to .gitignore
echo '.task-docs' >> .gitignore
```

**Why this happens:** In v2.0+, `.task-docs` is project-local (each project has its own), not global (`~/.task-docs`).

---

### Project Not Detected

**Error:** `Generic project detected instead of Starship/Alephbeis`

**Cause:** Project detection pattern doesn't match your current directory or git remote

**Debug:**
```bash
# Check current directory
pwd

# Check git remote
git remote get-url origin

# Check project config
cat ~/.claude/config/projects/starship.yaml | grep -A 2 "project:"
```

**Fix:** Update the project YAML config with correct detection patterns:
```yaml
project:
  path: "~/Projects/starship"              # Update this
  git_remote_pattern: "JanusTrade/starship"  # Or this
```

---

### YAML Parse Error

**Error:** `Failed to load project context` or YAML-related errors

**Cause:** Invalid YAML syntax in project configuration file

**Debug:**
```bash
# Validate all YAML configs
~/.claude/tests/validate-yaml.sh

# Check specific file
yq eval . ~/.claude/config/projects/starship.yaml
```

**Fix:**
- Check indentation (use spaces, not tabs)
- Ensure quotes are balanced
- Validate YAML syntax online at yamllint.com
- Compare with a working example

---

### Command Not Found: yq

**Warning:** `yq not installed, using basic YAML parsing`

**Cause:** `yq` command-line YAML processor not installed

**Impact:** Basic YAML parsing still works, but complex nested fields might not load correctly

**Fix (optional):**
```bash
# macOS
brew install yq

# Linux
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
chmod +x /usr/local/bin/yq

# Verify
yq --version
```

---

### YouTrack MCP: Invalid Project ID

**Error:** `Project not found` or `Invalid project` when using YouTrack MCP tools

**Cause:** YouTrack MCP requires the numeric project ID (e.g., `0-0`), not the project key (e.g., `STAR`)

**Debug:**
```bash
# List all projects to find their IDs
# Use the MCP tool: mcp__youtrack__list_projects
```

**Fix:** Update your project YAML config with the correct numeric ID:
```yaml
# In ~/.claude/config/projects/YOUR-PROJECT.yaml
issue_tracking:
  project_id: "0-0"  # Use ID, not key

# Or under mcp_tools section:
mcp_tools:
  youtrack:
    project_id: "0-0"  # Use ID, not key
```

**Known project IDs:**
- Starship (STAR): `0-0`
- Alephbeis (AB): `0-6`

---

### Issue Key Not Found in Branch

**Error:** `Could not determine issue key from current branch`

**Cause:** Not on a feature branch, or branch name doesn't contain issue key

**Debug:**
```bash
# Check current branch
git branch --show-current

# Check expected pattern
echo $PROJECT_ISSUE_REGEX  # After loading project context
```

**Fix:**
- Switch to a feature branch: `git checkout feature/STAR-1234-My-Feature`
- Or provide issue key explicitly when prompted

---

### Task Folder Already Exists

**Warning:** `Task folder already exists: .task-docs/STAR-1234-Feature-Name`

**Cause:** Trying to create a task folder that already exists

**Not an error:** This is usually fine - workflows will use the existing folder

**If you want to start fresh:**
```bash
# Archive the old folder
mv .task-docs/STAR-1234-Old-Name .task-docs/archive/STAR-1234-Old-Name

# Or delete it (careful!)
rm -rf .task-docs/STAR-1234-Old-Name
```

---

### Git Repository Not Found

**Error:** `Not in a git repository`

**Cause:** Running command outside of a git repository

**Fix:**
```bash
# Initialize git if needed
git init

# Or navigate to your project
cd /path/to/your/project
```

---

### Permission Denied

**Error:** `Permission denied` when creating .task-docs or running scripts

**Cause:** File permissions or ownership issues

**Fix:**
```bash
# Check permissions
ls -la .

# Fix permissions on .task-docs
chmod 755 .task-docs

# Fix permissions on scripts
chmod +x ~/.claude/lib/*.sh
chmod +x ~/.claude/tests/*.sh
```

---

### Library Not Found

**Error:** `source: file not found: ~/.claude/lib/common.sh`

**Cause:** Bash library files not in expected location

**Debug:**
```bash
# Check if files exist
ls -la ~/.claude/lib/

# Check CLAUDE_ROOT environment variable
echo $CLAUDE_ROOT
```

**Fix:**
```bash
# Ensure libraries are in correct location
cd ~/.claude
ls lib/*.sh

# If missing, you may need to reinstall or pull latest changes
```

---

## Performance Issues

### Slow Project Detection

**Symptom:** Project detection takes several seconds

**Cause:** Checking many YAML files or slow git operations

**Fix:**
- Reduce number of YAML files in `~/.claude/config/projects/`
- Use specific path patterns in YAML configs
- Ensure git remote is accessible

---

## Getting Help

If you encounter an issue not covered here:

1. **Check logs:** Run with `DEBUG=1` to see detailed logging:
   ```bash
   DEBUG=1 /plan-task-g
   ```

2. **Validate configuration:**
   ```bash
   ~/.claude/tests/validate-yaml.sh
   ```

3. **Check project context:**
   ```bash
   source ~/.claude/lib/project-context.sh
   load_project_context
   show_project_context
   ```

---

## Reporting Issues

When reporting issues, please include:
- Error message (full output)
- Command you ran
- Current directory (`pwd`)
- Git branch (`git branch --show-current`)
- Project being detected (`echo $PROJECT_NAME` after loading context)
- Debug output (`DEBUG=1 <command>`)

---

**Last Updated:** 2025-12-10
**Version:** 2.1.0
