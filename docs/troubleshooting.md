# Troubleshooting Guide

**Version:** 2.0.0
**Last Updated:** 2025-11-20

---

## Common Issues

### .wip Folder Not Found

**Error:** `.wip folder not found in project directory`

**Cause:** Project doesn't have a `.wip/` folder yet (it's project-local, not global)

**Fix:**
```bash
# Create .wip folder in your project directory
cd /path/to/your/project
mkdir .wip

# Add to .gitignore
echo '.wip' >> .gitignore
```

**Why this happens:** In v2.0, `.wip` is project-local (each project has its own), not global (`~/.wip`).

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

**Warning:** `Task folder already exists: .wip/STAR-1234-Feature-Name`

**Cause:** Trying to create a task folder that already exists

**Not an error:** This is usually fine - workflows will use the existing folder

**If you want to start fresh:**
```bash
# Archive the old folder
mv .wip/STAR-1234-Old-Name .wip/archive/STAR-1234-Old-Name

# Or delete it (careful!)
rm -rf .wip/STAR-1234-Old-Name
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

**Error:** `Permission denied` when creating .wip or running scripts

**Cause:** File permissions or ownership issues

**Fix:**
```bash
# Check permissions
ls -la .

# Fix permissions on .wip
chmod 755 .wip

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

4. **Review upgrade plan:** See `/Users/shmuel/claude-workflows-upgrade-plan.md`

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

**Last Updated:** 2025-11-20
**Version:** 2.0.0
