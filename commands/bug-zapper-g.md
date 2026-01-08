---
description: Hunt for actual bugs - traces dependencies, verifies existence, finds type mismatches (global)
---

# Bug Zapper

Hunt for **actual bugs** by tracing dependencies and verifying correctness.

**This is NOT about:** architecture, standards, style, or requirements.
**This IS about:** Will this code crash? Do things exist? Do types match?

---

## STOP - MANDATORY FIRST ACTION

**YOU MUST CALL TodoWrite AND Bash RIGHT NOW before reading any other files.**

```javascript
TodoWrite({
  todos: [
    {content: "Detect context (run detect-mode.sh)", status: "in_progress", activeForm: "Detecting context"},
    {content: "Get user approval to proceed", status: "pending", activeForm: "Getting approval"},
    {content: "Load review history (check for rejected suggestions)", status: "pending", activeForm: "Loading review history"},
    {content: "Gather full context (files, dependencies)", status: "pending", activeForm: "Gathering full context"},
    {content: "Phase 1: Dependency chain analysis", status: "pending", activeForm: "Tracing dependencies"},
    {content: "Phase 2: Existence verification", status: "pending", activeForm: "Verifying existence"},
    {content: "Phase 3: Type mismatch detection", status: "pending", activeForm: "Checking type alignment"},
    {content: "Phase 4: Null safety analysis", status: "pending", activeForm: "Analyzing null safety"},
    {content: "Phase 5: Logic error detection", status: "pending", activeForm: "Detecting logic errors"},
    {content: "Phase 6: Resource & state bugs", status: "pending", activeForm: "Checking resource handling"},
    {content: "Phase 7: Copy-paste bug detection", status: "pending", activeForm: "Finding copy-paste bugs"},
    {content: "Generate bug report", status: "pending", activeForm: "Generating bug report"}
  ]
})
```

```bash
~/.claude/lib/detect-mode.sh --pretty
```

**CALL BOTH TOOLS NOW. Do not read any other files first.**

---

## Step 1: Quick Context

After detection script runs, present results as a table:

| Field | Value |
|-------|-------|
| Branch | [branch name] |
| Issue Key | [if any] |
| Task Folder | [if any] |
| Commits Ahead | [N] |
| Uncommitted Changes | [N] |

**Mark todo complete: "Detect context"**

---

## Step 2: Get Approval

**MANDATORY: Use AskUserQuestion before proceeding:**

```javascript
AskUserQuestion({
  questions: [{
    question: "Ready to run Bug Zapper on your changes?",
    header: "Confirm",
    multiSelect: false,
    options: [
      {label: "Yes, hunt for bugs", description: "Analyze all changes for potential bugs"},
      {label: "Only specific files", description: "I'll specify which files to analyze"},
      {label: "Cancel", description: "Don't run bug analysis"}
    ]
  }]
})
```

If "Only specific files": Ask for file paths, then proceed with those only.
If "Cancel": Stop here.

**Mark todo complete: "Get user approval"**

---

## Step 3: Load Review History

**CRITICAL: Check for previously rejected suggestions before hunting.**

### 3.1 Find Review Log

```bash
# Find task folder and review log
TASK_FOLDER=$(find "$PROJECT_TASK_DOCS_DIR" -type d -name "${ISSUE_KEY}*" 2>/dev/null | head -1)
REVIEW_FILE="$TASK_FOLDER/logs/review.md"

if [ -f "$REVIEW_FILE" ]; then
  echo "=== PREVIOUS REVIEW DECISIONS ==="
  cat "$REVIEW_FILE"
  echo "=== END PREVIOUS DECISIONS ==="
else
  echo "No previous review history found."
fi
```

### 3.2 Extract Rejected Suggestions

From the review log, build a list of **REJECTED** suggestions:

| # | Suggestion | Category | Reason Rejected | File:Line |
|---|------------|----------|-----------------|-----------|
| 1 | [title] | [bug type] | [reason] | [location] |

