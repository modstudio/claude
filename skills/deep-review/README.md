# Deep Review Skill

**Skill:** Parallel multi-agent code review with synthesis
**Version:** 2.0.0
**Entry point:** `commands/deep-review-g.md`
**Orchestrator:** `skills/deep-review/main.md`

---

## Overview

Deep Review launches **7 specialized review agents in parallel**, each with its own ~200k context window, then synthesizes results into a unified report. This gives 7x the analysis capacity, faster wall time, and better finding quality through cross-validation.

### Architecture: Fan-Out / Fan-In

```
                    ┌─────────────────────┐
                    │  /deep-review-g     │  ← Command entry point
                    │  (detect context)   │
                    └─────────┬───────────┘
                              │
                              v
                    ┌─────────────────────┐
                    │  main.md            │  ← Orchestrator (Opus)
                    │  Steps 1-3: Setup   │
                    └─────────┬───────────┘
                              │
              Step 4: Fan-Out │ (7 parallel Task calls)
                              │
      ┌─────┬─────┬─────┬────┴────┬─────┬─────┐
      v     v     v     v         v     v     v
   ┌─────┐┌────┐┌────┐┌─────┐┌─────┐┌────┐┌─────┐
   │ Bug ││Bug ││Arch││Corr.││Qual.││Test││Dead │  ← Sonnet agents
   │ BE  ││ FE ││Rev.││Rev. ││Rev. ││Rev.││Code │     (~200k each)
   └──┬──┘└─┬──┘└─┬──┘└──┬──┘└──┬──┘└─┬──┘└──┬──┘
      │     │     │      │      │     │      │
      └─────┴─────┴──────┴──┬───┴─────┴──────┘
                             │
               Step 5: Fan-In│ (synthesis in Opus)
                             │
                    ┌────────v────────────┐
                    │  Synthesis          │
                    │  - Deduplicate      │
                    │  - Contract check   │
                    │  - Cross-validate   │
                    │  - Normalize        │
                    │  - Resolve conflicts│
                    └─────────┬───────────┘
                              │
                    ┌─────────v───────────┐
                    │  Unified Report     │  ← Chat output only
                    │  (Step 6)           │
                    └─────────────────────┘
```

---

## Agent Table

| Agent | Focus | Scope | Key Checks |
|-------|-------|-------|------------|
| **bug-hunter-backend** | PHP/Laravel bugs | `*.php` | 16 phases: deps, existence, types, null safety, logic, resources, copy-paste, type juggling, error handling, TOCTOU, framework misuse, contracts, side effects, temporal coupling, deviant behavior, boundaries |
| **bug-hunter-frontend** | Vue/JS/TS bugs | `*.vue`, `*.js`, `*.ts` | 13 phases: deps, existence, types, null safety, logic, Vue reactivity, async hazards, error handling, cleanup/lifecycle, coercion, shadowing, boundaries, copy-paste |
| **arch-reviewer** | Architecture | All files | DDD, models, services, handlers, controllers, Vue 3 readiness |
| **correctness-reviewer** | Correctness + Security | All files | Edge cases, error handling, type safety, concurrency, N+1, OWASP |
| **quality-reviewer** | Code quality | All files | Naming, typing, comments, metrics, PSR-12 |
| **test-reviewer** | Tests | Test files | Structure, quality, coverage, execution |
| **dead-code-reviewer** | Dead code | All files | Unused functions, orphaned files, stale routes, refactor remnants |

All agents:
- Use **sonnet** model with **30 max turns**
- Are **read-only** (except test-reviewer runs tests via Bash)
- Have **blanket read permission** (no interaction needed for file reads, git commands)
- Receive pre-loaded module content (no wasted turns reading config files)
- Receive shared severity-levels and citation-standards

---

## Permission Model

Agents operate under a **read-only permission policy** based on a simple principle:

> **If it doesn't write, create, modify, or delete anything — just do it. No approval needed.**

| Action | Permission |
|--------|-----------|
| Any read-only action (Read, Grep, Glob, Bash that only reads) | Auto-approved |
| Edit, Write, any Bash that modifies files | Blocked (agents never modify code) |

This ensures agents can trace dependencies, read any file, run git/awk/grep/find/test commands — anything that's read-only — without pausing for approval.

---

## Comparison: Standard Report vs Deep Review

| Aspect | Standard Report (`/code-review-g`) | Deep Review (`/deep-review-g`) |
|--------|--------------------------------------|-------------------------------|
| Context windows | 1 (shared) | 7+1 (agents + orchestrator) |
| Analysis capacity | ~200k tokens total | ~1.6M tokens total |
| Parallelism | Sequential phases | 7 agents run simultaneously |
| Wall time | 10-20 minutes | ~5-8 minutes |
| Model | Single context (Opus) | Sonnet agents + Opus synthesis |
| Bug detection | 1 pass, both stacks | Dedicated backend + frontend hunters |
| Dead code | Not checked | Dedicated agent |
| Cross-validation | None | Multi-agent agreement detection |
| Contract checking | None | Frontend-backend mismatch at synthesis |
| Best for | Standard PRs, quick feedback | Large refactors, critical releases |

