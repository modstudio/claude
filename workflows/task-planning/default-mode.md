# Default Mode - YouTrack-Driven Planning

**Mode**: Standard planning workflow
**When to use**: Normal tasks with existing YouTrack issues, some context available

---

## Assumptions

- Issue exists in YouTrack
- Some context is available
- Standard workflow applies

---

## Workflow Flow

### Phase 1: Discovery & Context Gathering

**Steps:**
1. **Get issue key** from user (format: `{PROJECT_KEY}-XXXX`)
2. **Fetch issue from YouTrack** using `mcp__youtrack__issue_lookup` or `mcp__youtrack__issue_details`
   - Extract issue summary/slug for directory naming
3. **Check for existing `.wip` folder**:
   - Pattern: `.wip/{PROJECT_KEY}-XXXX-{slug}/` (issue key + summary for context)
   - Search pattern: `.wip/{PROJECT_KEY}-XXXX*` (may have different slug if issue renamed)
   - If folder exists → proceed to Phase 1B (Existing Task)
   - If folder doesn't exist → proceed to Phase 1A (New Task)

#### Phase 1A: New Task Setup

1. **Create folder**: `.wip/{PROJECT_KEY}-XXXX-{slug}/`
   - Extract slug from YouTrack issue summary
   - Use same slug format as git branches (from YouTrack API)
2. **Check for existing branch**:
   - Run `git branch --list "*{PROJECT_KEY}-XXXX*"` to check if branch exists
   - If branch exists:
     - Present branch name to user
     - Ask if they want to continue with existing branch or create new one
     - Document branch name in `00-status.md`
   - If no branch exists:
     - Note that branch will be created in Phase 4 (after approval)
3. **Fetch related context**:
   - Get issue description, custom fields, links
   - Check for related issues (subtasks, links, blocked-by)
   - Search YouTrack docs for relevant articles (if applicable)
4. **Reference project standards**:
   - Read relevant files from `.ai/rules/`
   - Follow project-specific conventions
5. **Create boilerplate documents** (see Document Structure in README.md)
6. **Present initial context** to user:
   - Task summary
   - Issue type, priority, sprint
   - Existing branch (if found)
   - Related issues found
   - Relevant docs found
   - Link to YouTrack issue

#### Phase 1B: Existing Task Resumption

1. **Read existing documents** from `.wip/{PROJECT_KEY}-XXXX-{slug}/`
   - Search pattern: `.wip/{PROJECT_KEY}-XXXX*` to find folder even if slug changed
2. **Validate against YouTrack**:
   - Check if task description changed
   - Check if new related issues exist
   - Check if priority/sprint changed
3. **Assess documentation quality**:
   - Check if docs follow standardized structure
   - Identify missing required documents
   - Identify documentation that needs reorganization
4. **Present status** to user:
   - Current progress (from `00-status.md`)
   - Documentation completeness
   - Recommended actions:
     - If docs are non-standard: propose reorganization plan
     - If docs are incomplete: list missing sections
     - If docs are current: proceed with work

**User Decision Point**: For existing tasks with non-standard docs:
- Keep existing structure (if mostly complete)
- Reorganize to standardized structure
- Keep specific files and reorganize rest

---

### Phase 2: Requirements Analysis

**Goal**: Understand business requirements and identify all questions/uncertainties.

**Steps:**

1. **Analyze task description** from YouTrack
2. **Review linked documentation**:
   - Extract relevant business rules
   - Document domain concepts
   - Note any contradictions or gaps
3. **Identify related code** patterns:
   - Search for similar features
   - Find existing patterns to follow
   - Note architectural decisions
4. **Generate questions list**:
   - Business logic uncertainties
   - Technical approach options
   - Edge cases to clarify
   - Integration points to confirm

**Output**: Draft `01-functional-requirements.md` with:
- Business context
- User stories (if applicable)
- Acceptance criteria
- **Uncertainties section** (questions to ask)

**User Decision Point**: Present questions to user for clarification.

---

### Phase 3: Technical Planning

**Goal**: Create detailed implementation plan based on clarified requirements.

**Steps:**

