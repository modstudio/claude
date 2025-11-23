# Loading Project Context

**Module:** Project Context Loading
**Version:** 2.0.0

---

## Executing Project Detection

```bash
# Source required libraries
source ~/.claude/lib/common.sh
source ~/.claude/lib/project-context.sh
source ~/.claude/lib/wip-utils.sh
source ~/.claude/lib/issue-utils.sh
source ~/.claude/lib/git-utils.sh

# Load project configuration
load_project_context
```

---

## Project Configuration Loaded

**Project:** ${PROJECT_NAME}
**Type:** ${PROJECT_TYPE}

### Issue Tracking

- **Pattern:** ${PROJECT_ISSUE_PATTERN} (e.g., STAR-1234, AB-567)
- **Regex:** `${PROJECT_ISSUE_REGEX}`
- **System:** ${PROJECT_ISSUE_SYSTEM}

### Standards

- **Location:** `${PROJECT_STANDARDS_DIR}`
- **Citation Format (Architecture):** ${PROJECT_CITATION_ARCHITECTURE}
- **Citation Format (Style):** ${PROJECT_CITATION_STYLE}

### Storage

- **WIP Root:** `${PROJECT_WIP_ROOT}` (project-local, in current project directory)
- **Task Folders:** `${PROJECT_WIP_ROOT}/{ISSUE_KEY}-{slug}/`

### Knowledge Base

- **Location:** `${PROJECT_KB_LOCATION}`
- **Source:** ${PROJECT_KB_SOURCE} (gitignored, git, external, or none)
- **Access Method:** ${PROJECT_KB_ACCESS_METHOD} (bash, git, mcp, or none)

### Test Commands

- **All Tests:** `${PROJECT_TEST_CMD_ALL}`
- **Unit Tests:** `${PROJECT_TEST_CMD_UNIT}`

### Branching

- **Base Branch:** ${PROJECT_BASE_BRANCH}
- **Branch Pattern:** ${PROJECT_BRANCH_PATTERN}

---

## Available Variables

All project configuration is now available as environment variables with `PROJECT_*` prefix:

- `PROJECT_NAME` - Project name
- `PROJECT_TYPE` - Project type (Laravel, Node.js, etc.)
- `PROJECT_ISSUE_PATTERN` - Human-readable issue pattern
- `PROJECT_ISSUE_REGEX` - Regex pattern for issue key extraction
- `PROJECT_STANDARDS_DIR` - Location of project standards
- `PROJECT_WIP_ROOT` - Location of .wip folder (always `./.wip`)
- `PROJECT_KB_LOCATION` - Knowledge base location
- `PROJECT_KB_SOURCE` - Knowledge base source type
- `PROJECT_KB_ACCESS_METHOD` - How to access knowledge base
- `PROJECT_CITATION_ARCHITECTURE` - Citation format for architecture docs
- `PROJECT_CITATION_STYLE` - Citation format for style guides
- `PROJECT_TEST_CMD_ALL` - Command to run all tests
- `PROJECT_BASE_BRANCH` - Base git branch

---

## Next Steps

With project context loaded, workflows can now:
- Extract issue keys using `$PROJECT_ISSUE_REGEX`
- Access standards from `$PROJECT_STANDARDS_DIR`
- Create task folders in `$PROJECT_WIP_ROOT`
- Run tests using `$PROJECT_TEST_CMD_ALL`
- Format citations using `$PROJECT_CITATION_*` formats
