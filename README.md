# Claude Code - Personal Configuration

This directory contains personal Claude Code skills, commands, and templates with **multi-project support via YAML configuration**.

## Architecture: Orchestrator Pattern

This configuration follows an **orchestrator pattern** where slash commands act as lightweight dispatchers that load project context, select modes, and delegate to specialized skill implementations.

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
│ - Dispatch to skill         │    - Executes selected mode
└──────┬──────────────────────┘
       │
       v
┌─────────────────────────────┐
│ skills/name/mode.md         │  ← Mode implementation
│ - Uses project config       │    - Standards from YAML
│ - Detailed steps            │    - Complete process
│ - Returns to orchestrator   │    - Can switch modes
└─────────────────────────────┘

Reference docs: skills/name/README.md
```

## Directory Structure

```
~/.claude/
├── config/
│   ├── global.yaml            # Global settings (storage, defaults)
│   └── projects/              # Project configurations
│       ├── starship.yaml          # Starship project config
│       ├── alephbeis.yaml         # Alephbeis project config
│       ├── north-star.yaml        # North Star project config
│       ├── stella-polaris.yaml    # Stella Polaris project config
│       └── generic.yaml           # Fallback for unknown projects
│
├── commands/                  # Orchestrators (invoked via /command-g)
│   ├── plan-task-g.md         # → skills/task-planning/
│   ├── new-task-g.md          # → skills/task-planning/ (new task shortcut)
│   ├── code-review-g.md       # → skills/code-review/
│   ├── bug-zapper-g.md        # → skills/code-review/bug-zapper.md
│   ├── external-review-g.md   # → skills/code-review/external.md
│   ├── release-g.md           # → skills/release/
│   ├── commit-plan-g.md       # → skills/commit-planning/
│   ├── update-docs-g.md       # → skills/update-docs/
│   ├── sync-docs-g.md         # → skills/task-planning/sync-docs.md
│   ├── batch-tests-g.md       # Run tests in batches, fix iteratively
│   └── refresh-context-g.md   # Re-detect project context
│
├── skills/                    # Detailed skill implementations
│   ├── project-context.md     # Multi-project config loader
│   ├── helpers.md             # Common functions across skills
│   │
│   ├── task-planning/         # Task planning skills
│   │   ├── README.md              # Reference documentation
│   │   ├── config.md              # Configuration reference
│   │   ├── default-mode.md        # Planning skill (existing + new tasks)
│   │   ├── in-progress-mode.md    # Reconciliation skill
│   │   ├── sync-docs.md           # Sync docs with implementation
│   │   └── quick-reference.md     # Quick lookup guide
│   │
│   ├── code-review/           # Code review skills
│   │   ├── README.md              # Reference documentation
│   │   ├── report.md              # Automated comprehensive review
│   │   ├── bug-zapper.md          # Bug hunting (dependencies, types)
│   │   ├── quick.md               # Fast review for small PRs
│   │   ├── interactive.md         # Manual step-by-step review
│   │   └── external.md            # Evaluate external reviews
│   │
│   ├── release/               # Release skills
│   │   ├── README.md              # Reference documentation
│   │   └── main.md                # CI/CD release skill
│   │
│   ├── commit-planning/       # Commit planning skill
│   │   ├── README.md              # Reference documentation
│   │   └── main.md                # Commit planning implementation
│   │
│   └── update-docs/           # Documentation update skill
│       ├── README.md              # Reference documentation
│       ├── task-mode.md           # Update docs from task changes
│       └── article-mode.md        # Update specific articles
│
├── templates/                 # Document templates
│   ├── task-planning/
│   │   ├── README.md                 # Template usage guide
│   │   ├── 00-status.md
│   │   ├── 01-task-description.md
│   │   ├── 02-functional-requirements.md
│   │   ├── 03-implementation-plan.md
│   │   ├── 04-todo.md
│   │   └── logs/
│   │       ├── decisions.md       # ADR-style decisions
│   │       └── review.md          # External review feedback
│   ├── code-review/
│   │   ├── interactive-notes.md   # Interactive review notes
│   │   ├── quick-checklist.md     # Quick review checklist
│   │   └── review-report.md       # Full review report
│   ├── update-docs/
│   │   ├── updated-article.md     # Updated article template
│   │   ├── summary.md             # Update summary template
│   │   └── review-checklist.md    # Review checklist template
│   └── projects/
│       ├── project-template.yaml  # Full project config template
│       ├── minimal-template.yaml  # Minimal project config
│       └── README.md              # Template usage guide
│
├── lib/                       # Shell libraries and CLI tools
│   ├── bin/                       # User-facing CLI wrappers (call these)
│   │   ├── gather-context         # Gather task context for agents
│   │   └── detect-mode            # Detect planning mode from git state
│   │
│   ├── posix/                     # POSIX fallback scripts (sh/dash/zsh)
│   │   ├── core.sh                # Shared POSIX utilities
│   │   ├── gather-context.sh      # Minimal context gatherer
│   │   └── detect-mode.sh         # Minimal mode detector
│   │
│   ├── common.sh                  # Bash logging, colors, error handling
│   ├── git-utils.sh               # Git operations
│   ├── issue-utils.sh             # Issue key extraction/validation
│   ├── task-docs-utils.sh         # Task docs folder management
│   ├── todo-utils.sh              # TodoWrite JSON patterns
│   ├── template-utils.sh          # Template rendering
│   ├── project-context.sh         # YAML config loading
│   ├── gather-context.sh          # Bash-enhanced (rich output)
│   └── detect-mode.sh             # Bash-enhanced (--pretty option)
│
├── modules/                   # Reusable rule/guideline modules
│   ├── shared/                    # Cross-skill modules (9 modules)
│   │   ├── quick-context.md           # Fast context scan for mode detection
│   │   ├── full-context.md            # Complete context gathering
│   │   ├── approval-gate.md           # Approval checkpoint pattern
│   │   ├── plan-mode-discipline.md    # Read-only planning discipline
│   │   ├── todo-patterns.md           # TodoWrite patterns
│   │   ├── standards-loading.md       # Load project standards
│   │   ├── git-safety-checks.md       # Git safety validations
│   │   ├── youtrack-fetch-issue.md    # YouTrack issue fetching
│   │   └── youtrack-create-issue.md   # YouTrack issue creation
│   │
│   ├── code-review/               # Code review specific (16 modules)
│   │   ├── review-rules.md            # Review guidelines
│   │   ├── severity-levels.md         # Issue classification
│   │   ├── citation-standards.md      # Citation formats
│   │   ├── architecture-review.md     # Architecture compliance
│   │   ├── correctness-review.md      # Logic and robustness
│   │   ├── code-quality-review.md     # Style and quality
│   │   ├── bugs-review.md             # Bug detection patterns
│   │   ├── test-review.md             # Test quality and execution
│   │   ├── auto-fix-phase.md          # Linter and debug cleanup
│   │   ├── generate-report.md         # Report compilation
│   │   ├── critical-checks.md         # Quick critical checks
│   │   ├── performance-security.md    # Performance and security
│   │   ├── linter-failure-handling.md  # Handle linter failures
│   │   ├── bug-categories.md          # Bug type classification
│   │   ├── session-review-file.md     # Session review output
│   │   └── append-review-log.md       # Cumulative review log
│   │
│   ├── task-planning/             # Task planning specific (14 modules)
│   │   ├── planning-core.md           # Core planning logic
│   │   ├── create-task-folder.md      # Folder creation
│   │   ├── ensure-docs-structure.md   # Verify docs exist
│   │   ├── get-user-context.md        # Get context from user
│   │   ├── analyze-requirements.md    # Requirements analysis
│   │   ├── technical-planning.md      # Technical plan creation
│   │   ├── search-codebase.md         # Codebase exploration
│   │   ├── resume-existing-task.md    # Resume existing task
│   │   ├── start-implementation.md    # Begin implementation
│   │   ├── finalize-documentation.md  # Finalize docs
│   │   ├── gather-implementation-state.md  # Git/code state
│   │   ├── compare-and-sync.md        # Compare planned vs actual
│   │   ├── sync-docs-with-implementation.md  # Sync docs
│   │   └── standard-docs-structure.md # Standard doc structure
│   │
│   └── docs/                      # Documentation update modules
│       ├── context-strategy.md        # Context gathering strategy
│       ├── project-variables.md       # PROJECT_* variable reference
│       └── style-guide-loading.md     # Style guide loading
│
├── docs/                      # Conceptual documentation
│   ├── task-planning-overview.md  # High-level overview
│   └── troubleshooting.md         # Troubleshooting guide
│
├── tests/                     # Validation scripts
│   ├── validate-modules.sh        # Check module references
│   ├── validate-yaml.sh           # Validate YAML configurations
│   └── shell-compatibility.sh     # Shell compatibility tests
│
└── README.md                  # This file
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

