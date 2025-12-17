# Task Planning Workflows

Task planning workflows with multi-project support via YAML configuration and three planning modes.

**Uses Claude's Plan Mode discipline**: Read-only exploration → User approval → Implementation

## Quick Start

```bash
# Invoke task planning
/plan-task-g

# Auto-detects mode based on context
# Asks you to confirm mode selection
# Executes the appropriate workflow
```

---

## Plan Mode Discipline

**All planning workflows follow Claude's Plan Mode discipline.**

See `~/.claude/modules/plan-mode-discipline.md` for detailed guidance.

### The Two Phases

| Phase | Mode | What's Allowed |
|-------|------|----------------|
| Planning | **READ-ONLY** | Read, Grep, Glob, WebSearch, AskUserQuestion, MCP lookups |
| Implementation | **WRITE-ENABLED** | Edit, Write, Bash, git operations |

### Key Rules

1. **During planning (before approval):**
   - Do NOT create files or folders
   - Do NOT edit any files
   - Do NOT run Bash commands that modify state
   - Only use read-only tools to research

2. **Parallel research:**
   - Launch multiple search tools in parallel
   - Wait for all results
   - Synthesize findings
   - Present summary to user

3. **The Approval Gate:**
   - Present complete plan with specific files
   - Wait for explicit approval ("Yes", "Go ahead", "Approved")
   - Do NOT interpret questions as approval
   - Only then proceed to implementation

4. **After approval:**
   - Create task docs folder and documents
   - Create git branch
   - Begin implementation

### Why Plan Mode?

- **Prevents wasted effort** - Don't write code based on wrong assumptions
- **Ensures user alignment** - Get buy-in before committing
- **Better decisions** - Research thoroughly before choosing
- **Thorough exploration** - Understand patterns before proposing solutions

---

## File Structure

```
~/.claude/
├── config/
│   └── projects/                          ← Project configurations (YAML)
│       ├── starship.yaml                  ← Starship config
│       ├── alephbeis.yaml                 ← Alephbeis config
│       └── generic.yaml                   ← Fallback config
│
└── workflows/
    ├── project-context.md                 ← Multi-project loader
    └── task-planning/
        ├── README.md                      ← This file
        ├── default-mode.md                ← Standard YouTrack-driven workflow
        ├── greenfield-mode.md             ← Exploratory workflow
        ├── in-progress-mode.md            ← Review & sync workflow
        └── quick-reference.md             ← Quick lookup guide
```

**Storage Configuration**: Project-local `${TASK_DOCS_DIR}` folder (must exist in project directory)

**Project Files (Created by Workflows):**
```
${TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/
├── 00-status.md                  ← Status & Overview (index)
├── 01-task-description.md        ← Task Description (high-level overview)
├── 02-functional-requirements.md ← Functional Requirements (detailed)
├── 03-implementation-plan.md     ← Technical Plan
├── 04-todo.md                    ← Implementation Checklist
└── logs/                         ← Activity logs
    ├── decisions.md              ← Decision Log (ADR-style)
    └── review.md                 ← External review feedback
```
*Where `${TASK_DOCS_DIR}` defaults to `./.task-docs/` - PROJECT-LOCAL in the project directory (add to .gitignore)*

---

## How It Works

### 1. Project Detection

Workflow automatically detects which project you're in:

```bash
cd ~/Projects/starship
# Detects: Starship (from YAML: starship.yaml)
# Issue pattern: STAR-####
# Storage: $TASK_DOCS_DIR/STAR-####-{slug}/ (from global.yaml)
# Standards: .ai/rules/
# Tests: Docker + PHPUnit

cd ~/Projects/alephbeis-app
# Detects: Alephbeis (from YAML: alephbeis.yaml)
# Issue pattern: AB-####
# Storage: $TASK_DOCS_DIR/AB-####-{slug}/ (from global.yaml)
# Standards: .ai/rules/
# Tests: Docker + PHPUnit
```

