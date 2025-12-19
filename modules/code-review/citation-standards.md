# Citation Standards Module

**Module:** Rule citation format and SSOT guidance
**Version:** 1.0.0

## Purpose
Define consistent citation formats for referencing project standards in code review findings.

## Scope
CODE-REVIEW - Used by: all code review workflows

---

## SSOT Principle (Single Source of Truth)

**Never duplicate rules inside workflows or reports.**

1. **Consult** standard files from `PROJECT_STANDARDS_DIR` (e.g., `.ai/rules/`)
2. **Cite** findings using the project's citation format
3. **Link** to specific sections when possible
4. **Verify** rules exist before citing them

---

## Citation Format

### Standard Citation Pattern

```
[CATEGORY §section.subsection]
```

Where:
- `CATEGORY` = Rule category (ARCH, STYLE, TEST, LARAVEL, etc.)
- `section` = Major section number or name
- `subsection` = Optional subsection reference

### Project-Specific Formats

Each project defines its citation format in the YAML config:

```yaml
citation_format:
  architecture: "[ARCH §{section}]"
  style: "[STYLE §{section}]"
  test: "[TEST §{section}]"
  laravel: "[LARAVEL §{topic}]"
```

Access via variables:
- `PROJECT_CITATION_ARCHITECTURE`
- `PROJECT_CITATION_STYLE`
- `PROJECT_CITATION_TEST`

---

## Citation Categories

### Architecture ([ARCH §...])

For findings related to:
- DDD structure and domain boundaries
- Model design (fillable, casts, relationships)
- Service/Handler patterns
- Repository patterns
- Controller responsibilities
- Database schema and migrations

**Source:** `.ai/rules/20-architecture.md`

**Examples:**
```
[ARCH §models.fillable] - Missing $fillable array
[ARCH §handlers.single-responsibility] - Handler does too much
[ARCH §repositories.no-business-logic] - Business logic in repository
[ARCH §migrations.reversible] - Missing down() method
```

### Style ([STYLE §...])

For findings related to:
- Naming conventions
- Type hints and return types
- Code formatting (PSR-12)
- Comments and documentation
- Code metrics (function length, complexity)

**Source:** `.ai/rules/10-coding-style.md`

**Examples:**
```
[STYLE §naming.booleans] - Boolean should be is*/has*/should*
[STYLE §typing.return-types] - Missing return type
[STYLE §metrics.function-length] - Function exceeds 50 lines
[STYLE §comments.no-obvious] - Comment states the obvious
```

### Testing ([TEST §...])

For findings related to:
- Test class structure
- Assertion patterns
- Mocking practices
- Test coverage requirements
- Test naming

**Source:** `.ai/rules/30-testing.md`

**Examples:**
```
[TEST §structure.final-class] - Test class not declared final
[TEST §assertions.self] - Use self::assertSame() not $this->
[TEST §mocking.no-createMock] - Use createStub() instead
[TEST §coverage.new-methods] - New public method needs tests
```

### Laravel ([LARAVEL §...])

For findings related to Laravel best practices (via Laravel Boost MCP):

**Examples:**
```
[LARAVEL §eloquent.n+1] - N+1 query detected
[LARAVEL §validation.form-request] - Validation should be in FormRequest
[LARAVEL §migrations.indexes] - Missing index on foreign key
```

---

## How to Cite Findings

### In Issue Description

```markdown
**MAJOR:** Business logic in controller
**Location:** `app/Http/Controllers/OrderController.php:45-67`
**Violation:** [ARCH §controllers.thin]
**Issue:** Controller contains order validation and pricing logic
**Fix:** Move to `app/Domains/Order/Handlers/CreateOrderHandler.php`
```

### In Summary Table

| # | Severity | Issue | Violation | Suggestion |
|---|----------|-------|-----------|------------|
| 1 | ⚠️ MAJOR | Logic in controller | [ARCH §controllers] | Move to handler |
| 2 | 📋 MINOR | Missing return type | [STYLE §typing] | Add `: void` |

### In Inline Comments

```markdown
**File:** `app/Services/ProductService.php:45`

> **[STYLE §naming.intent]** Variable `$p` should describe intent: `$activeProduct`
```

---

## Finding Section References

### Discovering Available Sections

1. Read the standards file
2. Note section headers (##, ###)
3. Use descriptive section names

```bash
# Find sections in architecture rules
grep "^##" .ai/rules/20-architecture.md
```

### Section Naming Convention

If formal section numbers don't exist, use descriptive keys:

| Instead of | Use |
|------------|-----|
| `[ARCH §3.2.1]` | `[ARCH §models.relationships]` |
| `[STYLE §2.4]` | `[STYLE §naming.booleans]` |
| `[TEST §1.1]` | `[TEST §structure.final-class]` |

---

## When Citations Are Required

| Severity | Citation Required? |
|----------|-------------------|
| BLOCKER | **Yes** - Must cite violated rule |
| MAJOR | **Yes** - Must cite violated rule |
| MINOR | **Recommended** - Cite if applicable |
| NIT | **Optional** - Often style preference |

---

## Citation Validation

Before citing a rule:

1. **Verify the rule exists** in the standards file
2. **Quote or paraphrase** the actual rule text if helpful
3. **Link to documentation** if available
4. **Don't invent rules** - only cite documented standards

### If No Rule Exists

If the issue is valid but no documented rule covers it:

```markdown
**Issue:** [Description]
**Note:** Consider adding this to project standards
**Suggested standard:** [Proposed rule text]
```

---

## Examples by Project

### Starship Project

```markdown
[ARCH §models.fillable] - From .ai/rules/20-architecture.md
[STYLE §naming.units] - From .ai/rules/10-coding-style.md
[TEST §coverage.handlers] - From .ai/rules/30-testing.md
```

### Alephbeis Project

```markdown
[ARCH §domain.boundaries] - From .ai/rules/20-architecture.md
[STYLE §typing.strict] - From .ai/rules/10-coding-style.md
```

### Generic Projects

When no project-specific rules exist:
```markdown
[BEST-PRACTICE] - General industry standard
[PSR-12] - PHP-FIG standard
[OWASP] - Security best practice
```

---

**End of Module**