Skills automatically detect which project you're in:

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

**See:** `skills/project-context.md` for full documentation

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
   - Default - Planning skill (handles existing tasks and new tasks)
   - In Progress - Reconciliation skill (sync docs with implementation)

3. **Execute Selected Mode Skill**

**Features:**
- **Project-aware** - Uses YAML configuration
- Auto-detects appropriate mode based on context (branch, task docs folder, commits)
- Creates standardized documentation in `${PROJECT_TASK_DOCS_DIR}/{PROJECT_KEY}-XXXX-{slug}/`
- Fetches task from YouTrack (if available)
- Searches for relevant business docs (if available)
- Creates detailed implementation plan
- Mode transitions (Default ↔ In Progress)

**Skills:**
- Entry: `commands/plan-task-g.md` (orchestrator)
- Default (Planning): `skills/task-planning/default-mode.md` - handles existing and new tasks
- In Progress (Reconciliation): `skills/task-planning/in-progress-mode.md` - sync docs with implementation

**See:** `skills/task-planning/README.md` for details

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
- Records to `${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/logs/review.md`
- Builds review history for learning over time

**Skills:**
- Entry: `commands/code-review-g.md` (Phase 0 loads project)
- Interactive: `skills/code-review/interactive.md`
- Quick: `skills/code-review/quick.md`
- Report: `skills/code-review/report.md`
- External: `skills/code-review/external.md`

