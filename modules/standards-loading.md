# Standards Loading Module

**Module:** Project standards file discovery and loading
**Version:** 1.0.0

This module defines how to discover and load project coding standards from the standards directory. All workflows that need to reference standards should use this pattern.

---

## Standards Directory Structure

Standards are stored in `PROJECT_STANDARDS_DIR` (typically `.ai/rules/`):

```
.ai/rules/
├── 00-system-prompt.md    # Interaction rules, persona
├── 10-coding-style.md     # Naming, typing, formatting
├── 20-architecture.md     # DDD, patterns, structure
├── 30-testing.md          # Test conventions, coverage
└── 40-*.md                # Additional project-specific rules
```

**Numbering convention:**
- `00-09`: System/meta rules
- `10-19`: Code style and formatting
- `20-29`: Architecture and design
- `30-39`: Testing
- `40+`: Project-specific extensions

---

## Loading Standards

### Quick Load (Most Common)

```bash
# Get standards directory from project context
STANDARDS_DIR="$PROJECT_STANDARDS_DIR"  # e.g., .ai/rules/

# List available standards files
ls -la "$STANDARDS_DIR"*.md 2>/dev/null || echo "No standards found"
```

### Full Load Pattern

```bash
# Read all standards files in order
for file in "$PROJECT_STANDARDS_DIR"*.md; do
  if [[ -f "$file" ]]; then
    echo "=== Loading: $(basename "$file") ==="
    # Process file...
  fi
done
```

### Selective Load (Specific Rules)

```bash
# Load only architecture rules
cat "$PROJECT_STANDARDS_DIR/20-architecture.md"

# Load only style rules
cat "$PROJECT_STANDARDS_DIR/10-coding-style.md"

# Load only testing rules
cat "$PROJECT_STANDARDS_DIR/30-testing.md"
```

---

## Standards File Reference

### 00-system-prompt.md (Interaction Rules)

Contains:
- Agent persona and behavior
- Communication guidelines
- Workflow interaction patterns
- Not typically needed for code review

### 10-coding-style.md (Style Guide)

Contains:
- Naming conventions (variables, functions, classes)
- Type hint requirements
- Code formatting (PSR-12 compliance)
- Comment guidelines
- Code metrics (function length, complexity limits)
- Forbidden patterns (dd, var_dump, etc.)

**Use for:** Code quality review, style checks

### 20-architecture.md (Architecture Rules)

Contains:
- DDD structure and domain boundaries
- Model patterns (fillable, casts, relationships)
- Service/Handler pattern requirements
- Repository patterns
- Controller responsibilities
- Migration conventions
- Frontend architecture (Vue components, API clients)

**Use for:** Architecture review, pattern compliance

### 30-testing.md (Testing Rules)

Contains:
- Test class structure (final, naming)
- Assertion patterns (self:: vs $this->)
- Mocking guidelines (createStub vs createMock)
- Coverage requirements
- Test organization (Unit/Feature/Acceptance)
- Fixture and builder usage

**Use for:** Test review, coverage analysis

---

## Caching Section Headings

For efficient citation during reviews, cache section headings:

```bash
# Extract section headings from architecture rules
grep -E "^#{2,3} " "$PROJECT_STANDARDS_DIR/20-architecture.md" | head -20

# Example output:
# ## Models
# ### Fillable Arrays
# ### Type Casts
# ## Services
# ### Handler Pattern
```

Use these headings for citations: `[ARCH §models.fillable]`

---

## Standards Not Found Handling

If standards files are missing:

```bash
if [[ ! -d "$PROJECT_STANDARDS_DIR" ]]; then
  echo "⚠️ WARNING: Standards directory not found: $PROJECT_STANDARDS_DIR"
  echo "Proceeding with generic best practices only"
  # Fall back to generic checks
fi

if [[ ! -f "$PROJECT_STANDARDS_DIR/20-architecture.md" ]]; then
  echo "⚠️ WARNING: Architecture rules not found"
  echo "Skipping architecture-specific checks"
fi
```

---

## Integration with Reviews

### Pre-Review Standards Load

Before starting a review, load relevant standards:

```markdown
## Standards Loading

1. **Architecture:** Read `$PROJECT_STANDARDS_DIR/20-architecture.md`
   - Note section headings for citations
   - Focus on patterns relevant to changed files

2. **Style:** Read `$PROJECT_STANDARDS_DIR/10-coding-style.md`
   - Note naming conventions
   - Note type requirements

3. **Testing:** Read `$PROJECT_STANDARDS_DIR/30-testing.md`
   - Note test structure requirements
   - Note assertion patterns
```

### Standards Checklist

After loading, verify:

- [ ] Architecture rules loaded and understood
- [ ] Style guide loaded and understood
- [ ] Testing rules loaded and understood
- [ ] Section headings cached for citations
- [ ] Project-specific rules identified

---

## Project-Specific Extensions

Some projects have additional rules beyond the standard set:

```bash
# Find all standards files
find "$PROJECT_STANDARDS_DIR" -name "*.md" -type f | sort

# Look for project-specific extensions
ls "$PROJECT_STANDARDS_DIR"/4*.md 2>/dev/null
```

Examples of extensions:
- `40-api-design.md` - API endpoint conventions
- `41-database.md` - Database-specific rules
- `42-security.md` - Security requirements

---

## Using Standards in Workflows

### Reference Pattern

```markdown
## Architecture Review

**Standards Source:** `$PROJECT_STANDARDS_DIR/20-architecture.md`

For each modified file, check against loaded standards:
- Models → [ARCH §models.*]
- Services → [ARCH §services.*]
- Handlers → [ARCH §handlers.*]
- Controllers → [ARCH §controllers.*]
```

### Citation Pattern

When citing violations:

```markdown
**Violation:** [ARCH §models.fillable]
**Rule:** "All models must define $fillable array explicitly"
**Source:** `.ai/rules/20-architecture.md` line 45
```

---

**End of Module**
