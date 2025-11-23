# Claude Code - Personal Configuration

This directory contains personal Claude Code workflows, commands, and templates with **multi-project support via YAML configuration**.

## Architecture: Orchestrator Pattern

This configuration follows an **orchestrator pattern** where slash commands act as lightweight dispatchers that load project context, select modes, and delegate to specialized workflow implementations.

```
┌──────────────┐
│ User types:  │
│ /command-g   │
└──────┬───────┘
       │
       v
┌─────────────────────────────┐
│ commands/command-g.md       │  ← Orchestrator
│ - Load project context      │    - Detects project from YAML
│ - Auto-detect mode/level    │    - Suggests based on context
│ - Ask user to confirm       │    - Via AskUserQuestion
│ - Dispatch to workflow      │    - Executes selected mode
└──────┬──────────────────────┘
       │
       v
┌─────────────────────────────┐
│ workflows/name/mode.md      │  ← Mode implementation
│ - Uses project config       │    - Standards from YAML
│ - Detailed steps            │    - Complete process
│ - Returns to orchestrator   │    - Can switch modes
└─────────────────────────────┘

Reference docs: workflows/name/README.md
```

## Directory Structure

```
~/.claude/
├── config/
│   └── projects/          # Project configurations
│       ├── starship.yaml      # Starship project config
│       ├── alephbeis.yaml     # Alephbeis project config
│       └── generic.yaml       # Fallback for unknown projects
│
├── commands/               # Orchestrators (invoked via /command-g)
│   ├── plan-task-g.md     # → workflows/task-planning/
│   ├── code-review-g.md   # → workflows/code-review/
│   ├── release-g.md       # → workflows/release/
│   └── commit-plan-g.md   # → workflows/commit-planning/
│
├── workflows/              # Detailed workflow implementations
│   ├── project-context.md # Multi-project config loader
│   │
│   ├── task-planning/     # Task planning workflows
│   │   ├── README.md              # Reference documentation
│   │   ├── default-mode.md        # Standard YouTrack-driven planning
│   │   ├── greenfield-mode.md     # Exploratory planning
│   │   ├── in-progress-mode.md    # Review & sync workflow
│   │   └── quick-reference.md     # Quick lookup guide
│   │
│   ├── code-review/       # Code review workflows
│   │   ├── README.md              # Reference documentation
│   │   ├── interactive.md         # Manual step-by-step review
│   │   ├── quick.md               # Fast review for small PRs
│   │   ├── report.md              # Automated comprehensive review
│   │   └── external.md            # Evaluate external reviews
│   │
│   ├── release/           # Release workflows
│   │   ├── README.md              # Reference documentation
│   │   └── main.md                # CI/CD release workflow
│   │
│   └── commit-planning/   # Commit planning workflow
│       ├── README.md              # Reference documentation
│       └── main.md                # Commit planning implementation
│
├── templates/               # Document templates
│   ├── external-review-fixes.md  # External review record template
│   └── task-planning/
│       ├── 00-status.md
│       ├── 01-functional-requirements.md
│       ├── 02-decisions.md
│       ├── 03-implementation-plan.md
│       ├── 04-task-description.md
│       └── 05-todo.md
│
└── README.md                # This file
```

## Multi-Project Support

### Project Configuration (YAML)

Each project has a YAML configuration file in `config/projects/`:

**starship.yaml:**
```yaml
project:
  name: "Starship"
  path: "~/Projects/starship"

issue_tracking:
  pattern: "STAR-####"
  regex: "STAR-[0-9]+"
  system: "YouTrack"

standards:
  location: ".ai/rules/"
  files:
    - path: ".ai/rules/20-architecture.md"
      purpose: "DDD structure"

test_commands:
  all: "docker compose ... exec starship_server ./vendor/bin/phpunit"

mcp_tools:
  laravel_boost:
    enabled: true
  youtrack:
    enabled: true
```

### Project Detection

Workflows automatically detect which project you're in:

```bash
cd ~/Projects/starship
/code-review-g
# → Loads starship.yaml configuration
# → Issue pattern: STAR-####
# → Standards: .ai/rules/
# → Tests: Docker commands from YAML

cd ~/Projects/alephbeis-app
/code-review-g
# → Loads alephbeis.yaml configuration
# → Issue pattern: AB-####
# → Standards: .ai/rules/
# → Different test commands
```

### Adding New Projects

1. **Copy template:**
   ```bash
   cp ~/.claude/config/projects/starship.yaml ~/.claude/config/projects/myproject.yaml
   ```

2. **Edit configuration:**
   ```yaml
   project:
     name: "MyProject"
     path: "~/Projects/my-project"

   issue_tracking:
     pattern: "MP-####"
     regex: "MP-[0-9]+"

   # ... rest of config
   ```

3. **Test detection:**
   ```bash
   cd ~/Projects/my-project
   /project-context
   # Should load your YAML file
   ```

**See:** `workflows/project-context.md` for full documentation

---

## Available Commands

**Note:** All global commands use `-g` suffix to avoid conflicts with project commands.

### `/plan-task-g`
Multi-mode task planning with YouTrack integration and automatic project detection.

**Usage:** `/plan-task-g STAR-2235` or `/plan-task-g AB-123` or just `/plan-task-g`

**Flow:**
1. **Phase 0: Load Project Context** (automatic)
   - Detects project from YAML (Starship/Alephbeis/etc)
   - Loads standards, test commands, issue patterns

2. **Auto-Detect Planning Mode:**
   - Default - Standard YouTrack-driven planning
   - Greenfield - Exploratory work without issue key
   - In Progress - Review and sync existing work

3. **Execute Selected Mode Workflow**

**Features:**
- **Project-aware** - Uses YAML configuration
- Auto-detects appropriate mode based on context (branch, .wip folder, commits)
- Creates standardized documentation in `.wip/{PROJECT_KEY}-XXXX-{slug}/`
- Fetches task from YouTrack (if available)
- Searches for relevant business docs (if available)
- Creates detailed implementation plan
- Mode transitions (Greenfield → Default → In Progress)

**Workflows:**
- Entry: `commands/plan-task-g.md` (orchestrator)
- Default: `workflows/task-planning/default-mode.md`
- Greenfield: `workflows/task-planning/greenfield-mode.md`
- In Progress: `workflows/task-planning/in-progress-mode.md`

**See:** `workflows/task-planning/README.md` for details

---

### `/code-review-g`

Multi-mode code review with **automatic project detection** and severity analysis.

**Flow:**
1. **Phase 0: Load Project Context** (automatic)
   - Detects project from YAML (Starship/Alephbeis/etc)
   - Loads standards, test commands, citation formats
   - Extracts issue key from branch name

2. **Select Review Mode:**
   - Interactive - Manual step-by-step with approval gates
   - Quick - Fast checklist for small PRs
   - Report - Comprehensive automated review
   - **External** - Evaluate external code reviews

**Features:**
- **Project-aware** - Uses YAML configuration
- **Standards compliance** - Checks against `.ai/rules/` or project standards
- **Citation formats** - Project-specific (e.g., `[ARCH §Section]` vs `[ARCH: "quote"]`)
- **Correct test commands** - From YAML configuration
- **MCP integration** - Laravel Boost, YouTrack (if configured)
- **Circular review** - Tracks external review evaluations over time

**External Review Mode:**
- Evaluates reviews from AI tools (Copilot, ChatGPT, Cursor)
- Evaluates human reviewer comments
- Evaluates linter output (PHPCS, ESLint, PHPStan)
- Independently verifies each suggestion
- Accept/Modify/Reject decisions with reasoning
- Records to `.wip/{ISSUE_KEY}/external-review-fixes.md`
- Builds review history for learning over time

**Workflows:**
- Entry: `commands/code-review-g.md` (Phase 0 loads project)
- Interactive: `workflows/code-review/interactive.md`
- Quick: `workflows/code-review/quick.md`
- Report: `workflows/code-review/report.md`
- External: `workflows/code-review/external.md`

**See:** `workflows/code-review/README.md` for details

---

