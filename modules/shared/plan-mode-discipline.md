# Plan Mode Discipline

**Module:** Planning vs implementation phase separation
**Version:** 1.0.0

## Purpose
Enforce separation between planning (read-only) and implementation (write) phases.

## Scope
SHARED - Used by: task-planning workflows

**Core principle**: Separate planning from implementation. Never modify anything during planning.

---

## Why This Matters

Plan Mode ensures:
1. **Understanding before action** - Avoid making changes you'll need to undo
2. **User alignment** - Get buy-in before committing to an approach
3. **Better decisions** - Research thoroughly before choosing solutions
4. **Reduced waste** - Don't write code based on wrong assumptions

---

## The Two Phases

### Phase A: Planning (READ-ONLY)

**During planning, you are in research mode.**

**Allowed tools:**
- `Read` - Read files to understand code
- `Grep` - Search for patterns
- `Glob` - Find files
- `WebSearch` - Research solutions
- `WebFetch` - Fetch documentation
- `AskUserQuestion` - Clarify requirements
- `TodoWrite` - Track planning progress
- MCP read tools (YouTrack lookup, etc.)

**Forbidden tools (until approval):**
- `Edit` - No editing project source files
- `Write` - No creating project source files
- `Bash` commands that modify state:
  - No `git commit`, `git push`, `git checkout -b`
  - No `npm install`, `composer require`
  - No modifying project source code
- `NotebookEdit` - No editing notebooks

### Task Docs Exception

**Task docs folder (`.task-docs/`) may be created and written to during planning.**

This is intentional because:
- Task docs track planning progress and decisions
- They're populated as research and analysis unfolds
- The approval gate controls **implementation**, not documentation

**During planning, you MAY:**
- Create `.task-docs/{ISSUE_KEY}-{slug}/` folder
- Write to task planning documents (00-status.md, 02-functional-requirements.md, etc.)
- Update decision logs and notes

**The approval gate still controls:**
- Creating git branches
- Modifying project source code
- Installing dependencies
- Any changes outside `.task-docs/`

**Read-only Bash allowed:**
- `git status`, `git log`, `git diff`, `git branch --list`
- `ls`, `cat`, `find`, `grep` (prefer dedicated tools)
- `php -l`, `npm run lint --dry-run` (validation only)

### Phase B: Implementation (WRITE-ENABLED)

**Only after explicit user approval, you may:**
- Edit files
- Create files
- Run bash commands that modify state
- Create git branches and commits
- Install dependencies

---

## Planning Techniques

### 1. Thorough Exploration

Before proposing any solution:

```markdown
### Exploration Checklist
- [ ] Read all relevant existing files
- [ ] Search for similar patterns in codebase
- [ ] Identify existing conventions and styles
- [ ] Understand architectural patterns in use
- [ ] Check for related tests
- [ ] Review any existing documentation
```

**Don't assume - verify:**
- Check if similar feature exists
- Check how similar problems were solved
- Check naming conventions actually used
- Check project structure and patterns

### Parallel Research Pattern

**Run multiple research operations in parallel, then synthesize results.**

When exploring a codebase, launch multiple independent searches simultaneously:

```markdown
### Parallel Research Example

**Launch these searches in parallel (single message with multiple tool calls):**

1. Grep for similar feature patterns: `Grep pattern="similar_function" type="php"`
2. Glob for related files: `Glob pattern="**/Services/*Service.php"`
3. Read the main config: `Read file_path="/path/to/config.php"`
4. Search for tests: `Grep pattern="test.*feature" path="tests/"`

**After all results return, synthesize:**
- What patterns were found?
- What conventions are used?
- What files are relevant?
- What approach should we take?
```

