# Module: Agent Resource Allocation

## Purpose

Dynamic resource allocation (max_turns, model) for review agents.
Single source of truth for all skills that spawn review agents.

## Scope

SHARED - Used by: deep-review, bug-zapper-g, code-review, any skill spawning review agents

---

## Diff Metrics Collection

Before spawning agents, collect these metrics from the diff:

```bash
# Count files by type
git diff ${PROJECT_BASE_BRANCH:-develop}..HEAD --name-only | wc -l                                        # total_files
git diff ${PROJECT_BASE_BRANCH:-develop}..HEAD --name-only | grep '\.php$' | wc -l                        # backend_files
git diff ${PROJECT_BASE_BRANCH:-develop}..HEAD --name-only | grep -E '\.(vue|js|ts|jsx|tsx)$' | wc -l     # frontend_files
git diff ${PROJECT_BASE_BRANCH:-develop}..HEAD --name-only | grep -iE 'test|spec' | wc -l                 # test_files

# Count total lines changed
git diff ${PROJECT_BASE_BRANCH:-develop}..HEAD --stat | tail -1  # total_lines (additions + deletions)

# Check for security-sensitive files
git diff ${PROJECT_BASE_BRANCH:-develop}..HEAD --name-only | grep -iE 'auth|login|password|token|permission|gate|policy|middleware|csrf|encrypt|secret|api.*key' | wc -l  # security_files
```

Store as: `total_files`, `backend_files`, `frontend_files`, `test_files`, `total_lines`, `security_files`

---

## max_turns Formula

Use the diff metrics to compute `max_turns` per agent. Apply `min(formula, ceiling)`.

| Agent | Formula | Ceiling |
|-------|---------|---------|
| bug-hunter-backend | `40 + backend_files * 5` | 300 |
| bug-hunter-frontend | `40 + frontend_files * 5` | 300 |
| arch-reviewer | `40 + total_files * 4` | 250 |
| correctness-reviewer | `45 + total_files * 5` | 300 |
| quality-reviewer | `35 + total_files * 4` | 250 |
| test-reviewer | `40 + test_files * 6` | 300 |
| dead-code-reviewer | `35 + total_files * 4` | 250 |

Ceilings are safety nets only — be generous. It's far better for an agent to finish early
with unused turns than to run out before completing analysis.

---

## Model Selection

| Agent | Default | Upgrade to Opus When |
|-------|---------|---------------------|
| bug-hunter-backend | sonnet | `backend_files > 20` |
| correctness-reviewer | sonnet | `security_files > 0` OR `total_lines > 500` |
| all others | sonnet | never |

---

## Resource Guidance Template

Include this in every agent prompt so agents can self-manage their budget:

```
RESOURCE GUIDANCE: You have approximately {max_turns} turns to complete this review.
There are {file_count} files totaling ~{line_count} changed lines in your scope.
Prioritize files by likely impact. If you are running low on turns, summarize
remaining files rather than skipping them entirely.
```

Always pass `max_turns` to the Agent tool parameter AND include it in the prompt text.

---

## When to Parallelize

- **>15 changed files** — spawn specialized agents in parallel
- **<=15 files** — single-agent sequential analysis is fine
- When parallelizing, always compute and pass `max_turns` per agent using the formulas above
