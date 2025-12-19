# Code Review Workflows

Modular code review workflows with multi-project support via YAML configuration.

## Quick Start

```bash
# Invoke code review
/code-review-g

# Select mode:
# - Report Review (comprehensive)
# - Quick Review (fast)
# - Interactive Review (step-by-step)
# - External Review Evaluation
```

---

## Architecture

### Modular Design

The code review workflow follows a modular architecture similar to task-planning:

```
commands/code-review-g.md (entry point)
  │
  ├── modules/shared/quick-context.md (detect context)
  │
  └── Select Mode:
      ├── workflows/code-review/report.md
      ├── workflows/code-review/quick.md
      ├── workflows/code-review/interactive.md
      └── workflows/code-review/external.md
          │
          └── Each calls shared modules:
              ├── modules/shared/full-context.md (Code Review Mode)
              ├── modules/code-review/auto-fix-phase.md
              ├── modules/code-review/architecture-review.md
              ├── modules/code-review/correctness-review.md
              ├── modules/code-review/code-quality-review.md
              ├── modules/code-review/test-review.md
              ├── modules/code-review/generate-report.md
              ├── modules/code-review/critical-checks.md
              ├── modules/code-review/performance-security.md
              │
              └── Shared standards:
                  ├── modules/code-review/review-rules.md
                  ├── modules/code-review/severity-levels.md
                  └── modules/code-review/citation-standards.md
```

### Module Responsibilities

| Module | Purpose | Mode |
|--------|---------|------|
| `shared/full-context.md` | Gather git state, files, issue, task docs | READ-ONLY |
| `auto-fix-phase.md` | Run linters, remove debug statements | WRITE (safe) |
| `architecture-review.md` | Check architecture compliance | READ-ONLY |
| `correctness-review.md` | Check logic and robustness | READ-ONLY |
| `code-quality-review.md` | Check style and quality | READ-ONLY |
| `test-review.md` | Review tests and execute them | READ + BASH |
| `generate-report.md` | Compile final report | READ-ONLY |
| `critical-checks.md` | Quick checks for critical file types | READ-ONLY |
| `performance-security.md` | Performance and security checks | READ-ONLY |

### Shared Modules

| Module | Purpose |
|--------|---------|
| `review-rules.md` | Checklists for all review types |
| `severity-levels.md` | BLOCKER/MAJOR/MINOR/NIT definitions |
| `citation-standards.md` | How to cite rule violations |
| `standards-loading.md` | Load project standards from `.ai/rules/` |

---

## Review Modes

### 1. Report Review (Recommended)

**Best for:** Feature branches, regular PR reviews

**Process:**
1. Gather context (issue, git state, task docs)
2. Auto-fix simple issues (linter, debug statements)
3. Architecture review
4. Correctness & robustness analysis
5. Code quality review
6. Test review & execution
7. Generate comprehensive report

**Output:** Detailed markdown report with all findings

### 2. Quick Review

**Best for:** Small PRs, bug fixes (<500 lines)

**Process:**
1. Scope check (decide quick vs full)
2. Critical file checks (migrations, models)
3. Auto-fix phase
4. Test verification & execution
5. Quick report

**Output:** Pass/Fail report with critical issues only

### 3. Interactive Review

**Best for:** Complex changes, need manual control

**Process:** Same as Report but with STOP points after each step for user approval

**Output:** Step-by-step findings with approvals

### 4. External Review Evaluation

**Best for:** Evaluating AI or developer review feedback

**Process:**
1. Load project standards
2. Load current code state
3. User pastes external review
4. Parse and check for duplicates
5. Independent analysis of each suggestion
6. Generate evaluation report
7. Record to permanent file
8. Apply changes if approved

**Output:** Accept/Modify/Reject decisions with reasoning

---

## File Structure

