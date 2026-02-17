---
description: Thorough architecture review with leanness analysis
---

# Architecture Review Workflow

Deep architectural analysis focusing on structure, patterns, Laravel best practices, and leanness.

**This IS about:** Architecture, DDD, patterns, Laravel conventions, over-engineering
**This is NOT about:** Bugs, style, tests, security (use other review modes)

---

## STOP - MANDATORY FIRST ACTION

**YOU MUST CALL TodoWrite RIGHT NOW before reading any other files or running any commands.**

```javascript
TodoWrite({
  todos: [
    // Setup
    {content: "Load architecture standards and gather changed files", status: "in_progress", activeForm: "Loading standards"},
    {content: "Load relevant inline docs for changed directories", status: "pending", activeForm: "Loading inline docs"},

    // DDD Structure
    {content: "Check files are in correct domain directories", status: "pending", activeForm: "Checking file placement"},
    {content: "Verify domain boundaries respected (no cross-domain direct access)", status: "pending", activeForm: "Checking domain boundaries"},
    {content: "Check dependencies use contracts not concrete implementations", status: "pending", activeForm: "Checking dependencies"},

    // Laravel Practices (if Laravel project)
    {content: "Review Model patterns (fillable, casts, relationships, no business logic)", status: "pending", activeForm: "Reviewing models"},
    {content: "Review Service/Handler patterns (single responsibility, DI, stateless)", status: "pending", activeForm: "Reviewing services"},
    {content: "Review Controller patterns (thin, FormRequests, proper delegation)", status: "pending", activeForm: "Reviewing controllers"},
    {content: "Review Repository patterns (no business logic, query builders)", status: "pending", activeForm: "Reviewing repositories"},
    {content: "Review Database patterns (reversible migrations, indexes, FKs)", status: "pending", activeForm: "Reviewing database"},

    // Inline Doc Compliance
    {content: "Check no new files added to legacy directories", status: "pending", activeForm: "Checking legacy violations"},
    {content: "Verify new domain files match .context.md structure", status: "pending", activeForm: "Checking domain structure"},
    {content: "Check migration tracking updated for moved files", status: "pending", activeForm: "Checking migration tracking"},

    // Leanness
    {content: "Find single-implementation interfaces/abstract classes", status: "pending", activeForm: "Finding unnecessary abstractions"},
    {content: "Find pass-through methods with no added value", status: "pending", activeForm: "Finding pass-through code"},
    {content: "Find backwards-compat hacks (_vars, aliases, tombstones)", status: "pending", activeForm: "Finding compat hacks"},
    {content: "Find speculative/unused code (unused params, over-config)", status: "pending", activeForm: "Finding speculative code"},

    // Pattern Consistency
    {content: "Compare similar components for consistent patterns", status: "pending", activeForm: "Checking pattern consistency"},

    // Report
    {content: "Generate architecture report with findings", status: "pending", activeForm: "Generating report"}
  ]
})
```

**DO NOT CONTINUE READING THIS FILE until TodoWrite has been called.**

---

## Mode
READ-ONLY (no changes, only analyze)

---

## Phase 0: Project Context Detection

{{MODULE: ~/.claude/modules/shared/quick-context.md}}

---

## Step 1: Load Standards and Inline Docs

### 1a: Load Architecture Standards

```bash
cat "$PROJECT_STANDARDS_DIR/20-architecture.md"
```

Cache section headings for citations:
```bash
grep -E "^#{2,3} " "$PROJECT_STANDARDS_DIR/20-architecture.md" | head -30
```

### 1b: Gather Files to Review (Do This First)

**Based on selected scope from command:**

**Code Changes:**
```bash
# Get changed files and their directories
CHANGED_FILES=$(git diff --name-only $PROJECT_BASE_BRANCH...HEAD; git diff --name-only)
CHANGED_DIRS=$(echo "$CHANGED_FILES" | xargs -I {} dirname {} | sort -u)
```

**Task Docs Plan:**
Extract file paths mentioned in `$TASK_FOLDER/03-implementation-plan.md` and derive directories.

**Specific Files:**
Use directories from files provided by user.

### 1c: Load Relevant Inline Documentation Only

**Only load inline docs for directories with changes (not entire codebase):**

```bash
# Find inline docs only in changed directories and their parents
for dir in $CHANGED_DIRS; do
  # Check the directory itself
  [ -f "$dir/.context.md" ] && echo "=== $dir/.context.md ===" && cat "$dir/.context.md"
  [ -f "$dir/.migration.md" ] && echo "=== $dir/.migration.md ===" && cat "$dir/.migration.md"

  # Check parent directory (for domain-level docs)
  parent=$(dirname "$dir")
  [ -f "$parent/.context.md" ] && echo "=== $parent/.context.md ===" && cat "$parent/.context.md"
done
```

