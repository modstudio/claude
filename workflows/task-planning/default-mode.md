# Default Mode - YouTrack-Driven Planning

**Mode**: Standard planning workflow
**When to use**: Normal tasks with existing YouTrack issues, some context available

---

## Plan Mode Discipline

**CRITICAL**: This workflow follows Claude's Plan Mode discipline.

### Phase Overview

| Phase | Mode | Tools Allowed |
|-------|------|---------------|
| Phase 1-4 | **READ-ONLY** | Read, Grep, Glob, AskUserQuestion, WebSearch, MCP lookups |
| Phase 4 | **APPROVAL GATE** | Must get explicit user approval before proceeding |
| Phase 5 | **WRITE-ENABLED** | Edit, Write, Bash, git operations |

### Read-Only Phase Rules (Phases 1-4)

**During planning, you MUST NOT:**
- Edit or create files (no Edit, Write tools)
- Run Bash commands that modify state (no `git checkout -b`, `mkdir`, etc.)
- Create the task docs folder or documents
- Make any changes to the codebase or system

**You MAY:**
- Read files to understand the codebase
- Search for patterns with Grep/Glob
- Fetch information from YouTrack (MCP tools)
- Ask user clarifying questions
- Use TodoWrite for tracking progress
- Run read-only Bash: `git status`, `git log`, `git diff`, `ls`

### The Approval Gate (End of Phase 4)

**Before ANY implementation:**
1. Present complete plan to user
2. List specific files to create/modify
3. Describe each change
4. Wait for **explicit approval** ("Yes, proceed", "Go ahead", "Approved")

**Do NOT interpret questions or discussion as approval.**

### Planning Techniques

Apply these during phases 1-3:

1. **Thorough Exploration** - Read all relevant files, don't assume
2. **Pattern Recognition** - Understand existing conventions and architecture
3. **Strategic Analysis** - Consider multiple approaches, document trade-offs
4. **Decision Documentation** - Record why choices were made

See `~/.claude/modules/plan-mode-discipline.md` for detailed guidance.

---

## Assumptions

- Issue exists in YouTrack
- Some context is available
- Standard workflow applies

---

## 📋 MANDATORY: Initialize Todo List

**IMMEDIATELY when entering Default Mode, create a todo list to track planning progress:**

```javascript
TodoWrite({
  todos: [
    {content: "Phase 1: Discovery & context gathering", status: "in_progress", activeForm: "Gathering context"},
    {content: "Phase 2: Requirements analysis", status: "pending", activeForm: "Analyzing requirements"},
    {content: "Phase 3: Technical planning", status: "pending", activeForm: "Creating technical plan"},
    {content: "Phase 4: Review & approval", status: "pending", activeForm: "Getting approval"},
    {content: "Phase 5: Implementation", status: "pending", activeForm: "Implementing"}
  ]
})
```

**When user makes a choice (e.g., new task vs resuming), update the todo list accordingly:**

**For New Task (Phase 1) - READ-ONLY research phase:**
```javascript
TodoWrite({
  todos: [
    {content: "Fetch issue and check for existing task folder", status: "in_progress", activeForm: "Fetching issue context"},
    {content: "Review project docs for standards and architecture", status: "pending", activeForm: "Reviewing project standards and architecture"},
    {content: "Search codebase for similar implementations", status: "pending", activeForm: "Searching codebase"},
    {content: "Requirements analysis", status: "pending", activeForm: "Analyzing requirements"},
    {content: "Technical planning", status: "pending", activeForm: "Creating technical plan"},
    {content: "Review & approval", status: "pending", activeForm: "Getting approval"},
    {content: "Create task folder and implement", status: "pending", activeForm: "Implementing"}
  ]
})
```

**For Existing Task (resuming):**
```javascript
TodoWrite({
  todos: [
    {content: "Read existing documents", status: "in_progress", activeForm: "Reading existing docs"},
    {content: "Review project docs for standards and architecture", status: "pending", activeForm: "Reviewing project standards and architecture"},
    {content: "Validate against YouTrack", status: "pending", activeForm: "Validating against YouTrack"},
    {content: "Assess documentation quality", status: "pending", activeForm: "Assessing doc quality"},
    {content: "Continue from current phase", status: "pending", activeForm: "Continuing work"}
  ]
})
```

**Update todo list as you progress. Mark tasks complete immediately upon finishing.**

---

## Workflow Flow

### Phase 1: Discovery & Context Gathering

**Steps:**
1. **Get issue key** from user (e.g., `STAR-1234`, `AB-567`)
2. **Fetch issue from YouTrack** using `mcp__youtrack__issue_lookup` or `mcp__youtrack__issue_details`
   - Extract issue summary/slug for directory naming
3. **Check for existing task docs folder**:
   - Pattern: `${TASK_DOCS_DIR}/{ISSUE_KEY}/`
   - Search pattern: `${TASK_DOCS_DIR}/{ISSUE_KEY}*`
   - If folder exists → proceed to Phase 1B (Existing Task)
   - If folder doesn't exist → proceed to Phase 1A (New Task)

