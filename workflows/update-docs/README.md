# Update Documentation Workflow

Update knowledge base documentation to reflect implementation changes from tasks or direct article edits.

## Quick Start

```bash
# Update docs based on task implementation
/update-docs-g STAR-1234

# Update specific article directly
/update-docs-g Warehouse-Queue-Management.md

# Broad scan of recent tasks
/update-docs-g --broad
```

---

## File Structure

```
~/.claude/
├── commands/
│   └── update-docs-g.md                 <- Main orchestrator command
│
├── templates/
│   └── update-docs/
│       ├── updated-article.md           <- Template for updated articles
│       ├── summary.md                   <- Summary document template
│       └── review-checklist.md          <- Review checklist template
│
└── workflows/
    └── update-docs/
        ├── README.md                    <- This file
        ├── task-mode.md                 <- Task-based documentation updates
        └── article-mode.md              <- Direct article updates
```

**Output Location**: Project-local `.task-docs/{ISSUE_KEY}-{slug}/docs-updates/`

**Output Files Created:**
```
.task-docs/{ISSUE_KEY}-{slug}/
└── docs-updates/
    ├── {Article-Name-1}.md              <- Updated article content
    ├── {Article-Name-2}.md              <- Updated article content
    ├── _review-checklist.md             <- Articles reviewed/updated
    └── _summary.md                      <- Summary of all changes
```

---

## How It Works

### 1. Mode Detection

Workflow automatically detects which mode based on user input:

```bash
/update-docs-g STAR-1234
# Detects: Task Mode (issue key provided)

/update-docs-g Order-Processing.md
# Detects: Article Mode (article name provided)

/update-docs-g --broad
# Detects: Broad Mode (explicit flag)
```

### 2. Project Configuration

Reads knowledge base configuration from project YAML:

```yaml
# In ~/.claude/config/projects/{project}.yaml
documentation:
  knowledge_base:
    location: "storage/app/youtrack_docs"
    source: "gitignored"
    access_method: "bash"
```

### 3. Mode Execution

```
User -> /update-docs-g [input]
    |
Phase 0: Load project context
Step 1: Auto-detect mode
Step 2: Confirm mode with user
Step 3: Execute selected mode workflow
    |
  [Task Mode] -> task-mode.md
  [Article Mode] -> article-mode.md
  [Broad Mode] -> task-mode.md (extended)
```

---

## Documentation Modes

### Mode 1: Task Mode

**When to use**: After completing a task, to update docs affected by implementation

**Flow**: 7-phase workflow
1. Discovery - Get task folder, analyze implementation
2. Article Search - Find relevant knowledge base articles
3. Impact Analysis - Determine which articles need updates
4. Review List - Present list to user for confirmation
5. Article Check - Detailed comparison for each article
6. Update Creation - Create updated versions
7. Summary - Generate summary and sync instructions

**[-> See Task Mode Documentation](./task-mode.md)**

---

### Mode 2: Article Mode

**When to use**: Direct updates to specific article(s) without task context

**Flow**: 5-phase workflow
1. Article Selection - User specifies article(s)
2. Article Fetch - Read current content
3. Change Analysis - Understand what needs updating
4. Update Creation - Create updated version
5. Summary - Document changes

**[-> See Article Mode Documentation](./article-mode.md)**

---

### Mode 3: Broad Mode

**When to use**: Comprehensive scan for documentation gaps across related tasks

**Flow**: Extended Task Mode
1. Find recent completed tasks
2. Check if their docs were updated
3. Cross-reference for missed documentation
4. Aggregate all needed updates
5. Run Task Mode for each area

---

## Key Requirements (All Modes)

Every documentation update MUST:

### 1. Verify Code Alignment
- Review ALL related code implementing documented features
- Ensure documentation reflects **current code implementation**
- Update outdated API endpoints, parameters, workflows
- Validate example code actually works

### 2. Apply Style Guide
- Read Documentation Style Guide before making updates
- All updates must conform to style guide standards
- Consistent terminology and formatting

### 3. Write for Non-Technical Users
- Clear, accessible language
- Avoid jargon or explain when used
- Focus on user tasks and outcomes

### 4. Use Present Tense
- All implemented features in present tense
- "Users can..." not "Users will be able to..."

### 5. Include Summary of Changes
- REQUIRED at end of every updated document
- List all changes made
- Document code verification status

---

## Best Practices

### When to Run

**Run after:**
- Task implementation is complete
- Major feature additions
- User-facing behavior changes
- API/workflow modifications

**Don't run:**
- During active implementation (wait until done)
- For internal-only changes (no user impact)
- When no knowledge base exists

### Process Tips

1. **Complete implementation first** - Don't update docs for incomplete work
2. **Read style guide first** - Understand documentation standards
3. **Verify against code** - Always check current implementation
4. **Read before writing** - Understand current article before changes
5. **Don't overwrite** - Always create copies, never modify originals directly

---

**Workflow Version:** 1.0.0
