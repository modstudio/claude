---
description: Detect and load project-specific context from YAML configuration
---

# Project Context Detection

Detects which project you're in and loads project-specific configuration from YAML files.

**Purpose:** Provide project-specific context for workflows (code review, external review, etc.)

**Configuration Location:** `~/.claude/config/projects/*.yaml`

---

## How It Works

### Step 1: Detect Current Project

```bash
# Get current directory
CWD=$(pwd)
PROJECT_NAME=$(basename "$CWD")

# Get git remote (if available)
GIT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "none")
```

### Step 2: Match Against Known Projects

**Check project YAML files in `~/.claude/config/projects/`:**

```bash
# List available project configs
ls ~/.claude/config/projects/*.yaml

# For each project YAML:
# - Check if path matches (e.g., ~/Projects/starship)
# - Check if git remote pattern matches (e.g., "JanusTrade/starship")
# - Use first match
```

**Detection logic:**

1. **Check Starship** (`~/.claude/config/projects/starship.yaml`)
   - Path contains: `/starship`
   - OR Git remote contains: `JanusTrade/starship`

2. **Check Alephbeis** (`~/.claude/config/projects/alephbeis.yaml`)
   - Path contains: `/alephbeis-app` or `/alephbeis`
   - OR Git remote contains: `alephbeis`

3. **Fallback to Generic** (`~/.claude/config/projects/generic.yaml`)
   - If no match found
   - Auto-detection mode

### Step 3: Load Project Configuration

**Read YAML file:**
```bash
# Example: Load starship.yaml
PROJECT_CONFIG=$(cat ~/.claude/config/projects/starship.yaml)

# Parse YAML to get:
# - project.name
# - issue_tracking.pattern
# - standards.location
# - citation_format.*
# - storage.location
# - test_commands.*
# - etc.
```

### Step 4: Extract Issue Key

```bash
# Get current branch
BRANCH=$(git branch --show-current)

# Use project's issue pattern
ISSUE_KEY=$(echo "$BRANCH" | grep -oE "${PROJECT_CONFIG.issue_tracking.regex}")
```

### Step 5: Output Context

Provide structured context to calling workflow.

---

## Output Format

When this workflow executes, it returns:

```markdown
# Project Context: {PROJECT_NAME}

**Detected Project:** {project.name}
**Type:** {project.type}
**Current Branch:** {branch}
**Issue Key:** {ISSUE_KEY}

---

## Configuration Source

**YAML File:** `~/.claude/config/projects/{project_name}.yaml`
**Last Modified:** {file_mtime}

---

## Issue Tracking

**Pattern:** {issue_tracking.pattern}
**Regex:** {issue_tracking.regex}
**System:** {issue_tracking.system}
**URL Template:** {issue_tracking.url_template}

---

## Standards

**Location:** {standards.location}

**Files:**
{for each file in standards.files}
- `{file.path}` - {file.purpose}
{end for}

**Main Guide:** {standards.main_guide}

---

## Citation Format

**Architecture:** {citation_format.architecture}
**Style:** {citation_format.style}
**Testing:** {citation_format.testing}

**Examples:**
{for each example in citation_format.examples}
- {example}
{end for}

---

## Storage

**Location:** {storage.location}

**Standard Files:**
{for each file in storage.files}
- {file_name}: `{storage.location}{file_value}`
{end for}

**For this task:**
- External Review: `.task-docs/{ISSUE_KEY}-{slug}/logs/review.md`
- Decisions: `.task-docs/{ISSUE_KEY}-{slug}/logs/decisions.md`

---

## MCP Tools

{for each tool in mcp_tools}
**{tool_name}:** {enabled}
{if enabled}
  Commands: {commands.join(", ")}
{endif}
{end for}

---

## Tech Stack

**Backend:**
- Framework: {tech_stack.backend.framework} {tech_stack.backend.version}
- Language: PHP {tech_stack.backend.php_version}
- Database: {tech_stack.backend.database}
- Architecture: {tech_stack.backend.architecture}

**Frontend:**
- Framework: {tech_stack.frontend.framework} {tech_stack.frontend.version}
- UI: {tech_stack.frontend.ui_library}
- Styling: {tech_stack.frontend.styling}

---

## Docker Configuration

**Required:** {docker.required}
**Compose File:** {docker.compose_file}
**PHP Container:** {docker.containers.php}
**User ID:** {docker.user_id}

---

## Test Commands

**Unit Tests:**
```bash
{test_commands.unit}
```

**All Tests:**
```bash
{test_commands.all}
```

**Specific File:**
```bash
{test_commands.specific_file}
# Replace {FILE_PATH} with actual file path
```

{if test_commands.functional}
**Functional Tests:**
```bash
{test_commands.functional}
```
{endif}

{if test_commands.acceptance}
**Acceptance Tests:**
```bash
{test_commands.acceptance}
```
{endif}

---

## Linter/Quality Commands

{for each linter in linter_commands}
**{linter_name}:**
```bash
{linter_command}
```
{end for}

---

## Documentation

{if documentation.business_docs}
**Business Docs:** {documentation.business_docs}
{endif}

{if documentation.toc_file}
**Table of Contents:** {documentation.toc_file}
{endif}

{if documentation.architecture_examples}
**Architecture Examples:** {documentation.architecture_examples}
{endif}

---

## Project Notes

{notes}

---

**Context loaded successfully from YAML configuration.**
```

---

## For Workflow Authors

When your workflow needs project context:

### Usage Pattern