#### Phase 1A: New Task Setup

**Remember: This phase is READ-ONLY. Research and present findings, don't create files yet.**

1. **Identify folder name** (will create after approval):
   - Pattern: `${TASK_DOCS_DIR}/{ISSUE_KEY}/`
   - Note this for Phase 5
2. **Check for existing branch** (read-only):
   - Run `git branch --list "*{ISSUE_KEY}*"` to check if branch exists
   - If branch exists:
     - Present branch name to user
     - Ask if they want to continue with existing branch or create new one
   - If no branch exists:
     - Note that branch will be created in Phase 5 (after approval)
3. **Fetch related context** (read-only research):
   - Get issue description, custom fields, links from YouTrack
   - Check for related issues (subtasks, links, blocked-by)
   - Search YouTrack docs for relevant articles (if applicable)
4. **Read project standards** (read-only):
   - Read relevant files from `.ai/rules/`
   - Note project-specific conventions for later
5. **Search for similar implementations** (exploration):
   - Use Grep/Glob to find similar patterns in codebase
   - Read related files to understand existing approaches
   - Document patterns found for technical planning
6. **Present initial context** to user:
   - Task summary
   - Issue type, priority, sprint
   - Existing branch (if found)
   - Related issues found
   - Similar patterns found in codebase
   - Relevant docs found
   - Link to YouTrack issue

**Note:** Task docs folder and documents are created in Phase 5 after approval.

#### Phase 1B: Existing Task Resumption

1. **Read existing documents** from `${TASK_DOCS_DIR}/{ISSUE_KEY}/`
   - Search pattern: `${TASK_DOCS_DIR}/{ISSUE_KEY}*`
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

**Mode: READ-ONLY** - Research and analyze, present findings verbally

**Goal**: Understand business requirements and identify all questions/uncertainties.

**Steps:**

1. **Analyze task description** from YouTrack (read-only)
2. **Review linked documentation** (read-only):
   - Read relevant business rules
   - Understand domain concepts
   - Note any contradictions or gaps
3. **Explore related code** (read-only):
   - Use Grep/Glob to search for similar features
   - Read existing implementations to understand patterns
   - Note architectural decisions and conventions
4. **Generate questions list**:
   - Business logic uncertainties
   - Technical approach options
   - Edge cases to clarify
   - Integration points to confirm

**Output**: Present verbally (NOT written to files yet):
- Business context summary
- User stories (if applicable)
- Acceptance criteria as understood
- **Uncertainties section** (questions to ask)

**Planning Technique**: Use thorough exploration before proposing solutions.

**User Decision Point**: Present questions to user for clarification.

---

### Phase 3: Technical Planning

**Mode: READ-ONLY** - Design approach, present plan verbally

**Goal**: Create detailed implementation plan based on clarified requirements.

**Planning Techniques to Apply:**

1. **Pattern Recognition** - What existing patterns should we follow?
2. **Strategic Analysis** - Consider multiple approaches, choose best one
3. **Decision Documentation** - Record reasoning for choices

**Steps:**

1. **Explore existing patterns** (read-only):
   - Read similar implementations in codebase
   - Understand architectural conventions
   - Identify reusable components/services
2. **Analyze multiple approaches**:
   - Consider at least 2 different approaches
   - Document pros/cons of each
   - Choose best approach with reasoning
3. **Design implementation plan**:
   - Break down into phases/steps
   - Identify specific files to create/modify
   - Database changes needed
   - API endpoints affected
   - Frontend components affected
   - Testing strategy
   - Risk assessment
4. **Prepare decisions summary**:
   - Key technical decisions and rationale
   - Trade-offs made
   - Risks identified and mitigations

**Output**: Present verbally (NOT written to files yet):
- Complete implementation plan
- Files to create/modify (specific paths)
- Decisions and rationale
- Task description summary

---

### Phase 4: Review & Approval

**Mode: APPROVAL GATE** - This is the transition point from planning to implementation

**Goal**: Get explicit user approval before ANY implementation begins.

**CRITICAL**: Do NOT proceed to Phase 5 without explicit approval.

**Steps:**

1. **Present complete plan** to user (verbally, formatted clearly):

```markdown
## Implementation Plan Summary

### What I Found (from exploration)
- [Summary of codebase research]
- [Patterns identified]
- [Related code found]

### Proposed Approach
- [High-level description]
- [Why this approach over alternatives]

### Files to Create
- `path/to/new/file.php` - [purpose]
- `path/to/another/file.php` - [purpose]

### Files to Modify
- `path/to/existing/file.php` - [what changes]

### Implementation Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]
...

### Key Decisions
- [Decision 1]: [Rationale]
- [Decision 2]: [Rationale]

### Risks & Mitigations
- [Risk 1] - [Mitigation]
- [Risk 2] - [Mitigation]

---

**Ready to proceed with implementation?**
```

