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
│   ├── commit-plan-g.md   # → workflows/commit-planning/
│   └── update-docs-g.md   # → workflows/update-docs/
│
├── workflows/              # Detailed workflow implementations
│   ├── project-context.md # Multi-project config loader
│   │
│   ├── task-planning/     # Task planning workflows
│   │   ├── README.md              # Reference documentation
│   │   ├── default-mode.md        # Planning workflow (existing + new tasks)
│   │   ├── in-progress-mode.md    # Reconciliation workflow
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
│   ├── commit-planning/   # Commit planning workflow
│   │   ├── README.md              # Reference documentation
│   │   └── main.md                # Commit planning implementation
│   │
│   └── update-docs/        # Documentation update workflow
│       ├── README.md              # Reference documentation
│       ├── knowledge-base.md      # Update knowledge base docs
│       ├── inline.md              # Update inline code docs
│       └── api.md                 # Update API documentation
│
├── templates/               # Document templates
│   └── task-planning/
│       ├── 00-status.md
│       ├── 01-task-description.md
│       ├── 02-functional-requirements.md
│       ├── 03-implementation-plan.md
│       ├── 04-todo.md
│       └── logs/
│           ├── decisions.md      # ADR-style decisions
│           └── review.md         # External review feedback
│
├── lib/                     # Shell libraries and CLI tools
│   ├── bin/                     # User-facing CLI wrappers (call these)
│   │   ├── gather-context       # Gather task context for agents
│   │   └── detect-mode          # Detect planning mode from git state
│   │
│   ├── posix/                   # POSIX fallback scripts (sh/dash/zsh)
│   │   ├── core.sh              # Shared POSIX utilities
│   │   ├── gather-context.sh    # Minimal context gatherer
│   │   └── detect-mode.sh       # Minimal mode detector
│   │
│   ├── common.sh                # Bash logging, colors, error handling
│   ├── git-utils.sh             # Git operations
│   ├── issue-utils.sh           # Issue key extraction/validation
│   ├── task-docs-utils.sh       # Task docs folder management
│   ├── todo-utils.sh            # TodoWrite JSON patterns
│   ├── template-utils.sh        # Template rendering
│   ├── project-context.sh       # YAML config loading
│   ├── gather-context.sh        # Bash-enhanced (rich output)
│   └── detect-mode.sh           # Bash-enhanced (--pretty option)
│
├── modules/                 # Reusable rule/guideline modules
│   ├── shared/                   # Cross-workflow modules
│   │   ├── quick-context.md          # Fast context scan for mode detection
│   │   ├── full-context.md           # Complete context gathering
│   │   ├── approval-gate.md          # Approval checkpoint pattern
│   │   ├── todo-patterns.md          # TodoWrite patterns
│   │   ├── youtrack-fetch-issue.md   # YouTrack issue fetching
│   │   └── ...                       # Other shared modules
│   │
│   ├── code-review/              # Code review specific
│   │   ├── review-rules.md           # Review guidelines
│   │   ├── severity-levels.md        # Issue classification
│   │   └── citation-standards.md     # Citation formats
│   │
│   ├── task-planning/            # Task planning specific
│   │   ├── planning-core.md          # Core planning logic
│   │   ├── create-task-folder.md     # Folder creation
│   │   └── ...                       # Other planning modules
│   │
│   └── docs/                     # Documentation update modules
│       ├── context-strategy.md       # Context gathering strategy
│       └── style-guide-loading.md    # Style guide loading
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
   - Default - Planning workflow (handles existing tasks and new tasks)
   - In Progress - Reconciliation workflow (sync docs with implementation)

3. **Execute Selected Mode Workflow**

**Features:**
- **Project-aware** - Uses YAML configuration
- Auto-detects appropriate mode based on context (branch, .task-docs folder, commits)
- Creates standardized documentation in `.task-docs/{PROJECT_KEY}-XXXX-{slug}/`
- Fetches task from YouTrack (if available)
- Searches for relevant business docs (if available)
- Creates detailed implementation plan
- Mode transitions (Default ↔ In Progress)

