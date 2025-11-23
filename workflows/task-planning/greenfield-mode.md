# Greenfield Mode - User-Driven Planning

**Mode**: Start fresh with minimal context
**When to use**: Exploratory work, prototypes, tasks not yet in YouTrack

---

## Assumptions

- Little or no context available
- Task may not exist in YouTrack yet
- Need user to provide initial overview
- Exploratory or prototype work

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

### Step 3: Create Working Directory

**Folder naming:**

**With YouTrack issue**:
- `.wip/{PROJECT_KEY}-XXXX-{slug}/`
- Follow standard naming convention

**Without YouTrack issue** (temporary):
- `.wip/exploratory-{short-name}/`
- Use descriptive short name from user's overview
- Examples:
  - `.wip/exploratory-notifications-widget/`
  - `.wip/exploratory-new-dashboard/`
  - `.wip/exploratory-api-refactor/`

---

### Step 4: Document User's Overview

**Create initial documentation:**

1. **Create `00-status.md`**:
   - Add "Greenfield Mode" tag
   - Mark as exploratory if no issue exists
   - Note: "Created in Greenfield mode - may need YouTrack issue later"
   - Document current understanding

2. **Create `01-functional-requirements.md`**:
   - Capture user's description
   - List what's known
   - List what's unknown (to explore)
   - Mark as "Draft - Exploratory"

3. **Create other docs as needed**:
   - May skip some standard docs initially
   - Add them as context becomes clearer

---

### Step 5: Proceed with Planning

**Planning approach:**

1. **Ask clarifying questions**:
   - Based on user's overview
   - Focus on high-level goals first
   - Technical details come later

2. **Explore options**:
   - Present multiple approaches
   - Discuss trade-offs
   - User feedback shapes direction

3. **Create lightweight implementation plan**:
   - May be more exploratory than detailed
   - Focus on first steps, not entire solution
   - Update as you learn more

4. **Suggest creating YouTrack issue**:
   - If work scope becomes clear
   - Before committing significant code
   - Can formalize the task

---

### Step 6: Greenfield Exit Strategy

**When to formalize:**

Before implementation or when scope is clear:

1. **Recommend creating YouTrack issue**:
   - "This looks like it's taking shape. Should we create a YouTrack issue for tracking?"
   - Help user create issue if needed

2. **Migrate folder structure**:
   ```bash
   # From temporary
   mv .wip/exploratory-notifications-widget/ .wip/STAR-2301-Notifications-Widget/
   ```

3. **Update all docs**:
   - Remove "Greenfield Mode" tag
   - Add issue references
   - Sync `04-task-description.md` with YouTrack
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
- [ ] Create temporary `.wip/exploratory-{name}/` folder
- [ ] Document user's overview in `01-functional-requirements.md`
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
- [ ] Migrate folder to proper naming: `.wip/{PROJECT_KEY}-XXXX-{slug}/`
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
7. Create folder: `.wip/exploratory-notifications-widget/`
8. Create `00-status.md` with "Greenfield Mode - Exploratory" tag
9. Document overview in `01-functional-requirements.md`:
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
17. Migrate: `.wip/exploratory-notifications-widget/` → `.wip/STAR-2301-Notifications-Widget/`
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
   - From: `.wip/exploratory-{name}/`
   - To: `.wip/{PROJECT_KEY}-XXXX-{slug}/`
4. Update `00-status.md`:
   - Remove "Greenfield Mode" tag
   - Add issue key and link
   - Add proper branch name
5. Update `04-task-description.md`:
   - Sync with YouTrack issue description
6. Add any missing standard docs
7. Update `01-functional-requirements.md`:
   - Add issue references
   - Formalize acceptance criteria
8. Present: "✅ Migrated to official task {PROJECT_KEY}-XXXX. Ready to proceed with Default Mode."

---

**Return to**: [Task Planning README](./README.md)
