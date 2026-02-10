---
description: Deep code review - parallel multi-agent analysis (global)
---

# Deep Code Review

I'll perform a **deep parallel code review** using 7 specialized agents analyzing your code simultaneously.

**Skill Documentation:** `~/.claude/skills/deep-review/`

---

## YOUR FIRST RESPONSE MUST INCLUDE THESE TWO TOOL CALLS:

1. **TodoWrite** - Create a todo list with 3 items:
   - "Detect context (run detect-mode.sh)" status=in_progress activeForm="Detecting context"
   - "Confirm review scope" status=pending activeForm="Confirming scope"
   - "Execute deep review skill" status=pending activeForm="Executing deep review"

2. **Bash** - Run: `~/.claude/lib/detect-mode.sh --pretty`

**CALL BOTH TOOLS NOW. Do not read any other files first. Do not run git commands directly.**

---

## After Detection Script Runs

Update the todo list:
- First item -> completed
- Second item -> in_progress

Present the detected context as a table:

| Field | Value |
|-------|-------|
| Mode | [detected mode] |
| Branch | [branch name] |
| Issue Key | [key or "none"] |
| Task Folder | [path or "none"] |
| Commits Ahead | [count] |
| Uncommitted | [count] |

---

## Step 2: Confirm Review Scope

**MANDATORY: Use AskUserQuestion to confirm:**

```javascript
AskUserQuestion({
  questions: [{
    question: "Ready to launch deep review with 7 parallel agents?",
    header: "Deep Review",
    multiSelect: false,
    options: [
      {label: "Full Deep Review (Recommended)", description: "All 7 agents: backend bugs, frontend bugs, architecture, correctness/security, quality, tests, dead code. Includes auto-fix phase."},
      {label: "Skip auto-fix phase", description: "Run all 7 review agents but skip the auto-fix (linter/debug cleanup) phase."},
      {label: "Switch to standard review", description: "Use single-context /code-review-g instead (faster, less thorough)."}
    ]
  }]
})
```

**If user selects "Switch to standard review":**
- Tell user to run `/code-review-g` instead
- Stop execution

Mark todo as completed: "Confirm review scope"

---

## Step 3: Execute Deep Review Skill

**Read and execute:** `~/.claude/skills/deep-review/main.md`

**After reading the skill file, your FIRST action must be to call TodoWrite with the skill's todo list (shown at top of file). Then follow the skill steps.**

Pass the user's choice about auto-fix to the skill:
- "Full Deep Review" -> run auto-fix phase
- "Skip auto-fix phase" -> skip Step 2 in skill

Mark todo as completed: "Execute deep review skill"

---

## Module Architecture

```
commands/deep-review-g.md (this file - entry point)
  │
  └── skills/deep-review/main.md (orchestrator)
      │
      ├── Step 1: Gather Context
      │   └── modules/shared/full-context.md
      │
      ├── Step 2: Auto-Fix (skippable)
      │   └── modules/code-review/auto-fix-phase.md
      │
      ├── Step 3: Prepare Agent Context
      │   ├── modules/code-review/severity-levels.md (all agents)
      │   ├── modules/code-review/citation-standards.md (all agents)
      │   ├── modules/code-review/bugs-review.md (both bug-hunters)
      │   ├── modules/code-review/bug-categories.md (both bug-hunters)
      │   ├── modules/code-review/architecture-review.md (arch-reviewer)
      │   ├── modules/code-review/review-rules.md (arch-reviewer)
      │   ├── modules/code-review/correctness-review.md (correctness-reviewer)
      │   ├── modules/code-review/performance-security.md (correctness-reviewer)
      │   ├── modules/code-review/code-quality-review.md (quality-reviewer)
      │   ├── modules/code-review/test-review.md (test-reviewer)
      │   └── modules/code-review/dead-code-review.md (dead-code-reviewer)
      │
      ├── Step 4: Launch 7 Agents (PARALLEL)
      │   ├── agents/bug-hunter-backend.md
      │   ├── agents/bug-hunter-frontend.md
      │   ├── agents/arch-reviewer.md
      │   ├── agents/correctness-reviewer.md
      │   ├── agents/quality-reviewer.md
      │   ├── agents/test-reviewer.md
      │   └── agents/dead-code-reviewer.md
      │
      ├── Step 5: Synthesize Results
      │   └── Deduplicate, cross-validate, normalize, resolve conflicts
      │
      └── Step 6: Present Report (CHAT ONLY)
          └── Unified report with recommendations
```

---

## Key Reminders

1. **FIRST:** Create TodoWrite with all steps
2. **Follow todos in order** — mark in_progress -> completed
3. **Context loading happens in the skill** — each agent gets pre-loaded modules
4. **All 7 agents launch in a single response** — this is critical for parallelism
5. **Report goes to CHAT only** — never create files

---

Begin: **Create TodoWrite**, then execute each step in order.