```
~/.claude/
├── commands/
│   └── code-review-g.md              ← Entry point
│
├── modules/
│   ├── code-review/                  ← Code review specific
│   │   ├── auto-fix-phase.md
│   │   ├── architecture-review.md
│   │   ├── correctness-review.md
│   │   ├── code-quality-review.md
│   │   ├── test-review.md
│   │   ├── generate-report.md
│   │   ├── critical-checks.md        ← Quick checks for migrations, models, etc.
│   │   ├── performance-security.md   ← Performance and security checks
│   │   ├── review-rules.md
│   │   ├── severity-levels.md
│   │   └── citation-standards.md
│   │
│   └── shared/                       ← Cross-workflow
│       ├── quick-context.md
│       ├── full-context.md           ← Includes "For Code Review Mode" section
│       ├── standards-loading.md
│       └── ...
│
├── workflows/
│   └── code-review/
│       ├── README.md                 ← This file
│       ├── report.md                 ← Full review controller
│       ├── quick.md                  ← Quick review controller
│       ├── interactive.md            ← Interactive controller
│       └── external.md               ← External evaluation controller
```

---

## Mode Comparison

| Feature | Report | Quick | Interactive | External |
|---------|--------|-------|-------------|----------|
| Automated | Yes | Yes | No (STOP points) | Yes |
| Auto-fix | Yes | Yes | No | No |
| Architecture | Full | Critical only | Full | N/A |
| Tests | All | Modified | All | Optional |
| Time | 10-20 min | 5-10 min | 30+ min | Varies |
| Best for | PRs | Bug fixes | Complex | Feedback |

---

## Project Configuration

### Standards Location

Standards loaded from `$PROJECT_STANDARDS_DIR` (typically `.ai/rules/`):

```
.ai/rules/
├── 10-coding-style.md     ← Style, naming, formatting
├── 20-architecture.md     ← DDD, patterns, structure
└── 30-testing.md          ← Test conventions
```

### Citation Format

Each project defines citation format in YAML:

```yaml
citation_format:
  architecture: "[ARCH §{section}]"
  style: "[STYLE §{section}]"
  test: "[TEST §{section}]"
```

### Test Commands

Project-specific test commands:

```yaml
test_commands:
  all: "docker compose exec app ./vendor/bin/phpunit"
  unit: "docker compose exec app ./vendor/bin/phpunit --testsuite=unit"
```

---

## Usage Examples

### Standard PR Review

```bash
cd ~/Projects/starship
git checkout feature/STAR-2233-Add-Feature

/code-review-g
# Select: "Report Review"
# Review runs automatically
# Get comprehensive report
```

### Quick Bug Fix

```bash
cd ~/Projects/starship
git checkout bugfix/STAR-2234-Fix-Bug

/code-review-g
# Select: "Quick Review"
# Fast checklist + tests
# Get pass/fail report
```

### Complex Multi-Commit

```bash
cd ~/Projects/starship
git checkout feature/STAR-2235-Big-Refactor

/code-review-g
# Select: "Interactive Review"
# Step through with approvals
# Control each phase
```

### Evaluate External Feedback

```bash
cd ~/Projects/starship
/code-review-g
# Select: "External Review Evaluation"
# Paste Copilot/ChatGPT suggestions
# Get independent analysis
```

---

## Severity Levels

| Level | Symbol | Blocks Merge? | Must Fix? |
|-------|--------|---------------|-----------|
| BLOCKER | ⛔ | Yes | Yes |
| MAJOR | ⚠️ | Conditional | Should |
| MINOR | 📋 | No | Encouraged |
| NIT | 💡 | No | Optional |

See `modules/code-review/severity-levels.md` for full definitions.

---

## Troubleshooting

### Standards Not Found

```bash
# Check standards directory
ls $PROJECT_STANDARDS_DIR

# Typical location
ls .ai/rules/
```

### Tests Failing

```bash
# Run tests manually
$PROJECT_TEST_CMD_ALL

# Check test command in project config
grep test_commands ~/.claude/config/projects/*.yaml
```

### Context Not Loading

```bash
# Check gather-context script
~/.claude/lib/bin/gather-context

# Check task docs exist
ls .task-docs/
```

---

**Last Updated:** 2025-12-19
**Version:** 4.0 (Modular Architecture)
