# Module: performance-security

## Purpose
Quick scan for performance and security issues in code review.

## Scope
CODE-REVIEW - Used by interactive.md and full reviews

## Mode
READ-ONLY

---

## Performance Checks

### Database & Queries

- [ ] **N+1 queries** - Loading related data in loops
  - Look for: `foreach` with relationship access
  - Fix: Use `with()` or `load()` for eager loading

- [ ] **Missing indexes** - Foreign keys and frequently queried columns
  - Check migrations for index definitions
  - Verify indexes on columns used in WHERE clauses

- [ ] **Large dataset handling**
  - Use `chunk()` or `cursor()` for large collections
  - Avoid `get()->count()`, use `count()` directly

- [ ] **Unnecessary eager loading**
  - Don't eager load relationships not used
  - Use `select()` to limit columns

### Memory & Processing

- [ ] **Large loops/collections**
  - Memory usage in bulk operations
  - Consider chunking for >1000 records

- [ ] **Expensive calculations in loops**
  - Move invariant calculations outside loops
  - Cache repeated lookups

- [ ] **String concatenation in loops**
  - Use array + implode instead

---

## Security Checks

### Input Validation

- [ ] **SQL injection risks**
  - Raw queries with user input
  - Use parameterized queries or Eloquent

- [ ] **XSS vulnerabilities**
  - Unescaped user content in views
  - Use `{{ }}` not `{!! !!}` for user data

- [ ] **Input validation**
  - All user input validated via FormRequest
  - Server-side validation (not just client)

### Authentication & Authorization

- [ ] **CSRF protection**
  - Forms include CSRF token
  - API routes properly protected

- [ ] **Authorization checks**
  - Gate/Policy checks before actions
  - Middleware protecting routes

- [ ] **Mass assignment protection**
  - `$fillable` defined on models
  - No `$guarded = []`

### Data Protection

- [ ] **Sensitive data exposure**
  - No secrets in logs
  - No passwords in responses

- [ ] **File upload validation**
  - File type verification
  - Size limits enforced

---

## Severity Classification

| Issue | Severity |
|-------|----------|
| SQL injection | BLOCKER |
| XSS vulnerability | BLOCKER |
| Auth bypass | BLOCKER |
| N+1 in high-traffic | MAJOR |
| Missing CSRF | MAJOR |
| Missing validation | MAJOR |
| N+1 in low-traffic | MINOR |
| Performance optimization | MINOR |

---

## Output Format

```markdown
### Performance Issues

**N+1 Query Detected**
- **Location:** `app/Services/ProductService.php:45`
- **Pattern:** Loading `variants` in foreach loop
- **Fix:** Add `with('variants')` to initial query
- **Severity:** MAJOR

### Security Issues

**Missing Authorization**
- **Location:** `app/Http/Controllers/OrderController.php:78`
- **Issue:** No policy check before order deletion
- **Fix:** Add `$this->authorize('delete', $order)`
- **Severity:** MAJOR
```

---

**End of Module**
