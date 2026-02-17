---
description: Architecture review - thorough structural analysis with leanness check (global)
---

# Architecture Review

Deep architectural analysis focusing on structure, patterns, and leanness.

**Skill Documentation**: `~/.claude/skills/code-review/arch-review.md`

---

## YOUR FIRST RESPONSE MUST INCLUDE THESE TWO TOOL CALLS:

1. **TodoWrite** - Create a todo list with 3 items:
   - "Detect context and review scope" status=in_progress activeForm="Detecting context"
   - "Select review scope (changes vs task docs)" status=pending activeForm="Selecting review scope"
   - "Execute architecture review workflow" status=pending activeForm="Executing architecture review"

2. **Bash** - Run: `~/.claude/lib/detect-mode.sh --pretty`

**CALL BOTH TOOLS NOW. Do not read any other files first. Do not run git commands directly.**

---

## After Detection Script Runs

Update the todo list:
- First item → completed
- Second item → in_progress

Present the detected context as a table.

---

## Step 2: Select Review Scope

**MANDATORY: Use AskUserQuestion to present scope options:**

```javascript
AskUserQuestion({
  questions: [{
    question: "What do you want to review for architecture compliance?",
    header: "Review Scope",
    multiSelect: false,
    options: [
      {label: "Code Changes (Recommended)", description: "Review all changes on current branch vs base branch"},
      {label: "Task Docs Plan", description: "Review implementation plan from task docs (planning mode)"},
      {label: "Specific Files", description: "Review specific files or directories you'll provide"}
    ]
  }]
})
```

Mark todo as completed: "Select review scope"

---

## Step 3: Execute Architecture Review

**Read and follow:** `~/.claude/skills/code-review/arch-review.md`

**After reading the skill file, your FIRST action must be to call TodoWrite with the skill's todo list. Then follow the skill steps.**

---

## What This Review Covers

| Area | Focus |
|------|-------|
| **Project Architecture** | DDD structure, domain boundaries, file placement |
| **Laravel Best Practices** | Model patterns, service patterns, repository patterns (uses Boost MCP) |
| **Inline Doc Compliance** | Respects `.context.md` rules, migration tracking |
| **Leanness Review** | Over-engineering, unnecessary abstractions, premature optimization |
| **Pattern Consistency** | Consistent patterns across similar components |

## What This Review Does NOT Cover

- Bug detection (use `/code-review-g` → Bug Zapper)
- Code style/formatting (use `/code-review-g` → Quick Review)
- Test coverage (use `/code-review-g` → Report Review)
- Security issues (use `/code-review-g` → Report Review)

---

## Resources Used

**Standards:** `$PROJECT_STANDARDS_DIR/20-architecture.md`
**Inline Docs:** `.context.md` and `.migration.md` files in relevant directories
**Laravel Boost MCP:** `mcp__laravel-boost__search-docs` (if Laravel project)
**Task Docs:** `$PROJECT_TASK_DOCS_DIR/{issue}/03-implementation-plan.md` (if reviewing plan)

---

Begin: **Create TodoWrite**, then execute each step in order.
