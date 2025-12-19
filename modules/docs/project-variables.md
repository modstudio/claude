# Project Variables Reference

**Module:** PROJECT_* variables reference
**Version:** 1.0.0

## Purpose
Document all PROJECT_* variables available after project configuration is loaded.

## Scope
DOCS - Reference for: all workflows using project context

**Type:** Reference documentation (not an action module)

---

## How Context Is Loaded

Project context is loaded by the parent command (e.g., `/code-review-g`, `/release-g`, `/commit-plan-g`) before the workflow starts. The command:

1. Detects the current project from git remote or working directory
2. Loads the appropriate YAML config from `~/.claude/config/projects/`
3. Extracts issue key from branch name using the project's regex pattern
4. Sets all variables for use in the workflow

---

## Available Variables

### Project Information

| Variable | Description | Example |
|----------|-------------|---------|
| `PROJECT_NAME` | Project display name | `Starship`, `Alephbeis` |
| `PROJECT_KEY` | Project key for issue tracking | `STAR`, `AB` |
| `PROJECT_ROOT` | Absolute path to project root | `/path/to/starship` |

### Issue Tracking

| Variable | Description | Example |
|----------|-------------|---------|
| `ISSUE_KEY` | Extracted issue key from branch | `STAR-1234` |
| `ISSUE_PATTERN` | Display pattern | `STAR-####` |
| `ISSUE_REGEX` | Regex for extraction | `STAR-[0-9]+` |

### Standards & Documentation

| Variable | Description | Example |
|----------|-------------|---------|
| `PROJECT_STANDARDS_DIR` | Location of coding standards | `.ai/rules/` |
| `PROJECT_KB_DIR` | Knowledge base directory | `.ai/kb/` |
| `PROJECT_TASK_DOCS_DIR` | Task documentation root | `.task-docs/` |

### Citation Format

| Variable | Description | Example |
|----------|-------------|---------|
| `PROJECT_CITATION_ARCHITECTURE` | Architecture citation format | `[ARCH §X.Y]` |
| `PROJECT_CITATION_STYLE` | Style citation format | `[STYLE §X.Y]` |
| `PROJECT_CITATION_TEST` | Test citation format | `[TEST §X.Y]` |

### Test Commands

| Variable | Description | Example |
|----------|-------------|---------|
| `PROJECT_TEST_CMD_ALL` | Run all tests | `docker compose exec... phpunit` |
| `PROJECT_TEST_CMD_UNIT` | Run unit tests | `...phpunit tests/Unit` |
| `PROJECT_TEST_CMD_FEATURE` | Run feature tests | `...phpunit tests/Feature` |

### MCP Tools

| Variable | Description |
|----------|-------------|
| `PROJECT_MCP_YOUTRACK` | YouTrack MCP available (true/false) |
| `PROJECT_MCP_LARAVEL_BOOST` | Laravel Boost MCP available (true/false) |

### YouTrack Configuration (CRITICAL)

**IMPORTANT:** YouTrack MCP tools require `project_id`, NOT `project_key`.

| Variable | Description | Example |
|----------|-------------|---------|
| `PROJECT_YOUTRACK_PROJECT_ID` | **YouTrack project ID** - use this for MCP calls | `0-0`, `0-6` |
| `PROJECT_YOUTRACK_PROJECT_KEY` | Project key prefix (for display only) | `STAR`, `AB` |

**Usage:**
- When calling `mcp__youtrack__search_issues`, `mcp__youtrack__create_issue`, etc., **always use `PROJECT_YOUTRACK_PROJECT_ID`**
- The project key (`STAR`, `AB`) is for human-readable display and issue key patterns only
- Example: To search Starship issues, use `project_id: "0-0"`, NOT `project_id: "STAR"`

---

## Usage in Workflows

### Referencing This Module

Instead of duplicating Phase 0 sections, workflows should include:

```markdown
## Phase 0: Project Context

{{MODULE: ~/.claude/modules/docs/project-variables.md}}

**Verify before continuing:**
- [ ] Project context loaded successfully
- [ ] Issue key extracted: `ISSUE_KEY`
- [ ] Standards location confirmed: `PROJECT_STANDARDS_DIR`
```

### Accessing Variables

Variables are accessed directly by name:

```bash
# In bash
echo "Issue: $ISSUE_KEY"
echo "Standards: $PROJECT_STANDARDS_DIR"

# Run project tests
$PROJECT_TEST_CMD_UNIT tests/Unit/MyTest.php
```

### Task Documentation Path

Task docs are stored at: `{PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/`

Example: `.task-docs/STAR-1234-add-feature/`

---

## Validation

Workflows should verify context is complete before proceeding:

```bash
# Verify required variables exist
~/.claude/lib/bin/detect-mode

# This outputs:
# - PROJECT_NAME
# - ISSUE_KEY (if on feature branch)
# - Branch status
# - Uncommitted changes
```

---

## Fallback Behavior

If context cannot be loaded:

1. **No project detected**: Use generic defaults from `config/projects/generic.yaml`
2. **No issue key in branch**: Warn user, ask if they want to continue without
3. **Standards files missing**: Warn user, skip standards-based checks

---

## SSOT Principle

**Do NOT duplicate rules inside workflows.**

- Always consult standard files from `PROJECT_STANDARDS_DIR`
- Cite findings using `PROJECT_CITATION_*` format
- Reference this module instead of copying variable lists

---

**End of Module**
