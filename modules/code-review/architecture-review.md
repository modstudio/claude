# Module: architecture-review

## Purpose
Review code against architecture rules from project standards.

## Scope
CODE-REVIEW - Used by report and interactive modes

## Mode
READ-ONLY

---

## Inputs
- Changed files list from gather-review-context
- Standards loaded from `$PROJECT_STANDARDS_DIR/20-architecture.md`

## Instructions

### Step 1: Load Inline Documentation (Relevant Only)

**Only load inline docs for directories with actual changes:**

```bash
# Get unique directories from changed files
CHANGED_DIRS=$(git diff --name-only $PROJECT_BASE_BRANCH...HEAD | xargs -I {} dirname {} | sort -u)

# Find inline docs only in changed directories (and their parents)
for dir in $CHANGED_DIRS; do
  # Check the directory itself
  [ -f "$dir/.context.md" ] && echo "=== $dir/.context.md ===" && cat "$dir/.context.md"
  [ -f "$dir/.migration.md" ] && echo "=== $dir/.migration.md ===" && cat "$dir/.migration.md"

  # Check parent directory (for domain-level docs)
  parent=$(dirname "$dir")
  [ -f "$parent/.context.md" ] && echo "=== $parent/.context.md ===" && cat "$parent/.context.md"
done
```

**Only check legacy docs if changes touch legacy directories:**
```bash
# Check if any changes are in legacy directories
if echo "$CHANGED_DIRS" | grep -qE "^app/(Models|Services|Repositories|Contracts)"; then
  for dir in app/Models app/Services app/Repositories app/Contracts; do
    echo "$CHANGED_DIRS" | grep -q "^$dir" && [ -f "$dir/.context.md" ] && cat "$dir/.context.md"
  done
fi
```

**Extract compliance requirements from loaded docs:**
| Check | Source |
|-------|--------|
| No new files in legacy directories | Legacy `.context.md` "Do not add" warnings |
| Files in correct domain location | Domain `.context.md` structure |
| Migration entries updated | `.migration.md` tracking |

---

### Step 2: Load Architecture Standards

```bash
cat "$PROJECT_STANDARDS_DIR/20-architecture.md"
```

Cache section headings for citations:
```bash
grep -E "^#{2,3} " "$PROJECT_STANDARDS_DIR/20-architecture.md" | head -30
```

### Step 3: Review Backend Files

**For each modified file, check appropriate rules:**

#### Models (`app/Models/*.php`, `app/Domains/*/Models/*.php`)
- [ ] UUIDs used for IDs where applicable
- [ ] Static constructors for complex creation
- [ ] Eloquent relationships marked `@internal only for Eloquent`
- [ ] Classes declared `final` or `abstract`
- [ ] `$fillable` array properly defined
- [ ] `$casts` defined for booleans, dates, custom types
- [ ] Getter methods have return types
- [ ] No business logic (just accessors/data methods)

#### Services (`app/Services/*.php`, `app/Domains/*/Services/*.php`)
- [ ] Business logic in Command/Handler pattern
- [ ] Uses DTOs for complex data (not raw arrays)
- [ ] All methods have type hints
- [ ] No database queries (delegated to repositories)
- [ ] Stateless where possible

#### Handlers (`app/Domains/*/Commands/Handlers/*.php`)
- [ ] Single responsibility per handler
- [ ] Dependencies injected via constructor
- [ ] Handles exactly one command
- [ ] Returns appropriate value or void
- [ ] Uses repositories for data access

#### Repositories (`app/Repositories/*.php`)
- [ ] No business logic
- [ ] Query builders for complex queries
- [ ] Uses Criteria pattern for filters
- [ ] Readable queries (not over-optimized)

#### Controllers (`app/Http/Controllers/*.php`)
- [ ] Thin (delegates to handlers/services)
- [ ] Uses FormRequests for validation
- [ ] Returns via ResponseFactory
- [ ] Multi-action where appropriate

#### Migrations (`database/migrations/*.php`)
- [ ] Both `up()` and `down()` methods
- [ ] Migrations reversible
- [ ] Column comments present
- [ ] Data migrations separate from schema

### Step 4: Review Frontend Files

#### Components (`resources/js/components/**/*.vue`)
- [ ] File names in PascalCase
- [ ] Imports use `@` alias
- [ ] Include `.vue` extension in imports

#### Vue 3 Readiness
- [ ] No new mixins (use composables)
- [ ] No `$on`/`$off`/`$once` usage
- [ ] No filters `{{ value | filter }}`
- [ ] Uses `v-slot` syntax
- [ ] No `Vue.set()`/`Vue.delete()`

#### API Clients
- [ ] Components don't call axios directly
- [ ] Use `*ApiClient.js` files

### Step 5: Inline Documentation Compliance

**Check for violations of inline doc rules:**

#### New Files in Legacy Directories
- [ ] No new files added to `app/Models/` (should be in `app/Domains/*/Models/`)
- [ ] No new files added to `app/Services/` (should be in `app/Domains/*/Services/`)
- [ ] No new files added to `app/Repositories/` (should be in `app/Domains/*/Repositories/`)
- [ ] No new files added to `app/Contracts/` (should be in `app/Domains/*/Contracts/`)

**Detection:**
```bash
# Find new files in legacy directories
git diff --name-only --diff-filter=A $PROJECT_BASE_BRANCH...HEAD | grep -E "^app/(Models|Services|Repositories|Contracts)/[^/]+\.(php)$"
```

#### Domain Structure Compliance
- [ ] New domain files match `.context.md` directory structure
- [ ] Cross-domain references align with documented relationships
- [ ] Migration files updated when moving files between directories

#### Migration Tracking
- [ ] Files being moved are tracked in source `.migration.md`
- [ ] Completed migrations removed from `.migration.md`
- [ ] New domains have `.context.md` if substantial

---

## Output Format

For each finding:
```markdown
**[SEVERITY]:** [Issue description]
**Location:** `file/path:line`
**Violation:** [ARCH §section]
**Current Code:**
\`\`\`{language}
[actual code]
\`\`\`
**Fix Required:**
\`\`\`{language}
[corrected code]
\`\`\`
```

---

## Outputs

```markdown
## Architecture Review

**Standards:** $PROJECT_STANDARDS_DIR/20-architecture.md

### Findings

#### CRITICAL
[List or "None"]

#### MAJOR
[List or "None"]

#### MINOR
[List or "None"]

### Architecture Compliance Matrix

| Standard | Status | Notes |
|----------|--------|-------|
| DDD Structure | ✓/✗ | [findings] |
| Models | ✓/✗ | |
| Services/Handlers | ✓/✗ | |
| Repositories | ✓/✗ | |
| Controllers | ✓/✗ | |
| Frontend | ✓/✗ | |
| Vue 3 Readiness | ✓/✗ | |
| **Inline Docs Compliance** | ✓/✗ | |

### Inline Documentation Compliance

| Check | Status | Details |
|-------|--------|---------|
| No new files in legacy dirs | ✓/✗ | [list violations] |
| Domain structure matches docs | ✓/✗ | |
| Migration tracking updated | ✓/✗ | |
| New domains documented | ✓/✗ | |
```

---

**End of Module**
