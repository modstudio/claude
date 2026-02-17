# Module: leanness-review

## Purpose
Detect over-engineering, unnecessary abstractions, and premature optimization.

## Scope
CODE-REVIEW - Used by arch-review workflow

## Mode
READ-ONLY

---

## Core Principle

> The right amount of complexity is the minimum needed for the current task.
> Three similar lines of code is better than a premature abstraction.

---

## Inputs
- Changed files from context gathering
- Existing codebase patterns for comparison

## Instructions

### Step 1: Abstraction Audit

**For each new abstraction (interface, abstract class, factory, etc.), ask:**

1. **Is there more than one implementation?**
   - NO → Flag as potential over-engineering
   - YES → Check if implementations are genuinely different

2. **Is this a public API boundary?**
   - NO → Concrete class is usually fine
   - YES → Interface may be justified

3. **Is the abstraction hiding meaningful complexity?**
   - NO → It's just indirection
   - YES → May be warranted

**Detection patterns:**

```bash
# Find interfaces with likely single implementation
for iface in $(grep -l "^interface " app/**/*.php); do
  name=$(basename "$iface" .php)
  impls=$(grep -rl "implements.*$name" app/ | wc -l)
  [ "$impls" -eq 1 ] && echo "Single impl: $iface"
done
```

```bash
# Find abstract classes with single concrete
for abstract in $(grep -l "^abstract class" app/**/*.php); do
  name=$(basename "$abstract" .php)
  extends=$(grep -rl "extends.*$name" app/ | wc -l)
  [ "$extends" -eq 1 ] && echo "Single extend: $abstract"
done
```

---

### Step 2: Indirection Audit

**Signs of unnecessary indirection:**

| Pattern | Likely Unnecessary If |
|---------|----------------------|
| Service → Repository | Service just calls `$repo->find()` with no logic |
| Handler → Service | Handler just delegates with no transformation |
| DTO → Model | DTO has same fields, no validation/transformation |
| Event → Listener | Could be direct method call, not async/cross-domain |
| Facade → Class | No testing benefit, just wraps static calls |

**Check for pass-through methods:**

```php
// OVER-ENGINEERED: Pass-through with no value
public function getUser(int $id): User
{
    return $this->userRepository->find($id);  // Just delegates
}

// LEAN: Direct usage
$user = $userRepository->find($id);
```

**Flag methods that:**
- Have 1-2 lines that just call another service
- Add no error handling, validation, or transformation
- Could be replaced by direct caller usage

---

### Step 3: Feature Flag / Backwards Compatibility Audit

**Unnecessary complexity patterns:**

```php
// OVER-ENGINEERED: Renaming unused to suppress warnings
$_unusedVar = $something;

// LEAN: Just remove it
// (no code)
```

```php
// OVER-ENGINEERED: Re-export for backwards compatibility
// In ServiceProvider
$this->app->alias(NewService::class, 'old.service.name');

// LEAN: Update the usages
// Change callers to use new name
```

```php
// OVER-ENGINEERED: Comment tombstones
// REMOVED: Old implementation was here
// TODO: Remove this after next release

// LEAN: Just delete it
// (no code)
```

**Check for:**
- [ ] Variables prefixed with `_` that are never used elsewhere
- [ ] Alias/facade registrations for renamed services
- [ ] Comments explaining removed code
- [ ] "Deprecated" annotations with no removal timeline

---

### Step 4: Speculative Generality Audit

**Signs of "might need this later" code:**

| Pattern | Question to Ask |
|---------|-----------------|
| Unused method parameters | Why accept what you don't use? |
| Config for internal behavior | Who would configure this? |
| Plugin/hook architecture | Is there a second plugin? |
| Strategy pattern | Is there a second strategy? |
| Empty interface methods | Will anything implement these? |

**Detection:**

```bash
# Find unused parameters (PHP)
# Look for functions where $param is defined but never used in body
grep -n "function.*\$[a-z]" changed_files | while read line; do
  # Check if parameter is used in function body
done
```

```bash
# Find suspiciously configurable code
grep -n "config\|option\|setting\|flag" changed_files
```

---

### Step 5: Duplication vs Abstraction Decision

**When is duplication OK?**

| Lines Duplicated | Action |
|------------------|--------|
| 2-3 lines, 2 places | Keep duplicated |
| 2-3 lines, 3+ places | Consider extracting |
| 5+ lines, 2 places | Consider extracting |
| Different contexts | Keep duplicated (accidental similarity) |

**Wrong reasons to abstract:**
- "DRY principle" (not a law, it's guidance)
- "Might need to change it in one place" (YAGNI)
- "Looks cleaner" (readability is subjective)

**Right reasons to abstract:**
- Actual bug was caused by inconsistent copies
- Business rule that must be enforced uniformly
- Complex logic that needs thorough testing

---

### Step 6: Complexity Justification

**For each piece of complex code found, determine if it's justified:**

| Complexity Type | Justified When | Not Justified When |
|-----------------|----------------|-------------------|
| Multiple classes | Genuine responsibilities | Artificial separation |
| Interface | Public API or >1 impl | Internal single impl |
| Factory | Complex construction | Simple `new` works |
| Event system | Async or cross-domain | Same-module sync call |
| Strategy pattern | Runtime selection | Compile-time known |
| Decorator | Composable features | One-time extension |

---

## Output Format

```markdown
### Leanness Findings

#### REMOVE (Unnecessary Complexity)

**[L-001]:** Single-implementation interface
- **Location:** `app/Contracts/SomeInterface.php`
- **Pattern:** Interface with only one implementation
- **Implementation:** `app/Services/SomeService.php`
- **Recommendation:** Delete interface, use concrete class directly
- **Impact:** Reduces indirection, simplifies DI container

**[L-002]:** Pass-through service method
- **Location:** `app/Services/UserService.php:45`
- **Pattern:** Method that only delegates to repository
- **Current:**
```php
public function find(int $id): User
{
    return $this->repo->find($id);
}
```
- **Recommendation:** Callers should use repository directly
- **Impact:** Removes unnecessary layer

#### SIMPLIFY (Could Be Leaner)

[Same format with improvement suggestions]

#### JUSTIFIED (Complexity Warranted)

| Location | Complexity | Justification |
|----------|------------|---------------|
| `file:line` | [type] | [why needed] |
```

---

## Leanness Score

Calculate based on findings:

| Score | Criteria |
|-------|----------|
| **LEAN** | 0 REMOVE, ≤2 SIMPLIFY |
| **ACCEPTABLE** | ≤2 REMOVE, ≤5 SIMPLIFY |
| **OVER-ENGINEERED** | >2 REMOVE or >5 SIMPLIFY |

---

## Outputs

- List of unnecessary abstractions
- List of pass-through indirections
- List of speculative code
- Leanness score
- Concrete removal/simplification recommendations

---

**End of Module**