**Workflows:**
- Entry: `commands/plan-task-g.md` (orchestrator)
- Default (Planning): `workflows/task-planning/default-mode.md` - handles existing and new tasks
- In Progress (Reconciliation): `workflows/task-planning/in-progress-mode.md` - sync docs with implementation

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
- Records to `.task-docs/{ISSUE_KEY}-{slug}/logs/review.md`
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
- Storage locations (`.task-docs/{ISSUE_KEY}/`)
- MCP tool availability

**Workflow:** `workflows/project-context.md`

---

### `/update-docs-g`

Update documentation to reflect implementation changes.

**Usage:** `/update-docs-g`

**Flow:**
1. **Phase 0: Load Project Context** (automatic)
   - Detects project from YAML
   - Loads documentation standards and style guides
   - Identifies documentation locations

2. **Select Update Mode:**
   - Knowledge Base - Update `.task-docs/` and knowledge base files
   - Inline - Update code comments and docblocks
   - API - Update API documentation (OpenAPI, etc.)

3. **Execute Selected Mode Workflow**

**Features:**
- **Project-aware** - Uses YAML configuration
- **Style-guide compliant** - Follows project documentation standards
- **Diff-aware** - Analyzes what changed to update relevant docs
- **Non-destructive** - Preserves existing documentation structure

**Workflows:**
- Entry: `commands/update-docs-g.md` (orchestrator)
- Knowledge Base: `workflows/update-docs/knowledge-base.md`
- Inline: `workflows/update-docs/inline.md`
- API: `workflows/update-docs/api.md`

**See:** `workflows/update-docs/README.md` for details

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

### Task Planning Templates

**Location:** `templates/task-planning/`

**Root Documents:**
- `00-status.md` - Task status tracking
- `01-task-description.md` - Task description (high-level overview)
- `02-functional-requirements.md` - Functional requirements (detailed)
- `03-implementation-plan.md` - Implementation steps
- `04-todo.md` - Todo list

**Logs Subfolder:**
- `logs/decisions.md` - Architectural decisions (ADR-style)
- `logs/review.md` - External review evaluations

**Purpose:**
- Root docs: Core task planning documents
- `logs/decisions.md`: Record architectural decisions with context, alternatives, consequences
- `logs/review.md`: Track external review evaluations for circular review process

**All docs created at start of planning** (even if initially empty)

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

### `.task-docs/` Directory Structure

All workflows use `.task-docs/{ISSUE_KEY}-{slug}/` for task-specific files:

```
{project}/.task-docs/
├── {ISSUE_KEY}-{slug}/              # Example: STAR-2233-Add-Feature
│   ├── 00-status.md                 # Task status & overview (index)
│   ├── 01-task-description.md       # Task description (high-level)
│   ├── 02-functional-requirements.md # Functional requirements (detailed)
│   ├── 03-implementation-plan.md    # Technical plan
│   ├── 04-todo.md                   # Implementation checklist
│   └── logs/                        # Activity logs
│       ├── decisions.md             # Architectural decisions (ADR-style)
│       └── review.md                # External review feedback
│
└── {ISSUE_KEY}-{slug}/              # Another task
    ├── 00-status.md
    ├── 01-task-description.md
    ├── 02-functional-requirements.md
    ├── 03-implementation-plan.md
    ├── 04-todo.md
    └── logs/
        ├── decisions.md
        └── review.md
```