**Store this list - you MUST check against it during all phases.**

### 3.3 Duplicate Handling Rules

| If your finding... | Then... |
|--------------------|---------|
| Same as past REJECTED, same context | **SKIP** - don't report again |
| Same as past REJECTED, context changed | **RE-EVALUATE** - note why context matters |
| Same as past ACCEPTED (fixed) | **VERIFY** - confirm it was actually fixed |
| Similar to past decision | **REFERENCE** - maintain consistency |
| Completely new | **REPORT** - proceed normally |

**Mark todo complete: "Load review history"**

---

## Step 4: Gather Full Context

{{MODULE: ~/.claude/modules/shared/full-context.md}}

**Use "For Code Review Mode" section.**

Additionally, for Bug Zapper specifically:

### 3.1 Get All Changed Files

```bash
# Committed changes vs base
git diff --name-only $PROJECT_BASE_BRANCH...HEAD

# Uncommitted changes
git diff --name-only

# Untracked files
git ls-files --others --exclude-standard
```

### 3.2 Categorize Files by Type

| Category | Files |
|----------|-------|
| Models | [list] |
| Services | [list] |
| Controllers | [list] |
| Repositories | [list] |
| Jobs/Commands | [list] |
| Events/Listeners | [list] |
| Tests | [list] |
| Other | [list] |

### 3.3 Build Dependency Map

For each changed file, note:
- What it imports/uses
- What imports/uses it

**Mark todo complete: "Gather full context"**

---

## Phase 1: Dependency Chain Analysis

**For EACH changed file, complete this checklist:**

### 1.1 Trace UP (What does this file depend on?)

- [ ] List all `use` statements / imports
- [ ] For each imported class:
  - [ ] Verify class file exists
  - [ ] Verify class is autoloadable
  - [ ] Verify namespace matches file path
- [ ] For each imported method/function:
  - [ ] Verify it exists on the class
  - [ ] Verify it's public/accessible
- [ ] Check for circular dependencies

### 1.2 Trace DOWN (What depends on this file?)

```bash
# Find all usages of changed class
grep -rn "use.*ClassName\|new ClassName\|ClassName::" --include="*.php" .
```

- [ ] List all files that import this class
- [ ] For each caller:
  - [ ] Check if method signature changes break them
  - [ ] Check if return type changes break them
  - [ ] Check if removed methods are still called

### 1.3 Document Findings

| File | Depends On | Used By | Issues |
|------|------------|---------|--------|
| [file] | [list] | [list] | [any] |

**Mark todo complete: "Phase 1"**

---

## Phase 2: Existence Verification

**Complete this checklist for ALL references:**

### 2.1 Class Existence

For every `new ClassName()`:
- [ ] Search: `class ClassName`
- [ ] Verify file exists and is autoloadable
- [ ] Check constructor parameters match

For every `ClassName::method()`:
- [ ] Search: `class ClassName`
- [ ] Search: `function method` in that class
- [ ] Verify method is static

### 2.2 Method Existence

For every `$obj->method()`:
- [ ] Trace `$obj` to its type/class
- [ ] Search: `function method` in that class
- [ ] Check parent classes if not found
- [ ] Check traits if not found
- [ ] Verify method is public

### 2.3 Property Existence

For every `$obj->property`:
- [ ] Trace `$obj` to its type/class
- [ ] Search: `$property` or `protected $property` or `public $property`
- [ ] Check if it's a magic property (__get)
- [ ] Check if it's a relation (Laravel models)

### 2.4 Interface Compliance

For every `class X implements Y`:
- [ ] List all methods required by interface Y
- [ ] Verify each method exists in class X
- [ ] Verify signatures match exactly

### 2.5 Abstract Method Implementation

For every `class X extends AbstractY`:
- [ ] List all abstract methods in AbstractY
- [ ] Verify each is implemented in X
- [ ] Verify signatures match

### 2.6 Configuration & Constants

