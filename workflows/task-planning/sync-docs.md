# Sync Docs Workflow

**Purpose:** Synchronize task documentation with actual implementation reality.

**Philosophy:** Rewrite docs as if the current implementation was the original plan. Divergences are captured in ADRs, not as inline annotations.

---

## ⛔ STOP - MANDATORY FIRST ACTION

**YOU MUST CALL TodoWrite RIGHT NOW before reading any other files or running any commands.**

```javascript
TodoWrite({
  todos: [
    {content: "Detect context", status: "in_progress", activeForm: "Detecting context"},
    {content: "Review task docs", status: "pending", activeForm: "Reviewing docs"},
    {content: "Review implementation", status: "pending", activeForm: "Reviewing implementation"},
    {content: "Identify divergences", status: "pending", activeForm: "Identifying divergences"},
    {content: "Ask user how to handle divergences", status: "pending", activeForm: "Asking user about divergences"},
    {content: "Rewrite docs to match implementation", status: "pending", activeForm: "Rewriting docs"},
    {content: "Update ADRs for divergences", status: "pending", activeForm: "Updating ADRs"}
  ]
})
```

**⛔ DO NOT CONTINUE until TodoWrite has been called.**

---

## Phase 0: Project Context

{{MODULE: ~/.claude/modules/shared/quick-context.md}}

---

## Step 1: Detect Context

**Run detection script:**

```bash
~/.claude/lib/detect-mode.sh --pretty
```

**Required outputs:**
- `ISSUE_KEY` - The issue being worked on
- `TASK_FOLDER` - Path to task docs
- `BRANCH` - Current branch
- `COMMITS_AHEAD` - Work done
- `UNCOMMITTED` - Pending changes

**If TASK_FOLDER is "none":**
- Cannot sync docs that don't exist
- Suggest using `/plan-task-g` to create docs first

---

## Step 2: Review Task Docs

**Read ALL documentation in task folder:**

```bash
# List contents
ls -la "$TASK_FOLDER"

# Read each doc (use Read tool)
```

**Documents to review:**

| Document | Purpose | Key Information |
|----------|---------|-----------------|
| `00-status.md` | Current state | Phase, completion % |
| `01-task-description.md` | Scope | Summary, goals |
| `02-functional-requirements.md` | Requirements | What should be built |
| `03-implementation-plan.md` | Technical plan | How it should be built |
| `04-todo.md` | Checklist | What's done/remaining |
| `logs/decisions.md` | History | Past decisions |

**Build `PLANNED_STATE`:** Understanding of what was planned.

---

## Step 3: Review Implementation

{{MODULE: ~/.claude/modules/task-planning/gather-implementation-state.md}}

**Additional analysis:**

### 3.1 Analyze Changed Files

```bash
# Get full list of changes vs base branch
git diff --name-only ${PROJECT_BASE_BRANCH:-develop}..HEAD
```

**Categorize changes:**
- New files created
- Existing files modified
- Files deleted

### 3.2 Analyze Commit History

```bash
# Get commit messages for context
git log ${PROJECT_BASE_BRANCH:-develop}..HEAD --oneline
```

**Extract:**
- What work was done (from messages)
- Sequence of changes
- Any pivots or restarts

### 3.3 Analyze Code Structure

**Read key files to understand:**
- Architecture used
- Patterns implemented
- Dependencies added

**Build `IMPLEMENTED_STATE`:** Understanding of what was actually built.

---

## Step 4: Identify Divergences

**Compare PLANNED_STATE vs IMPLEMENTED_STATE:**

### 4.1 Approach Divergences

| Planned Approach | Actual Approach | Significance |
|------------------|-----------------|--------------|
| {from plan} | {from code} | Minor/Major |

### 4.2 Scope Divergences

| Planned Scope | Actual Scope | Change Type |
|---------------|--------------|-------------|
| {requirement} | {status} | Added/Removed/Changed |

### 4.3 Architecture Divergences

| Planned Structure | Actual Structure | Impact |
|-------------------|------------------|--------|
| {from plan} | {from code} | Low/Medium/High |

**Categorize each divergence:**

| Category | ADR Required? | Doc Update |
|----------|---------------|------------|
| Minor adjustment | No | Rewrite quietly |
| Approach change | Yes | Rewrite + ADR |
| Scope change | Yes | Rewrite + ADR |
| Architecture change | Yes | Rewrite + ADR |

**Output `DIVERGENCES` list to chat.**

---

## Step 4.5: Ask User How to Handle Divergences

**Present divergences to user and ask for direction:**

Use `AskUserQuestion` to get user guidance on how to handle each category of divergence.

### Divergence Categories

| Category | Description |
|----------|-------------|
| **Added** | Items in implementation but not in docs (new features/code added) |
| **Not Implemented** | Items in docs but not in code (planned but skipped) |
| **Changed** | Items that differ between docs and implementation |

### Ask User

**For each significant divergence, present options:**

```javascript
AskUserQuestion({
  questions: [
    {
      question: "How should I handle the divergences found?",
      header: "Divergences",
      multiSelect: false,
      options: [
        {
          label: "Update docs to match code",
          description: "Rewrite documentation to reflect actual implementation (recommended)"
        },
        {
          label: "Review each divergence",
          description: "Go through each divergence individually and decide"
        },
        {
          label: "Show divergences only",
          description: "Just list the divergences without making changes"
        }
      ]
    }
  ]
})
```

