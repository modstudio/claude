---
description: Sync task documentation with actual implementation (global)
---

# Sync Docs

Synchronize task documentation to match the actual implementation. Rewrite docs as if the current implementation was the original plan.

**Workflow Documentation**: `~/.claude/workflows/task-planning/sync-docs.md`

---

## YOUR FIRST RESPONSE MUST INCLUDE THESE TWO TOOL CALLS:

1. **TodoWrite** - Create a todo list:
   - "Detect context" status=in_progress activeForm="Detecting context"
   - "Review task docs" status=pending activeForm="Reviewing docs"
   - "Review implementation" status=pending activeForm="Reviewing implementation"
   - "Identify divergences" status=pending activeForm="Identifying divergences"
   - "Get user approval for divergence handling" status=pending activeForm="Getting user approval"
   - "Rewrite docs to match implementation" status=pending activeForm="Rewriting docs"
   - "Update ADRs for divergences" status=pending activeForm="Updating ADRs"

2. **Bash** - Run: `~/.claude/lib/detect-mode.sh --pretty`

**CALL BOTH TOOLS NOW. Do not read any other files first.**

---

## After Detection Script Runs

Update todo: first item → completed, second item → in_progress

**Present the context as a table, then proceed to Step 2.**

---

## Step 2: Review Task Docs

**Read ALL documentation in the task folder:**

```bash
TASK_FOLDER="{from detect-mode output}"
ls -la "$TASK_FOLDER"
```

**Read each doc:**
- `00-status.md` - Current status
- `01-task-description.md` - Task scope and goals
- `02-functional-requirements.md` - Requirements list
- `03-implementation-plan.md` - Technical approach
- `04-todo.md` - Checklist
- `logs/decisions.md` - ADRs (if exists)

**Build understanding of what was PLANNED.**

Mark todo complete, move to next.

---

## Step 3: Review Implementation

{{MODULE: ~/.claude/modules/task-planning/gather-implementation-state.md}}

**Additionally, review:**
1. **Changed files** - What was actually built
2. **Commit messages** - What the commits say was done
3. **Code structure** - How it's organized

**Build understanding of what was IMPLEMENTED.**

Mark todo complete, move to next.

---

## Step 4: Identify Divergences

**Compare PLANNED vs IMPLEMENTED:**

| Aspect | Planned | Implemented | Divergence |
|--------|---------|-------------|------------|
| Approach | {from docs} | {from code} | {difference} |
| Scope | {from docs} | {from code} | {difference} |
| Structure | {from docs} | {from code} | {difference} |

**Categorize divergences:**

1. **Minor adjustments** - Small implementation details
2. **Approach changes** - Different technical approach than planned
3. **Scope changes** - Added/removed functionality
4. **Architecture changes** - Structural decisions changed

**Output summary to chat, then mark todo complete.**

---

## Step 5: Rewrite Docs to Match Implementation

**⚠️ CRITICAL: REWRITE, DON'T APPEND**

- Do NOT add "deviation" sections
- Do NOT mark things as "changed from original plan"
- REWRITE docs as if the current implementation was ALWAYS the plan

**Update order:**

### 5.1 Update `00-status.md`
Reflect actual current status.

### 5.2 Update `03-implementation-plan.md`
**REWRITE entirely** to describe what was actually built:
- Actual architecture used
- Actual files created/modified
- Actual approach taken

**The reader should think this was the original plan.**

### 5.3 Update `02-functional-requirements.md`
Update requirements to match what was actually implemented:
- Mark implemented items as complete
- Remove requirements that were descoped
- Add requirements that emerged during implementation

### 5.4 Update `04-todo.md`
Reflect actual completion state:
- Check off completed items
- Add any remaining work

### 5.5 Update `01-task-description.md`
Update summary to accurately describe current scope.

**Mark todo complete, move to next.**

---

## Step 6: Update ADRs for Divergences

**For each significant divergence (approach/architecture changes):**

**Append to `logs/decisions.md`:**

```markdown
## ADR-{N}: {Decision Title}

**Date**: {today}
**Status**: Accepted

**Context**
{What situation led to this decision}

**Decision**
{What we decided to do}

**Rationale**
{Why this approach was chosen over the original plan}

**Consequences**
- {Positive outcome}
- {Trade-off accepted}
```

**ADR criteria - create ADR when:**
- Technical approach changed significantly
- Scope was modified (added/removed features)
- Architecture pattern changed
- Tool/library choice changed

**Don't create ADR for:**
- Minor implementation details
- Bug fixes
- Code organization tweaks

**Mark todo complete.**

---

## Step 7: Present Summary

```markdown
## Docs Sync Complete

### Documents Updated
| Document | Changes |
|----------|---------|
| 00-status.md | {change summary} |
| 01-task-description.md | {change summary} |
| 02-functional-requirements.md | {change summary} |
| 03-implementation-plan.md | {change summary} |
| 04-todo.md | {change summary} |

### ADRs Created
- ADR-{N}: {title} - {brief reason}

### Divergences Documented
| Original Plan | Actual Implementation | ADR |
|---------------|----------------------|-----|
| {planned} | {actual} | ADR-{N} |

### Current State
- Status: {current status}
- Completion: {X%}
- Remaining: {items}
```

---

## Key Principles

### Rewrite, Don't Annotate
- Docs should read cleanly
- No "deviation" markers
- Implementation IS the plan now

### ADRs Capture History
- Divergences go in ADRs, not inline docs
- ADRs explain WHY things changed
- Future readers check ADRs for history

### Output to Chat
- Summaries go to chat
- Only task docs are written to files
- No separate report files created

---

## Modules Used

- `task-planning/gather-implementation-state.md` - Get git/code state
- Detection script for context

---

Begin: **Create TodoWrite**, then **run detect-mode.sh**.