**Benefits of parallel research:**
- Faster exploration (don't wait for sequential calls)
- More comprehensive (multiple angles at once)
- Better synthesis (see all context together)

**How to implement:**
1. Identify independent research questions
2. Launch all read-only tools in a single response
3. Wait for all results
4. Synthesize findings into a coherent summary
5. Present synthesis to user

**Example parallel calls:**

```
# In a single message, call:
- Grep: Search for "Repository" pattern
- Grep: Search for "Service" pattern
- Glob: Find all models
- Read: Project README
- Read: Architecture docs
- WebSearch: Best practices for [technology]
```

**Then synthesize:**
```markdown
## Research Synthesis

### Codebase Patterns Found
- Repository pattern used for data access (found in 5 files)
- Service layer handles business logic (found in 8 files)
- Models are thin, only relationships

### Conventions Identified
- Naming: `{Entity}Repository`, `{Action}Service`
- Location: `app/Repositories/`, `app/Services/`
- Testing: Feature tests in `tests/Feature/`

### Relevant Files for This Task
- `app/Repositories/UserRepository.php` - similar pattern
- `app/Services/AuthService.php` - related functionality

### Recommended Approach
Based on existing patterns, we should...
```

### 2. Pattern Recognition

Analyze existing code to understand:

```markdown
### Pattern Analysis
- **Architecture**: What patterns are used? (Repository, Service, etc.)
- **File organization**: Where do similar files live?
- **Naming**: How are similar things named?
- **Dependencies**: What's already available to use?
- **Testing**: How are similar features tested?
```

### 3. Strategic Analysis

Consider multiple approaches:

```markdown
### Approach Analysis

**Option A: [Name]**
- Pros: ...
- Cons: ...
- Effort: ...
- Risk: ...

**Option B: [Name]**
- Pros: ...
- Cons: ...
- Effort: ...
- Risk: ...

**Recommendation:** Option [X] because [reasoning]
```

### 4. Document Decisions

Record why choices were made:

```markdown
### Decision: [Title]

**Context:** What problem are we solving?
**Options Considered:** What alternatives exist?
**Decision:** What did we choose?
**Rationale:** Why this choice?
**Consequences:** What follows from this decision?
```

---

## The Approval Gate

**Planning ends with explicit user approval.**

### Before Approval, Present:

1. **Summary of findings** - What you learned from exploration
2. **Proposed approach** - What you plan to do
3. **Files to modify** - Specific files and changes
4. **Implementation steps** - Ordered list of actions
5. **Risks/concerns** - Anything to watch out for

### Approval Request Format:

```markdown
## Implementation Plan Summary

### What I Found
[Summary of exploration findings]

### Proposed Approach
[High-level description of solution]

### Changes Required

**Files to create:**
- `path/to/new/file.php` - [purpose]

**Files to modify:**
- `path/to/existing/file.php` - [what changes]

### Implementation Steps
1. [First step]
2. [Second step]
3. [Third step]
...

### Risks
- [Risk 1 and mitigation]
- [Risk 2 and mitigation]

---

**Ready to proceed with implementation?**
```

### Wait for Explicit Approval

**Do NOT proceed until user confirms.**

Valid approvals:
- "Yes, proceed"
- "Looks good, go ahead"
- "Approved"
- User selects approval option

Not approvals:
- Silence
- "Let me think about it"
- "What about...?" (follow-up questions)
- "Can you also...?" (scope change - re-plan)

---

## When to Use Plan Mode

**Always use for:**
- New features
- Multi-file changes
- Architectural decisions
- Changes to core functionality
- Anything touching >2-3 files
- Unfamiliar parts of codebase

**May skip for:**
- Single-line typo fixes
- Adding a log statement
- Obvious bug fixes with clear solution
- User gave very specific instructions

**When in doubt, plan first.**

---

## Integration with Task Planning

### Default Mode Phases

| Phase | Plan Mode | Actions |
|-------|-----------|---------|
| Phase 1: Discovery | READ-ONLY | Fetch from YouTrack, search for context |
| Phase 2: Requirements | READ-ONLY | Analyze requirements, ask questions |
| Phase 3: Technical Planning | READ-ONLY | Design approach, create plan document |
| Phase 4: Review & Approval | **GATE** | Present plan, get explicit approval |
| Phase 5: Implementation | WRITE-ENABLED | Execute approved plan |

### Task Docs in Planning Phase

**During READ-ONLY phase, documents are conceptual:**
- Think through what will go in each document
- Present content to user for review
- Only write documents after approval

**Alternative approach (if user prefers):**
- Create task docs folder and documents during planning
- Mark clearly as "DRAFT - Pending Approval"
- This is acceptable if user enables it

---

## Common Mistakes to Avoid

### During Planning

1. **Creating files before approval**
   - Don't create the task-docs folder until approved
   - Don't create implementation files "to test"

2. **Running modifying commands**
   - Don't create git branches yet
   - Don't install dependencies "to check"

3. **Making "small" changes**
   - No "let me just fix this typo while I'm here"
   - No "I'll add this comment to clarify"

4. **Assuming approval**
   - Don't interpret questions as approval
   - Wait for explicit go-ahead

### During Approval

1. **Rushing to implementation**
   - Give user time to review
   - Answer follow-up questions fully

2. **Vague plans**
   - Be specific about what will change
   - List actual file paths

3. **Missing risks**
   - Mention what could go wrong
   - Note dependencies or blockers

---

## Example: Plan Mode in Action

**User**: "Add a feature to export user data as CSV"

**Agent (Planning Phase):**

```
Let me research how this should be implemented.

### Exploration

**Searching for existing export functionality...**
- Found: `app/Services/ReportExporter.php` - existing PDF export
- Found: `app/Http/Controllers/Admin/ExportController.php` - admin exports

**Checking CSV libraries...**
- Project uses `league/csv` (in composer.json)
- Example usage in `app/Services/DataImporter.php`

**Reviewing user model...**
- User fields: id, name, email, created_at, profile_data (json)
- Has sensitive fields: password, remember_token (must exclude)

**Checking permissions...**
- Export requires `users.export` permission
- Existing pattern in `ExportController`

### Analysis

**Option A: Add to existing ExportController**
- Pros: Follows existing pattern, minimal new code
- Cons: Controller is already large

**Option B: Create dedicated UserExportService**
- Pros: Single responsibility, reusable
- Cons: More files to create

**Recommendation:** Option B - follows service pattern used elsewhere

### Proposed Approach

1. Create `UserExportService` with export logic
2. Add route and controller method for CSV download
3. Add permission check
4. Create test for export functionality

### Files to Create/Modify

**Create:**
- `app/Services/UserExportService.php` - Export logic
- `tests/Feature/UserExportTest.php` - Feature test

**Modify:**
- `app/Http/Controllers/Admin/ExportController.php` - Add endpoint
- `routes/admin.php` - Add route

### Implementation Steps

1. Create UserExportService with exportToCsv method
2. Add route: GET /admin/users/export/csv
3. Add controller method calling service
4. Add permission middleware
5. Create feature test
6. Test manually

### Risks
- Large user tables may timeout - will add chunking
- JSON profile_data needs flattening - will handle in service

---

**Ready to proceed with implementation?**
```

**User**: "Yes, go ahead"

**Agent (Implementation Phase):**

```
Creating UserExportService...
[Uses Edit/Write tools to implement]
```

---

## Checklist

### Before Any Modification

- [ ] Have I explored the codebase thoroughly?
- [ ] Do I understand existing patterns?
- [ ] Have I considered multiple approaches?
- [ ] Is my plan specific and actionable?
- [ ] Have I presented the plan to the user?
- [ ] Did the user explicitly approve?

**If any answer is NO, stay in planning mode.**

---

## Key Takeaways

1. **Planning = READ-ONLY** - No modifications until approved
2. **Explore thoroughly** - Understand before proposing
3. **Present clear plans** - Specific files, specific changes
4. **Wait for approval** - Explicit user confirmation required
5. **Then implement** - Follow the approved plan

**The discipline of plan mode prevents wasted effort and ensures user alignment.**
