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

### Step 1: Load Relevant Inline Documentation

**Only load inline docs for directories relevant to the task (not entire codebase):**

#### 1a: Identify Target Directories from Task Keywords

From task description, extract domain/directory keywords:
- Feature names → likely domain directory
- Model names → `app/Domains/Core/{Domain}/Models/` or `app/Models/`
- Service names → `app/Domains/Core/{Domain}/Services/` or `app/Services/`

```bash
# Example: If task mentions "Bids" or "BidOpportunity"
TARGET_DOMAINS="Bids"  # Derived from task keywords

# Find inline docs only for relevant domains
for domain in $TARGET_DOMAINS; do
  [ -f "app/Domains/Core/$domain/.context.md" ] && cat "app/Domains/Core/$domain/.context.md"
  [ -f "app/Domains/Core/$domain/.migration.md" ] && cat "app/Domains/Core/$domain/.migration.md"
done
```

#### 1b: Check Legacy Docs (Only If Task Might Touch Legacy)

**Only read legacy directory docs if task involves:**
- Creating new Models/Services/Repositories → read those legacy docs
- Migrating files → read source and target docs

```bash
# Example: If task involves creating a Model
NEEDS_MODEL=true  # Derived from task requirements

if [ "$NEEDS_MODEL" = true ]; then
  [ -f "app/Models/.context.md" ] && cat "app/Models/.context.md"
fi
```

#### 1c: Extract Constraints from Loaded Docs

| Constraint | Source |
|------------|--------|
| Prohibited locations | Legacy `.context.md` files (if loaded) |
| Target structure | Domain `.context.md` files |
| Planned migrations | `.migration.md` files |
| Domain relationships | Cross-references in domain docs |

---

### Step 2: Identify Search Terms
From task description, identify:
- Feature names
- Domain concepts
- Technical components
- Similar functionality keywords

### Step 3: Search for Patterns
```bash
# Search for similar features
grep -r "similar_term" --include="*.php" app/

# Find related files
find . -name "*related*" -type f

# Search for domain concepts
grep -rn "DomainConcept" app/
```

**Use Grep/Glob tools, NOT bash grep**

### Step 4: Read Similar Implementations
For each relevant file found:
- Read the file
- Understand the pattern used
- Note reusable components

### Step 5: Document Findings

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

### Directory Constraints (from inline docs)
- **Prohibited:** `app/Models/`, `app/Services/`, `app/Repositories/`, `app/Contracts/`
- **Target Domain:** `app/Domains/Core/{Domain}/`
- **Existing Migrations:** [list any files in .migration.md targeting same domain]
```

### Step 6: Plan Inline Doc Updates

**If creating new directories or significantly modifying a domain:**

Check if inline docs need to be created or updated:

| Scenario | Action |
|----------|--------|
| New domain directory | Create `.context.md` from template |
| Moving files to domain | Add entries to source `.migration.md` |
| Migration complete | Mark files as migrated or remove from `.migration.md` |
| New domain relationships | Update `.context.md` cross-references |

**Add to implementation plan:**
```markdown
## Inline Documentation Updates

### New Files to Create
- [ ] `app/Domains/Core/{NewDomain}/.context.md` - Domain context

### Files to Update
- [ ] `app/{LegacyDir}/.migration.md` - Add migration entries for files being moved
- [ ] `app/Domains/Core/{Domain}/.context.md` - Update relationships
```

---

## Output Summary

Present to user:
```markdown
## Codebase Search Results

**Found {N} related files**

### Inline Documentation Discovered
| Directory | Context | Migrations |
|-----------|---------|------------|
| `app/Models/` | Legacy - no new files | 15 files to migrate |
| `app/Domains/Core/Bids/` | Active | 8 files pending |

### Directory Constraints
- **Cannot create in:** `app/Models/`, `app/Services/`, `app/Repositories/`, `app/Contracts/`
- **Target location:** `app/Domains/Core/{Domain}/`

### Key Findings
1. Similar feature exists in {location}
2. Can reuse {component} for {purpose}
3. Project uses {pattern} for this type of work

### Relevant Files
- `path/to/file.php` - [why relevant]

### Inline Doc Updates Needed
- [ ] Create `app/Domains/Core/{Domain}/.context.md`
- [ ] Update `app/Models/.migration.md` with new migration targets
```

---

## Outputs
- `RELATED_FILES`: List of relevant files
- `PATTERNS_FOUND`: Architecture patterns identified
- `INLINE_DOCS_FOUND`: List of `.context.md` and `.migration.md` files discovered
- `DIRECTORY_CONSTRAINTS`: Prohibited and target locations
- `INLINE_DOC_UPDATES`: Required inline doc changes for implementation plan
- Updated `02-functional-requirements.md`
