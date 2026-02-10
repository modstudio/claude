---
description: Deep review orchestrator - parallel multi-agent code review with synthesis
---

# Deep Review Orchestrator

Executing **parallel multi-agent deep review** of all git changes. Seven specialized review agents analyze code simultaneously, each with its own context window, then results are synthesized into a unified report.

---

## STOP - MANDATORY FIRST ACTION

**YOU MUST CALL TodoWrite RIGHT NOW before reading any other files or running any commands.**

```javascript
TodoWrite({
  todos: [
    {content: "Gather full review context", status: "in_progress", activeForm: "Gathering review context"},
    {content: "Auto-fix simple issues (skippable)", status: "pending", activeForm: "Running auto-fix"},
    {content: "Prepare agent context (pre-load modules)", status: "pending", activeForm: "Preparing agent context"},
    {content: "Launch 7 review agents in parallel", status: "pending", activeForm: "Running parallel review agents"},
    {content: "Synthesize results from all agents", status: "pending", activeForm: "Synthesizing review results"},
    {content: "Present unified deep review report", status: "pending", activeForm: "Generating deep review report"}
  ]
})
```

**DO NOT CONTINUE until TodoWrite has been called.**

---

## Permission Policy for Review Agents

**All review agents operate under a READ-ONLY permission model:**

- **Auto-approve:** ANY action that does not modify files, state, or data. This includes all Read/Grep/Glob calls and all Bash commands that only read (git, awk, wc, ls, find, grep, test runners, etc.)
- **Blocked:** Edit, Write, and any Bash command that creates, modifies, or deletes files. Review agents should NEVER need these.

**When constructing agent prompts, include this instruction:**

```
PERMISSION POLICY: You have blanket permission for ANY read-only action — no need to
ask or wait for approval. This includes: reading any file in the repo or task docs,
running any Bash command that does not modify files (git diff, git log, grep, awk, wc,
find, test runners, etc.), and using Grep/Glob freely. The rule is simple: if it doesn't
write, create, modify, or delete anything, just do it. NEVER use Edit or Write tools.
```

This ensures agents can trace dependencies, read related files, run any analysis command, and execute tests without pausing for approval on every action.

---

## Mode

- Steps 1-3: READ-ONLY (gathering) + WRITE-ENABLED (auto-fix only)
- Step 4: PARALLEL AGENTS (read-only reviewers — auto-approved for all reads)
- Steps 5-6: READ-ONLY (synthesis and reporting)

---

## Step 1: Gather Full Review Context

{{MODULE: ~/.claude/modules/shared/full-context.md}}

**Use "For Code Review Mode" section.**

**You MUST execute ALL of these actions:**

### Action 1: Run gather-context script
```bash
~/.claude/lib/bin/gather-context
```

### Action 2: Git state (run in parallel)
```bash
git status --short
git diff --cached --name-status
git diff --name-status
git diff ${PROJECT_BASE_BRANCH:-develop}..HEAD --stat
git diff ${PROJECT_BASE_BRANCH:-develop}..HEAD --name-only
```

### Action 3: YouTrack issue (if MCP available and ISSUE_KEY exists)
Use: `mcp__youtrack__get_issue` with issue_id = ISSUE_KEY

### Action 4: Task docs (if TASK_FOLDER exists)
Read all .md files in the task folder, especially:
- `02-functional-requirements.md` — acceptance criteria
- `03-implementation-plan.md` — planned files, decisions

### Categorize Changed Files

Group files by type — this determines which bug-hunter agents get which files:
- **Backend:** `*.php` in app/, database/, routes/, config/ → **bug-hunter-backend**
- **Frontend:** `*.vue`, `*.js`, `*.ts` in resources/, src/ → **bug-hunter-frontend**
- **Tests:** files in tests/ → **test-reviewer** (+ both bug-hunters for test bugs)
- **Config/Migrations:** config/, database/migrations/ → **arch-reviewer**, **dead-code-reviewer**
- **All files** → arch-reviewer, correctness-reviewer, quality-reviewer, dead-code-reviewer

Store the file list — it will be passed to all agents.

**Mark todo complete: "Gather full review context"**

---

## Step 2: Auto-Fix Phase (Skippable)

**If the user selected "Skip auto-fix phase", skip this step entirely.**

{{MODULE: ~/.claude/modules/code-review/auto-fix-phase.md}}

**Mark todo complete: "Auto-fix simple issues"**

---

## Step 3: Prepare Agent Context

**Mark todo in_progress: "Prepare agent context"**

Read and store the content of all module files that agents will need. This pre-loading ensures agents can start analyzing immediately without wasting turns reading files.

