# Quick Code Review Checklist

**Project:** ${PROJECT_NAME}
**Branch:** `${GIT_BRANCH}`
**Date:** ${CURRENT_DATE}

---

## Quick Assessment

**Files Changed:** ${FILES_CHANGED}
**Lines Changed:** +${LINES_ADDED} / -${LINES_REMOVED}
**Overall Status:** ✅ Looks Good / ⚠️ Needs Work / 🔴 Issues Found

---

## Architecture & Design

- [ ] Follows project architecture patterns (${PROJECT_CITATION_ARCHITECTURE})
- [ ] Proper separation of concerns
- [ ] No architectural violations
- [ ] Design patterns used correctly

**Notes:**

---

## Vue 3 Readiness (Frontend Changes)

- [ ] No new mixins (use composables `use*.js` instead)
- [ ] No deprecated APIs (`$on`/`$off`/`$once`, filters, `Vue.set()`)
- [ ] Uses `v-slot` syntax, not deprecated `slot` attribute
- [ ] Business logic in plain JS functions (not tied to `this`)
- [ ] Vuex modules kept simple (Pinia migration ready)

**Notes:**

---

## Code Quality

- [ ] Follows style guide (${PROJECT_CITATION_STYLE})
- [ ] Consistent naming conventions
- [ ] Functions are focused and single-purpose
- [ ] No code duplication
- [ ] No commented-out code
- [ ] No debug statements

**Notes:**

---

## Security

- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] Output sanitization implemented
- [ ] No SQL injection risks
- [ ] No XSS vulnerabilities
- [ ] Auth/authz checks in place

**Notes:**

---

## Testing

- [ ] Tests exist for new code
- [ ] Edge cases covered
- [ ] All tests passing: `${PROJECT_TEST_CMD_ALL}`
- [ ] Coverage meets target (80%+)

**Test Results:**
```
${TEST_OUTPUT}
```

**Notes:**

---

## Performance

- [ ] No obvious performance issues
- [ ] Database queries optimized
- [ ] Caching used appropriately
- [ ] Resource usage reasonable

**Notes:**

---

## Documentation

- [ ] Code documented appropriately
- [ ] README updated if needed
- [ ] API docs updated if needed
- [ ] Breaking changes documented

**Notes:**

---

## Issues Found

### Critical 🔴
- [ ] None

### Major ⚠️
- [ ] None

### Minor 📋
- [ ] None

---

## Recommendation

**Status:** ✅ Approved / ⚠️ Needs Minor Fixes / 🔴 Needs Major Revision

**Next Steps:**
1. 
2. 
3. 

---

**Reviewed by:** Claude
**Date:** ${CURRENT_DATETIME}
