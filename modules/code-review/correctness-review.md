# Module: correctness-review

## Purpose
Review code for correctness, robustness, and edge case handling.

## Scope
CODE-REVIEW - Used by report and interactive modes

## Mode
READ-ONLY

---

## Inputs
- Changed files containing business logic
- Requirements from task docs (if available)

## Instructions

### Step 1: Logic Paths & Edge Cases

For each file with business logic, verify:

- [ ] All code paths covered (if/else, switch, early returns)
- [ ] Edge cases handled:
  - Empty arrays/collections
  - Null values
  - Zero and negative numbers
  - Boundary conditions (min/max values)
  - Empty strings
- [ ] Default values appropriate
- [ ] Fallback behavior defined

### Step 2: Error Handling

- [ ] Exceptions properly caught and logged
- [ ] Error messages meaningful to developers
- [ ] User-facing errors appropriate
- [ ] Graceful degradation where applicable
- [ ] No silent failures
- [ ] Stack traces preserved when re-throwing

### Step 3: Type Safety & Contracts

- [ ] Nullability handled correctly (`?Type` vs `Type`)
- [ ] Type contracts respected (method signatures)
- [ ] No unsafe type coercion
- [ ] Array type safety (`@param array<string, Product>`)
- [ ] Return types match documentation

### Step 4: Concurrency & Async Patterns

- [ ] Race conditions considered
- [ ] Database transactions used for multi-step operations
- [ ] Locks used appropriately (Redis, database)
- [ ] Idempotency for retryable operations
- [ ] Queue job failures handled
- [ ] Event ordering considered

### Step 5: Data Handling

- [ ] Timezone awareness in date operations
- [ ] DateTime objects used (not strings)
- [ ] Pagination bounds checked
- [ ] Large dataset handling (chunking, streaming)
- [ ] Memory usage considered for bulk operations
- [ ] Currency precision maintained (decimal types)

### Step 6: Transactional Integrity

- [ ] Database transactions around multi-step operations
- [ ] Rollback on failure
- [ ] No partial state on errors
- [ ] Atomic operations where needed
- [ ] Savepoints for nested transactions

---

## Requirements Verification (if task docs available)

**Compare implementation vs requirements:**

| ID | Requirement | Status | Evidence |
|----|-------------|--------|----------|
| AC1 | [From docs] | PASS/PARTIAL/MISSING | `file:line` or test |

**Check for:**
- Planned files vs actual changes
- Unexpected changes (scope creep?)
- Missing implementation

---

## Output Format

```markdown
**[SEVERITY]:** [Issue description]
**Location:** `file/path:line`
**Violation:** [ARCH §correctness] or specific rule
**Issue:** [What's wrong]
**Impact:** [What could break]
**Fix:**
\`\`\`{language}
[corrected approach]
\`\`\`
```

---

## Outputs

```markdown
## Correctness & Robustness Analysis

### Findings

#### CRITICAL
[List or "None"]

#### MAJOR
[List or "None"]

#### MINOR
[List or "None"]

### Requirements Compliance (if applicable)

| ID | Requirement | Status | Evidence |
|----|-------------|--------|----------|
| AC1 | [desc] | | |

**Summary:**
- Fully Implemented: [N] of [Total]
- Partially Implemented: [N]
- Missing: [N]
```

---

**End of Module**