For every `config('key')`:
- [ ] Search config files for that key
- [ ] Verify key path is valid

For every `env('VAR')`:
- [ ] Check `.env.example` for VAR
- [ ] Verify default provided

For every `CONSTANT`:
- [ ] Search for `const CONSTANT` or `define('CONSTANT'`

### 2.7 Summary Table

| Reference | Type | Exists? | Location | Issue |
|-----------|------|---------|----------|-------|
| [ref] | class/method/prop | Y/N | file:line | [desc] |

**Mark todo complete: "Phase 2"**

---

## Phase 3: Type Mismatch Detection

**Complete this checklist for ALL type boundaries:**

### 3.1 Parameter Type Checking

For every function/method call:
- [ ] Get the function signature (parameter types)
- [ ] Trace the type of each argument being passed
- [ ] Compare: Does argument type match parameter type?
- [ ] Check nullable: Is `?Type` passed to `Type`?

```php
// Check this pattern:
function process(string $data, int $count): void
$service->process($variable, $other);
// Trace: What type is $variable? What type is $other?
```

### 3.2 Return Type Checking

For every function/method:
- [ ] Note declared return type
- [ ] Find all `return` statements
- [ ] Verify each return value matches declared type
- [ ] Check: Does `void` method have any returns with values?

### 3.3 Assignment Type Checking

For typed properties:
- [ ] Note the declared type
- [ ] Find all assignments to that property
- [ ] Verify each assignment is compatible

### 3.4 Generic/Collection Type Checking

For generic types (`Collection<User>`, `array<string, int>`):
- [ ] Verify items added match the generic type
- [ ] Verify items retrieved are used correctly

### 3.5 Cross-Boundary Types

At API boundaries:
- [ ] Request data matches expected types
- [ ] Response data matches declared return type
- [ ] Serialization/deserialization preserves types

### 3.6 Summary Table

| Location | Expected | Actual | Match? | Issue |
|----------|----------|--------|--------|-------|
| file:line | Type | Type | Y/N | [desc] |

**Mark todo complete: "Phase 3"**

---

## Phase 4: Null Safety Analysis

**Complete this checklist for ALL nullable values:**

### 4.1 Nullable Return Values

Find all uses of methods that return nullable:
- [ ] `find()` - returns `?Model`
- [ ] `first()` - returns `?Model`
- [ ] `firstWhere()` - returns `?Model`
- [ ] Any method with `?Type` return

For each usage:
- [ ] Is null checked before access? (`if ($x)`, `$x ?? default`, `$x?->`)
- [ ] Is `OrFail` variant used instead?
- [ ] Is null a valid case that's handled?

### 4.2 Optional Relations

For Laravel models:
- [ ] List all optional relations (belongsTo, hasOne without constraint)
- [ ] Find all accesses to those relations
- [ ] Verify null is checked before nested access

```php
// BAD: profile might be null
$user->profile->avatar;

// GOOD: null-safe operator
$user->profile?->avatar;

// GOOD: explicit check
$user->profile ? $user->profile->avatar : null;
```

### 4.3 Chained Method Calls

Find patterns like `$a->b()->c()->d()`:
- [ ] Can any method in chain return null?
- [ ] Is null-safe operator used where needed?

### 4.4 Array Key Access

For array access `$arr['key']`:
- [ ] Is key guaranteed to exist?
- [ ] Is `??` used for default?
- [ ] Is `isset()` or `array_key_exists()` checked first?

### 4.5 Optional Parameters

For parameters with default null:
- [ ] Is null checked before use in method body?
- [ ] Is null a valid flow or an error case?

### 4.6 Summary Table

| Location | Nullable Source | Checked? | Issue |
|----------|-----------------|----------|-------|
| file:line | find()/relation/etc | Y/N | [desc] |

**Mark todo complete: "Phase 4"**

---

## Phase 5: Logic Error Detection

**Complete this checklist for ALL logic patterns:**

### 5.1 Comparison Operators