**Only load legacy docs if changes touch those directories:**
```bash
# Check each legacy directory only if it has changes
for legacy in app/Models app/Services app/Repositories app/Contracts; do
  if echo "$CHANGED_DIRS" | grep -q "^$legacy"; then
    [ -f "$legacy/.context.md" ] && cat "$legacy/.context.md"
    [ -f "$legacy/.migration.md" ] && cat "$legacy/.migration.md"
  fi
done
```

**Mark todo complete when done.**

---

## Step 2: DDD Structure Review

{{MODULE: ~/.claude/modules/code-review/architecture-review.md}}

**Execute Steps 3-4 (Backend/Frontend structure checks)**

### Additional DDD Checks:

| Check | Status | Notes |
|-------|--------|-------|
| Domain boundaries respected | | |
| No cross-domain direct access | | |
| Shared kernel properly used | | |
| Aggregates have clear roots | | |
| Events flow correctly between domains | | |

**For each file, verify:**
- [ ] File is in correct domain
- [ ] Dependencies only on allowed domains
- [ ] Uses domain contracts (not concrete implementations)
- [ ] Follows domain's `.context.md` structure

**Mark todo complete when done.**

---

## Step 3: Laravel Best Practices (via Boost MCP)

**Skip if not a Laravel project (`PROJECT_MCP_LARAVEL_BOOST != true`)**

### 3a: Query Boost Docs

Use `mcp__laravel-boost__search-docs` for relevant topics:

```javascript
// Search based on changed file types
mcp__laravel-boost__search-docs({query: "Eloquent model best practices relationships"})
mcp__laravel-boost__search-docs({query: "service container dependency injection"})
mcp__laravel-boost__search-docs({query: "database migrations conventions"})
mcp__laravel-boost__search-docs({query: "form request validation"})
```

### 3b: Laravel Pattern Checklist

#### Models
- [ ] `$fillable` properly defined (not `$guarded = []`)
- [ ] `$casts` for dates, booleans, JSON, enums
- [ ] Relationships use proper return types
- [ ] Scopes are chainable and well-named
- [ ] Accessors/Mutators use attribute casting where possible
- [ ] No business logic in models (use services/handlers)

#### Services/Handlers
- [ ] Single responsibility
- [ ] Constructor injection (not `app()` helper)
- [ ] Stateless where possible
- [ ] Returns DTOs or value objects (not arrays)

#### Controllers
- [ ] Thin controllers (delegate to handlers/services)
- [ ] Uses FormRequests for validation
- [ ] Single responsibility per action
- [ ] Proper HTTP status codes

#### Repositories
- [ ] Query builders for complex queries
- [ ] Uses Criteria pattern for filters
- [ ] No business logic
- [ ] Proper eager loading

#### Database
- [ ] Migrations are reversible
- [ ] Foreign keys with proper cascading
- [ ] Indexes on frequently queried columns
- [ ] Column comments for non-obvious fields

### 3c: Get Application Context

```javascript
// Get app info for context
mcp__laravel-boost__application-info()
```

**Mark todo complete when done.**

---

## Step 4: Inline Documentation Compliance

{{MODULE: ~/.claude/modules/code-review/architecture-review.md}}

**Execute Step 5 (Inline Documentation Compliance)**

### Detailed Checks:

#### New Files in Legacy Directories
```bash
# Find new files in legacy directories
git diff --name-only --diff-filter=A $PROJECT_BASE_BRANCH...HEAD | grep -E "^app/(Models|Services|Repositories|Contracts)/[^/]+\.php$"
```

**Each new file in legacy dir = CRITICAL violation**

#### Domain Structure Matches Docs
For each domain with changes:
1. Read domain's `.context.md`
2. Verify new files match documented structure
3. Check cross-references match actual dependencies

#### Migration Tracking
- [ ] Files being moved tracked in source `.migration.md`
- [ ] Completed migrations removed from tracking
- [ ] New domains have `.context.md` if substantial

**Mark todo complete when done.**

---

## Step 5: Leanness Review

{{MODULE: ~/.claude/modules/code-review/leanness-review.md}}

**Core principle:** The right amount of complexity is the minimum needed for the current task.

### Over-Engineering Patterns to Detect:

#### Premature Abstraction
- [ ] Interface with single implementation (and no plans for more)
- [ ] Abstract class with single concrete class
- [ ] Factory that only creates one type
- [ ] Generic helper that's used once
- [ ] Wrapper that just delegates