**Universal Convention** (same for all projects):
- **Format**: `.task-docs/{ISSUE_KEY}-{slug}/` where slug matches branch name
- **Issue key**: Extracted from branch name (STAR-####, AB-####, etc.)
- **Slug**: Title-Case-With-Hyphens from issue title (same as branch)
- **Root docs (00-04)**: Always created at planning start
- **Logs folder**: Contains append-only activity logs (decisions, reviews)
- **Gitignore**: Usually in `.gitignore` (personal work-in-progress)
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

## Shell Libraries (`lib/`)

The `lib/` directory contains shell utilities used by workflows and commands.

### Structure

```
lib/
├── bin/                  # CLI wrappers (auto-detect shell)
│   ├── gather-context    # → Uses bash if available, falls back to posix/
│   └── detect-mode       # → Uses bash if available, falls back to posix/
│
├── posix/                # POSIX fallback (works in sh, dash, zsh, bash)
│   ├── core.sh           # Shared utilities
│   ├── gather-context.sh # Minimal version
│   └── detect-mode.sh    # Minimal version
│
└── *.sh                  # Bash-enhanced libraries (rich features)
```

### Usage

**Always call wrappers from `lib/bin/`** - they auto-detect shell:

```bash
# Gather task context (for agents)
~/.claude/lib/bin/gather-context [ISSUE_KEY]
~/.claude/lib/bin/gather-context --quick STAR-1234
~/.claude/lib/bin/gather-context --list STAR-1234

# Detect planning mode
~/.claude/lib/bin/detect-mode
~/.claude/lib/bin/detect-mode --json
~/.claude/lib/bin/detect-mode --pretty  # (bash only - colored output)
```

### In Workflows

Workflows call the bin wrappers:

```bash
# In commands/*.md or workflows/*.md
~/.claude/lib/bin/detect-mode
~/.claude/lib/bin/gather-context
```

### Sourcing Bash Libraries

For bash scripts that need rich functionality:

```bash
#!/bin/bash
source ~/.claude/lib/common.sh        # Logging, colors, error handling
source ~/.claude/lib/git-utils.sh     # Git operations
source ~/.claude/lib/issue-utils.sh   # Issue key extraction
source ~/.claude/lib/task-docs-utils.sh  # Task docs management
source ~/.claude/lib/project-context.sh  # YAML config loading
```

### Available Libraries

| Library | Purpose |
|---------|---------|
| `common.sh` | Logging (`log_info`, `log_error`), colors, validation |
| `git-utils.sh` | Branch operations, commit counting, status checks |
| `issue-utils.sh` | Extract/validate issue keys, generate slugs |
| `task-docs-utils.sh` | Find/create task folders, list documents |
| `todo-utils.sh` | TodoWrite JSON generation |
| `template-utils.sh` | Template rendering with variable substitution |
| `project-context.sh` | YAML config loading, project detection |

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

- **2025-12-10 v3.1**: Shell library reorganization
  - Consolidated `lib/` structure with clear separation
  - Added `lib/bin/` wrappers (auto-detect shell)
  - Added `lib/posix/` fallback scripts (POSIX-compliant)
  - Bash-enhanced versions with rich output (`--pretty`)
  - Removed redundant modules (replaced by scripts)
  - Updated all workflow references to use `lib/bin/`
  - Standardized variable naming (`_DIR` suffix)

- **2025-11-14 v3.0**: Multi-project YAML configuration
  - Added `config/projects/` directory for YAML configs
  - Created `starship.yaml`, `alephbeis.yaml`, `generic.yaml`
  - Added `project-context.md` workflow (YAML loader)
  - Updated `code-review-g.md` with Phase 0 (load context)
  - Moved template to `templates/task-planning/logs/review.md`
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
# Extract issue key from branch and find task folder
ISSUE_KEY=$(git branch --show-current | grep -oE '[A-Z]+-[0-9]+')
cat .task-docs/${ISSUE_KEY}*/logs/review.md
```

---

**Maintained by:** Shmuel (Personal)
**Pattern:** Thin Controller → YAML Config → Workflow Implementation
**Purpose:** Cross-project AI-assisted development workflows
**Version:** 3.0 (YAML-based multi-project)