Search for potential issues:
- [ ] `if ($x = value)` - assignment instead of comparison?
- [ ] `==` vs `===` - identity vs equality correct?
- [ ] Float comparisons - using epsilon?
- [ ] String comparisons - case sensitivity correct?
- [ ] Object comparisons - reference vs value intended?

### 5.2 Boolean Logic

Check complex conditions:
- [ ] Precedence correct? (need parentheses?)
- [ ] De Morgan's law applied correctly?
- [ ] Short-circuit evaluation side effects?
- [ ] Double negation simplified?

### 5.3 Loop Boundaries

For every loop:
- [ ] `<` vs `<=` correct for array bounds?
- [ ] Off-by-one in start index?
- [ ] Off-by-one in end index?
- [ ] Empty collection handled?

### 5.4 Switch/Match Statements

For every switch/match:
- [ ] All enum cases covered?
- [ ] Default case present?
- [ ] Fall-through intentional and documented?
- [ ] Break statements present where needed?

### 5.5 Dead/Unreachable Code

Search for:
- [ ] Code after `return`, `throw`, `exit`, `die`
- [ ] Conditions that are always true/false
- [ ] Else branches that can never execute
- [ ] Catch blocks for impossible exceptions

### 5.6 Edge Cases

For each algorithm/logic:
- [ ] Empty input handled?
- [ ] Single item handled?
- [ ] Max/min values handled?
- [ ] Negative numbers handled (if applicable)?
- [ ] Zero handled?

### 5.7 Summary Table

| Location | Pattern | Issue | Severity |
|----------|---------|-------|----------|
| file:line | [what] | [problem] | CRIT/MAJ/MIN |

**Mark todo complete: "Phase 5"**

---

## Phase 6: Resource & State Bugs

**Complete this checklist for ALL resources:**

### 6.1 File Handles

For every file operation:
- [ ] `fopen()` has matching `fclose()`?
- [ ] Close happens in all paths (including exceptions)?
- [ ] Using try-finally or context manager?

### 6.2 Database Connections/Transactions

For database operations:
- [ ] Transactions have commit AND rollback?
- [ ] All paths end transaction?
- [ ] Nested transactions use savepoints?
- [ ] Connections released after use?

### 6.3 Locks

For any locking:
- [ ] Lock released in all paths?
- [ ] Timeout configured?
- [ ] Deadlock potential (multiple locks)?

### 6.4 External Connections

For HTTP/API/Socket connections:
- [ ] Connection closed after use?
- [ ] Timeout configured?
- [ ] Error response handled?

### 6.5 State Consistency

For stateful operations:
- [ ] Object valid after all method calls?
- [ ] Partial state on error prevented?
- [ ] Events fired after state change complete?
- [ ] Caches invalidated when data changes?

### 6.6 Queue Job Safety

For queued jobs:
- [ ] Job idempotent (safe to retry)?
- [ ] Failure handled gracefully?
- [ ] Timeout configured?
- [ ] State changes atomic?

### 6.7 Summary Table

| Location | Resource | Acquired | Released | Issue |
|----------|----------|----------|----------|-------|
| file:line | [type] | line:N | line:N/MISSING | [desc] |

**Mark todo complete: "Phase 6"**

---

## Phase 7: Copy-Paste Bug Detection

**Complete this checklist for duplicate patterns:**

### 7.1 Similar Code Blocks

Find similar code blocks in changed files:
- [ ] Nearly identical code with minor differences
- [ ] Same structure, different variables
- [ ] Similar method calls in sequence

For each similar block:
- [ ] Are all differences intentional?
- [ ] Is there a "9 of 10 updated" pattern?
- [ ] Should this be refactored? (note only, not a bug)

### 7.2 Variable Name Mismatches

Look for:
- [ ] Variable names that don't match context
- [ ] Similar variable names used interchangeably
- [ ] Method called on wrong object

