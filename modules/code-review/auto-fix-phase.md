# Module: auto-fix-phase

## Purpose
Run project linters and remove debug statements before detailed review. Reduces noise and saves review time.

## Scope
CODE-REVIEW - Used by report and quick review modes

## Mode
WRITE-ENABLED (for auto-fixes only)

**Note:** This module makes safe, mechanical fixes that have zero risk of changing behavior. Only formatting and debug statement removal.

---

## Inputs
- `PROJECT_BASE_BRANCH`: Base branch to compare against (e.g., develop)
- Changed file list from gather-review-context

## Instructions

### Step 1: Run Project Linter/Fixer

**PHP projects:**
```bash
CHANGED_PHP=$(git diff ${PROJECT_BASE_BRANCH} --name-only --diff-filter=ACMR | grep '\.php$' | tr '\n' ' ')
if [ -n "$CHANGED_PHP" ]; then
  docker compose exec -T {container} ./vendor/bin/php-cs-fixer fix $CHANGED_PHP --config=.php-cs-fixer.php
fi
```

**JavaScript/TypeScript projects:**
```bash
CHANGED_JS=$(git diff ${PROJECT_BASE_BRANCH} --name-only --diff-filter=ACMR | grep -E '\.(js|ts|vue|jsx|tsx)$' | tr '\n' ' ')
if [ -n "$CHANGED_JS" ]; then
  npx prettier --write $CHANGED_JS
  npx eslint --fix $CHANGED_JS
fi
```

**Record:** Files fixed by linter: [count]

### Step 2: Find and Remove Debug Statements

**Search for debug statements:**
```bash
git diff ${PROJECT_BASE_BRANCH} | grep -E "dd\(|var_dump|print_r|console\.log|die\("
```

**If found, use Edit tool to remove:**
- `dd()` - Remove entire statement
- `var_dump()` - Remove entire statement
- `print_r()` - Remove entire statement
- `console.log()` - Remove entire statement (unless in debug utility)
- `die()` - Remove entire statement

**Record:** Debug statements removed: [count]

### Step 3: Final Cleanup Check

After running fixers, verify no remaining issues:
- [ ] Trailing whitespace
- [ ] Missing newline at EOF
- [ ] Extra blank lines

---

## What NOT to Auto-Fix

**Always report these (never auto-fix):**
- Variable/function renaming
- Adding type hints
- Restructuring code
- Any logic changes
- Missing tests
- Architecture issues
- Changes to public APIs

---

## Outputs

```markdown
## Auto-Fixed Issues

**{N} issues auto-fixed** - no action required:

| Type | Count | Details |
|------|-------|---------|
| Linter/Fixer | {N} files | PHP CS Fixer / Prettier |
| Debug statements | {N} | dd(), console.log(), etc. |
| Manual fixes | {N} | Trailing whitespace, etc. |
| **Total** | **{N}** | |

**Fixer command used:**
\`\`\`bash
{actual command run}
\`\`\`
```

---

## Verification

After auto-fixes, run linter in check mode to verify:
```bash
./vendor/bin/php-cs-fixer fix $CHANGED_PHP --dry-run --diff
```

---

**End of Module**