1. **Document decisions** made during Q&A:
   - Add to `02-decision-log.md` in ADR format
   - Mark obvious technical decisions (document but don't re-ask)
   - Mark user-confirmed decisions
2. **Create implementation plan**:
   - Break down into phases/steps
   - Identify files to create/modify
   - Database changes needed
   - API endpoints affected
   - Frontend components affected
   - Testing strategy
   - Risk assessment
3. **Update task description** (`04-task-description.md`):
   - High-level summary of what needs to be done
   - Reference key decisions
   - Suitable for YouTrack task description update

**Output**: Complete `03-implementation-plan.md` and `04-task-description.md`

---

### Phase 4: Review & Approval

**Goal**: Get user approval before implementation begins.

**Steps:**

1. **Update status document** (`00-status.md`):
   - Mark planning phase complete
   - Show readiness for implementation
2. **Present complete plan** to user:
   - Link to all documentation
   - Summary of key decisions
   - Implementation approach
   - Estimated timeline (if determinable)
3. **Create git branch** (once approved):
   - Format: `{type}/{PROJECT_KEY}-XXXX-{slug}`
   - Base: `develop` (or `master` for hotfix)

**User Decision Point**: Approve plan or request changes.

**Branch Verification**:
- Check if branch already exists: `git branch --list "*{PROJECT_KEY}-XXXX*"`
- If branch exists:
  - Confirm with user to use existing branch
  - Check out existing branch
  - Document in `00-status.md`
- If no branch exists:
  - Create branch per git workflow rules
  - Format from project standards: `{type}/{PROJECT_KEY}-XXXX-{slug}`
  - Base branch: `develop` (or `master` for hotfix)

---

### Phase 5: Implementation

**Goal**: Execute implementation plan with ongoing documentation updates.

**Steps:**

1. **Update `05-todo.md`** with detailed implementation checklist
2. **Work through implementation** following single-step rule:
   - Report what was done
   - Describe next step
   - Ask permission
   - Wait for approval
3. **Update status** as phases complete:
   - Mark phases complete in `00-status.md`
   - Update `05-todo.md` checklist
   - Document new decisions in `02-decision-log.md`
4. **Track blockers/issues** in `00-status.md`:
   - If blocked, document why
   - If new questions arise, add to `02-decision-log.md`
   - Update progress tracking

**Note**: Use TodoWrite tool in parallel for real-time task tracking during implementation.

---

## Checklist

### Starting New Task (Phase 1A)
- [ ] Get issue key from user
- [ ] Fetch from YouTrack (get issue summary for slug)
- [ ] Create `.wip/{PROJECT_KEY}-XXXX-{slug}/` folder
- [ ] Create all 6 standard documents
- [ ] Search for relevant documentation
- [ ] Present context and questions to user
- [ ] Update `00-status.md` status to "Planning"

### Resuming Existing Task (Phase 1B)
- [ ] Search for `.wip/{PROJECT_KEY}-XXXX*` (glob pattern)
- [ ] Read `00-status.md` first
- [ ] Present current status and next actions
- [ ] Validate docs are current (check YouTrack for changes)
- [ ] If non-standard structure, offer reorganization

### Planning Phase (Phase 2-3)
- [ ] Gather requirements in `01-functional-requirements.md`
- [ ] Ask all clarifying questions
- [ ] Document decisions in `02-decision-log.md`
- [ ] Create implementation plan in `03-implementation-plan.md`
- [ ] Write task description in `04-task-description.md`
- [ ] Update `00-status.md` to "Ready for Implementation"
- [ ] Get user approval

### Implementation Phase (Phase 4-5)
- [ ] Create git branch
- [ ] Create detailed checklist in `05-todo.md`
- [ ] Start TodoWrite tool for real-time tracking
- [ ] Update `00-status.md` to "In Progress"
- [ ] Follow single-step rule
- [ ] Update docs as decisions/changes occur
- [ ] Mark phases complete in `00-status.md`

### Completion Phase
- [ ] Update `00-status.md` to "Review"
- [ ] Check all acceptance criteria met
- [ ] Update `04-task-description.md` with final summary
- [ ] After merge, update `00-status.md` to "Complete"
- [ ] Consider updating YouTrack task description

---

## Example: Default Mode in Action

**User**: "Let's work on STAR-2235 - it's a small bug fix"

**Agent**:
1. Auto-detect: No .wip folder, no branch, user provided issue key → Suggest Default Mode
2. Ask user to confirm mode → User confirms Default Mode
3. Fetch STAR-2235 from YouTrack (gets issue summary: "Fix Login Error")
4. Search for `.wip/STAR-2235*` - doesn't exist
5. Create folder `.wip/STAR-2235-Fix-Login-Error/` and boilerplate docs
6. Present context: "This is a bug fix in X. I found related code in Y."
7. Ask clarifying questions (if any)
8. Create implementation plan
9. Get approval
10. Create branch and start work

---

**Return to**: [Task Planning README](./README.md)
