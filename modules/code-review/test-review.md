# Module: test-review

## Purpose
Review test quality and execute tests.

## Scope
CODE-REVIEW - Used by all review modes

## Mode
READ-ONLY (review) + BASH (test execution)

---

## Inputs
- Test files from changed files list
- Standards from `$PROJECT_STANDARDS_DIR/30-testing.md`

## Instructions

### Step 1: Find Test Files

```bash
git status --short | grep -E "test|Test"
git diff ${PROJECT_BASE_BRANCH} --name-only | grep -E "test|Test"
```

### Step 2: Test Class Structure Review

For each test file, check:

- [ ] Class declared `final`
- [ ] Method names in `camelCase`
- [ ] Return type `void` on all test methods
- [ ] Uses `self::assertSame()` NOT `$this->assertSame()`
- [ ] Uses `createStub()` preferred over `createMock()`
- [ ] Never uses `createMock()` (always `createStub()` or `createConfiguredMock()`)

### Step 3: Test Quality Review

- [ ] Descriptive variable names (`$expectedResult`, not `$result1`)
- [ ] Covers happy path
- [ ] Covers error scenarios
- [ ] Uses fixtures from `tests/Fixtures/`
- [ ] Uses builders from `tests/ModelBuilders/`
- [ ] Meaningful test data (not just `'test'`)
- [ ] Data providers for multiple scenarios
- [ ] Precise assertions (verify business effects)

### Step 4: Test Coverage Check

**For each new/modified file WITHOUT tests, note:**
- File path
- What needs testing
- Suggested test file location
- Test type needed (Unit/Functional/Acceptance)

**Coverage requirements:**
- [ ] All new public methods have tests
- [ ] All new classes have tests
- [ ] Modified business logic has tests
- [ ] Edge cases covered

### Step 5: Execute Tests

**Run all affected test files:**
```bash
${PROJECT_TEST_CMD_UNIT} {test-file-path}
```

**Record for each test:**
- Test file name
- Number of tests
- Number of assertions
- Execution time
- Status (PASS/FAIL)
- Any failures/errors with details

---

## Output Format

### Test Results Table

```markdown
| Test File | Tests | Assertions | Time | Status |
|-----------|-------|------------|------|--------|
| FooTest | 9 | 10 | 0.5s | PASS |
| BarTest | 5 | 9 | 5.7s | PASS |
| **TOTAL** | **14** | **19** | **6.2s** | **ALL PASS** |
```

### Failed Test Format

```markdown
**Test:** `tests/Unit/FooTest.php::testBar`
**Error:** [error message]
**Cause:** [likely cause]
**Fix:** [how to resolve]
```

### Missing Tests Format

```markdown
**Missing Tests:**
| File | Needs Testing | Suggested Test | Type |
|------|---------------|----------------|------|
| `app/Services/Foo.php` | `process()` method | `tests/Unit/FooTest.php` | Unit |
```

---

## Outputs

```markdown
## Test Review

### Test Execution Results

| Test File | Tests | Assertions | Time | Status |
|-----------|-------|------------|------|--------|
| ... | ... | ... | ... | ... |
| **TOTAL** | **N** | **N** | **Ns** | **STATUS** |

### Test Quality Findings

#### MAJOR
[List or "None"]

#### MINOR
[List or "None"]

### Missing Test Coverage

[List files needing tests or "All new code has tests"]

### Failed Tests (if any)

[Details or "All tests passing"]
```

---

**End of Module**