```php
// Suspicious pattern:
$userA = $this->getUser($idA);
$userB = $this->getUser($idB);
$this->process($userA);  // Should this be $userB?
$this->notify($userA);   // Both use $userA - intentional?
```

### 7.3 Constant/Enum Confusion

Look for:
- [ ] Similar constants used (STATUS_ACTIVE vs STATUS_ENABLED)
- [ ] Magic strings that should be constants
- [ ] Inconsistent constant usage

### 7.4 Import Errors

Check for:
- [ ] Wrong class imported (similar names)
- [ ] Old import not updated after refactor
- [ ] Unused imports (possible sign of incomplete change)

### 7.5 Summary Table

| Location | Pattern | Suspicious Element | Likely Bug? |
|----------|---------|-------------------|-------------|
| file:line | [description] | [what's wrong] | Y/N/MAYBE |

**Mark todo complete: "Phase 7"**

---

## Generate Bug Report

**Output to CHAT (no files created):**

```markdown
# Bug Zapper Report

## Executive Summary

| Metric | Value |
|--------|-------|
| Files Analyzed | [N] |
| Total Bugs Found | [N] |
| Critical | [N] |
| Major | [N] |
| Minor | [N] |
| Skipped (previously rejected) | [N] |

**Verdict:** [SAFE TO MERGE | FIX CRITICAL FIRST | NEEDS REVIEW | BLOCKED]

---

## Bugs by Category

| Category | Critical | Major | Minor | Total |
|----------|----------|-------|-------|-------|
| Existence | | | | |
| Type Mismatch | | | | |
| Null Safety | | | | |
| Logic Error | | | | |
| Resource/State | | | | |
| Copy-Paste | | | | |
| **TOTAL** | | | | |

---

## Critical Bugs (Must Fix)

### BUG-001: [Title]
**Severity:** CRITICAL
**Category:** [type]
**Location:** `file/path:line`

**Problem:**
[Explain what's wrong]

**Impact:**
[What will happen - crash, data corruption, etc.]

**Evidence:**
```{lang}
[relevant code]
```

**Fix:**
```{lang}
[corrected code]
```

---

[Repeat for each critical bug]

---

## Major Bugs (Should Fix)

[Same format as critical]

---

## Minor Bugs (Consider Fixing)

[Same format, can be more condensed]

---

## Skipped (Previously Rejected)

**These potential issues were found but NOT reported because they were previously raised and rejected:**

| # | Issue | Category | Previous Review | Rejection Reason |
|---|-------|----------|-----------------|------------------|
| 1 | [title] | [type] | Review #N (date) | [brief reason] |

**Note:** If context has significantly changed since the rejection, these may be re-evaluated.

---

## Dependency Chain Issues

### Broken Dependencies
[List any missing classes/methods/properties]

### Risky Signature Changes
[List changes that might break existing callers]

---

## Files Analyzed

| File | Category | Bugs | Status |
|------|----------|------|--------|
| [path] | [type] | [N] | CLEAN/ISSUES |

---

## Recommendations

1. [First priority action]
2. [Second priority action]
3. [etc.]
```

**Mark todo complete: "Generate bug report"**

---

## Execution Constraints

**You MUST:**
- Complete EVERY checklist item (mark with [x] or note N/A)
- Focus ONLY on bugs (not style, architecture, standards)
- Check review history BEFORE reporting any bug
- Skip bugs that were previously rejected (unless context changed)
- Trace dependency chains up AND down
- Verify existence of every referenced class/method
- Check null safety for all nullable returns
- Provide specific file:line references
- Give code examples for fixes
- Be thorough - this is a deep bug hunt

**You MUST NOT:**
- Re-raise previously rejected suggestions (list in "Skipped" section instead)
- Comment on code style
- Check architecture compliance
- Verify requirements
- Make any code changes
- Run tests (this is static analysis only)
- Skip any checklist items

---

## Reference

{{MODULE: ~/.claude/modules/code-review/bug-categories.md}}

---

Begin bug hunting now.
