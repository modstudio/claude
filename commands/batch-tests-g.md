---
description: Run all tests in batches, fix failures iteratively (global)
---

# Batch Test Runner

Run all tests organized in batches, fix failures as you go, and iterate until green.

---

## YOUR FIRST RESPONSE MUST INCLUDE:

1. **TodoWrite** - Create todo list:
   - "Discover and organize tests into batches" status=in_progress activeForm="Organizing tests"
   - "Run batch 1" status=pending activeForm="Running batch 1"
   - "Fix failing tests" status=pending activeForm="Fixing tests"
   - "Run full suite verification" status=pending activeForm="Verifying all tests"

2. **Bash** - Discover test files:
   ```bash
   # For PHP/Laravel projects
   find tests -name "*Test.php" -type f | head -100
   ```

**CALL BOTH TOOLS NOW.**

---

## Step 1: Organize Tests into Batches

**Discover all test files and organize by type/domain:**

### For Laravel/PHP Projects:

```bash
# Count tests by directory
echo "=== Unit Tests ==="
find tests/Unit -name "*Test.php" -type f 2>/dev/null | wc -l

echo "=== Feature Tests ==="
find tests/Feature -name "*Test.php" -type f 2>/dev/null | wc -l

echo "=== Functional Tests ==="
find tests/Functional -name "*Test.php" -type f 2>/dev/null | wc -l

echo "=== Acceptance Tests ==="
find tests/Acceptance -name "*Test.php" -type f 2>/dev/null | wc -l
```

### Organize into Batches

**⚠️ Target batch size: ~50 tests**

- Aim for approximately 50 tests per batch
- Can exceed 50 if it keeps a domain/directory together
- Don't split a logical group just to hit 50

**Batch strategy:**

1. **Group by domain/directory first** - Keep related tests together
2. **Split large domains** - If a domain has 150 tests, split into 3 batches
3. **Combine small domains** - Group small directories to reach ~50

**Example organization:**

| Batch | Contents | Count |
|-------|----------|-------|
| 1 | Unit/Product | 52 |
| 2 | Unit/Orders + Unit/Shipping | 48 |
| 3 | Unit/Inventory | 65 (keep together - one domain) |
| 4 | Feature/Product | 45 |
| 5 | Feature/Orders | 55 |
| ... | ... | ... |

**Don't do this:**
- Split `Unit/Product` (52 tests) into two batches of 26
- Run 200 tests in one batch

**Do this:**
- Keep `Unit/Inventory` (65 tests) together - it's one domain
- Combine `Unit/Reports` (20) + `Unit/Users` (25) = 45 tests

**Present batch plan to user:**

```markdown
## Test Batch Plan

| Batch | Type | Count | Est. Time |
|-------|------|-------|-----------|
| 1 | Unit | {N} | ~{X}min |
| 2 | Feature | {N} | ~{X}min |
| 3 | Functional | {N} | ~{X}min |
| 4 | Acceptance | {N} | ~{X}min |

**Total:** {N} test files

Proceed with Batch 1?
```

---

## Step 2: Run Batch

**Run tests for current batch:**

```bash
# Example for Laravel - adjust testsuite name
docker compose exec -u1000 starship_server ./vendor/bin/phpunit --testsuite=unit
```

**Or run specific directory:**

```bash
docker compose exec -u1000 starship_server ./vendor/bin/phpunit tests/Unit/
```

**Capture output and identify:**
- Total tests run
- Passed count
- Failed count
- Error count
- Specific failing tests

---

## Step 3: Record Failures

**For each failing test, record:**

```markdown
## Batch {N} Results

**Status:** {X} passed, {Y} failed, {Z} errors

### Failing Tests

| Test | Error | File |
|------|-------|------|
| testSomething | {error message} | `tests/Unit/FooTest.php:45` |
| testAnother | {error message} | `tests/Unit/BarTest.php:78` |
```

**Update TodoWrite:**
- Add todo for each failing test: "Fix {TestName}"
- Keep "Run batch {N}" as in_progress until all fixed

---

## Step 4: Fix Failing Tests

**For each failure:**

### 4.1 Analyze the Failure
- Read the test file
- Read the code being tested
- Understand what's expected vs actual

### 4.2 Determine Fix Type

| Issue | Action |
|-------|--------|
| Test is wrong | Fix the test |
| Code is wrong | Fix the code |
| Setup issue | Fix test setup/fixtures |
| Environment issue | Note for user |

### 4.3 Apply Fix

Use Edit tool to fix the test or code.

### 4.4 Rerun Single Test

```bash
# Verify fix works
docker compose exec -u1000 starship_server ./vendor/bin/phpunit --filter=testMethodName tests/Path/ToTest.php
```

### 4.5 Mark Fixed

Update todo: "Fix {TestName}" → completed

---

## Step 5: Rerun Batch

**After fixing all failures in batch:**

```bash
# Rerun entire batch
docker compose exec -u1000 starship_server ./vendor/bin/phpunit --testsuite=unit
```

**If still failures:** Return to Step 4
**If all pass:** Mark batch complete, proceed to next batch

---

## Step 6: Next Batch

**Update TodoWrite:**
- Current batch → completed
- Add next batch todo: "Run batch {N+1}"

**Repeat Steps 2-5 for each batch.**

---

## Step 7: Full Suite Verification

**After all batches pass individually:**

```bash
# Run complete test suite
docker compose exec -u1000 starship_server ./vendor/bin/phpunit
```

**Present results:**

```markdown
## Full Test Suite Results

**Status:** {PASS/FAIL}

| Metric | Value |
|--------|-------|
| Total Tests | {N} |
| Passed | {N} |
| Failed | {N} |
| Time | {X}s |

### Batches Completed
- [x] Batch 1: Unit ({N} tests)
- [x] Batch 2: Feature ({N} tests)
- [x] Batch 3: Functional ({N} tests)
- [x] Batch 4: Acceptance ({N} tests)

### Fixes Applied
- {file}: {what was fixed}
- {file}: {what was fixed}
```

---

## Step 8: Ask About Another Run

```javascript
AskUserQuestion({
  questions: [{
    question: "All tests passing! Would you like to run the full suite again to confirm?",
    header: "Verify",
    multiSelect: false,
    options: [
      {label: "Run full suite again", description: "One more complete run to confirm everything passes"},
      {label: "Done", description: "Tests are passing, we're done"}
    ]
  }]
})
```

**If another run:** Go back to Step 7
**If done:** Present final summary

---

## Final Summary

```markdown
## Batch Test Run Complete

### Summary
- **Batches run:** {N}
- **Total tests:** {N}
- **All passing:** Yes

### Fixes Applied ({count})

| File | Change |
|------|--------|
| {file} | {description} |

### Test Health
- Unit: {N} tests ✓
- Feature: {N} tests ✓
- Functional: {N} tests ✓
- Acceptance: {N} tests ✓
```

---

## Key Principles

### Batch for Manageability
- Don't run everything at once
- Fix as you go
- Smaller batches = faster feedback

### Fix Before Proceeding
- Don't accumulate failures
- Each batch should be green before next
- Rerun to confirm fixes

### Track Everything
- Use TodoWrite for each failing test
- Record what was fixed
- Final summary shows all changes
