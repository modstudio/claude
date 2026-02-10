# Module: approval-gate

## Purpose
Present plan to user and get explicit approval before proceeding.

## Scope
SHARED - Used by: task-planning, code-review, release skills

## Mode
READ-ONLY (until approval received)

---

## Inputs
- Plan summary to present
- List of files to create/modify
- Key decisions made

---

## Instructions

### Step 1: Present Plan Summary

Format:
```markdown
## Implementation Plan Summary

### What I Found
- [Summary of research/exploration]
- [Patterns identified]
- [Related code found]

### Proposed Approach
- [High-level description]
- [Why this approach]

### Files to Create
- `path/to/file.ext` - [purpose]

### Files to Modify
- `path/to/existing.ext` - [what changes]

### Implementation Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Key Decisions
- [Decision]: [Rationale]

### Risks & Mitigations
- [Risk] → [Mitigation]

---

**Ready to proceed with implementation?**
```

### Step 2: Wait for Explicit Approval

**Valid approvals (proceed):**
- "Yes"
- "Proceed"
- "Go ahead"
- "Approved"
- "Looks good"
- "LGTM"
- "Do it"

**NOT approvals (do not proceed):**
- Questions: "What about...?", "Can you...?"
- Hesitation: "Let me think", "Hmm"
- Silence / no response
- Requests: "Change X to Y"
- Concerns: "I'm worried about..."

### Step 3: Handle Non-Approval

**If user asks questions:**
→ Answer the questions
→ Present plan again
→ Wait for approval again

**If user requests changes:**
→ Go back to planning phase
→ Revise plan per feedback
→ Present revised plan
→ Wait for approval

**If user explicitly rejects:**
→ Ask: "What would you like to change?"
→ Revise or abort based on response

---

## Outputs
- `APPROVED`: true/false
- `FEEDBACK`: Any user feedback to incorporate

**Note:** Controller decides next step based on APPROVED output.