**If user chooses "Review each divergence":**

For each divergence, ask:

- **Added items:** "Document this new feature?" / "Leave undocumented?"
- **Not implemented:** "Remove from docs?" / "Mark as future work?" / "Flag as TODO?"
- **Changed items:** "Update docs to match?" / "Keep original docs?" / "Note the difference in ADR?"

**Proceed to Step 5 based on user direction.**

---

## Step 5: Rewrite Docs

**⚠️ CRITICAL PRINCIPLE: REWRITE, DON'T APPEND**

The goal is clean documentation that reads as if the current implementation was always the plan.

**DO NOT:**
- Add "Note: this changed from original plan"
- Create "deviations" sections
- Leave outdated content with strikethrough
- Append "updates" at the bottom

**DO:**
- Rewrite sections to reflect reality
- Remove outdated content entirely
- Write as if this was always the plan
- Keep docs clean and readable

### 5.1 Update `00-status.md`

```markdown
## Status: {actual current status}

**Phase:** {current phase}
**Completion:** {realistic %}
**Last Updated:** {today}
```

### 5.2 Update `03-implementation-plan.md`

**FULL REWRITE** to describe actual implementation:

```markdown
## Implementation Approach

{Describe the actual approach taken}

## Architecture

{Describe actual architecture used}

## Key Components

{List actual components created}

## Files Changed

{List actual files with purposes}
```

### 5.3 Update `02-functional-requirements.md`

**Update each requirement:**

- Implemented → Mark complete with evidence
- Not implemented → Remove or mark as future
- New requirements → Add as if always planned

### 5.4 Update `04-todo.md`

**Reflect actual state:**

```markdown
## Completed
- [x] {actually completed items}

## In Progress
- [ ] {current work}

## Remaining
- [ ] {actual remaining work}
```

### 5.5 Update `01-task-description.md`

**Update summary to reflect actual scope:**

```markdown
## Summary

{Accurate description of what this task accomplishes}

## Scope

{Actual scope, not original scope}
```

---

## Step 6: Update ADRs

**For each divergence requiring an ADR:**

**Append to `logs/decisions.md`:**

```markdown
---

## ADR-{N}: {Descriptive Title}

**Date:** {YYYY-MM-DD}
**Status:** Accepted

### Context

{What situation or discovery led to this decision}
{What was the original plan}
{What changed or was learned}

### Decision

{What we decided to do instead}
{The new approach taken}

### Rationale

{Why this approach is better}
{What benefits it provides}
{What trade-offs were accepted}

### Consequences

**Positive:**
- {benefit}

**Negative/Trade-offs:**
- {trade-off accepted}

**Neutral:**
- {side effect}
```

### ADR Guidelines

**Create ADR when:**
- Technical approach changed significantly
- Scope expanded or contracted
- Architecture pattern changed
- Tool/library/dependency changed
- Performance/security trade-off made

**Don't create ADR for:**
- Minor refactoring
- Bug fixes
- Code style changes
- Variable naming
- File organization tweaks

---

## Step 7: Present Summary

**Output to chat:**

```markdown
## Docs Sync Complete: {ISSUE_KEY}

### Summary
- **Documents updated:** {count}
- **ADRs created:** {count}
- **Divergences documented:** {count}

### Documents Updated

| Document | Key Changes |
|----------|-------------|
| 00-status.md | Status: {old} → {new} |
| 01-task-description.md | Scope clarified |
| 02-functional-requirements.md | {N} requirements updated |
| 03-implementation-plan.md | Rewritten to match implementation |
| 04-todo.md | {N} items updated |

### ADRs Created

| ADR | Title | Reason |
|-----|-------|--------|
| ADR-{N} | {title} | {brief reason} |

### Key Divergences Captured

| Original Plan | Actual Implementation |
|---------------|----------------------|
| {planned} | {actual} |

### Current State

- **Status:** {current}
- **Completion:** {%}
- **Remaining Work:**
  - {item 1}
  - {item 2}

### Next Steps

1. {recommended next action}
2. {optional follow-up}
```

---

## Key Principles

### 1. Implementation IS the Plan

Once code is written, that's the reality. Docs describe reality, not aspirations.

### 2. Clean Documentation

Future readers shouldn't see the mess of planning vs execution. They see clean docs that describe what exists.

### 3. ADRs Tell the Story

The history of decisions lives in ADRs. Main docs are always current state.

### 4. No Report Files

All summaries go to chat. Only task docs are file artifacts.

---

## Error Handling

### No Task Folder Found

```
Task folder not found for {ISSUE_KEY}.

Options:
1. Run /plan-task-g to create task documentation
2. Specify task folder path manually
3. Create docs structure first
```

### No Implementation Found

```
No commits or changes found on branch.

This command syncs docs WITH implementation.
If no implementation exists, use /plan-task-g instead.
```

### Docs Already Current

```
Documentation appears to match implementation.

No significant divergences found.
Minor updates made: {list}

Docs are in sync.
```

---

## Module Dependencies

- `~/.claude/modules/shared/quick-context.md`
- `~/.claude/modules/task-planning/gather-implementation-state.md`
- `~/.claude/lib/detect-mode.sh`
