# Module: technical-planning

## Purpose
Design implementation approach and create detailed plan.

## Scope
TASK-PLANNING specific

## Mode
READ-ONLY (planning) + WRITE (to task docs only)

**Note:** This module writes the implementation plan to the task docs folder, which is created early in the planning flow. This is an intentional exception - we populate task docs during planning but only begin code implementation after approval.

---

## Inputs
- `TASK_FOLDER`: Where to write plan
- `REQUIREMENTS`: From analyze-requirements module
- `PATTERNS_FOUND`: From search-codebase module

---

## Instructions

### Step 1: Consider Multiple Approaches
For each major decision:
- Identify at least 2 approaches
- Document pros/cons of each
- Choose best approach with reasoning

### Step 2: Design Implementation Plan

**Break down into phases:**
1. Database/schema changes
2. Backend implementation
3. Frontend implementation
4. Integration
5. Testing

**For each phase, identify:**
- Specific files to create
- Specific files to modify
- Dependencies on other phases

### Step 3: Document Decisions

**Write to `logs/decisions.md`:**
```markdown
## ADR-001: {Decision Title}

**Date:** {date}
**Status:** Proposed

### Context
{Why this decision is needed}

### Options Considered
1. **{Option A}**: {description}
   - Pros: {pros}
   - Cons: {cons}

2. **{Option B}**: {description}
   - Pros: {pros}
   - Cons: {cons}

### Decision
Chose **{Option X}** because {reasoning}

### Consequences
- {Consequence 1}
- {Consequence 2}
```

### Step 4: Write Implementation Plan

**Write to `03-implementation-plan.md`:**
```markdown
## Approach
{High-level description of chosen approach}

## Files to Create
| File | Purpose |
|------|---------|
| `path/to/new.php` | {purpose} |

## Files to Modify
| File | Changes |
|------|---------|
| `path/to/existing.php` | {what changes} |

## Implementation Phases

### Phase 1: {Name}
- [ ] {Step 1}
- [ ] {Step 2}

### Phase 2: {Name}
- [ ] {Step 1}

## Testing Strategy
- Unit tests for: {components}
- Feature tests for: {scenarios}

## Risk Assessment
| Risk | Impact | Mitigation |
|------|--------|------------|
| {Risk 1} | High | {mitigation} |
```

---

## Outputs
- Updated `03-implementation-plan.md`
- Updated `logs/decisions.md`
- `FILES_TO_CREATE`: List of new files
- `FILES_TO_MODIFY`: List of files to change