### Shared Standards (all agents need these)

Read these files and store their content:
1. `~/.claude/modules/code-review/severity-levels.md`
2. `~/.claude/modules/code-review/citation-standards.md`

### Agent-Specific Modules

| For Agent | Read These Modules |
|-----------|-------------------|
| bug-hunter-backend | `~/.claude/modules/code-review/bugs-review.md`, `~/.claude/modules/code-review/bug-categories.md` |
| bug-hunter-frontend | `~/.claude/modules/code-review/bugs-review.md`, `~/.claude/modules/code-review/bug-categories.md` |
| arch-reviewer | `~/.claude/modules/code-review/architecture-review.md`, `~/.claude/modules/code-review/review-rules.md` |
| correctness-reviewer | `~/.claude/modules/code-review/correctness-review.md`, `~/.claude/modules/code-review/performance-security.md` |
| quality-reviewer | `~/.claude/modules/code-review/code-quality-review.md` |
| test-reviewer | `~/.claude/modules/code-review/test-review.md` |
| dead-code-reviewer | `~/.claude/modules/code-review/dead-code-review.md` |

### Project Standards

If `$PROJECT_STANDARDS_DIR` exists, read all standard files:
```bash
ls "$PROJECT_STANDARDS_DIR"/*.md 2>/dev/null
```

Read each file and store its content.

### Review History

Check for prior review decisions to avoid re-raising rejected items:
```bash
# Find review logs for current issue
ls ${PROJECT_TASK_DOCS_DIR}/${ISSUE_KEY:-NONE}*/logs/review.md 2>/dev/null
```

If found, read the review log and extract previously rejected findings.

**Mark todo complete: "Prepare agent context"**

---

## Step 4: Launch 7 Review Agents in Parallel

**Mark todo in_progress: "Launch 7 review agents"**

**CRITICAL: All 7 Task calls MUST be in a single response** so Claude Code runs them concurrently.

For each agent, construct a prompt with this structure:

```
PERMISSION POLICY: You have blanket permission for ANY read-only action — no need to
ask or wait for approval. This includes: reading any file, running any Bash command that
does not modify files (git, grep, awk, wc, find, test runners, etc.), and using Grep/Glob.
The rule is simple: if it doesn't write, create, modify, or delete anything, just do it.
NEVER use Edit or Write tools.

## Your Role
[Agent-specific role description from ~/.claude/agents/{agent}.md]

## Review Instructions
[Pre-loaded module content specific to this agent]

## Shared Standards
[Content from severity-levels.md + citation-standards.md]

## Project Standards
[Content from $PROJECT_STANDARDS_DIR files, if any]

## Review History (skip findings matching these rejected items)
[Content from logs/review.md, or "None — no prior reviews"]

## Changed Files
[File list with categories from Step 1]
[For bug-hunter-backend: ONLY backend files (*.php)]
[For bug-hunter-frontend: ONLY frontend files (*.vue, *.js, *.ts)]
[For other agents: ALL changed files]

## Diff Summary
[git diff --stat output from Step 1]

## Base Branch
PROJECT_BASE_BRANCH={value}

## Test Commands (test-reviewer only)
PROJECT_TEST_CMD_UNIT={value}
PROJECT_TEST_CMD_ALL={value}

Begin: Read each changed file listed above and apply your review checklist.
You can read ANY file in the repo — do not wait for permission on reads.
Report findings in the structured format defined in your role.
End with your summary counts (CRITICAL: N, MAJOR: N, MINOR: N).
```

### Launch All 7 Agents

**All 7 in a SINGLE response:**

```javascript
// Agent 1: Bug Hunter (Backend — PHP/Laravel)
Task({
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "Bug Hunter Backend: Review PHP files for bugs",
  prompt: /* constructed prompt with bug-hunter-backend role + bugs-review + bug-categories modules, ONLY backend files */
})

// Agent 2: Bug Hunter (Frontend — Vue/JS/TS)
Task({
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "Bug Hunter Frontend: Review Vue/JS/TS files for bugs",
  prompt: /* constructed prompt with bug-hunter-frontend role + bugs-review + bug-categories modules, ONLY frontend files */
})

// Agent 3: Architecture Reviewer
Task({
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "Arch Reviewer: Review N files for architecture",
  prompt: /* constructed prompt with arch-reviewer role + architecture-review + review-rules modules */
})

// Agent 4: Correctness & Security Reviewer
Task({
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "Correctness Reviewer: Review N files for correctness/security",
  prompt: /* constructed prompt with correctness-reviewer role + correctness-review + performance-security modules */
})

// Agent 5: Quality Reviewer
Task({
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "Quality Reviewer: Review N files for code quality",
  prompt: /* constructed prompt with quality-reviewer role + code-quality-review module */
})

// Agent 6: Test Reviewer
Task({
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "Test Reviewer: Review N files for test quality + run tests",
  prompt: /* constructed prompt with test-reviewer role + test-review module + test commands */
})

// Agent 7: Dead Code Reviewer
Task({
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "Dead Code Reviewer: Find unused code and refactor remnants",
  prompt: /* constructed prompt with dead-code-reviewer role + dead-code-review module */
})
```

