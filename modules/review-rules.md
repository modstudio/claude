# Code Review Rules Module

**Module:** Shared Review Rules & Checklists
**Version:** 1.0.0

This module contains all review checklists shared between interactive and report workflows.

---

## Backend Architecture Rules (PHP)

### Models (`app/Models/*.php`, `app/Domains/*/Models/*.php`)
- [ ] UUIDs used for IDs where applicable
- [ ] Static constructors for complex creation
- [ ] Eloquent relationships marked `@internal only for Eloquent`
- [ ] Classes declared `final` or `abstract`
- [ ] `$fillable` array properly defined
- [ ] `$casts` defined for booleans, dates, custom types
- [ ] Getter methods have return types
- [ ] No business logic (just accessors/data methods)
- [ ] Follows organization data structure (internal vs customer tables)

### Services (`app/Services/*.php`, `app/Domains/*/Services/*.php`)
- [ ] Business logic in Command/Handler pattern (not in service methods)
- [ ] Uses DTOs for complex data (not raw arrays)
- [ ] All methods have type hints
- [ ] No database queries (delegated to repositories)
- [ ] Stateless where possible

### Handlers (`app/Domains/*/Commands/Handlers/*.php`)
- [ ] Single responsibility per handler
- [ ] Dependencies injected via constructor
- [ ] Handles exactly one command
- [ ] Returns appropriate value or void
- [ ] Uses repositories for data access

### Repositories (`app/Repositories/*.php`, `app/Domains/*/Repositories/*.php`)
- [ ] No business logic
- [ ] Query builders for complex queries
- [ ] Uses Criteria pattern for filters
- [ ] Readable queries (not over-optimized)
- [ ] No computed/raw SQL in model attributes

### Controllers (`app/Http/Controllers/*.php`)
- [ ] Thin (delegates to handlers/services)
- [ ] Uses FormRequests for validation
- [ ] Returns via ResponseFactory
- [ ] Multi-action where appropriate

### FormRequests (`app/Http/Requests/**/*.php`)
- [ ] All validation rules defined
- [ ] Uses custom validation rules when needed
- [ ] No business logic in authorize()

### Migrations (`database/migrations/*.php`)
- [ ] Timestamp format: `YYYY_MM_DD_HHMMSS`
- [ ] Descriptive names
- [ ] Both `up()` and `down()` methods
- [ ] Uses Schema facade
- [ ] Reversible (down() actually works)
- [ ] Table names in `snake_case`
- [ ] Columns: `id` (UUID first), timestamps last
- [ ] Comments on columns for clarity
- [ ] Data migrations separate from schema migrations

---

## Frontend Architecture Rules (Vue.js)

### Components (`resources/js/components/**/*.vue`)
- [ ] File names in PascalCase
- [ ] Component `name` in PascalCase
- [ ] Self-closing empty tags
- [ ] Template tags in PascalCase
- [ ] Imports use `@` alias
- [ ] Include `.vue` extension in imports

### Architecture Pattern (Feature-Dominant with Ad-Hoc UI Layer)
- [ ] Routes organized by feature domain
- [ ] Components reusable across features
- [ ] Composables extracted for shared logic
- [ ] Follows team's architectural pattern (not generic Vue best practices)

### API Clients (`resources/js/services/**/*ApiClient.js`)
- [ ] Components don't call axios directly
- [ ] Request/response handling centralized
- [ ] Error handling included

### State Management (Vuex)
- [ ] Only shared/cached/persistent UI state
- [ ] Mutations via `commit()` only
- [ ] Not used for local component state

---

## Vue 3 Readiness Rules

While still on Vue 2, ensure new code follows Vue 3 compatible patterns:

### Composition API Preparation
- [ ] **No new mixins** - use composable functions (`use*.js`) instead
  - ❌ `mixins: [myMixin]` → ✅ `const { data, method } = useMyComposable()`
- [ ] Avoid `this.$refs` for component communication - use props/events
- [ ] Business logic extracted to plain JS functions (not tied to `this`)
- [ ] Avoid complex `this` context dependencies
- [ ] Keep component options simple and separable (easier migration)

### Deprecated Vue 2 APIs (Removed in Vue 3)
- [ ] No `$on`, `$off`, `$once` - use mitt/tiny-emitter if event bus needed
- [ ] No filters `{{ value | filter }}` - use computed properties or methods
- [ ] No `$listeners` or `$attrs` implicit inheritance assumptions
- [ ] No `Vue.set()` / `Vue.delete()` - use spread operator or reassignment
- [ ] No `$scopedSlots` - use `$slots` unified API

### Template Syntax
- [ ] Use `v-slot:name` or `#name`, not `slot="name"` attribute
- [ ] `<template v-slot:default>` not `<template slot="default">`
- [ ] `key` on `v-for` children, not on `<template>` wrapper

### Component Patterns
- [ ] Explicit `emits` option for custom events (Vue 3 requires declaration)
- [ ] Local component imports preferred over global registration
- [ ] Props with explicit types and defaults

### Vuex → Pinia Migration Path
- [ ] Vuex modules kept simple and flat
- [ ] No deeply nested module structures
- [ ] Getters used for derived state
- [ ] Actions kept focused (maps to Pinia actions)
- [ ] Document state shape (helps Pinia migration)