**See:** `skills/code-review/README.md` for details

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

3. **Execute Selected Level Skill**

**Features:**
- **Project-aware** - Uses YAML configuration
- Extracts task ID from branch name using project pattern
- Creates PR if needed (removes AI attribution)
- Waits for CI/CD validation at each stage
- Optional YouTrack status update (if configured)
- Error handling with retry logic

**Skills:**
- Entry: `commands/release-g.md` (orchestrator)
- Implementation: `skills/release/main.md`

**See:** `skills/release/README.md` for details

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

**Skills:**
- Entry: `commands/commit-plan-g.md` (orchestrator)
- Implementation: `skills/commit-planning/main.md`

**See:** `skills/commit-planning/README.md` for details

---

### `/project-context`

Load project-specific configuration for use by other skills.

**Usage:** Called automatically by `/code-review-g` and other skills

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
- Storage locations (`${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}/`)
- MCP tool availability

**Skill:** `skills/project-context.md`

---

### `/update-docs-g`

Update knowledge base documentation to reflect implementation changes.

**Usage:** `/update-docs-g STAR-1234` or `/update-docs-g Article-Name.md` or `/update-docs-g --broad`

**Flow:**
1. **Phase 0: Load Project Context** (automatic)
   - Detects project from YAML
   - Loads documentation standards and style guides
   - Identifies knowledge base location

2. **Select Update Mode:**
   - Task Mode - Update docs based on task implementation changes
   - Article Mode - Update specific articles directly
   - Broad Mode - Scan recent tasks for documentation gaps

3. **Execute Selected Mode Skill**

**Features:**
- **Project-aware** - Uses YAML configuration
- **Style-guide compliant** - Follows project documentation standards
- **Diff-aware** - Analyzes what changed to update relevant docs
- **Non-destructive** - Creates copies in `${PROJECT_TASK_DOCS_DIR}/`, never overwrites originals

**Skills:**
- Entry: `commands/update-docs-g.md` (orchestrator)
- Task Mode: `skills/update-docs/task-mode.md`
- Article Mode: `skills/update-docs/article-mode.md`

**See:** `skills/update-docs/README.md` for details

---

### `/batch-tests-g`

Run all tests organized in batches, fix failures iteratively until green.

**Usage:** `/batch-tests-g`

**Flow:**
1. Discover and organize tests into batches (~50 tests each)
2. Present batch plan for approval
3. Run each batch sequentially
4. Fix failures as encountered (analyze, fix, rerun single test)
5. Rerun batch to confirm all pass
6. Proceed to next batch
7. Ask to loop again or finish

**Features:**
- Groups tests by domain/directory
- Targets ~50 tests per batch for manageability
- Fixes tests as you go (no accumulating failures)
- Tracks every fix with TodoWrite
- Final summary of all changes applied

---

### `/bug-zapper-g`

Hunt for actual bugs by tracing dependencies and verifying correctness.

**Usage:** `/bug-zapper-g`

**Focus:** Will this code crash? Do things exist? Do types match?
**Not about:** Architecture, standards, style, or requirements.

