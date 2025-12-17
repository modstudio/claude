# Greenfield Mode - User-Driven Planning

**Mode**: Start fresh with minimal context
**When to use**: Exploratory work, prototypes, tasks not yet in YouTrack

---

## Plan Mode Discipline

**CRITICAL**: This workflow follows Claude's Plan Mode discipline.

### Phase Overview

| Step | Mode | Tools Allowed |
|------|------|---------------|
| Steps 1-5 | **READ-ONLY** | Read, Grep, Glob, AskUserQuestion, WebSearch |
| Step 5 end | **APPROVAL GATE** | Must get explicit user approval |
| Step 6+ | **WRITE-ENABLED** | Edit, Write, Bash, git operations |

### Read-Only Phase Rules (Steps 1-5)

**During planning, you MUST NOT:**
- Edit or create files
- Create the exploratory folder
- Run Bash commands that modify state

**You MAY:**
- Read files to understand the codebase
- Search for patterns with Grep/Glob
- Ask user clarifying questions
- Use TodoWrite for tracking
- Run read-only Bash: `git status`, `git log`, `ls`

### Parallel Research

**When exploring, run multiple searches in parallel:**
1. Launch independent read operations in one message
2. Wait for all results
3. Synthesize findings
4. Present summary to user

### The Approval Gate (End of Step 5)

Before creating ANY files:
1. Present complete plan to user
2. List specific files to create
3. Wait for explicit approval
4. Only then proceed to create folder and docs

---

## Assumptions

- Little or no context available
- Task may not exist in YouTrack yet
- Need user to provide initial overview
- Exploratory or prototype work

---

## 📋 MANDATORY: Initialize Todo List

**IMMEDIATELY when entering Greenfield Mode, create a todo list to track progress:**

**NOTE:** Steps 1-5 are READ-ONLY. Folder/file creation happens in Step 6 AFTER user approval.

```javascript
TodoWrite({
  todos: [
    {content: "Get initial context from user", status: "in_progress", activeForm: "Getting initial context"},
    {content: "Review project docs for standards and architecture", status: "pending", activeForm: "Reviewing project standards and architecture"},
    {content: "Optional YouTrack integration", status: "pending", activeForm: "Checking YouTrack integration"},
    {content: "Plan working directory structure", status: "pending", activeForm: "Planning directory structure"},
    {content: "Plan documentation content", status: "pending", activeForm: "Planning documentation"},
    {content: "Design plan and get user approval", status: "pending", activeForm: "Getting approval"},
    {content: "Create folder, docs, and implement", status: "pending", activeForm: "Creating and implementing"},
    {content: "Formalize when ready (migrate to Default)", status: "pending", activeForm: "Formalizing task"}
  ]
})
```

**When transitioning to Default Mode (after formalization), update the todo list:**
```javascript
TodoWrite({
  todos: [
    {content: "Migrate folder to proper naming", status: "in_progress", activeForm: "Migrating folder"},
    {content: "Update all docs with issue references", status: "pending", activeForm: "Updating docs"},
    {content: "Remove Greenfield tag", status: "pending", activeForm: "Removing Greenfield tag"},
    {content: "Continue with Default Mode workflow", status: "pending", activeForm: "Continuing with Default Mode"}
  ]
})
```

**Update todo list as you progress. Mark tasks complete immediately upon finishing.**

---

## Workflow Flow

### Step 1: Get Initial Context from User

**Ask user for overview:**

1. "Please provide a brief overview of what you want to accomplish"
2. "Do you have a YouTrack issue for this? (optional)"
3. "Any specific requirements or constraints?"

**Gather context**:
- What problem are you trying to solve?
- What's the expected outcome?
- Are there any technical constraints?
- Is this a prototype, exploration, or production feature?

---

### Step 2: Optional YouTrack Integration

**If user provides issue key**:
- Fetch from YouTrack using `mcp__youtrack__issue_lookup`
- Extract any available context
- Proceed with hybrid approach (Greenfield + YouTrack data)

**If no issue key**:
- Proceed entirely from user's description
- Note: Issue can be created later

---

### Step 3: Plan Working Directory

**Mode: READ-ONLY** - Determine folder name, don't create yet

**Folder naming (to be created after approval):**

**With YouTrack issue**:
- `${TASK_DOCS_DIR}/{ISSUE_KEY}/`
- Follow standard naming convention

