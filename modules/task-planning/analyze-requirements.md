# Module: analyze-requirements

## Purpose
Analyze requirements, generate questions, and document findings.

## Scope
TASK-PLANNING specific

## Mode
READ-ONLY (analysis) + WRITE (to task docs only)

**Note:** This module writes findings to the task docs folder, which is created early in the planning flow to track progress. This is an intentional exception - we create task docs during planning but only begin implementation after approval.

---

## Inputs
- `TASK_FOLDER`: Where to write findings
- `DESCRIPTION`: Issue description from YouTrack
- `PATTERNS_FOUND`: From search-codebase module

---

## Instructions

### Step 1: Analyze Task Description
From YouTrack description, identify:
- Core functionality required
- User stories implied
- Acceptance criteria (explicit or implicit)
- Edge cases mentioned

### Step 2: Review Business Context
- Read related documentation
- Check knowledge base if available
- Note domain-specific rules

### Step 3: Generate Questions
Identify uncertainties in:
- **Business logic**: How should X behave when Y?
- **Technical approach**: Should we use A or B pattern?
- **Edge cases**: What happens if Z?
- **Integration**: How does this connect to W?

### Step 4: Document Findings

**Write to `02-functional-requirements.md`:**
```markdown
## Business Context
[Summary of business rules and domain concepts]

## User Stories
- As a {user}, I want to {action} so that {benefit}

## Acceptance Criteria
- [ ] {Criterion 1}
- [ ] {Criterion 2}

## Edge Cases
- {Edge case 1}: {expected behavior}
- {Edge case 2}: {expected behavior}

## Uncertainties / Questions
### Unresolved
1. {Question about business logic}
2. {Question about technical approach}

### Resolved
(Move questions here after user answers)
```

---

## User Interaction

**Present questions to user:**
```markdown
## Questions Before Proceeding

I have {N} questions to clarify:

1. **{Topic}**: {Question}?
2. **{Topic}**: {Question}?

Please answer these so I can proceed with planning.
```

**After user answers:**
- Update `02-functional-requirements.md`
- Move answered questions to "Resolved" section
- Add any new questions that arose

---

## Outputs
- `QUESTIONS`: List of questions for user
- Updated `02-functional-requirements.md`