**Flow:**
1. Detect context and get user approval
2. Load review history (check for rejected suggestions)
3. Gather full context (files, dependencies)
4. Phase 1: Dependency chain analysis (trace up and down)
5. Phase 2: Existence verification (classes, methods, properties)
6. Phase 3: Type mismatch detection
7. Phase 4: Null safety analysis
8. Phase 5: Logic error detection
9. Phase 6: Resource & state bugs
10. Phase 7: Copy-paste bug detection
11. Generate bug report

**Features:**
- **Review-aware** - Skips previously rejected suggestions
- **Comprehensive** - 7-phase static analysis checklist
- **Evidence-based** - Specific file:line references with code examples
- **Non-destructive** - Static analysis only, no code changes
- Severity ratings: CRITICAL / MAJOR / MINOR

**Skills:**
- Entry: `commands/bug-zapper-g.md` (orchestrator)
- Implementation: `skills/code-review/bug-zapper.md`

---

### `/external-review-g`

Evaluate external code reviews (from AI tools, developers, linters) against project standards.

**Usage:** `/external-review-g`

**Flow:**
1. Detect context
2. User pastes external review text
3. Parse suggestions and check for duplicates against review history
4. Independently evaluate each suggestion against project standards
5. Present verdict (ACCEPT / MODIFY / REJECT) with reasoning
6. Apply changes if approved
7. Update review log

**Features:**
- **User-first** - Gets review text immediately, loads context in background
- **Independent** - Evaluates against project standards, not a rubber stamp
- **History-aware** - Checks past review decisions to avoid re-raising rejected items
- **Non-destructive** - Verdicts go to chat; files only created when changes applied

**Skills:**
- Entry: `commands/external-review-g.md` (orchestrator)
- Implementation: `skills/code-review/external.md`

---

### `/new-task-g`

Plan a new task, ignoring current branch state entirely.

**Usage:** `/new-task-g`

**Flow:**
1. Get task type from user (feature, bug fix, refactor, enhancement)
2. Get or create YouTrack issue (or proceed without one)
3. Create task documentation in `${PROJECT_TASK_DOCS_DIR}/`
4. Plan implementation
5. Offer worktree, branch switch, or save plan for later

**Features:**
- **Ignores current state** - Does not check branch, commits, or uncommitted changes
- **Worktree support** - Create git worktree to work on new task without disturbing current work
- **Full planning** - Creates all standard task docs (00-status through 04-todo + logs)
- **Flexible start** - Can proceed with or without YouTrack issue

---

### `/refresh-context-g`

Re-run context detection to refresh memory about current state.

**Usage:** `/refresh-context-g`

**Flow:**
1. Quick context scan (detect-mode.sh, branch, issue key, task folder)
2. Full context if needed (git state, changed files, dependencies)

**Skills:**
- Entry: `commands/refresh-context-g.md`
- Uses: `modules/shared/quick-context.md`, `modules/shared/full-context.md`

---

### `/sync-docs-g`

Synchronize task documentation to match the actual implementation.

**Usage:** `/sync-docs-g`

**Flow:**
1. Detect context
2. Review all task documentation (00-status through 04-todo + logs)
3. Review actual implementation (commits, changed files, code structure)
4. Identify divergences (planned vs implemented)
5. Get user approval for divergence handling
6. Rewrite docs to match implementation (as if current code was always the plan)
7. Create ADRs for significant divergences

**Features:**
- **Rewrite, don't annotate** - Docs read cleanly, no "deviation" markers
- **ADR-based history** - Divergences captured in decision log, not inline
- **Comprehensive** - Updates all 5 core docs plus decision log

**Skills:**
- Entry: `commands/sync-docs-g.md` (orchestrator)
- Implementation: `skills/task-planning/sync-docs.md`

---

## Design Principles

### 1. Orchestrator Pattern
- **Commands** (`commands/*-g.md`): Orchestrators
  - Load project context (Phase 0)
  - Auto-detect mode/level based on context
  - Ask user to confirm via AskUserQuestion
  - Dispatch to appropriate skill
  - ~50-300 lines

- **Skills** (`skills/*/`): Mode implementations
  - Use project configuration from YAML
  - Complete business logic for specific mode
  - Detailed steps and error handling
  - 100-1000+ lines per mode
  - Reusable across projects

- **README.md** (`skills/*/README.md`): Reference documentation
  - Overview of all modes
  - Conventions and best practices
  - Troubleshooting
  - Not executable - pure documentation

### 2. Separation of Concerns
- **Commands** = User interface (CLI invocation)
- **Skills** = Implementation (what to do)
- **Templates** = Document structure (how to format)
- **Projects** = Configuration (YAML per project)