### Vue 3 Severity Classification
- **BLOCKER:** N/A (Vue 2 code still works)
- **MAJOR:** New mixins, using removed APIs (`$on`, filters)
- **MINOR:** Old slot syntax, global registration
- **NIT:** Not using composable pattern for new shared logic

---

## Code Quality Rules

### Naming
- [ ] Precise, self-documenting names (no `product1`, `product2`)
- [ ] Booleans: `is*/has*/should*`
- [ ] Collections: plural; elements: singular
- [ ] Units in names: `*Seconds`, `*Dollars`, `*Meters`
- [ ] Intent-based: `$validPayload`, `$existingUser`

### Typing
- [ ] Scalar types declared everywhere possible
- [ ] Return types on all methods
- [ ] No `mixed` unless absolutely necessary
- [ ] Property types declared (PHP 7.4+)

### Comments
- [ ] Only when non-obvious
- [ ] PHPDoc for complex generics: `@return array<string, Product>`
- [ ] Links to business docs where relevant
- [ ] No commented-out code

### Code Metrics
- [ ] Functions ≤50 lines (guideline)
- [ ] Lines ≤170 characters (guideline)
- [ ] No forbidden functions: `dd`, `var_dump`, `echo`, `print_r`, `dump`
- [ ] No debug statements left in code
- [ ] PSR-12 compliance

---

## Correctness & Robustness Rules

### Logic Paths & Edge Cases
- [ ] All code paths covered (if/else, switch, early returns)
- [ ] Edge cases handled:
  - Empty arrays/collections
  - Null values
  - Zero and negative numbers
  - Boundary conditions (min/max values)
  - Empty strings
- [ ] Default values appropriate
- [ ] Fallback behavior defined

### Error Handling
- [ ] Exceptions properly caught and logged
- [ ] Error messages meaningful to developers
- [ ] User-facing errors appropriate
- [ ] Graceful degradation where applicable
- [ ] No silent failures
- [ ] Stack traces preserved when re-throwing

### Type Safety & Contracts
- [ ] Nullability handled correctly (`?Type` vs `Type`)
- [ ] Type contracts respected (method signatures)
- [ ] No unsafe type coercion
- [ ] Array type safety (`@param array<string, Product>`)
- [ ] Return types match documentation

### Concurrency & Async Patterns
- [ ] Race conditions considered
- [ ] Database transactions used for multi-step operations
- [ ] Locks used appropriately (Redis, database)
- [ ] Idempotency for retryable operations
- [ ] Queue job failures handled
- [ ] Event ordering considered

### Data Handling
- [ ] Timezone awareness in date operations
- [ ] DateTime objects used (not strings)
- [ ] Pagination bounds checked
- [ ] Large dataset handling (chunking, streaming)
- [ ] Memory usage considered for bulk operations
- [ ] Currency precision maintained (decimal types)

### Transactional Integrity
- [ ] Database transactions around multi-step operations
- [ ] Rollback on failure
- [ ] No partial state on errors
- [ ] Atomic operations where needed
- [ ] Savepoints for nested transactions

---

## Test Quality Rules

### Test Class Structure
- [ ] Class declared `final`
- [ ] Method names in `camelCase`
- [ ] Return type `void` on all test methods
- [ ] Uses `self::assertSame()` NOT `$this->assertSame()`
- [ ] Uses `createStub()` preferred over `createMock()`
- [ ] Never uses `createMock()` (always use `createStub()` or `createConfiguredMock()`)

### Test Quality
- [ ] Descriptive variable names (`$expectedResult`, not `$result1`)
- [ ] Covers happy path
- [ ] Covers error scenarios
- [ ] Uses fixtures from `tests/Fixtures/`
- [ ] Uses builders from `tests/ModelBuilders/`
- [ ] Meaningful test data (not just `'test'`)
- [ ] Data providers for multiple scenarios
- [ ] Precise assertions (verify business effects, not just method calls)

### Test Coverage
- [ ] All new public methods have tests
- [ ] All new classes have tests
- [ ] Modified business logic has tests
- [ ] Edge cases covered

---

## Severity Guidelines

### BLOCKER (stop-the-merge)
- Correctness/security/data loss issues
- Architecture violations affecting behavior
- Failing tests

### MAJOR (must fix before merge)
- New mixins (use composables)
- Using removed Vue 3 APIs (`$on`, filters)
- Standards violations
- Missing tests for new code
- N+1 queries

### MINOR (non-blocking)
- Old slot syntax
- Global component registration
- Naming improvements
- Documentation gaps

### NIT (optional)
- Trivial polish
- Style preferences
- Not using composable pattern for existing code

---

## Architecture Compliance Matrix Template

| Standard | Status | Notes |
|----------|--------|-------|
| **DDD Structure** | ✅/❌ | [specific findings] |
| **Models** | ✅/❌ | [fillable, casts, relationships] |
| **Services/Handlers** | ✅/❌ | [business logic location] |
| **Repositories** | ✅/❌ | [query patterns] |
| **Database** | ✅/❌ | [migrations, conventions] |
| **Frontend** | ✅/❌ | [components, API clients] |
| **Vue 3 Readiness** | ✅/❌ | [no mixins, no deprecated APIs, v-slot syntax] |
| **Code Style** | ✅/❌ | [naming, typing, PSR-12] |
| **Testing** | ✅/❌ | [coverage, quality, conventions] |
| **Laravel Standards** | ✅/❌ | [best practices] |
