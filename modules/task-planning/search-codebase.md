# Module: search-codebase

## Purpose
Search codebase for similar patterns and document findings.

## Scope
TASK-PLANNING specific (documents to task folder)

## Mode
READ-ONLY (search) + WRITE (to task docs only)

**Note:** This module writes findings to the task docs folder, which is created early in the planning flow to track progress. This is an intentional exception - we create task docs during planning but only begin implementation after approval.

---

## Inputs
- `ISSUE_KEY`: For context
- `TASK_FOLDER`: Where to write findings
- `SEARCH_TERMS`: Keywords from task description

---

## Instructions

### Step 1: Identify Search Terms
From task description, identify:
- Feature names
- Domain concepts
- Technical components
- Similar functionality keywords

### Step 2: Search for Patterns
```bash
# Search for similar features
grep -r "similar_term" --include="*.php" app/

# Find related files
find . -name "*related*" -type f

# Search for domain concepts
grep -rn "DomainConcept" app/
```

**Use Grep/Glob tools, NOT bash grep**

### Step 3: Read Similar Implementations
For each relevant file found:
- Read the file
- Understand the pattern used
- Note reusable components

### Step 4: Document Findings

**Write to `02-functional-requirements.md`:**
```markdown
## Existing Patterns Found

### Similar Features
- `app/Services/SimilarService.php` - Does X, could reuse Y
- `app/Models/RelatedModel.php` - Has pattern we need

### Reusable Components
- `AuthService` - Authentication handling
- `BaseRepository` - Database access pattern

### Conventions Observed
- Uses repository pattern for data access
- Events dispatched for side effects
- Form requests for validation
```

---

## Output Summary

Present to user:
```markdown
## Codebase Search Results

**Found {N} related files**

### Key Findings
1. Similar feature exists in {location}
2. Can reuse {component} for {purpose}
3. Project uses {pattern} for this type of work

### Relevant Files
- `path/to/file.php` - [why relevant]
```

---

## Outputs
- `RELATED_FILES`: List of relevant files
- `PATTERNS_FOUND`: Architecture patterns identified
- Updated `02-functional-requirements.md`