**Without YouTrack issue** (temporary):
- `${TASK_DOCS_DIR}/exploratory-{short-name}/`
- Use descriptive short name from user's overview
- Examples:
  - `${TASK_DOCS_DIR}/exploratory-notifications-widget/`
  - `${TASK_DOCS_DIR}/exploratory-new-dashboard/`
  - `${TASK_DOCS_DIR}/exploratory-api-refactor/`

**Note:** Folder is created in Step 6 after user approves the plan.

---

### Step 4: Plan Documentation Content

**Mode: READ-ONLY** - Plan what will go in docs, don't create files yet

**Plan initial documentation content:**

1. **Plan `00-status.md` content**:
   - Will include "Greenfield Mode" tag
   - Will mark as exploratory if no issue exists
   - Will note: "Created in Greenfield mode - may need YouTrack issue later"
   - Document current understanding (in your notes)

2. **Plan `02-functional-requirements.md` content**:
   - Capture user's description (in your notes)
   - List what's known
   - List what's unknown (to explore)
   - Will mark as "Draft - Exploratory"

3. **Explore codebase** (read-only):
   - Search for related patterns
   - Read similar implementations
   - Understand project structure

**Note:** Documents are created in Step 6 after user approves the plan.

---

### Step 5: Design Plan & Get Approval

**Mode: READ-ONLY then APPROVAL GATE**

**Planning approach:**

1. **Ask clarifying questions**:
   - Based on user's overview
   - Focus on high-level goals first
   - Technical details come later

2. **Explore options** (parallel research):
   - Search codebase for similar patterns
   - Read related implementations
   - Present multiple approaches
   - Discuss trade-offs
   - User feedback shapes direction

3. **Create lightweight implementation plan** (verbally):
   - May be more exploratory than detailed
   - Focus on first steps, not entire solution
   - Identify files to create/modify

4. **Present plan for approval**:

```markdown
## Greenfield Plan Summary

### What We're Building
[Summary from user's overview]

### Exploration Findings
[What you found in codebase research]

### Proposed Approach
[High-level approach]

### Initial Files to Create
- `${TASK_DOCS_DIR}/exploratory-{name}/00-status.md`
- `${TASK_DOCS_DIR}/exploratory-{name}/02-functional-requirements.md`
- [Other files as needed]

### First Implementation Steps
1. [First step]
2. [Second step]
...

---

**Ready to create folder and start?**
```

5. **Wait for explicit approval**:
   - Valid approvals: "Yes", "Go ahead", "Approved"
   - NOT approval: Questions, "What about...?"
   - Only then proceed to Step 6

---

### Step 6: Create Folder & Docs (After Approval)

**Mode: WRITE-ENABLED** - Only after explicit approval in Step 5

**Create the working directory and documents:**

```bash
# Use library function - NEVER hardcode path
source ~/.claude/lib/task-docs-utils.sh

# For exploratory work (no issue key)
TASK_FOLDER=$(create_exploratory_folder "short-name")
# Creates: ${TASK_DOCS_DIR}/exploratory-{short-name}/

# OR with issue key
TASK_FOLDER=$(create_task_folder "$ISSUE_KEY" "$SLUG")
```

**Create initial documents:**
- `00-status.md` - With Greenfield tag
- `02-functional-requirements.md` - User's requirements
- Other docs as needed

**Then proceed with implementation.**

---

### Step 7: Greenfield Exit Strategy

**When to formalize (later):**

Before significant implementation or when scope is clear:

1. **Recommend creating YouTrack issue**:
   - "This looks like it's taking shape. Should we create a YouTrack issue for tracking?"
   - Help user create issue if needed

2. **Migrate folder structure** (using library functions):
   ```bash
   source ~/.claude/lib/task-docs-utils.sh
   migrate_exploratory_to_task "exploratory-notifications-widget" "STAR-2301" "Notifications-Widget"
   ```

3. **Update all docs**:
   - Remove "Greenfield Mode" tag
   - Add issue references
   - Sync `01-task-description.md` with YouTrack
   - Update `00-status.md` with issue key

4. **Transition to Default Mode**:
   - Now follows standard workflow
   - Issue tracking in place
   - Ready for formal implementation

---

## Checklist