### 3. Configuration as Data
- **YAML files** contain project settings
- **Skills** read configuration, not hardcode
- **Easy maintenance** - update YAML, not skill code
- **Extensible** - add projects by dropping YAML files

### 4. Discoverable & Self-Documenting
- Each command has `description:` frontmatter for `/` autocomplete
- Skills reference each other with full paths
- README documents all available commands
- YAML files are human-readable configuration

### 5. Multi-Project Support
- **Auto-detection** from directory path or git remote
- **Project-specific** standards, tests, citations
- **Graceful fallback** to generic.yaml if unknown
- **One skill** works everywhere

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
- **You control** - Your preferences and skills
- **Not committed to git**
- **Cross-project** - Works in all projects
- **Contains:**
  - Project YAML configs (`config/projects/*.yaml`)
  - Reusable skills (`skills/`)
  - Templates (`templates/`)
  - Commands (`commands/`)

### Project (`.ai/` or `.claude/`) - Team
- **Team controls** - Shared standards and skills
- **Committed to git**
- **Project-specific** - Tailored to project needs
- **Referenced by:**
  - YAML `standards.location: ".ai/rules/"`
  - Skills load from these paths
  - Team conventions documented here

**Both coexist:** Project commands override global when present.

---

## Storage Conventions

### `${PROJECT_TASK_DOCS_DIR}` Directory Structure

All skills use `${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/` for task-specific files:

```
${PROJECT_TASK_DOCS_DIR}/
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
- **Format**: `${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/` where slug matches branch name
- **Issue key**: Extracted from branch name (STAR-####, AB-####, etc.)
- **Slug**: Title-Case-With-Hyphens from issue title (same as branch)
- **Root docs (00-04)**: Always created at planning start
- **Logs folder**: Contains append-only activity logs (decisions, reviews)
- **Gitignore**: Usually in `.gitignore` (personal work-in-progress)
- **Team use**: Can be committed for collaboration if desired
- **Consistent**: Same structure across all projects

---

## Integration with YouTrack

Many skills integrate with YouTrack MCP server:
- Fetch issue details: `mcp__youtrack__get_issue`
- Update issue status: `mcp__youtrack__update_issue`
- Search issues: `mcp__youtrack__search_issues`
- Get issue comments: `mcp__youtrack__get_issue_comments`

**Required:** YouTrack MCP server configured in MCP settings.

**Projects using YouTrack:**
- Starship (configured in `config/projects/starship.yaml`)

---

## Integration with Laravel Projects

Code review and task planning skills integrate with Laravel Boost MCP:
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

Execute `/project-context` skill to get project configuration.

## Ask Questions

Ask mode, parse arguments, then dispatch to skill.

Load and execute skill from `~/.claude/skills/new-command/main.md`.
```

2. **Create skill** in `skills/new-command/main.md`:
```markdown
# Skill Name

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

The `lib/` directory contains shell utilities used by skills and commands.

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

### In Skills

Skills call the bin wrappers:

```bash
# In commands/*.md or skills/*.md
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
- **Skills** (`skills/*/`): When improving implementation
- **Templates** (`templates/`): When standardizing new document types
- **README**: When adding/changing commands or structure

### Keeping It Clean

- ✅ One YAML per project in `config/projects/`
- ✅ Commands stay thin (<200 lines)
- ✅ Commands load project context (Phase 0)
- ✅ Skills use configuration, don't hardcode
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
  - Updated all skill references to use `lib/bin/`
  - Standardized variable naming (`_DIR` suffix)

- **2025-11-14 v3.0**: Multi-project YAML configuration
  - Added `config/projects/` directory for YAML configs
  - Created `starship.yaml`, `alephbeis.yaml`, `generic.yaml`
  - Added `project-context.md` skill (YAML loader)
  - Updated `code-review-g.md` with Phase 0 (load context)
  - Moved template to `templates/task-planning/logs/review.md`
  - Optimized external review skill (previous reviews in Phase 4.2)
  - Centralized all templates in `templates/` folder
  - Comprehensive documentation updates

- **2025-11-14 v2.0**: Reorganized to thin controller pattern
  - Moved dispatchers to `commands/`
  - Organized skills into subdirectories
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
cat ${PROJECT_TASK_DOCS_DIR}/${ISSUE_KEY}*/logs/review.md
```

---

**Maintained by:** Shmuel (Personal)
**Pattern:** Thin Controller → YAML Config → Skill Implementation
**Purpose:** Cross-project AI-assisted development skills
**Version:** 3.1 (Shell library reorganization)