```markdown
## Phase 0: Load Project Context

Execute `/project-context` workflow.

**Returns:** Project configuration object with all settings.

**Use for:**
- Issue key extraction: `PROJECT.issue_tracking.regex`
- Standards loading: `PROJECT.standards.files[]`
- Citation format: `PROJECT.citation_format.*`
- Storage paths: `PROJECT.storage.location`
- Test commands: `PROJECT.test_commands.*`
- MCP tool availability: `PROJECT.mcp_tools.*`
```

### Example: External Review Workflow

```bash
# 1. Load project context
PROJECT_CONFIG=$(execute project-context)

# 2. Extract issue key using project pattern
ISSUE_KEY=$(git branch --show-current | grep -oE "${PROJECT_CONFIG.issue_tracking.regex}")

# 3. Load standards from project location
for file in "${PROJECT_CONFIG.standards.files[@]}"; do
  cat "${file.path}"
done

# 4. Use project storage location for review log
REVIEW_FILE=".task-docs/STAR-2233-Feature/logs/review.md"
# Result: .task-docs/STAR-2233-Feature/logs/review.md

# 5. Run project-specific tests
eval "${PROJECT_CONFIG.test_commands.unit}"

# 6. Use project citation format
CITATION="${PROJECT_CONFIG.citation_format.architecture}"
# Result: [ARCH §{section-heading}]
```

---

## Adding a New Project

### 1. Create YAML File

Create `~/.claude/config/projects/{project-name}.yaml`:

```yaml
project:
  name: "MyProject"
  type: "Laravel"
  path: "~/Projects/my-project"
  git_remote_pattern: "myorg/my-project"

issue_tracking:
  pattern: "MP-####"
  regex: "MP-[0-9]+"
  system: "Jira"

standards:
  location: ".docs/standards/"
  files:
    - path: ".docs/standards/architecture.md"
      purpose: "Architecture guidelines"

citation_format:
  architecture: "[ARCH: {quote}]"

storage:
  task_docs_dir: ".task-docs/"

test_commands:
  all: "npm test"

# ... rest of configuration
```

### 2. Test Detection

```bash
cd ~/Projects/my-project
/project-context

# Should detect and load your YAML file
```

### 3. Use Template

Copy from existing YAML (starship.yaml or alephbeis.yaml) and modify.

---

## Project YAML Schema

### Required Fields

```yaml
project:
  name: string              # Display name
  type: string              # Laravel/Node/Python/etc
  description: string       # Brief description

issue_tracking:
  pattern: string           # Human-readable (e.g., "STAR-####")
  regex: string             # For extraction (e.g., "STAR-[0-9]+")
  system: string            # YouTrack/Jira/GitHub/etc

standards:
  location: string          # Relative path to standards
  files: array              # List of standard files

citation_format:
  architecture: string      # Citation template
  style: string            # Citation template

storage:
  location: string          # Always ".task-docs/{ISSUE_KEY}/"
  files:
    external_review: string # Filename
    specification: string   # Filename

test_commands:
  all: string              # Command to run all tests
```

### Optional Fields

```yaml
branching:
  base_branch: string
  pattern: string
  types: array

documentation:
  business_docs: string
  toc_file: string

mcp_tools:
  tool_name:
    enabled: boolean
    commands: array

docker:
  required: boolean
  containers:
    php: string

linter_commands:
  linter_name: string

notes: string              # Multi-line notes
```

---

## Auto-Detection (Generic Fallback)

If no project matches, `generic.yaml` is used with auto-detection:

**Auto-detected:**
- Issue pattern from branch names
- Base branch (develop → main → master)
- Standards location (.ai/rules/ → CONTRIBUTING.md → docs/)
- Tech stack from project files
- Test commands from package.json/composer.json

**Limitations:**
- Less specific citations
- May need manual verification
- Test commands might be generic

**Recommendation:** Create specific YAML config for frequently used projects.

---

## Configuration Files Location

```
~/.claude/
├── config/
│   └── projects/
│       ├── starship.yaml       ← Starship project config
│       ├── alephbeis.yaml      ← Alephbeis project config
│       ├── generic.yaml        ← Fallback for unknown projects
│       └── myproject.yaml      ← Add your own projects
├── templates/
│   └── task-planning/
│       ├── 00-status.md ... 04-todo.md
│       └── logs/
│           ├── decisions.md
│           └── review.md
└── workflows/
    ├── project-context.md  ← This file (loader)
    └── code-review/
        └── external.md
```

---

## Maintenance

### Update Project Config

Edit the YAML file directly:

```bash
# Edit starship config
code ~/.claude/config/projects/starship.yaml

# Changes take effect immediately (no reload needed)
```

### Add New Standard File

```yaml
standards:
  files:
    - path: ".ai/rules/new-standard.md"
      purpose: "New guidelines"
```

### Update Test Commands

```yaml
test_commands:
  unit: "new-test-command"
```

### Enable New MCP Tool

```yaml
mcp_tools:
  new_tool:
    enabled: true
    commands:
      - command1
      - command2
```

---

## Troubleshooting

### Project Not Detected

**Check:**
1. YAML file exists in `~/.claude/config/projects/`
2. Path or git remote pattern matches
3. YAML syntax is valid

**Debug:**
```bash
# List project configs
ls -la ~/.claude/config/projects/

# Check current directory
pwd

# Check git remote
git remote get-url origin

# Verify YAML syntax
cat ~/.claude/config/projects/starship.yaml
```

### Wrong Project Detected

**Cause:** Multiple projects match patterns

**Fix:** Make patterns more specific in YAML files

### YAML Parse Error

**Cause:** Invalid YAML syntax

**Fix:**
- Check indentation (use spaces, not tabs)
- Validate YAML online
- Compare with working example

---

**Ready to use. Invoke with `/project-context` or from other workflows.**
