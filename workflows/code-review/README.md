# Code Review Workflows

Code review workflows with multi-project support via YAML configuration.

## Quick Start

```bash
# Invoke code review
/code-review-g

# Select: "External Review Evaluation"
# Paste external review text
# Get independent analysis with accept/reject decisions
```

---

## File Structure

```
~/.claude/
├── config/
│   ├── global.yaml                        ← Global configuration (storage.wip_root)
│   └── projects/                          ← Project configurations (YAML)
│       ├── starship.yaml                  ← Starship config
│       ├── alephbeis.yaml                 ← Alephbeis config
│       └── generic.yaml                   ← Fallback config
│
├── templates/                             ← Reusable templates
│   └── external-review-log.md            ← Review record template
│
└── workflows/
    ├── project-context.md                 ← Multi-project loader
    ├── helpers.md                         ← Helper functions
    └── code-review/
        ├── README.md                      ← This file
        ├── external.md                    ← External review evaluator
        ├── interactive.md                 ← Manual step-by-step (if exists)
        ├── quick.md                       ← Quick checklist (if exists)
        └── report.md                      ← Comprehensive review (if exists)
```

**Storage Configuration**: See `~/.claude/config/global.yaml` (`storage.wip_root`)

**Project Files (Created by Workflows):**
```
${WIP_ROOT}/{ISSUE_KEY}-{slug}/
├── external-review-log.md                 ← Review record (appended)
├── specification.md                       ← Task specification
└── notes.md                               ← Task notes
```
*Where `WIP_ROOT` defaults to `~/.wip` (GLOBAL location)*

---

## How It Works

### 1. Project Detection

Workflow automatically detects which project you're in:

```bash
cd ~/Projects/starship
# Detects: Starship (from YAML: starship.yaml)
# Issue pattern: STAR-####
# Standards: .ai/rules/
# Tests: Docker + PHPUnit

cd ~/Projects/alephbeis-app
# Detects: Alephbeis (from YAML: alephbeis.yaml)
# Issue pattern: AB-####
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

### 3. External Review Evaluation

```
User → /code-review-g → "External Review"
    ↓
Phase 0: Load project context (from YAML)
Phase 1: Load standards + previous reviews
Phase 2: Get current code state
Phase 3: User pastes external review
Phase 5: Independent analysis
Phase 6: Generate evaluation report
Phase 7: Record to ${WIP_ROOT}/{ISSUE_KEY}-{slug}/external-review-log.md
Phase 8: Apply changes (optional)
```

---

## External Review Workflow

### What It Does

**Evaluates external code reviews from:**
- AI tools (GitHub Copilot, ChatGPT, Cursor)
- Human reviewers
- Automated linters (PHPCS, ESLint, PHPStan)
- Static analysis tools

**Provides:**
- ✅ Independent verification of each suggestion
- ✅ Accept/Modify/Reject decisions with reasoning
- ✅ Citations to project standards
- ✅ Permanent record for circular review
- ✅ Learning feedback loop

### Circular Review Concept

**Review → Record → Review the Review → Improve**

1. External reviewer reviews code
2. You evaluate their review (this workflow)
3. Record evaluation in `${WIP_ROOT}/{ISSUE_KEY}-{slug}/external-review-log.md`
4. Next review reads past evaluations
5. Maintain consistency, learn patterns
6. Improve calibration over time

**Example Record:**
```markdown
## Review #1 - 2025-11-14
Source: GitHub Copilot
Analyzed: 8 suggestions
✅ Accepted: 2 (25%) - Good at null checks
❌ Rejected: 5 (62%) - Doesn't understand DDD
Quality: ⭐⭐⭐ (3/5)

Lesson: Copilot good for simple bugs, ignore architecture suggestions
```

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

## Usage Examples

### Evaluate GitHub Copilot Review

```bash
cd ~/Projects/starship
# On branch: feature/STAR-2233-Add-Feature

/code-review-g → "External Review"