2. **Wait for explicit approval**:
   - Valid approvals: "Yes", "Proceed", "Go ahead", "Approved", "Looks good"
   - NOT approval: Questions, "Let me think", silence, "What about...?"
   - If user asks questions → answer them, present plan again
   - If user requests changes → go back to Phase 3, revise plan

3. **Only after approval** proceed to Phase 5

**User Decision Point**: Approve plan or request changes.

**What happens after approval (Phase 5):**
- Create task docs folder and documents (using `${TASK_DOCS_DIR}`)
- Create git branch
- Begin implementation

---

### Phase 5: Implementation

**Mode: WRITE-ENABLED** - Only reached after explicit user approval in Phase 4

**Goal**: Execute approved implementation plan.

**Pre-Implementation Setup:**

1. **Create task docs folder** (now allowed):
   ```bash
   # Use library function - NEVER hardcode path
   source ~/.claude/lib/task-docs-utils.sh
   TASK_FOLDER=$(create_task_folder "$ISSUE_KEY" "$SLUG")
   # This creates: ${TASK_DOCS_DIR}/${ISSUE_KEY}-${SLUG}/ with logs/ subdirectory
   ```

2. **Create all task documents**:
   - `00-status.md` - From plan summary
   - `01-task-description.md` - Task description (high-level overview)
   - `02-functional-requirements.md` - Requirements gathered
   - `03-implementation-plan.md` - The approved plan
   - `04-todo.md` - Implementation checklist
   - `logs/decisions.md` - Decisions made during planning

3. **Create git branch**:
   - Check if exists: `git branch --list "*{ISSUE_KEY}*"`
   - If exists: confirm with user, checkout existing
   - If not: create new branch per project standards

**Implementation Steps:**

1. **Work through implementation** following single-step rule:
   - Report what was done
   - Describe next step
   - Ask permission
   - Wait for approval
2. **Update status** as phases complete:
   - Mark phases complete in `00-status.md`
   - Update `04-todo.md` checklist
   - Document new decisions in `logs/decisions.md`
3. **Track blockers/issues** in `00-status.md`:
   - If blocked, document why
   - If new questions arise, add to `logs/decisions.md`
   - Update progress tracking

**Note**: Use TodoWrite tool in parallel for real-time task tracking during implementation.

---

## Checklist

### Starting New Task (Phase 1A)
- [ ] Get issue key from user
- [ ] Fetch from YouTrack (get issue summary for slug)
- [ ] Create `${TASK_DOCS_DIR}/{ISSUE_KEY}/` folder
- [ ] Create all 6 standard documents
- [ ] Search for relevant documentation
- [ ] Present context and questions to user
- [ ] Update `00-status.md` status to "Planning"

### Resuming Existing Task (Phase 1B)
- [ ] Search for `${TASK_DOCS_DIR}/{ISSUE_KEY}*` (glob pattern)
- [ ] Read `00-status.md` first
- [ ] Present current status and next actions
- [ ] Validate docs are current (check YouTrack for changes)
- [ ] If non-standard structure, offer reorganization

### Planning Phase (Phase 2-3)
- [ ] Gather requirements in `02-functional-requirements.md`
- [ ] Ask all clarifying questions
- [ ] Document decisions in `logs/decisions.md`
- [ ] Create implementation plan in `03-implementation-plan.md`
- [ ] Write task description in `01-task-description.md`
- [ ] Update `00-status.md` to "Ready for Implementation"
- [ ] Get user approval

### Implementation Phase (Phase 4-5)
- [ ] Create git branch
- [ ] Create detailed checklist in `04-todo.md`
- [ ] Start TodoWrite tool for real-time tracking
- [ ] Update `00-status.md` to "In Progress"
- [ ] Follow single-step rule
- [ ] Update docs as decisions/changes occur
- [ ] Mark phases complete in `00-status.md`

### Completion Phase
- [ ] Update `00-status.md` to "Review"
- [ ] Check all acceptance criteria met
- [ ] Update `01-task-description.md` with final summary
- [ ] After merge, update `00-status.md` to "Complete"
- [ ] Consider updating YouTrack task description

---

## Example: Default Mode in Action

**User**: "Let's work on STAR-2235 - it's a small bug fix"

**Agent**:
1. Auto-detect: No task docs folder, no branch, user provided issue key → Suggest Default Mode
2. Ask user to confirm mode → User confirms Default Mode
3. Fetch STAR-2235 from YouTrack (gets issue summary: "Fix Login Error")
4. Search for `${TASK_DOCS_DIR}/STAR-2235*` - doesn't exist
5. Create folder `${TASK_DOCS_DIR}/STAR-2235-Fix-Login-Error/` and documents
6. Present context: "This is a bug fix in X. I found related code in Y."
7. Ask clarifying questions (if any)
8. Create implementation plan
9. Get approval
10. Create branch and start work

---

**Return to**: [Task Planning README](./README.md)