### 2. Configuration Loading

Loads project-specific settings from `~/.claude/config/projects/{project}.yaml`:

- Issue tracking pattern
- Standards file locations
- Citation formats
- Test commands
- MCP tool availability
- Storage conventions

### 3. Mode Selection

```
User → /plan-task-g
    ↓
Phase 0: Load project context (from YAML)
Step 1: Auto-detect mode (checks branch, .task-docs, commits)
Step 2: Confirm mode with user
Step 3: Execute selected mode workflow
    ↓
  [Default] → default-mode.md
  [Greenfield] → greenfield-mode.md
  [In Progress] → in-progress-mode.md
```

---

## Planning Modes

### Mode 1: Default Mode

**When to use**: Normal workflow, issue exists in YouTrack, starting fresh

**Flow**: Standard 5-phase workflow
1. Discovery & Context Gathering
2. Requirements Analysis
3. Technical Planning
4. Review & Approval
5. Implementation

**[➜ See Default Mode Documentation](./default-mode.md)**

**Typical scenarios:**
- User provides issue key (e.g., "Let's work on STAR-2228")
- No existing .task-docs folder found
- No uncommitted changes or commits on branch
- Standard planned development

---

### Mode 2: Greenfield Mode

**When to use**: Exploratory work, prototypes, tasks not yet in YouTrack

**Flow**: User-driven exploration
1. Get initial context from user
2. Optional YouTrack integration
3. Create working directory (temporary: `.task-docs/exploratory-{name}/`)
4. Document user's overview
5. Proceed with planning
6. Formalize when ready (migrate to Default Mode)

**[➜ See Greenfield Mode Documentation](./greenfield-mode.md)**

**Typical scenarios:**
- User says "explore", "prototype", "try out"
- No issue key mentioned yet
- Experimental or research work
- Will formalize later if successful

---

### Mode 3: In Progress Mode

**When to use**: Resuming work, reviewing progress, syncing docs with implementation

**Flow**: Comprehensive review and sync
1. Gather current state (git, .task-docs folder, code changes)
2. Review existing documentation
3. Compare implementation vs documentation
4. Identify discrepancies (including standards violations)
5. Present findings to user
6. Ask user to clarify discrepancies
7. Fix or update documentation
8. Create alignment matrix (requirements ↔ implementation ↔ tests ↔ standards)
8.5. Code standards & implementation readiness check (.ai/rules/, Laravel, security)
9. Present updated state (including merge readiness assessment)

**[➜ See In Progress Mode Documentation](./in-progress-mode.md)**

**Typical scenarios:**
- Existing .task-docs folder found
- Branch has commits already
- Uncommitted changes present
- User says "continue", "resume", "review progress"

---

## Folder Naming Convention

**Storage Location**: Configured in `~/.claude/config/global.yaml` (`storage.task_docs_dir`)

### Standard Naming

**Format**: `${TASK_DOCS_DIR}/{ISSUE_KEY}/`

- `${TASK_DOCS_DIR}` is PROJECT-LOCAL in the project directory (must exist, add to .gitignore)
- Use issue key from YouTrack (e.g., STAR-2228, AB-1390)
- Same as git branch name (without type prefix like `feature/`)
- Provides context when browsing directories
- Extract slug from YouTrack issue summary/title

**How to get the slug**:
1. Fetch issue from YouTrack using `mcp__youtrack__issue_lookup` or `mcp__youtrack__issue_details`
2. The response includes the issue summary/title
3. YouTrack automatically generates a slug in URLs (e.g., `/issue/STAR-2228/Warehouse-Queue`)
4. Use the same slug for consistency, or generate from summary if not in API response
5. Slug format: Title-Case-With-Hyphens (same as git branch naming)

