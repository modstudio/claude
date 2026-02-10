---
description: Bug hunting mode - find actual bugs through dependency tracing
---

# Bug Zapper Review

Hunting for **actual bugs** by tracing dependencies and verifying correctness.

**This is NOT about:** architecture, standards, style, or requirements.
**This IS about:** Will this code crash? Do things exist? Do types match?

---

## STOP - MANDATORY FIRST ACTION

**YOU MUST CALL TodoWrite RIGHT NOW before reading any other files or running any commands.**

```javascript
TodoWrite({
  todos: [
    {content: "Gather changed files and context", status: "in_progress", activeForm: "Gathering context"},
    {content: "Trace dependency chains (up and down)", status: "pending", activeForm: "Tracing dependencies"},
    {content: "Verify existence (classes, methods, properties)", status: "pending", activeForm: "Verifying existence"},
    {content: "Check type alignment across boundaries", status: "pending", activeForm: "Checking type alignment"},
    {content: "Analyze null safety patterns", status: "pending", activeForm: "Analyzing null safety"},
    {content: "Detect logic errors and edge cases", status: "pending", activeForm: "Detecting logic errors"},
    {content: "Check for copy-paste bugs", status: "pending", activeForm: "Checking for copy-paste bugs"},
    {content: "Generate bug report", status: "pending", activeForm: "Generating bug report"}
  ]
})
```

**DO NOT CONTINUE READING THIS FILE until TodoWrite has been called.**

---

## Mode
READ-ONLY (no changes, only find bugs)

---

## Phase 0: Project Context Detection

{{MODULE: ~/.claude/modules/shared/quick-context.md}}

---

## Step 1: Gather Changed Files

Get all files that have changed:

```bash
# All changes (staged, unstaged, untracked)
git diff --name-only $PROJECT_BASE_BRANCH...HEAD
git diff --name-only
git ls-files --others --exclude-standard
```

**Focus on files with logic:**
- Controllers, Services, Handlers, Repositories
- Models with methods
- Jobs, Commands, Events, Listeners
- API routes and middleware
- Vue/React components with logic

**Skip:**
- Config files (unless referenced in code)
- Pure template/view files
- CSS/style files
- Documentation

**Mark todo complete when done.**

---

## Step 2: Dependency Chain Analysis

{{MODULE: ~/.claude/modules/code-review/bugs-review.md}}

**Execute Phase 1: Dependency Chain Analysis**

For each changed file:

1. **Trace UP (what does this file depend on?):**
   - List all imports/uses
   - Verify each imported class exists
   - Check if imported methods are real

2. **Trace DOWN (what depends on this file?):**
   - Find all files that import/use this class
   - Check if changes break callers
   - Verify signature changes are safe

```bash
# Find what uses a class
grep -rn "use.*ClassName\|new ClassName\|ClassName::" --include="*.php" .

# Find method usages
grep -rn "->methodName(" --include="*.php" .
```

**Mark todo complete when done.**

---

## Step 3: Existence Verification

**Execute Phase 2 from bugs-review module**

For every reference, verify it exists:

| Reference Type | How to Verify |
|----------------|---------------|
| `new ClassName` | Search for `class ClassName` |
| `Class::method()` | Find method in class |
| `$obj->method()` | Trace $obj type, find method |
| `$obj->property` | Find property declaration |
| `config('key')` | Check config files |
| `env('VAR')` | Check .env.example |

**Report any that don't exist.**

**Mark todo complete when done.**

---

## Step 4: Type Alignment Check

**Execute Phase 3 from bugs-review module**

Check type mismatches:

1. **Parameter types:**
   ```php
   // Calling: $service->process($data)
   // Definition: function process(string $data)
   // Check: Is $data actually a string?
   ```

2. **Return types:**
   ```php
   // Definition: function find(): ?User
   // Usage: $user->name
   // Bug: No null check!
   ```

3. **Generic/Collection types:**
   ```php
   // Definition: function getUsers(): Collection
   // Usage: foreach ($users as $user) { $user->id }
   // Check: Is Collection typed? Do items have 'id'?
   ```

**Mark todo complete when done.**

---

## Step 5: Null Safety Analysis

**Execute Phase 4 from bugs-review module**

Find potential null errors:

**High-risk patterns to search:**
```bash
# Find uses of find/first without null check
grep -n "find\|first\|get" changed_files | grep -v "if\|??\|?->"

# Find chained method calls (potential null in chain)
grep -n "->.*->.*->" changed_files
```

**Check each:**
- `->find()` - returns `?Model`, is null handled?
- `->first()` - returns `?Model`, is null handled?
- `->get()` - returns Collection (ok) but `->first()` on it?
- Optional relations accessed without check?

**Mark todo complete when done.**

---

## Step 6: Logic Error Detection

**Execute Phases 5-6 from bugs-review module**

**Search for common logic bugs:**

```bash
# Assignment in condition (should be ==)
grep -n "if.*[^!=<>]=[^=]" changed_files

# Off-by-one in loops
grep -n "for.*<=" changed_files

# Dead code after return
grep -A1 "return\|throw\|exit" changed_files
```

**Check:**
- Comparison operators (`==` vs `===`)
- Loop bounds (`<` vs `<=`)
- Unreachable code
- Empty catch blocks
- Incomplete switch cases

**Mark todo complete when done.**

---

## Step 7: Copy-Paste Bug Detection

**Execute Phase 7 from bugs-review module**

**Look for:**
- Similar code blocks with one variable different
- Variable names that don't fit context
- Method calls on wrong object

**Pattern matching:**
```bash
# Find duplicate lines
sort changed_files | uniq -d

# Similar variable names in close proximity
grep -n "\$user\|\$customer\|\$member" changed_files
```

**Mark todo complete when done.**

---

## Step 8: Generate Bug Report

**Output to CHAT (no files created):**

```markdown
# Bug Zapper Report

## Summary

| Category | Bugs Found | Critical | Major | Minor |
|----------|------------|----------|-------|-------|
| Existence | | | | |
| Type Mismatch | | | | |
| Null Safety | | | | |
| Logic Error | | | | |
| Copy-Paste | | | | |
| **TOTAL** | | | | |

## Dependency Chain Analysis

### Broken Dependencies
[List any missing classes/methods]

### Risky Signature Changes
[List changes that might break callers]

## Critical Bugs (Will Crash)

[For each bug:]
### BUG-001: [Title]
- **File:** `path/file:line`
- **Type:** [category]
- **Problem:** [what's wrong]
- **Impact:** [what will happen]
- **Fix:**
```{lang}
[code]
```

## Major Bugs (Likely Issues)

[Same format]

## Minor Bugs (Potential Issues)

[Same format]

## Files Analyzed
- [list of files checked]

## Recommendation
[SAFE TO MERGE | FIX CRITICAL FIRST | NEEDS REVIEW]
```

**Mark todo complete when done.**

---

## Execution Constraints

**You MUST:**
- Focus ONLY on bugs (not style, architecture, standards)
- Trace dependency chains up AND down
- Verify existence of every referenced class/method
- Check null safety for all nullable returns
- Provide specific file:line references
- Give code examples for fixes

**You MUST NOT:**
- Comment on code style
- Check architecture compliance
- Verify requirements
- Make any code changes
- Run tests (this is about static analysis)

---

Begin bug hunting now.
