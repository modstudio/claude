# Code Review Report

**Project:** ${PROJECT_NAME}
**Date:** ${CURRENT_DATE}
**Reviewer:** Claude
**Branch:** `${GIT_BRANCH}`

---

## Summary

**Files Analyzed:** ${FILES_CHANGED}
**Total Changes:** +${LINES_ADDED} / -${LINES_REMOVED}
**Overall Assessment:** ⚠️ Needs Revision / ✅ Approved / 🔴 Major Issues

---

## Executive Summary

[2-3 sentence overview of the changes and overall code quality]

---

## Files Reviewed

### Category: New Files

| File | Lines | Purpose | Assessment |
|------|-------|---------|------------|
| `path/to/file.ext` | +123 | [Purpose] | ✅ / ⚠️ / 🔴 |

### Category: Modified Files

| File | Changes | Purpose | Assessment |
|------|---------|---------|------------|
| `path/to/file.ext` | +50 -20 | [Changes description] | ✅ / ⚠️ / 🔴 |

### Category: Deleted Files

| File | Reason | Impact |
|------|--------|--------|
| `path/to/file.ext` | [Reason for deletion] | [Impact description] |

---

## Architecture Review

### Standards Compliance

**Reference:** ${PROJECT_CITATION_ARCHITECTURE}

- [ ] **Follows project architecture patterns**
  - Status: ✅ Compliant / ⚠️ Minor Issues / 🔴 Non-Compliant
  - Notes: [Details]

- [ ] **Proper separation of concerns**
  - Status: ✅ / ⚠️ / 🔴
  - Notes: [Details]

- [ ] **Correct use of design patterns**
  - Status: ✅ / ⚠️ / 🔴
  - Notes: [Details]

- [ ] **Module boundaries respected**
  - Status: ✅ / ⚠️ / 🔴
  - Notes: [Details]

### Architecture Concerns

#### Concern 1: [Title]

**Severity:** 🔴 Critical / ⚠️ Major / 📋 Minor
**Location:** `file.ext:line`

**Issue:**
[Description of the architecture issue]

**Recommendation:**
[How to fix it]

**References:**
- ${PROJECT_CITATION_ARCHITECTURE}

---

## Code Quality Review

### Style Guide Compliance

**Reference:** ${PROJECT_CITATION_STYLE}

- [ ] **Naming conventions followed**
  - Status: ✅ / ⚠️ / 🔴
  - Issues: [List any naming issues]

- [ ] **Code formatting consistent**
  - Status: ✅ / ⚠️ / 🔴
  - Issues: [List formatting issues]

- [ ] **Documentation standards met**
  - Status: ✅ / ⚠️ / 🔴
  - Issues: [List documentation issues]

### Code Quality Metrics

- **Cyclomatic Complexity:** [Assessment]
- **Code Duplication:** [Assessment]
- **Function Length:** [Assessment]
- **File Length:** [Assessment]

### Code Quality Issues

#### Issue 1: [Title]

**Severity:** 🔴 Critical / ⚠️ Major / 📋 Minor
**Location:** `file.ext:line`
**Category:** Bug / Performance / Maintainability / Readability

**Issue:**
```
[Code snippet showing the issue]
```

**Problem:**
[Description of why this is an issue]

**Recommendation:**
```
[Suggested fix or improvement]
```

---

## Security Review

### Security Checklist

- [ ] **No hardcoded secrets or credentials**
  - Status: ✅ Clean / 🔴 Found Issues
  - Details: [List any issues found]

- [ ] **Input validation implemented**
  - Status: ✅ / ⚠️ / 🔴
  - Details: [Assessment]

- [ ] **Output sanitization implemented**
  - Status: ✅ / ⚠️ / 🔴
  - Details: [Assessment]

- [ ] **Authentication/authorization checks present**
  - Status: ✅ / ⚠️ / 🔴 / N/A
  - Details: [Assessment]

- [ ] **No SQL injection vulnerabilities**
  - Status: ✅ / 🔴
  - Details: [Assessment]

- [ ] **No XSS vulnerabilities**
  - Status: ✅ / 🔴
  - Details: [Assessment]

- [ ] **No CSRF vulnerabilities**
  - Status: ✅ / 🔴
  - Details: [Assessment]

### Security Concerns

#### Security Issue 1: [Title]

**Severity:** 🔴 Critical / ⚠️ High / 📋 Medium / 💡 Low
**Location:** `file.ext:line`
**OWASP Category:** [e.g., A03:2021 – Injection]

**Vulnerability:**
```
[Code snippet showing the vulnerability]
```

**Risk:**
[Description of the security risk]

**Fix:**
```
[Secure code example]
```

**References:**
- [OWASP link or security documentation]

---

## Testing Review

### Test Coverage

**Test Command:** `${PROJECT_TEST_CMD_ALL}`

- **Overall Coverage:** ${TEST_COVERAGE}%
- **Lines Covered:** ${LINES_COVERED} / ${TOTAL_LINES}
- **Target:** 80%+

### Coverage by File

| File | Coverage | Status |
|------|----------|--------|
| `file.ext` | 85% | ✅ |
| `file2.ext` | 60% | ⚠️ Below target |

### Test Quality

- [ ] **Tests exist for new functionality**
  - Status: ✅ / ⚠️ / 🔴
  - Missing: [List untested features]

- [ ] **Edge cases covered**
  - Status: ✅ / ⚠️ / 🔴
  - Missing: [List uncovered edge cases]

- [ ] **Error cases tested**
  - Status: ✅ / ⚠️ / 🔴
  - Missing: [List untested error scenarios]

