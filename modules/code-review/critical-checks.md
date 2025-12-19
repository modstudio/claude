# Module: critical-checks

## Purpose
Quick checklist for critical file types. Used for fast reviews when full architecture review isn't needed.

## Scope
CODE-REVIEW - Used by quick.md and as subset in other modes

## Mode
READ-ONLY

---

## Migration Files

**For each migration file, verify:**

- [ ] Both `up()` and `down()` methods present
- [ ] Migrations are reversible (down actually undoes up)
- [ ] Timestamp format: `YYYY_MM_DD_HHMMSS`
- [ ] Descriptive names
- [ ] Column comments present for clarity
- [ ] Data migrations separate from schema migrations
- [ ] Uses Schema facade
- [ ] Table names in `snake_case`

**Severity if missing:**
- Missing `down()`: MAJOR
- Not reversible: MAJOR
- Missing comments: MINOR

---

## Model Changes

**For each modified model, verify:**

- [ ] `$fillable` array updated for new columns
- [ ] `$casts` defined for booleans, dates, custom types
- [ ] Methods have return types
- [ ] No business logic (only getters/setters/accessors)
- [ ] Eloquent relationships marked `@internal only for Eloquent`
- [ ] Classes declared `final` or `abstract`
- [ ] UUIDs used for IDs where applicable

**Severity if missing:**
- Missing `$fillable`: BLOCKER (security)
- Missing `$casts`: MAJOR
- Business logic in model: MAJOR

---

## Service/Handler Changes

**For each service or handler, verify:**

- [ ] Business logic in handlers, not controllers
- [ ] Uses DTOs for complex data (not raw arrays with >2-3 params)
- [ ] Type hints on all parameters and returns
- [ ] No obvious N+1 query patterns
- [ ] Dependencies injected via constructor
- [ ] Single responsibility per handler

**Severity if missing:**
- N+1 queries: MAJOR
- Missing type hints: MAJOR
- Logic in wrong layer: MAJOR

---

## Controller Changes

**For each controller, verify:**

- [ ] Thin (delegates to handlers/services)
- [ ] Uses FormRequests for validation
- [ ] Returns via ResponseFactory
- [ ] No business logic

**Severity if missing:**
- Business logic in controller: MAJOR
- Missing validation: MAJOR

---

## Frontend Changes

**For each Vue/JS file, verify:**

- [ ] No `axios` calls in components (use `*ApiClient.js`)
- [ ] Props properly typed
- [ ] No `console.log` left behind
- [ ] Components use PascalCase file names
- [ ] Imports use `@` alias
- [ ] Include `.vue` extension in imports

**Severity if missing:**
- axios in component: MAJOR
- console.log left: MINOR (auto-fixable)

---

## Vue 3 Readiness

**Critical patterns to avoid (removed in Vue 3):**

- [ ] No new mixins introduced (use composables `use*.js`)
- [ ] No `$on`/`$off`/`$once` usage
- [ ] No filters `{{ value | filter }}` (use computed/methods)
- [ ] Uses `v-slot` syntax, not deprecated `slot` attribute
- [ ] No `Vue.set()`/`Vue.delete()` calls
- [ ] No `$scopedSlots` usage

**Severity:**
- New mixins: MAJOR
- Using removed APIs: MAJOR
- Old slot syntax: MINOR

---

## Quick Decision Matrix

| File Type | Key Checks | Blocker If |
|-----------|------------|------------|
| Migration | up/down, reversible | N/A |
| Model | $fillable, $casts | Missing $fillable |
| Handler | Single responsibility, DI | N/A |
| Controller | Thin, FormRequest | N/A |
| Vue | No axios, no console.log | N/A |

---

**End of Module**