---

## File Structure

```
~/.claude/
├── agents/                          ← Agent definitions
│   ├── bug-hunter-backend.md            # PHP/Laravel bugs (16 phases)
│   ├── bug-hunter-frontend.md           # Vue/JS/TS bugs (13 phases)
│   ├── arch-reviewer.md                 # Architecture compliance
│   ├── correctness-reviewer.md          # Logic + perf + security
│   ├── quality-reviewer.md              # Code quality & style
│   ├── test-reviewer.md                # Test quality + execution
│   └── dead-code-reviewer.md           # Dead code detection
│
├── commands/
│   └── deep-review-g.md            ← Command entry point
│
├── skills/
│   └── deep-review/
│       ├── README.md                ← This file
│       └── main.md                  ← Orchestrator skill
│
└── modules/code-review/             ← Shared modules (SSOT)
    ├── severity-levels.md               # All agents
    ├── citation-standards.md            # All agents
    ├── bugs-review.md                   # Both bug-hunters
    ├── bug-categories.md                # Both bug-hunters
    ├── architecture-review.md           # arch-reviewer
    ├── review-rules.md                  # arch-reviewer
    ├── correctness-review.md            # correctness-reviewer
    ├── performance-security.md          # correctness-reviewer
    ├── code-quality-review.md           # quality-reviewer
    ├── test-review.md                   # test-reviewer
    └── dead-code-review.md              # dead-code-reviewer
```

---

## How It Works

### Step 1: Gather Context (sequential)
- Run `gather-context` script
- Collect git state (status, diff, changed files)
- Fetch YouTrack issue (if available)
- Read task docs (if available)
- Categorize changed files (backend → bug-hunter-backend, frontend → bug-hunter-frontend)

### Step 2: Auto-Fix Phase (sequential, skippable)
- Run linter/fixer on changed files
- Remove debug statements
- Record what was fixed

### Step 3: Prepare Agent Context (sequential)
- Read all module files agents will need
- Read project standards
- Load review history
- This pre-loading means agents start analyzing immediately

### Step 4: Launch Agents (parallel fan-out)
- All 7 Task calls in a single response
- Each agent gets: role + modules + standards + changed files + diff + permission policy
- Bug-hunter-backend gets only PHP files; bug-hunter-frontend gets only Vue/JS/TS files
- Agents run concurrently with ~200k context each
- All read operations auto-approved — no interaction pauses

### Step 5: Synthesize (sequential fan-in)
- Parse findings from all 7 agents
- Deduplicate (same file:line from multiple agents)
- **Frontend-backend contract mismatch check** (cross-stack synthesis)
- Cross-validate CRITICAL findings by reading actual code
- Normalize severity across agents
- Check review history for previously rejected items
- Resolve conflicts when agents disagree

### Step 6: Present Report (chat only)
- Executive summary with recommendation
- Findings grouped by severity
- Dead code section with cleanup impact
- Agent coverage table
- Test results
- Synthesis notes (cross-validation, contract issues, dismissed, conflicts)
- Action plan with checkboxes

---

## Error Handling

| Scenario | Action |
|----------|--------|
| Agent times out | Note gap in coverage table, continue |
| Both bug-hunters or test-reviewer fail | Cannot approve — recommend `/code-review-g` as fallback |
| Single bug-hunter fails | Note gap for that stack, other agents provide coverage |
| arch/correctness/quality/dead-code fails | Note gap, proceed with caution |
| Agent returns no findings | Valid — "no issues found" in coverage table |
| Agent returns unstructured output | Extract what possible, note in synthesis |

---

## Cost & Performance

- **Agents:** 7 x Sonnet (cost-effective for analysis work)
- **Orchestrator:** Opus (needed for synthesis quality)
- **Total tokens:** ~7-12x a standard review (spread across agents)
- **Wall time:** ~2-3x faster than sequential (agents run in parallel)
- **Best value:** Large PRs where a single context window would be saturated

---

## When to Use

**Use Deep Review when:**
- Large refactor (>20 files changed)
- Critical code paths (payments, auth, data migrations)
- Pre-release review of feature branch
- Want maximum bug detection confidence
- Need dead code cleanup after refactor
- Standard review context window feels saturated

**Use Standard Report (`/code-review-g`) when:**
- Small to medium PRs (<20 files)
- Quick feedback cycle needed
- Cost-sensitive reviews
- Simple bug fixes or documentation changes

---

**End of Documentation**