### Greenfield Setup
- [ ] Ask user for task overview
- [ ] Ask if YouTrack issue exists (optional)
- [ ] Create temporary `${TASK_DOCS_DIR}/exploratory-{name}/` folder
- [ ] Document user's overview in `02-functional-requirements.md`
- [ ] Create `00-status.md` with "Greenfield" tag
- [ ] Note that this is exploratory work

### Exploratory Planning
- [ ] Ask clarifying questions about goals
- [ ] Explore multiple approaches with user
- [ ] Create lightweight implementation plan
- [ ] Focus on first steps, not complete solution
- [ ] Update docs as understanding grows

### Formalization (When Ready)
- [ ] Suggest creating YouTrack issue
- [ ] Help create issue if needed
- [ ] Fetch issue details from YouTrack
- [ ] Migrate folder to proper naming: `${TASK_DOCS_DIR}/{ISSUE_KEY}/`
- [ ] Update all docs with issue references
- [ ] Remove "Greenfield" tag
- [ ] Transition to Default Mode workflow

---

## Example: Greenfield Mode in Action

**User**: "I want to explore adding a new dashboard widget, not sure of the exact approach yet"

**Agent**:
1. Auto-detect: No issue key, user says "explore" → Suggest Greenfield Mode
2. Ask user to confirm mode → User confirms Greenfield Mode
3. Ask: "Please provide a brief overview of what you want to accomplish"
4. User: "I want to add a widget showing real-time notifications"
5. Ask: "Do you have a YouTrack issue for this?"
6. User: "Not yet"
7. Create folder: `${TASK_DOCS_DIR}/exploratory-notifications-widget/`
8. Create `00-status.md` with "Greenfield Mode - Exploratory" tag
9. Document overview in `02-functional-requirements.md`:
   ```markdown
   # Notifications Widget - Exploratory

   **Mode**: Greenfield - No YouTrack issue yet
   **Goal**: Add real-time notifications widget to dashboard

   ## What We Know
   - Need to show notifications in dashboard
   - Should be real-time
   - User wants to explore approaches

   ## What We Need to Explore
   - WebSocket vs polling approach?
   - Which dashboard page?
   - What types of notifications?
   - Design/UI preferences?
   ```
10. Ask clarifying questions about approach
11. Present options: WebSocket vs Server-Sent Events vs Polling
12. User chooses WebSocket approach
13. Create lightweight plan focusing on first prototype
14. Suggest: "This is shaping up well. Before we start coding, should we create a YouTrack issue for tracking?"
15. User: "Yes, create STAR-2301"
16. Fetch STAR-2301 from YouTrack
17. Migrate: `${TASK_DOCS_DIR}/exploratory-notifications-widget/` → `${TASK_DOCS_DIR}/STAR-2301-Notifications-Widget/`
18. Update all docs with issue references
19. Transition to Default Mode and proceed with implementation

---

## Best Practices for Greenfield Mode

**When to use:**
- ✅ Proof of concept / prototype work
- ✅ Exploring new technology or approach
- ✅ Unclear requirements that need discovery
- ✅ Experimentation before formal task creation
- ✅ Spike work to inform planning

**When NOT to use:**
- ❌ Production feature with clear requirements
- ❌ Bug fixes (use Default Mode)
- ❌ Tasks already in YouTrack (use Default Mode)
- ❌ Work that's already started (use In Progress Mode)

**Tips:**
- Keep docs lightweight initially
- Update as understanding grows
- Don't over-plan exploratory work
- Formalize once scope is clear
- Transition to Default Mode before major implementation

---

## Mode Transition: Greenfield → Default

**Trigger**: User creates or assigns official YouTrack issue

**Steps:**
1. Fetch issue from YouTrack
2. Extract issue summary for slug
3. Rename folder:
   - From: `${TASK_DOCS_DIR}/exploratory-{name}/`
   - To: `${TASK_DOCS_DIR}/{ISSUE_KEY}/`
4. Update `00-status.md`:
   - Remove "Greenfield Mode" tag
   - Add issue key and link
   - Add proper branch name
5. Update `01-task-description.md`:
   - Sync with YouTrack issue description
6. Add any missing standard docs
7. Update `02-functional-requirements.md`:
   - Add issue references
   - Formalize acceptance criteria
8. Present: "✅ Migrated to official task {ISSUE_KEY}. Ready to proceed with Default Mode."

---

**Return to**: [Task Planning README](./README.md)
