# Project Configuration Templates

This directory contains templates for creating project-specific configurations.

## Available Templates

### 1. project-template.yaml

**Comprehensive template** with all available configuration options documented.

**Use when:**
- Setting up a new project with full configuration
- You want to see all available options
- You need advanced features (MCP tools, deployment configs, etc.)

### 2. minimal-template.yaml

**Minimal template** with only essential configuration.

**Use when:**
- Quick setup for simple projects
- You only need basic issue tracking and git workflow
- You can add more configuration later as needed

## How to Use

1. **Choose a template** based on your needs
2. **Copy to projects directory:**
   ```bash
   cp ~/.claude/templates/projects/minimal-template.yaml \
      ~/.claude/config/projects/my-project.yaml
   ```
3. **Edit the file** with your project-specific settings
4. **Validate the configuration:**
   ```bash
   ~/.claude/tests/validate-yaml.sh ~/.claude/config/projects/my-project.yaml
   ```

## Configuration Fields

### Required Fields

- `project.name` - Project name
- `project.type` - Project type (Laravel, Node.js, etc.)
- `detection.paths` - Paths to match for auto-detection
- `issue_tracking.pattern` - Issue key pattern
- `issue_tracking.regex` - Regex for extracting issue keys
- `git.base_branch` - Base branch for features

### Important Optional Fields

- `documentation.knowledge_base.source` - Where docs are stored
- `documentation.knowledge_base.access_method` - How to access docs
- `testing.*` - Test commands
- `code_quality.*` - Linting and formatting commands

## Knowledge Base Configuration

The knowledge base configuration is important for accessing project documentation:

### Source Types

- **`gitignored`** - Docs stored locally but not committed
  - Example: YouTrack docs fetched via API
  - Use `access_method: bash` or `mcp`

- **`git`** - Docs committed to repository
  - Example: Markdown docs in docs/ folder
  - Use `access_method: bash` or `git`

- **`external`** - Docs on external system
  - Example: Confluence, Notion, external wiki
  - Use `access_method: mcp` or provide `base_url`

- **`none`** - No knowledge base available
  - Use `access_method: none`

### Access Methods

- **`bash`** - Use Read tool to read local files
  - For local docs in project directory

- **`git`** - Use git commands
  - For docs in separate git repository

- **`mcp`** - Use MCP tool
  - For API-based documentation systems
  - Requires `mcp_tool` configuration

- **`none`** - No access method
  - Knowledge base not accessible

## Example Configurations

### Laravel Project with YouTrack MCP

```yaml
project:
  name: "Starship"
  type: "Laravel"

detection:
  paths:
    - "/Users/user/projects/starship"
  git_remotes:
    - "github.com/organization/starship"

issue_tracking:
  pattern: "STAR-1234"
  regex: "(STAR-[0-9]+)"
  system: "YouTrack"
  base_url: "https://youtrack.organization.com"
  mcp:
    enabled: true
    tool_prefix: "mcp__youtrack"
    project_id: "STAR"

documentation:
  knowledge_base:
    location: "./storage/youtrack-docs"
    source: "gitignored"
    access_method: "bash"

testing:
  all_tests: "php artisan test"
  unit_tests: "php artisan test --testsuite=Unit"

git:
  base_branch: "develop"
```

### Simple Node.js Project

```yaml
project:
  name: "My API"
  type: "Node.js"

detection:
  paths:
    - "/Users/user/projects/my-api"

issue_tracking:
  pattern: "API-123"
  regex: "(API-[0-9]+)"
  system: "GitHub"
  base_url: "https://github.com/user/my-api/issues"

documentation:
  knowledge_base:
    location: "./docs"
    source: "git"
    access_method: "bash"

testing:
  all_tests: "npm test"

git:
  base_branch: "main"
```

## Validation

After creating or updating a project configuration, validate it:

```bash
~/.claude/tests/validate-yaml.sh ~/.claude/config/projects/my-project.yaml
```

This will check:
- YAML syntax is valid
- Required fields are present
- Field values are valid (e.g., knowledge_base.source is one of the allowed values)

## Troubleshooting

### Project not detected

1. Check that `detection.paths` matches your project directory
2. Check that `detection.git_remotes` matches your git remote URL
3. Run detection manually:
   ```bash
   source ~/.claude/lib/project-context.sh
   detect_project
   ```

### Knowledge base not accessible

1. Verify `knowledge_base.location` path is correct
2. Verify `knowledge_base.source` matches how docs are stored
3. Verify `knowledge_base.access_method` is appropriate for the source type
4. Check file permissions if using `access_method: bash`

### Tests not running

1. Verify `testing.all_tests` command works in your project directory
2. Check that required test dependencies are installed
3. Verify paths in test commands are correct

## See Also

- **Project Detection:** `~/.claude/lib/project-context.sh`
- **Validation Tool:** `~/.claude/tests/validate-yaml.sh`
- **Troubleshooting Guide:** `~/.claude/docs/troubleshooting.md`
- **Global Configuration:** `~/.claude/config/global.yaml`