- [ ] **Integration tests present**
  - Status: ✅ / ⚠️ / 🔴 / N/A
  - Notes: [Details]

### Test Execution Results

```
${TEST_OUTPUT}
```

**Result:** ✅ All Passing / ⚠️ Some Failing / 🔴 Major Failures

### Testing Concerns

#### Concern 1: [Title]

**Severity:** ⚠️ / 📋
**Area:** Unit / Integration / Coverage

**Issue:**
[Description of testing gap or issue]

**Recommendation:**
[What tests should be added]

---

## Performance Review

### Performance Considerations

- [ ] **Database queries optimized**
  - Status: ✅ / ⚠️ / 🔴 / N/A
  - Issues: [List N+1 queries, missing indexes, etc.]

- [ ] **No obvious performance bottlenecks**
  - Status: ✅ / ⚠️ / 🔴
  - Issues: [List potential bottlenecks]

- [ ] **Caching strategy appropriate**
  - Status: ✅ / ⚠️ / 🔴 / N/A
  - Issues: [List caching concerns]

- [ ] **Resource usage reasonable**
  - Status: ✅ / ⚠️ / 🔴
  - Issues: [Memory, CPU, network concerns]

### Performance Concerns

#### Concern 1: [Title]

**Severity:** ⚠️ / 📋
**Location:** `file.ext:line`

**Issue:**
[Description of performance concern]

**Impact:**
[Potential performance impact]

**Recommendation:**
[How to optimize]

---

## Best Practices Review

### Code Maintainability

- [ ] **Code is self-documenting with clear names**
  - Status: ✅ / ⚠️ / 🔴

- [ ] **Complex logic has comments explaining why**
  - Status: ✅ / ⚠️ / 🔴

- [ ] **Functions are focused and single-purpose**
  - Status: ✅ / ⚠️ / 🔴

- [ ] **No commented-out code**
  - Status: ✅ / 🔴

- [ ] **No debug statements or console.logs**
  - Status: ✅ / 🔴

### Error Handling

- [ ] **Errors are properly caught and handled**
  - Status: ✅ / ⚠️ / 🔴

- [ ] **Error messages are helpful and user-friendly**
  - Status: ✅ / ⚠️ / 🔴

- [ ] **Errors are logged appropriately**
  - Status: ✅ / ⚠️ / 🔴

### Dependencies

- [ ] **New dependencies justified and documented**
  - Status: ✅ / N/A

- [ ] **Dependency versions pinned or constrained**
  - Status: ✅ / ⚠️ / 🔴

- [ ] **No circular dependencies introduced**
  - Status: ✅ / 🔴

---

## Documentation Review

### Code Documentation

- [ ] **Public APIs documented**
  - Status: ✅ / ⚠️ / 🔴
  - Missing: [List undocumented APIs]

- [ ] **Complex logic explained**
  - Status: ✅ / ⚠️ / 🔴
  - Missing: [List areas needing explanation]

- [ ] **Type hints/annotations present**
  - Status: ✅ / ⚠️ / 🔴 / N/A
  - Missing: [List areas needing types]

### User Documentation

- [ ] **README updated if needed**
  - Status: ✅ / ⚠️ / 🔴 / N/A

- [ ] **API documentation updated**
  - Status: ✅ / ⚠️ / 🔴 / N/A

- [ ] **Migration guide provided if breaking changes**
  - Status: ✅ / 🔴 / N/A

---

## Critical Issues

### 🔴 Critical (Must Fix Before Merge)

1. **[Issue Title]** - `file.ext:line`
   - [Brief description]
   - [Why it's critical]

### ⚠️ Major (Should Fix Before Merge)

1. **[Issue Title]** - `file.ext:line`
   - [Brief description]
   - [Why it's important]

### 📋 Minor (Can Address in Follow-up)

1. **[Issue Title]** - `file.ext:line`
   - [Brief description]
   - [Nice to have improvement]

---

## Positive Highlights

Things done well in this code review:

1. **[Highlight 1]**
   - [What was done well and why it's good]

2. **[Highlight 2]**
   - [What was done well and why it's good]

---

## Recommendations

### Immediate Actions (Before Merge)

1. [ ] Fix all critical (🔴) issues
2. [ ] Address major (⚠️) security concerns
3. [ ] Ensure all tests pass
4. [ ] Update documentation

### Follow-up Tasks

1. [ ] Address minor issues
2. [ ] Improve test coverage to 80%+
3. [ ] Performance optimization
4. [ ] Technical debt items

---

## Suggestions Summary

| # | Severity | Issue | Suggestion |
|---|----------|-------|------------|
| 1 | 🔴 Critical | [Issue title] | [Brief fix recommendation] |
| 2 | ⚠️ Major | [Issue title] | [Brief fix recommendation] |
| 3 | 📋 Minor | [Issue title] | [Brief fix recommendation] |

**Totals:** 🔴 X Critical | ⚠️ X Major | 📋 X Minor

---

## Final Verdict

**Status:** ⚠️ Needs Revision / ✅ Approved / 🔴 Requires Major Changes

**Summary:**
[Final assessment and next steps]

**Conditions for Approval:**
- [ ] Condition 1
- [ ] Condition 2
- [ ] Condition 3

---

## References

- **Architecture Standards:** ${PROJECT_CITATION_ARCHITECTURE}
- **Style Guide:** ${PROJECT_CITATION_STYLE}
- **Knowledge Base:** ${PROJECT_KB_DIR}
- **Project Standards:** ${PROJECT_STANDARDS_DIR}

---

**Report Generated:** ${CURRENT_DATETIME}
**Reviewer:** Claude Code Review Agent