### `/release-g`
Guide releases through CI/CD pipeline with multi-level validation.

**Flow:**
1. **Phase 0: Load Project Context** (automatic)
   - Detects project from YAML
   - Loads test commands, branch conventions
   - Extracts issue key from branch name

2. **Select Release Level:**
   - Feature Branch Only - Push and verify tests
   - Feature + Develop - Merge to develop + staging deployment
   - Full Release - Production deployment (develop → master)

3. **Execute Selected Level Workflow**

**Features:**
- **Project-aware** - Uses YAML configuration
- Extracts task ID from branch name using project pattern
- Creates PR if needed (removes AI attribution)
- Waits for CI/CD validation at each stage
- Optional YouTrack status update (if configured)
- Error handling with retry logic

**Workflows:**
- Entry: `commands/release-g.md` (orchestrator)
- Implementation: `workflows/release/main.md`

**See:** `workflows/release/README.md` for details

---

### `/commit-plan-g`

Create focused commit plan with clear, structured commit messages.

**Usage:** `/commit-plan-g`

**Flow:**
1. **Phase 0: Load Project Context** (automatic)
   - Detects project from YAML
   - Loads commit message standards
   - Extracts issue key from branch name

2. **Analyze Changes:**
   - Staged files
   - Unstaged files
   - Untracked files

3. **Create Commit Plan:**
   - Logical groupings (atomic commits)
   - Clear commit messages per project standards
   - Proper dependency ordering

4. **Present for Approval**
   - Show complete plan
   - Wait for user approval
   - Execute after approval

**Features:**
- **Project-aware** - Uses YAML configuration
- Extracts issue key from branch name automatically
- Follows project commit message standards
- Creates atomic, focused commits
- Groups changes logically by layer/feature
- Ensures proper commit ordering (dependencies first)
- ❌ Never includes AI attribution in commits
- ✅ Includes issue key in all commit messages

**Requirements:**
- Must be in git repository
- Should be on feature branch (not master/develop)
- Branch name should include issue key (e.g., `feature/STAR-2233-Add-Feature`)

**Workflows:**
- Entry: `commands/commit-plan-g.md` (orchestrator)
- Implementation: `workflows/commit-planning/main.md`

**See:** `workflows/commit-planning/README.md` for details

---

### `/project-context`

Load project-specific configuration for use by other workflows.

**Usage:** Called automatically by `/code-review-g` and other workflows

**Can invoke directly:**
```bash
/project-context
# Shows detected project and configuration
```

