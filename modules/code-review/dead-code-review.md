# Module: dead-code-review

## Purpose
Detect dead code, unused references, and post-refactor remnants in changed files.

## Scope
CODE-REVIEW - Used by deep-review (via dead-code-reviewer agent) and optionally by report mode

## Mode
READ-ONLY

---

## Philosophy

This module is **particularly valuable after refactors**, where renaming, moving, or deleting code often leaves orphaned references. Dead code has real costs:
- Confuses future developers ("is this used?")
- Increases maintenance burden
- Can mask bugs (unused error handler means errors go unhandled)
- Bloats bundles and slows tools

---

## Instructions

### Phase 1: Trace the Diff for Orphaned References

**Start from what changed:**
- What was **removed/renamed** in the diff? Search for remaining references to old names.
- What was **added**? Does it replace something that's now dead?
- What files were **deleted**? Are there remaining imports/references?
- What was **moved**? Are old import paths still referenced?

### Phase 2: Unused Definitions

For each changed file, check:

**PHP:**
- [ ] Public/protected methods — search codebase for callers
- [ ] `use` statements — is the class used in the file?
- [ ] Class constants — are they referenced?
- [ ] Properties — are they accessed outside constructor?

**JS/TS/Vue:**
- [ ] Exported functions/constants — are they imported anywhere?
- [ ] `import` statements — is the imported name used?
- [ ] Component props — used in template or script?
- [ ] Emits — actually called?
- [ ] Composable return values — all destructured values used?

### Phase 3: Orphaned Files & Stale Config

- [ ] Components not imported in any other file or route
- [ ] Routes pointing to non-existent controllers
- [ ] Config keys never read
- [ ] Event listeners for events never dispatched
- [ ] Factory/seeder references to removed models

### Phase 4: Unreachable Code

- [ ] Code after return/throw/exit
- [ ] Always-true/false conditions
- [ ] Catch blocks for impossible exceptions
- [ ] Feature flag branches where flag is constant

### Phase 5: Post-Refactor Remnants

- [ ] Old class/function names in comments or strings
- [ ] Stale TODOs referencing completed/removed work
- [ ] Test doubles for changed/removed classes
- [ ] Commented-out code blocks (>3 lines)

---

## Exceptions (NOT Dead Code)

Do NOT flag these as dead:
- Laravel lifecycle methods (`boot`, `register`, `handle`, `rules`)
- PHPUnit test methods
- Event listeners registered in `EventServiceProvider`
- Magic methods (`__construct`, `__get`, etc.)
- Interface implementations
- Vue lifecycle hooks
- Side-effect imports (`import './styles.css'`)
- Dynamic dispatch targets (`call_user_func`, DI resolution)

---

## Output Format

```markdown
**[SEVERITY]:** [Dead code description]
**Location:** `file/path:line`
**Type:** unused-function | unused-import | orphaned-file | unreachable | refactor-remnant | commented-code
**Evidence:** [Search results showing zero references]
**Confidence:** HIGH | MEDIUM | LOW
**Recommendation:** REMOVE | VERIFY-THEN-REMOVE
```

---

## Outputs

```markdown
## Dead Code Review

### Findings

#### MAJOR (High Confidence)
[List or "None"]

#### MINOR (Needs Verification)
[List or "None"]

### Summary
| Category | Count | Est. Lines |
|----------|-------|------------|
| Unused Functions | N | ~N |
| Unused Imports | N | ~N |
| Orphaned Files | N | ~N |
| Unreachable Code | N | ~N |
| Stale Config/Routes | N | ~N |
| Refactor Remnants | N | ~N |
| Commented-Out Code | N | ~N |
| **TOTAL** | **N** | **~N lines** |
```

---

**End of Module**