#### Unnecessary Indirection
- [ ] Service that just calls repository
- [ ] Handler that just calls service
- [ ] DTO that mirrors model exactly
- [ ] Event/Listener that could be direct call

#### Feature Flag Overkill
- [ ] Backwards-compatibility for internal changes
- [ ] Renaming unused variables to `_var`
- [ ] Re-exporting things "just in case"
- [ ] `// removed` comments for deleted code

#### Speculative Generality
- [ ] "Might need this later" code
- [ ] Unused method parameters
- [ ] Over-configurable when simple is fine
- [ ] Plugin architecture for single use

### Leanness Heuristics:

| Pattern | Lean | Over-Engineered |
|---------|------|-----------------|
| 3 similar lines | OK | Don't abstract yet |
| Interface | >1 impl or public API | Single private impl |
| DTO | Cross-boundary data | Same-class data |
| Event | Cross-domain or async | Same-service call |
| Factory | Complex creation | `new` is fine |
| Config | User-facing | Dev convenience |

**Mark todo complete when done.**

---

## Step 6: Pattern Consistency Check

### Across Similar Components

For files of the same type, check consistency:

```bash
# Find all models and compare patterns
find app -name "*Model.php" -o -name "*.php" -path "*/Models/*" | head -10

# Find all services
find app -name "*Service.php" -o -name "*.php" -path "*/Services/*" | head -10

# Find all handlers
find app -name "*Handler.php" | head -10
```

**Check:**
- [ ] Similar components use same patterns
- [ ] Naming conventions consistent
- [ ] Error handling consistent
- [ ] Return types consistent
- [ ] Constructor injection patterns match

### With Existing Codebase

For new code, compare against existing similar code:
- Does it follow established patterns?
- Is the approach consistent with how similar features work?
- Are there existing utilities/helpers that could be reused?

**Mark todo complete when done.**

---

## Step 7: Generate Architecture Report

**Output to CHAT (no files created):**

```markdown
# Architecture Review Report

## Summary

| Area | Status | Issues |
|------|--------|--------|
| DDD Structure | | |
| Laravel Practices | | |
| Inline Doc Compliance | | |
| Leanness | | |
| Pattern Consistency | | |

## Standards Referenced
- `$PROJECT_STANDARDS_DIR/20-architecture.md`
- Inline docs: [list discovered]
- Laravel Boost: [queries made]

---

## DDD Structure

### Domain Boundaries
| Domain | Files Changed | Status |
|--------|---------------|--------|
| {domain} | {count} | |

### Findings
[List with severity]

---

## Laravel Best Practices

### Checklist Results
| Category | Status | Notes |
|----------|--------|-------|
| Models | | |
| Services/Handlers | | |
| Controllers | | |
| Repositories | | |
| Database | | |

### Findings
[List with severity]

---

## Inline Documentation Compliance

| Check | Status | Details |
|-------|--------|---------|
| No new files in legacy dirs | | |
| Domain structure matches | | |
| Migration tracking updated | | |

### Violations
[List any]

---

## Leanness Analysis

### Over-Engineering Detected

#### REMOVE (Unnecessary Complexity)
[For each:]
- **Location:** `file:line`
- **Pattern:** [type of over-engineering]
- **Problem:** [why it's unnecessary]
- **Recommendation:** [simpler alternative]

#### SIMPLIFY (Could Be Leaner)
[Same format]

#### OK (Complexity Justified)
[List where complexity is warranted]

### Leanness Score: [LEAN / ACCEPTABLE / OVER-ENGINEERED]

---

## Pattern Consistency

### Inconsistencies Found
[List any]

### Recommendations
[Suggestions for alignment]

---

## Critical Issues (Must Fix)

[List CRITICAL findings from all sections]

## Major Issues (Should Fix)

[List MAJOR findings]

## Minor Issues (Consider)

[List MINOR findings]

---

## Recommendation

[ARCHITECTURALLY SOUND | NEEDS REFACTORING | SIGNIFICANT REWORK NEEDED]

### Suggested Actions
1. [Priority action]
2. [Secondary action]
3. [etc.]
```

**Mark todo complete when done.**

---

## Execution Constraints

**You MUST:**
- Load and reference architecture standards
- Check inline documentation for all affected directories
- Use Laravel Boost MCP for Laravel projects
- Actively look for over-engineering
- Compare against existing patterns in codebase
- Provide specific file:line references
- Give concrete recommendations for issues found

**You MUST NOT:**
- Look for bugs (use Bug Zapper)
- Check code style (use Quick Review)
- Run tests
- Make any code changes
- Skip the leanness review

---

Begin architecture review now.
