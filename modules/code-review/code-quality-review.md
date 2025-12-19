# Module: code-quality-review

## Purpose
Review code against style and quality standards.

## Scope
CODE-REVIEW - Used by report and interactive modes

## Mode
READ-ONLY

---

## Inputs
- Changed files from gather-review-context
- Standards loaded from `$PROJECT_STANDARDS_DIR/10-coding-style.md`

## Instructions

### Step 1: Load Style Standards

```bash
cat "$PROJECT_STANDARDS_DIR/10-coding-style.md"
```

### Step 2: Naming Review

For each file, check:

- [ ] Precise, self-documenting names (no `product1`, `product2`)
- [ ] Booleans: `is*/has*/should*`
- [ ] Collections: plural; elements: singular
- [ ] Units in names: `*Seconds`, `*Dollars`, `*Meters`
- [ ] Intent-based: `$validPayload`, `$existingUser`

### Step 3: Typing Review

- [ ] Scalar types declared everywhere possible
- [ ] Return types on all methods
- [ ] No `mixed` unless absolutely necessary
- [ ] Property types declared (PHP 7.4+)

### Step 4: Comments Review

- [ ] Only when non-obvious
- [ ] PHPDoc for complex generics: `@return array<string, Product>`
- [ ] Links to business docs where relevant
- [ ] No commented-out code

### Step 5: Code Metrics

- [ ] Functions ≤50 lines (guideline)
- [ ] Lines ≤170 characters (guideline)
- [ ] No forbidden functions: `dd`, `var_dump`, `echo`, `print_r`, `dump`
- [ ] No debug statements left in code
- [ ] PSR-12 compliance

---

## Laravel Standards Check (if applicable)

**If Laravel Boost MCP available:**

Use `mcp__laravel-boost__search-docs` to verify best practices:

Search queries:
1. "database migrations best practices"
2. "Eloquent model fillable casts relationships"
3. "validation FormRequest rules"
4. "query builder joins performance"

**Verify:**
- [ ] Migrations follow Laravel conventions
- [ ] Model casts use appropriate types
- [ ] Queries avoid N+1 problems
- [ ] Validation rules properly structured
- [ ] Uses Laravel helpers where appropriate

---

## Output Format

```markdown
**[SEVERITY]:** [Issue description]
**Location:** `file/path:line`
**Violation:** [STYLE §section]
**Current:**
\`\`\`{language}
[current code]
\`\`\`
**Suggested:**
\`\`\`{language}
[improved code]
\`\`\`
```

---

## Outputs

```markdown
## Code Quality Review

**Standards:** $PROJECT_STANDARDS_DIR/10-coding-style.md

### Findings

#### MAJOR
[List or "None"]

#### MINOR
[List or "None"]

#### NIT
[List or "None"]

### Quality Metrics

| Metric | Status | Notes |
|--------|--------|-------|
| Naming | /| |
| Typing | /| |
| Comments | /| |
| Code Metrics | /| |
| Laravel Standards | /| |
```

---

**End of Module**