**Examples**:
- `${TASK_DOCS_DIR}/STAR-2228-Warehouse-Queue/` ✅
- `${TASK_DOCS_DIR}/AB-1390-TypeError-in-GenerateWordCharacterSet/` ✅
- ~~`${TASK_DOCS_DIR}/STAR-2228/`~~ ❌ (missing context)
- ~~`${TASK_DOCS_DIR}/feature/STAR-2233/`~~ ❌ (don't include type prefix)

**Searching for existing folders**:
```bash
# Get task docs root using helper
TASK_DOCS_DIR=$(get_task_docs_dir)

# Check if folder exists
if [ -z "$TASK_DOCS_DIR" ]; then
  echo "ERROR: No task docs folder found. Create with: mkdir .task-docs"
  exit 1
fi

# Search for task
find "$TASK_DOCS_DIR" -type d -name "{ISSUE_KEY}*"
```
- Example: `find "$TASK_DOCS_DIR" -type d -name "STAR-2228*"` → finds `${TASK_DOCS_DIR}/STAR-2228-Warehouse-Queue/`

### Special Cases

**Greenfield Mode** (temporary):
- Format: `${TASK_DOCS_DIR}/exploratory-{short-name}/`
- Migrate to standard format when issue is created
- Example: `${TASK_DOCS_DIR}/exploratory-auth-prototype/` → `${TASK_DOCS_DIR}/STAR-2250-Auth-Prototype/`

---

## Document Structure

All tasks use this standardized structure in `${TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/`:

### Required Documents

**`00-status.md` - Status & Overview**
- Central tracking document - always check here first
- Issue metadata, current status, progress tracking
- Quick links to all other docs, next actions
- Completion criteria checklist

**`01-task-description.md` - Task Description**
- High-level overview of what needs to be done
- Summary, acceptance criteria, scope boundaries
- What you'd put in a task management system
- Brief and actionable

**`02-functional-requirements.md` - Functional Requirements**
- Detailed requirements (REQ-1, REQ-2, etc.)
- Acceptance criteria per requirement
- Edge cases and expected behaviors
- Dependencies and out of scope items

**`03-implementation-plan.md` - Technical Plan**
- Detailed step-by-step implementation
- Files to create/modify, database changes
- API/frontend changes, testing strategy
- Risks, mitigations, timeline

**`04-todo.md` - Implementation Checklist**
- Phase-by-phase checklist
- Mirrors implementation plan phases
- Updated as work progresses
- More detailed than TodoWrite tool

**`logs/decisions.md` - Decision Log**
- ADR-style decision tracking
- Architecture decisions, technical approach choices
- Trade-offs, alternatives considered
- User-confirmed vs obvious decisions

### Optional Documents

**`archive/` subfolder**
- For old/non-standard docs when reorganizing
- Keep for reference but don't actively use

---

## Mode Transitions

**When to switch modes during a task:**

### Greenfield → Default
- **Trigger**: User creates or assigns official YouTrack issue
- **Action**: Migrate `${TASK_DOCS_DIR}/exploratory-*` → `${TASK_DOCS_DIR}/{ISSUE_KEY}/`
- **Update**: Add issue references to all docs, sync with YouTrack

### Default → In Progress
- **Trigger**: User starts coding without updating docs, or returns after a break
- **Action**: Run In Progress review to sync docs with code
- **Update**: Align docs with actual implementation

### In Progress → Default
- **Trigger**: After syncing, ready to continue with clean state
- **Action**: Return to normal Phase 5 (Implementation) workflow
- **Update**: Continue with updated docs as source of truth

### Any Mode → In Progress (Health Check)
- **Trigger**: User asks "where am I?" or "review my progress"
- **Action**: Run In Progress review at any time
- **Purpose**: Get current state summary and identify issues

**Best Practice**: Use In Progress mode periodically (weekly or after significant work) to ensure docs stay synchronized with implementation.

---

## Git Workflow Integration

- **Branch creation** happens after plan approval (Phase 4 in Default Mode)
- **Branch name**: `{type}/{ISSUE_KEY}` (from YouTrack, may include slug)
- **Base branch**: `develop` (or `master` for hotfix)
- **Never commit** to develop/main directly

---

## Shared Concepts (All Modes)

### TodoWrite Tool Integration
- Used during implementation (Phase 5) for **real-time tracking**
- **Parallel to `04-todo.md`** but more granular
- TodoWrite for current work-in-progress
- `04-todo.md` for overall progress tracking

### Single Step Rule
- Applies during implementation (Phase 5)
- Each step should be one logical commit
- **Report → Describe → Ask → Wait**

### Cleanup and Archival

**When to Clean Up**

**After task complete and deployed**:
- Keep `${TASK_DOCS_DIR}/{ISSUE_KEY}/` folder for reference
- No automatic deletion

**Manual cleanup** (user decides):
- Archive to `${TASK_DOCS_DIR}/archive/{ISSUE_KEY}/` if desired
- Delete if no longer needed

**What to Commit to Git**

**Recommendation**: `.task-docs/` should be **gitignored**
- Personal working directory
- Single developer use case
- Avoid clutter in repository

**Alternative**: Commit if team wants visibility
- Add `.task-docs/` to version control
- Update `.gitignore` to allow `.task-docs/`

---

## Automation Level

**Agent Behavior**:

1. **When user mentions task key** (e.g., "Let's work on STAR-2233"):
   - Proactively search for `${TASK_DOCS_DIR}/STAR-2233*` (glob pattern to find matching directory)
   - Auto-detect appropriate mode
   - Suggest mode to user
   - If not found, offer to run planning workflow

2. **When user asks to start a task**:
   - Always suggest planning workflow first
   - Don't start coding without planning phase
   - Auto-detect and suggest mode

3. **When user is already working on task**:
   - Search for `${TASK_DOCS_DIR}/{ISSUE_KEY}*` (glob pattern)
   - Auto-detect → likely In Progress Mode
   - If missing task docs folder, offer to create documentation

4. **When creating/updating docs**:
   - Always update `00-status.md` first
   - Keep `Last Updated` timestamps current
   - Update progress tracking in real-time

---

## Tools Used

**YouTrack MCP Tools** (if enabled):
- `mcp__youtrack__issue_lookup` - Fetch issue details
- `mcp__youtrack__issue_details` - Detailed issue information
- `mcp__youtrack__issue_search` - Find related issues
- `mcp__youtrack__issue_update` - Update task description
- `mcp__youtrack__issue_comment_create` - Add updates

**File Operations**:
- `Read` - Read existing docs
- `Write` - Create new docs
- `Edit` - Update existing docs
- `Glob` - Find files and folders
- `Grep` - Search code

**Git Operations**:
- `Bash` - Git commands for status, log, diff, branch operations

**Task Management**:
- `TodoWrite` - Real-time task tracking during implementation
- `AskUserQuestion` - User confirmations and choices

---

## Best Practices

1. **Always start with `00-status.md`** - it's the source of truth
2. **Keep timestamps updated** - shows document freshness
3. **Update progress in real-time** - don't batch updates
4. **Document decisions as they happen** - don't wait until end
5. **Ask questions early** - reduce uncertainty before coding
6. **Use TodoWrite during implementation** - for granular tracking
7. **Follow single-step rule** - report, propose, ask, wait
8. **Update status when blocked** - document why and what's needed
9. **Use In Progress mode periodically** - keep docs synced (weekly on active tasks)
10. **Choose the right mode** - Default for normal, Greenfield for exploration, In Progress for review

---

## Troubleshooting

### Problem: Can't find documentation
**Solution**: Check `${TASK_DOCS_DIR}/` directory or use glob pattern `${TASK_DOCS_DIR}/{ISSUE_KEY}*`

### Problem: Existing docs are messy
**Solution**: Use **In Progress Mode** to review, then offer reorganization options

### Problem: Task changed in YouTrack
**Solution**: Use **In Progress Mode** to sync changes, update docs

### Problem: Blocked during implementation
**Solution**: Update `00-status.md` to "Blocked", document blocker, notify user

### Problem: User wants to skip planning
**Solution**: Create minimal docs (at least `00-status.md` and `04-todo.md`) for tracking

### Problem: Not sure which mode to use
**Solution**: Run auto-detection (happens automatically in `/plan-task-g`), suggest mode, let user confirm

---

## Integration with Other Workflows

The task planning workflows can be called by:
- `/plan-task-g` (mode selector - primary entry point)
- Project-specific custom workflows
- Other slash commands

All workflows use the same:
- Project context detection
- YAML configuration
- Storage conventions
- Document structure

---

## Project Configuration

### Starship (starship.yaml)

```yaml
issue_tracking:
  pattern: "STAR-####"
  regex: "STAR-[0-9]+"
  system: "YouTrack"

standards:
  location: ".ai/rules/"
  # 00-system-prompt.md, 01-core-workflow.md, etc.

citation_format:
  architecture: "[ARCH §{section-heading}]"
  style: "[STYLE: \"{direct-quote}\"]"

storage:
  location: "${TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/"

test_commands:
  all: "docker compose ... exec starship_server ./vendor/bin/phpunit"

mcp_tools:
  laravel_boost: enabled
  youtrack: enabled
```

### Alephbeis (alephbeis.yaml)

```yaml
issue_tracking:
  pattern: "AB-####"
  regex: "AB-[0-9]+"

standards:
  location: ".ai/rules/"
  # code-architecture.md, codestyle.md, etc.

citation_format:
  architecture: "[ARCH: \"{direct-quote}\"]"

storage:
  location: "${TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/"

test_commands:
  all: "docker compose exec alephbeis_app ./vendor/bin/phpunit"

mcp_tools:
  laravel_boost: enabled
  playwright: enabled
```

---

## Adding a New Project

### 1. Create YAML Configuration

```bash
# Copy template
cp ~/.claude/config/projects/starship.yaml ~/.claude/config/projects/myproject.yaml

# Edit configuration
code ~/.claude/config/projects/myproject.yaml
```

### 2. Update Key Fields

```yaml
project:
  name: "MyProject"
  path: "~/Projects/my-project"
  git_remote_pattern: "myorg/my-project"

issue_tracking:
  pattern: "MP-####"
  regex: "MP-[0-9]+"

standards:
  location: ".docs/rules/"

storage:
  location: "${TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/"

test_commands:
  all: "npm test"
```

### 3. Test Detection

```bash
cd ~/Projects/my-project
/project-context

# Should load your YAML file
```

---

## Mode Selection Table

| Mode | Use Case | When Suggested | Output |
|------|----------|----------------|--------|
| **Default** | Normal tasks, issue exists | User provides issue key, no existing work | Standardized docs in `.task-docs/` |
| **Greenfield** | Exploration, prototypes | User says "explore", no issue key | Temporary docs, formalize later |
| **In Progress** | Resume work, review progress | Existing .task-docs or commits found | Synced docs + alignment matrix |

---

## Benefits

### For Users
- ✅ **No manual configuration** - Auto-detects project and mode
- ✅ **Consistent structure** - Same docs every time
- ✅ **Progress tracking** - Always know where you are
- ✅ **Context preservation** - Never lose requirements
- ✅ **Flexible workflow** - Choose the right mode for the situation

### For Multiple Projects
- ✅ **One workflow** - Works everywhere
- ✅ **Project-specific** - Standards, commands, patterns
- ✅ **Easy maintenance** - Update YAML, not workflow
- ✅ **Extensible** - Add projects easily

### For Teams
- ✅ **Share configs** - YAML files are portable
- ✅ **Consistent standards** - Same structure, formats
- ✅ **Knowledge transfer** - Docs explain decisions
- ✅ **Onboarding** - New developers can read `.task-docs/` docs

---

**Last Updated:** 2025-11-17
**Version:** 2.0 (Multi-mode with YAML-based multi-project support)
