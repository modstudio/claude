# Module: full-context

## Purpose
Deep context gathering after user confirms workflow mode. Comprehensive, thorough, fetches from all sources.

## Scope
SHARED - Used by: task-planning, code-review, release workflows

## Mode
READ-ONLY (gathering) + WRITE (documenting findings)

---

## When to Use
- AFTER user confirms workflow mode
- AFTER quick-context scan
- Can take as long as needed
- Run operations in PARALLEL where possible

---

## What to Gather (by mode)

### For Default/New Task Mode

**Run in parallel:**
```javascript
// 1. Fetch from YouTrack
mcp__youtrack__get_issue({ issue_id: "$ISSUE_KEY" })

// 2. Read task docs (if folder exists)
// Read all .md files in TASK_FOLDER

// 3. Search codebase for patterns
// Grep/Glob for related code

// 4. Read project standards
// Read relevant .ai/rules/ files
```

### For In Progress Mode

**Run in parallel:**
```bash
# 1. Full git diff
git diff ${PROJECT_BASE_BRANCH}..HEAD

# 2. All commits on branch
git log ${PROJECT_BASE_BRANCH}..HEAD --oneline

# 3. Changed files summary
git diff --stat ${PROJECT_BASE_BRANCH}..HEAD

# 4. Read ALL task docs
# Read every file in TASK_FOLDER
```

### For Default Mode (New Task)

When no issue key is available, gather from user:
- Task overview
- Goals and constraints
- Any existing context they have
- Offer to create YouTrack issue

→ See: `~/.claude/modules/task-planning/get-user-context.md`

### For Code Review Mode

**⛔ YOU MUST EXECUTE ALL OF THESE ACTIONS (run in parallel where possible):**

**Action 1: Run gather-context script**
```bash
~/.claude/lib/bin/gather-context
```
This loads task documentation. Read the output.

**Action 2: Get git state (run these in parallel)**
```bash
git status --short
git diff --cached --name-status
git diff --name-status
git diff ${PROJECT_BASE_BRANCH}..HEAD --stat
```

**Action 3: Fetch YouTrack issue (if MCP available and ISSUE_KEY exists)**
Use: `mcp__youtrack__get_issue` with issue_id = ISSUE_KEY

**Action 4: Read task docs (if TASK_FOLDER exists)**
Read all .md files in the task folder, especially:
- `02-functional-requirements.md` - acceptance criteria
- `03-implementation-plan.md` - planned files, decisions

**⛔ DO NOT proceed to Step 2 until you have executed ALL actions above.**

**Categorize changed files by type:**
- Backend: `*.php` in app/, database/
- Frontend: `*.vue`, `*.js`, `*.ts` in resources/
- Tests: files in tests/
- Config/Migrations: config/, database/migrations/

---

## Output Format

**Always present as structured summary:**

```markdown
## Context Summary

### Issue: {ISSUE_KEY}
- **Summary**: {from YouTrack}
- **Type**: {type} | **Priority**: {priority}
- **Status**: {status}

### Task Documentation
- **Folder**: {path or "not found"}
- **Status**: {from 00-status.md}
- **Completeness**: {X/6 docs exist}

### Codebase
- **Similar patterns**: {found in X files}
- **Related files**:
  - `path/to/file.php` - {why relevant}

### Key Findings
1. {Important finding}
2. {Important finding}

### Blockers/Concerns
- {Any issues to address}

<details>
<summary>Full details</summary>
{Expandable detailed content}
</details>
```

---

## Presentation Rules

1. **Summary first** - Key findings visible without expanding
2. **Tables for status** - Quick scanning
3. **Bullets for findings** - Easy to read
4. **Details for depth** - Expandable sections
5. **Never dump raw output** - Always synthesize

---

## Parallel Execution

**Run independent operations together:**

```javascript
// GOOD - parallel
Promise.all([
  fetchYouTrack(issueKey),
  readTaskDocs(taskFolder),
  searchCodebase(keywords),
  readStandards(standardsDir)
])

// BAD - sequential when not needed
await fetchYouTrack(issueKey)
await readTaskDocs(taskFolder)  // doesn't depend on above
```

---

## Outputs
- `ISSUE_DETAILS`: Full issue from YouTrack
- `TASK_DOCS_CONTENTS`: Contents of all docs
- `CODEBASE_PATTERNS`: Related code found
- `PROJECT_STANDARDS`: Applicable rules
- `CONTEXT_SUMMARY`: Formatted summary for user