**Provides:**
- Project name and type
- Issue tracking pattern (STAR-####, AB-####)
- Standards file locations
- Citation formats
- Test commands
- Storage locations (`.wip/{ISSUE_KEY}/`)
- MCP tool availability

**Workflow:** `workflows/project-context.md`

---

## Design Principles

### 1. Orchestrator Pattern
- **Commands** (`commands/*-g.md`): Orchestrators
  - Load project context (Phase 0)
  - Auto-detect mode/level based on context
  - Ask user to confirm via AskUserQuestion
  - Dispatch to appropriate workflow
  - ~50-300 lines

- **Workflows** (`workflows/*/`): Mode implementations
  - Use project configuration from YAML
  - Complete business logic for specific mode
  - Detailed steps and error handling
  - 100-1000+ lines per mode
  - Reusable across projects

- **README.md** (`workflows/*/README.md`): Reference documentation
  - Overview of all modes
  - Conventions and best practices
  - Troubleshooting
  - Not executable - pure documentation

### 2. Separation of Concerns
- **Commands** = User interface (CLI invocation)
- **Workflows** = Implementation (what to do)
- **Templates** = Document structure (how to format)
- **Projects** = Configuration (YAML per project)

### 3. Configuration as Data
- **YAML files** contain project settings
- **Workflows** read configuration, not hardcode
- **Easy maintenance** - update YAML, not workflow code
- **Extensible** - add projects by dropping YAML files

### 4. Discoverable & Self-Documenting
- Each command has `description:` frontmatter for `/` autocomplete
- Workflows reference each other with full paths
- README documents all available commands
- YAML files are human-readable configuration

### 5. Multi-Project Support
- **Auto-detection** from directory path or git remote
- **Project-specific** standards, tests, citations
- **Graceful fallback** to generic.yaml if unknown
- **One workflow** works everywhere

## Templates

### External Review Record Template

**Location:** `templates/external-review-fixes.md`

**Used by:** External review workflow to create `.wip/{ISSUE_KEY}/external-review-fixes.md`

**Purpose:**
- Record external review evaluations
- Track accept/reject decisions with reasoning
- Enable circular review (review the reviewer)
- Build institutional knowledge over time

**Structure:**
- File header with purpose
- Review sections (appended per review)
- Meta-evaluation (reviewer quality scoring)
- Statistics and learning notes

### Task Planning Templates

**Location:** `templates/task-planning/`

**Files:**
- `00-status.md` - Task status tracking
- `01-functional-requirements.md` - Requirements documentation
- `02-decisions.md` - Design decisions
- `03-implementation-plan.md` - Implementation steps
- `04-task-description.md` - Task description for YouTrack
- `05-todo.md` - Todo list

---

## Global vs Project Configuration

### Global (`~/.claude/`) - Personal
- **You control** - Your preferences and workflows
- **Not committed to git**
- **Cross-project** - Works in all projects
- **Contains:**
  - Project YAML configs (`config/projects/*.yaml`)
  - Reusable workflows (`workflows/`)
  - Templates (`templates/`)
  - Commands (`commands/`)

### Project (`.ai/` or `.claude/`) - Team
- **Team controls** - Shared standards and workflows
- **Committed to git**
- **Project-specific** - Tailored to project needs
- **Referenced by:**
  - YAML `standards.location: ".ai/rules/"`
  - Workflows load from these paths
  - Team conventions documented here

**Both coexist:** Project commands override global when present.

---

## Storage Conventions

### `.wip/` Directory Structure

All workflows use `.wip/{ISSUE_KEY}-{slug}/` for task-specific files:

```
{project}/.wip/
├── {ISSUE_KEY}-{slug}/              # Example: STAR-2233-Add-Feature or AB-1378-Fix-Bug
│   ├── 00-status.md                 # Task status & overview (index)
│   ├── 01-functional-requirements.md # Business requirements
│   ├── 02-decisions.md              # Decision log (ADR-style)
│   ├── 03-implementation-plan.md    # Technical plan
│   ├── 04-task-description.md       # Task summary (for YouTrack)
│   ├── 05-todo.md                   # Implementation checklist
│   └── external-review-fixes.md     # External review record (optional)
│
└── {ISSUE_KEY}-{slug}/              # Another task
    ├── 00-status.md
    ├── 01-functional-requirements.md
    ├── 02-decisions.md
    ├── 03-implementation-plan.md
    ├── 04-task-description.md
    ├── 05-todo.md
    └── external-review-fixes.md
```

**Universal Convention** (same for all projects):
- **Format**: `.wip/{ISSUE_KEY}-{slug}/` where slug matches branch name
- **Issue key**: Extracted from branch name (STAR-####, AB-####, etc.)
- **Slug**: Title-Case-With-Hyphens from issue title (same as branch)
- **Always included**: 00-05 files (status through todo)
- **Optional**: external-review-fixes.md (if using code review workflow)
- **Gitignore**: Usually in `.gitignore` (personal/WIP)
- **Team use**: Can be committed for collaboration if desired
- **Consistent**: Same structure across all projects

---

## Integration with YouTrack

Many workflows integrate with YouTrack MCP server:
- Fetch issue details: `mcp__youtrack__get_issue`
- Update issue status: `mcp__youtrack__update_issue`
- Search issues: `mcp__youtrack__search_issues`
- Get issue comments: `mcp__youtrack__get_issue_comments`

**Required:** YouTrack MCP server configured in MCP settings.

**Projects using YouTrack:**
- Starship (configured in `config/projects/starship.yaml`)

---

## Integration with Laravel Projects

Code review and task planning workflows integrate with Laravel Boost MCP:
- `mcp__laravel-boost__database-schema` - Database structure
- `mcp__laravel-boost__search-docs` - Laravel ecosystem docs
- `mcp__laravel-boost__application-info` - App info and packages
- `mcp__laravel-boost__tinker` - Test code snippets
- `mcp__laravel-boost__read-log-entries` - Application logs
- `mcp__laravel-boost__browser-logs` - Frontend logs

**Required:** Laravel Boost MCP server (for Laravel projects only).

**Projects using Laravel Boost:**
- Starship (configured in `config/projects/starship.yaml`)
- Alephbeis (configured in `config/projects/alephbeis.yaml`)

---

## Adding New Commands

1. **Create command** in `commands/new-command.md`:
```markdown
---
description: Brief description for autocomplete
---

# Command Name

## Phase 0: Load Project Context

Execute `/project-context` workflow to get project configuration.

## Ask Questions

Ask mode, parse arguments, then dispatch to workflow.

Load and execute workflow from `~/.claude/workflows/new-command/main.md`.
```

2. **Create workflow** in `workflows/new-command/main.md`:
```markdown
# Workflow Name

## Phase 0: Project Context Available

Use project context loaded by command:
- Standards: PROJECT_CONTEXT.standards.location
- Tests: PROJECT_CONTEXT.test_commands.*
- etc.

## Implementation

Detailed steps, error handling, etc.
```

3. **Test invocation**:
```bash
/new-command
```

---

## Maintenance

### When to Update

- **YAML configs** (`config/projects/*.yaml`): When adding projects or changing project settings
- **Commands** (`commands/*.md`): When changing invocation interface
- **Workflows** (`workflows/*/`): When improving implementation
- **Templates** (`templates/`): When standardizing new document types
- **README**: When adding/changing commands or structure

### Keeping It Clean

- ✅ One YAML per project in `config/projects/`
- ✅ Commands stay thin (<200 lines)
- ✅ Commands load project context (Phase 0)
- ✅ Workflows use configuration, don't hardcode
- ✅ Templates centralized in `templates/`
- ✅ Full paths in all references
- ✅ Document new commands in this README

### Project Configuration Best Practices

- ✅ Use existing YAML as template
- ✅ Test project detection after adding
- ✅ Keep patterns specific (avoid conflicts)
- ✅ Document project-specific MCP tools
- ✅ Include all test commands
- ✅ Specify citation formats

---

## Version History

- **2025-11-14 v3.0**: Multi-project YAML configuration ⭐ NEW
  - Added `config/projects/` directory for YAML configs
  - Created `starship.yaml`, `alephbeis.yaml`, `generic.yaml`
  - Added `project-context.md` workflow (YAML loader)
  - Updated `code-review-g.md` with Phase 0 (load context)
  - Moved template to `templates/external-review-fixes.md`
  - Optimized external review workflow (previous reviews in Phase 4.2)
  - Centralized all templates in `templates/` folder
  - Comprehensive documentation updates

- **2025-11-14 v2.0**: Reorganized to thin controller pattern
  - Moved dispatchers to `commands/`
  - Organized workflows into subdirectories
  - Standardized all commands to follow same pattern
  - Updated all internal references
  - Created comprehensive documentation

---

## Quick Reference

### Common Tasks

**Start code review:**
```bash
cd ~/Projects/starship  # or any project
/code-review-g
```

**Check project configuration:**
```bash
/project-context
```

**Add new project:**
```bash
cp ~/.claude/config/projects/starship.yaml ~/.claude/config/projects/newproject.yaml
code ~/.claude/config/projects/newproject.yaml
```

**View external reviews for current task:**
```bash
# Extract issue key from branch
ISSUE_KEY=$(git branch --show-current | grep -oE '[A-Z]+-[0-9]+')
cat .wip/${ISSUE_KEY}/external-review-fixes.md
```

---

**Maintained by:** Shmuel (Personal)
**Pattern:** Thin Controller → YAML Config → Workflow Implementation
**Purpose:** Cross-project AI-assisted development workflows
**Version:** 3.0 (YAML-based multi-project)