**Wait for all 7 agents to return results.**

**Mark todo complete: "Launch 7 review agents"**

---

## Step 5: Synthesize Results

**Mark todo in_progress: "Synthesize results"**

After all 7 agents return, process their results:

### 5.1 Parse Findings

Extract structured findings from each agent's output:
- Severity (CRITICAL, MAJOR, MINOR)
- Location (file:line)
- Issue description
- Category/type
- Evidence and fix

### 5.2 Deduplicate

Same file:line reported by multiple agents:
- Keep the most detailed finding
- Note agent agreement (e.g., "Found by: bug-hunter-backend, correctness-reviewer")
- Higher confidence when multiple agents flag the same issue

### 5.3 Frontend-Backend Contract Mismatch Check

With both bug-hunter outputs available, look for cross-stack issues:
- API resource fields (snake_case) vs TypeScript interface fields (camelCase)
- Response shape assumptions in frontend vs actual backend response structure
- Field names in FormRequest validation vs frontend form submissions
- Error response format consistency

### 5.4 Cross-Validate ALL Findings

**Every finding from every agent must be verified — not just CRITICAL ones.** Sonnet agents can hallucinate issues or misread code. The orchestrator is responsible for confirming each claim.

For **every** finding (CRITICAL, MAJOR, and MINOR):
- **Read the actual code** at the reported file:line
- Verify the issue exists as described by the agent
- Check that the evidence matches reality (does the code actually do what the agent claims?)
- Mark as **"Verified: yes"**, **"Verified: no — dismissed"**, or **"Verified: partially"**

**Actions based on verification:**

| Verification Result | Action |
|-------------------|--------|
| Verified: yes | Keep finding as-is |
| Verified: partially | Keep but adjust description to match what's actually there, note discrepancy |
| Verified: no | **Dismiss entirely** — do NOT include in report. Note in "Dismissed Findings" section |

**For CRITICAL findings that can't be confirmed:** Downgrade to MAJOR with a note explaining the uncertainty.

This verification step is what makes the deep review trustworthy — it ensures zero hallucinated findings reach the user.

### 5.5 Normalize Severity

Apply severity-levels.md consistently:
- If agents disagree on severity for the same issue, use the higher severity
- Ensure CRITICAL is reserved for stop-the-merge issues
- Ensure MAJOR is for should-fix-before-merge issues
- Dead code findings are MAJOR (high confidence) or MINOR (needs verification) — never CRITICAL

### 5.6 Check Review History

For each finding, compare against previously rejected items from review log:
- If a finding matches a previously rejected item, mark it as "Previously reviewed — rejected"
- Include in report but clearly labeled so user can skip
- Do NOT auto-dismiss — user may want to reconsider

### 5.7 Resolve Conflicts

If agents give contradictory advice:
- Note the conflict
- Read the actual code to determine which agent is correct
- Include resolution reasoning in synthesis notes

### 5.8 Handle Agent Failures

| Scenario | Action |
|----------|--------|
| Agent times out | Note gap in coverage table, continue with remaining agents |
| Agent returns no findings | Valid — record "no issues found" |
| Agent returns unstructured output | Extract what you can, note in synthesis notes |
| Both bug-hunters or test-reviewer fail | Flag as INCOMPLETE — these are critical agents |
| Single bug-hunter fails | Note gap for that stack, other agents still provide coverage |
| arch/correctness/quality/dead-code fails | Note gap, proceed with caution |

**Mark todo complete: "Synthesize results"**

---

## Step 6: Present Deep Review Report

**Mark todo in_progress: "Present report"**

**OUTPUT TO CHAT ONLY** — never create files.

### Report Format

