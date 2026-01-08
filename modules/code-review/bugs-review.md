# Module: bugs-review

## Purpose
Hunt for actual bugs by tracing dependencies, verifying existence, and finding logic errors.

## Scope
CODE-REVIEW - Bug hunting mode

## Mode
READ-ONLY

---

## Philosophy

This module is **NOT** about:
- Architecture compliance
- Code style or standards
- Requirements verification
- Test coverage

This module **IS** about:
- Will this code crash?
- Are all called methods/classes real?
- Do types match across boundaries?
- Are there logic errors waiting to happen?

---

## Instructions

### Phase 1: Dependency Chain Analysis

**For each changed file, trace UP and DOWN the dependency chain:**

#### 1.1 Imports & Dependencies (Trace UP)
- [ ] All imported classes/modules exist
- [ ] Imported methods actually exist on those classes
- [ ] No typos in import paths
- [ ] No circular dependencies that could cause issues

#### 1.2 Usages (Trace DOWN)
- [ ] Find all callers of changed methods
- [ ] Verify callers pass correct number of arguments
- [ ] Verify callers handle return type correctly
- [ ] Check if signature changes break callers

**Commands to use:**
```bash
# Find all references to a class/method
grep -r "ClassName" --include="*.php" --include="*.ts" --include="*.vue" .

# Check method signature
grep -n "function methodName" path/to/file

# Find usages
grep -rn "->methodName\|::methodName" --include="*.php" .
```

---

### Phase 2: Existence Verification

**Verify everything referenced actually exists:**

#### 2.1 Class & Method Existence
- [ ] All instantiated classes exist (`new ClassName`)
- [ ] All called static methods exist (`Class::method()`)
- [ ] All called instance methods exist (`$obj->method()`)
- [ ] All accessed properties exist
- [ ] All trait methods used actually exist in traits

#### 2.2 Interface & Contract Compliance
- [ ] Classes implementing interfaces have ALL required methods
- [ ] Method signatures match interface definitions exactly
- [ ] Abstract method implementations exist
- [ ] Parent class methods being called actually exist

#### 2.3 Configuration & Constants
- [ ] Referenced config keys exist
- [ ] Environment variables used are defined
- [ ] Constants referenced are defined
- [ ] Magic strings match actual values elsewhere

**Verification approach:**
```markdown
For each `new ClassName`:
1. Search for `class ClassName`
2. Verify file exists and is autoloadable
3. Check constructor signature matches

For each `$obj->method()`:
1. Trace $obj to its type
2. Search for `function method` in that class
3. Verify method is public
```

---

### Phase 3: Type Mismatch Detection

**Find places where types don't align:**

#### 3.1 Parameter Type Mismatches
- [ ] Arguments match parameter types
- [ ] Nullable parameters receive nullable-safe values
- [ ] Array types match (`array` vs `Collection` vs `array<string>`)
- [ ] Generic types align (`Builder<User>` passed to `Builder<Model>`)

#### 3.2 Return Type Mismatches
- [ ] Returned values match declared return type
- [ ] Void methods don't return values
- [ ] Nullable returns are handled by callers
- [ ] Mixed/union types handled correctly

#### 3.3 Assignment Type Mismatches
- [ ] Variables assigned compatible types
- [ ] Property types match assigned values
- [ ] Array element types consistent

**Common patterns to check:**
```php
// Wrong: passing int to string parameter
$service->process(123);  // but process(string $data)

// Wrong: not handling nullable return
$user = $repo->find($id);
$user->getName();  // find() returns ?User

// Wrong: array vs Collection mismatch
$this->items = collect($array);  // but items is typed as array
```

---

### Phase 4: Null Safety Analysis

**Find potential null pointer/reference errors:**

#### 4.1 Nullable Access Patterns
- [ ] Methods returning `?Type` - is null checked before use?
- [ ] `find()` / `first()` / `get()` results checked before access
- [ ] Optional parameters handled correctly
- [ ] Chained calls on potentially null objects

#### 4.2 Conditional Null Checks
- [ ] `if ($x)` followed by `$x->method()` - correct
- [ ] `$x->method()` without prior check - POTENTIAL BUG
- [ ] `$x ?? default` used appropriately
- [ ] Null coalescing assignment `??=` correct

