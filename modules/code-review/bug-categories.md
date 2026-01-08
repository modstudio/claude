# Bug Categories Reference

Quick reference for bug types detected by Bug Zapper mode.

---

## Category 1: Existence Bugs

**What:** Things referenced that don't actually exist.

| Bug Type | Pattern | Example |
|----------|---------|---------|
| Missing Class | `new ClassName` | Class not defined or autoloadable |
| Missing Method | `$obj->method()` | Method doesn't exist on class |
| Missing Static | `Class::method()` | Static method doesn't exist |
| Missing Property | `$obj->prop` | Property not declared |
| Missing Config | `config('key')` | Config key doesn't exist |
| Missing Env | `env('VAR')` | Env var not defined |
| Missing Trait Method | `$this->traitMethod()` | Method not in any trait |
| Missing Interface Method | `implements Interface` | Required method missing |

**Detection:** Search codebase for definition of referenced item.

---

## Category 2: Type Mismatch Bugs

**What:** Types don't align between definition and usage.

| Bug Type | Pattern | Example |
|----------|---------|---------|
| Parameter Type | `fn(string $x)` called with `int` | Wrong type passed |
| Return Type | `fn(): User` returns `null` | Nullable not declared |
| Assignment Type | `int $x = "string"` | Incompatible assignment |
| Generic Type | `Collection<User>` gets `Order` | Wrong generic type |
| Array Type | `array` vs `Collection` | Iterable mismatch |
| Union Type | `string\|int` handled as `string` | Missing type case |

**Detection:** Trace variable from definition to usage, check type at each point.

---

## Category 3: Null Safety Bugs

**What:** Null/undefined values accessed without checking.

| Bug Type | Pattern | Example |
|----------|---------|---------|
| Nullable Return | `find()->name` | find() returns ?Model |
| Optional Relation | `$user->profile->x` | profile might be null |
| First/Get | `->first()->id` | first() returns null on empty |
| Optional Param | `fn($x = null)` | $x used without check |
| Chained Null | `$a->b->c->d` | Any in chain could be null |
| Array Access | `$arr['key']` | Key might not exist |

**Dangerous Methods:**
- `find()`, `findOrFail()`, `first()`, `firstOrFail()`
- `get()` on single item expectations
- Optional relation accessors
- `array_get()`, `data_get()` without defaults

**Detection:** Find nullable returns, trace to usage, check for null guards.

---

## Category 4: Logic Bugs

**What:** Incorrect program logic.

| Bug Type | Pattern | Example |
|----------|---------|---------|
| Assignment vs Compare | `if ($x = 1)` | Should be `==` |
| Identity vs Equality | `$a == $b` | Objects need `===` |
| Off-by-One | `for ($i <= len)` | Should be `<` |
| Boundary | `array[$length]` | Index out of bounds |
| Negation | `!$x && !$y` | De Morgan's confusion |
| Precedence | `$a \|\| $b && $c` | Needs parentheses |
| Float Compare | `$f == 0.1` | Float precision issue |
| Dead Code | `return; $x = 1;` | Unreachable statement |

**Detection:** Pattern matching on conditions and loops.

---

## Category 5: Resource Bugs

**What:** Resources not properly managed.

| Bug Type | Pattern | Example |
|----------|---------|---------|
| File Leak | `fopen()` without `fclose()` | Handle not closed |
| Connection Leak | DB connection not released | Exhausts pool |
| Lock Leak | Lock acquired, not released | Deadlock risk |
| Stream Leak | Stream not closed | Memory/handle leak |
| Transaction Leak | Begin without commit/rollback | Hanging transaction |

**Detection:** Track resource acquisition to release, ensure all paths covered.

---

## Category 6: Copy-Paste Bugs

**What:** Errors from copying similar code.

| Bug Type | Pattern | Example |
|----------|---------|---------|
| Wrong Variable | `$userA` used where `$userB` expected | 9/10 updated |
| Wrong Object | `$orderService->send($user)` | Should be $customer |
| Wrong Method | `create()` but meant `update()` | Similar name mix-up |
| Incomplete Update | Most refs changed, one missed | Stale reference |
| Wrong Constant | `STATUS_ACTIVE` vs `STATUS_ENABLED` | Similar constant |

**Detection:** Find similar code blocks, check for subtle differences.

---

## Category 7: Concurrency Bugs

**What:** Issues with parallel/async execution.

| Bug Type | Pattern | Example |
|----------|---------|---------|
| Race Condition | Read-modify-write without lock | Lost update |
| Deadlock | Circular lock dependency | System hangs |
| Atomicity | Multi-step assumed atomic | Partial state |
| Order Violation | Depends on execution order | Random failures |
| Stale Read | Cached value used after change | Inconsistent state |

**Detection:** Identify shared mutable state, check for synchronization.

---

## Severity Classification

### CRITICAL (Will crash or corrupt data)
- Missing class/method (immediate crash)
- Null dereference on required value
- Type error causing exception
- Resource leak causing system failure
- Data corruption from race condition

### MAJOR (Likely to cause issues)
- Null not handled but rare path
- Type mismatch with implicit conversion
- Logic error affecting output
- Resource leak in normal flow
- Off-by-one in common case

### MINOR (Potential issues)
- Defensive null check missing
- Type inconsistency (works but wrong)
- Dead code
- Copy-paste smell (might be intentional)
- Edge case not handled

---

## Quick Detection Commands

```bash
# Find nullable method calls without checks
grep -rn "->find\|->first\|->get" --include="*.php" . | grep -v "if\|??\|?->\|OrFail"

# Find assignment in condition
grep -rn "if.*[^!=<>]=[^=]" --include="*.php" .

# Find chained method calls (null risk)
grep -rn "->.*->.*->" --include="*.php" .

# Find off-by-one candidates
grep -rn "for.*<=" --include="*.php" .

# Find dead code after return
grep -A1 -rn "return\|throw\|exit" --include="*.php" . | grep -v "^--$"

# Find empty catch blocks
grep -A2 -rn "catch.*{" --include="*.php" . | grep -B1 "^[[:space:]]*}$"
```

---

**End of Reference**