```markdown
# Deep Review Report

## Executive Summary

| Metric | Value |
|--------|-------|
| Status | PASS / NEEDS WORK / FAIL |
| Critical Issues | N |
| Major Issues | N |
| Minor Issues | N |
| Dead Code Found | N items (~N lines) |
| Tests | X/Y passing |
| Auto-Fixed | N issues |
| Agents Completed | 7/7 |
| **Recommendation** | **APPROVE / REQUEST CHANGES / REJECT** |

## Auto-Fixed Issues
[from Step 2, or "Skipped" if auto-fix was skipped]

## Findings by Severity

### CRITICAL (Must Fix Before Merge)

**[Issue Title]**
- **Location:** `file/path:line`
- **Violation:** [Standard reference]
- **Issue:** [Description]
- **Evidence:** [Code or trace]
- **Fix:** [Solution]
- **Found by:** [agent name(s)] | **Verified:** yes/no
---

### MAJOR (Should Fix Before Merge)

[Same format — every finding includes Found by + Verified status]

### MINOR (Non-Blocking)

[Same format — every finding includes Found by + Verified status]

## Dead Code

### High Confidence (MAJOR)
[Dead code findings from dead-code-reviewer with HIGH confidence]

### Needs Verification (MINOR)
[Findings with MEDIUM/LOW confidence]

### Cleanup Impact
- Estimated removable lines: ~N
- Files potentially deletable: N

## Review Agent Coverage

| Agent | Role | Findings | Critical | Major | Minor | Status |
|-------|------|----------|----------|-------|-------|--------|
| bug-hunter-backend | PHP/Laravel bugs | N | N | N | N | Complete/Failed/Timeout |
| bug-hunter-frontend | Vue/JS/TS bugs | N | N | N | N | Complete/Failed/Timeout |
| arch-reviewer | Architecture | N | N | N | N | Complete/Failed/Timeout |
| correctness-reviewer | Correctness/Security | N | N | N | N | Complete/Failed/Timeout |
| quality-reviewer | Code quality | N | N | N | N | Complete/Failed/Timeout |
| test-reviewer | Tests | N | N | N | N | Complete/Failed/Timeout |
| dead-code-reviewer | Dead code | N | N | N | N | Complete/Failed/Timeout |
| **TOTAL** | | **N** | **N** | **N** | **N** | |

## Test Results
[From test-reviewer agent output]

| Test File | Tests | Assertions | Time | Status |
|-----------|-------|------------|------|--------|
| ... | ... | ... | ... | ... |
| **TOTAL** | **N** | **N** | **Ns** | **STATUS** |

## Synthesis Notes

### Cross-Validation Results
- [Issues confirmed by multiple agents]
- [Issues where agents disagreed and how resolved]

### Frontend-Backend Contract Issues
- [Any mismatches found during cross-stack synthesis]

### Dismissed Findings
- [Findings dismissed with reasons]

### Previously Reviewed Items
- [Items matching review history — status from prior review]

### Coverage Gaps
- [Any agents that failed or timed out]
- [File types not covered]

## Action Plan

**REQUIRED Before Merge:**
- [ ] [Critical fix 1]
- [ ] [Critical fix 2]

**RECOMMENDED:**
- [ ] [Major fix 1]
- [ ] [Major fix 2]

**CLEANUP (Dead Code):**
- [ ] [Dead code removal 1]
- [ ] [Dead code removal 2]

**OPTIONAL:**
- [ ] [Minor improvement 1]
```

### Recommendation Logic

| Condition | Recommendation |
|-----------|---------------|
| 0 CRITICAL, 0 MAJOR | **APPROVE** |
| 0 CRITICAL, >0 MAJOR | **REQUEST CHANGES** |
| >0 CRITICAL | **REJECT** |
| Both bug-hunters or test-reviewer failed | Cannot approve — recommend `/code-review-g` as fallback |

**Mark todo complete: "Present report"**

---

## Execution Constraints

**You MUST:**
- Pre-load ALL module content before launching agents (Step 3)
- Launch ALL 7 agents in a single response (Step 4)
- Include the PERMISSION POLICY block in every agent prompt (auto-approve reads)
- Send only relevant files to each bug-hunter (backend files → backend, frontend files → frontend)
- Run frontend-backend contract check during synthesis (Step 5.3)
- Cross-validate EVERY finding by reading actual code — not just CRITICAL (Step 5.4)
- Deduplicate findings across agents (Step 5.2)
- Present unified report in chat only (Step 6)
- Track all phases with TodoWrite

**You MUST NOT:**
- Launch agents sequentially (they MUST be parallel)
- Create any files (report goes to chat only)
- Skip synthesis (don't just concatenate agent outputs)
- Auto-dismiss previously reviewed items (let user decide)
- Make any code changes (entire review is read-only, except auto-fix in Step 2)

---

Begin: **Call TodoWrite now**, then execute each step in order.
