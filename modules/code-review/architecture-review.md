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

### Step 1: Load Architecture Standards

```bash
cat "$PROJECT_STANDARDS_DIR/20-architecture.md"
```

Cache section headings for citations:
```bash
grep -E "^#{2,3} " "$PROJECT_STANDARDS_DIR/20-architecture.md" | head -30
```

### Step 2: Review Backend Files

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

### Step 3: Review Frontend Files

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
| DDD Structure | /| [findings] |
| Models | /| |
| Services/Handlers | /| |
| Repositories | /| |
| Controllers | /| |
| Frontend | /| |
| Vue 3 Readiness | /| |
```

---

**End of Module**