# Paste Copilot's suggestions
# Get analysis:
# - ✅ Suggestion #1: ACCEPTED - Violation [ARCH §Correctness]
# - ❌ Suggestion #2: REJECTED - Premature optimization
# - ⚠️ Suggestion #3: MODIFIED - Better approach exists

# Record saved to: ${WIP_ROOT}/STAR-2233-Feature-Name/external-review-log.md
```

### Evaluate Human Code Review

```bash
cd ~/Projects/alephbeis-app
# On branch: AB-1378-Smart-Test-Visibility

/code-review-g → "External Review"

# Paste code review comments
# Get independent evaluation
# Cross-reference with past reviews (if any)
# Record for future consistency
```

### Review the Review (Circular)

```bash
# Load .wip root from global config
WIP_ROOT="$HOME/.wip"  # From ~/.claude/config/global.yaml

# After multiple reviews:
cat "$WIP_ROOT/STAR-2233-Feature-Name/external-review-log.md"

# See:
# - Review #1, #2, #3...
# - Patterns in external review quality
# - Your own evaluation consistency
# - Learning over time
```

---

## Template Usage

### External Review Record Template

Located: `~/.claude/templates/external-review-log.md`

**Used for:** Creating `${WIP_ROOT}/{ISSUE_KEY}-{slug}/external-review-log.md`

**Structure:**
- File header with purpose
- How to use instructions
- Review sections (appended per review)
- Statistics summary
- Learning notes

**Workflow automatically:**
1. Creates file from template (first review)
2. Appends new review sections
3. Updates statistics
4. Maintains history

---

## Maintenance

### Update Project Configuration

```bash
# Edit YAML directly
code ~/.claude/config/projects/starship.yaml

# Changes take effect immediately
```

### Add New Standard File

```yaml
standards:
  files:
    - path: ".ai/rules/new-guideline.md"
      purpose: "New coding guidelines"
```

### Update Test Commands

```yaml
test_commands:
  unit: "docker compose exec app ./vendor/bin/phpunit --testsuite=unit"
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

## Benefits

### For Users
- ✅ **No manual configuration** - Auto-detects project
- ✅ **Consistent citations** - Uses project format
- ✅ **Correct test commands** - From YAML config
- ✅ **Review history** - Track all evaluations
- ✅ **Learning feedback** - Improve over time

### For Multiple Projects
- ✅ **One workflow** - Works everywhere
- ✅ **Project-specific** - Standards, commands, patterns
- ✅ **Easy maintenance** - Update YAML, not workflow
- ✅ **Extensible** - Add projects easily

### For Teams
- ✅ **Share configs** - YAML files are portable
- ✅ **Consistent standards** - Same citations, formats
- ✅ **Audit trail** - All reviews recorded
- ✅ **Knowledge building** - Circular review learnings

---

## Troubleshooting

### Project Not Detected

```bash
# Check YAML files exist
ls ~/.claude/config/projects/

# Check current path
pwd

# Check git remote
git remote get-url origin

# Verify YAML syntax
cat ~/.claude/config/projects/starship.yaml
```

### Wrong Project Detected

**Cause:** Multiple projects match patterns

**Fix:** Make patterns more specific in YAML files

```yaml
# Be specific
path: "~/Projects/starship"  # ✅ Specific
path: "~/Projects"           # ❌ Too broad
```

### Review File Not Created

**Check:**
- Task folder exists in `$WIP_ROOT`
- Issue key extracted correctly
- Permissions on `$WIP_ROOT` directory

**Debug:**
```bash
# Load .wip root from global config
WIP_ROOT="$HOME/.wip"  # From ~/.claude/config/global.yaml

# Check directory
ls -la "$WIP_ROOT/"

# Check branch name
git branch --show-current

# Extract issue key manually
git branch --show-current | grep -oE "STAR-[0-9]+"
```

---

## Integration with Other Workflows

The external review workflow can be called by:
- `/code-review-g` (mode selector)
- Project-specific `/code-review`
- Custom workflows

All workflows use the same:
- Project context detection
- YAML configuration
- Storage conventions
- Templates

---

**Last Updated:** 2025-11-14
**Version:** 3.0 (YAML-based multi-project)