**Dangerous patterns:**
```php
// BUG: find() returns ?User
$user = User::find($id);
$name = $user->name;  // will crash if not found

// BUG: first() returns ?Model
$order = $orders->first();
$total = $order->total;  // will crash if empty collection

// BUG: optional relation
$user->profile->avatar;  // profile might be null
```

---

### Phase 5: Logic Error Detection

**Find logic bugs and incorrect conditions:**

#### 5.1 Comparison Errors
- [ ] `==` vs `===` used correctly (identity vs equality)
- [ ] Floating point comparisons use epsilon
- [ ] String comparisons handle case correctly
- [ ] Array comparisons behave as expected
- [ ] Object comparisons are intentional

#### 5.2 Boolean Logic Errors
- [ ] De Morgan's law applied correctly
- [ ] Short-circuit evaluation side effects
- [ ] Negation errors (`!` applied correctly)
- [ ] Condition precedence correct (use parentheses)

#### 5.3 Boundary & Off-by-One Errors
- [ ] Loop bounds correct (`<` vs `<=`)
- [ ] Array index bounds (`length` vs `length-1`)
- [ ] Slice/substring bounds correct
- [ ] Pagination offset/limit correct

#### 5.4 Dead Code & Unreachable Paths
- [ ] Code after `return`, `throw`, `exit`
- [ ] Conditions that are always true/false
- [ ] Impossible else branches
- [ ] Catch blocks for exceptions that can't be thrown

**Common patterns:**
```php
// BUG: Off-by-one
for ($i = 0; $i <= count($arr); $i++) // should be <

// BUG: Wrong comparison
if ($status = 'active')  // assignment, not comparison

// BUG: Unreachable
return $result;
$this->cleanup();  // never executes
```

---

### Phase 6: Resource & State Bugs

**Find resource leaks and state management issues:**

#### 6.1 Resource Leaks
- [ ] File handles closed after use
- [ ] Database connections released
- [ ] Locks released in all paths (including exceptions)
- [ ] Streams closed
- [ ] External connections cleaned up

#### 6.2 State Consistency
- [ ] Object state valid after all method calls
- [ ] Transactions committed or rolled back
- [ ] Caches invalidated when data changes
- [ ] Events fired after state changes complete

#### 6.3 Concurrency Issues
- [ ] Shared mutable state protected
- [ ] Race conditions in async code
- [ ] Order-dependent operations properly sequenced
- [ ] Queue job idempotency

---

### Phase 7: Copy-Paste Error Detection

**Find bugs from copy-paste mistakes:**

#### 7.1 Duplicate Code Analysis
- [ ] Similar code blocks with subtle differences
- [ ] Variable names that don't match context
- [ ] "9 of 10 updated" patterns
- [ ] Inconsistent handling of similar cases

**Signs of copy-paste bugs:**
```php
// BUG: Forgot to update variable
$userA = $this->getUser($idA);
$userB = $this->getUser($idB);
$this->process($userA);  // should be $userB?

// BUG: Method called on wrong object
$orderService->createOrder($customer);
$orderService->sendConfirmation($user);  // should be $customer?
```

---

## Output Format

**For each bug found:**

```markdown
### BUG: [Short description]

**Severity:** CRITICAL | MAJOR | MINOR
**Type:** [existence | type-mismatch | null-safety | logic | resource | copy-paste]
**Location:** `file/path:line`

**The Problem:**
[Explain what's wrong]

**Why It's a Bug:**
[What will happen - crash, wrong result, data corruption]

**Evidence:**
[Show the code and trace the issue]

**Fix:**
```{language}
[corrected code]
```
```

---

## Output Summary

```markdown
## Bug Hunt Results

### Summary
- **CRITICAL bugs:** [N]
- **MAJOR bugs:** [N]
- **MINOR bugs:** [N]

### By Category
| Category | Count | Severity |
|----------|-------|----------|
| Existence | N | ... |
| Type Mismatch | N | ... |
| Null Safety | N | ... |
| Logic Error | N | ... |
| Resource | N | ... |
| Copy-Paste | N | ... |

### Dependency Chain Issues
[List any broken dependency chains found]

### Critical Bugs (Must Fix)
[Detailed list with fixes]

### Major Bugs (Should Fix)
[Detailed list with fixes]

### Minor Bugs (Consider Fixing)
[Detailed list with fixes]
```

---

**End of Module**
