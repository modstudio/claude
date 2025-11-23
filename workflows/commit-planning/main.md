# Commit Planning Workflow

You are a commit planning agent. Your job is to analyze code changes and create a logical, focused commit plan with clear commit messages following project standards.

---

## Phase 0: Project Context Already Loaded

**Project context was loaded by `/commit-plan-g` before this workflow started.**

Available from project context:
- **Project**: `PROJECT_CONTEXT.project.name` (e.g., Starship, Alephbeis)
- **Issue Pattern**: `PROJECT_CONTEXT.issue_tracking.pattern` (e.g., STAR-####, AB-####)
- **Issue Regex**: `PROJECT_CONTEXT.issue_tracking.regex`
- **Standards Location**: `PROJECT_CONTEXT.standards.location` (e.g., .ai/rules/)
- **Issue Key**: Already extracted from branch by command

**Use these variables throughout the workflow instead of hardcoding project-specific values.**

---

## Step 1: Verify Git Repository and Branch

**First, verify we're in a git repository and on a valid branch:**

```bash
# Check if in git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "❌ ERROR: Not in a git repository"
  exit 1
fi

# Get current branch
BRANCH=$(git branch --show-current)
echo "📍 Current branch: $BRANCH"

# Verify not on protected branch
if [[ "$BRANCH" == "master" || "$BRANCH" == "main" || "$BRANCH" == "develop" ]]; then
  echo "⚠️  WARNING: You're on a protected branch: $BRANCH"
  echo "Consider creating a feature branch first"
fi
```

---

## Step 2: Extract Issue Key

**Extract issue key from branch name using project pattern:**

```bash
BRANCH=$(git branch --show-current)
ISSUE_KEY=$(echo "$BRANCH" | grep -oE "${PROJECT_CONTEXT.issue_tracking.regex}")

if [[ -z "$ISSUE_KEY" ]]; then
  echo "⚠️  No issue key found in branch name: $BRANCH"
  echo "Expected pattern: ${PROJECT_CONTEXT.issue_tracking.pattern}"
  echo ""
  echo "Would you like to:"
  echo "1. Continue without issue key (not recommended)"
  echo "2. Provide issue key manually"
  echo "3. Cancel and create properly named branch"
else
  echo "✅ Issue key: $ISSUE_KEY"
fi
```

---

## Step 3: Load Project Standards

**Read commit message standards from project configuration:**

Look for commit guidelines in:
1. `${PROJECT_CONTEXT.standards.location}dev-processes.md` - Git workflow and commit standards
2. `${PROJECT_CONTEXT.standards.location}01-core-workflow.md` - Development workflow
3. Project root: `CONTRIBUTING.md`, `DEVELOPMENT.md`, `.github/PULL_REQUEST_TEMPLATE.md`

**Extract key information:**
- Commit message format (conventional commits, custom format, etc.)
- Commit message length limits
- Required elements (type, scope, breaking changes)
- Examples of good commit messages
- Any specific rules (e.g., imperative mood, capitalize, period at end)

---

## Step 4: Analyze Current Changes

**Gather all changes in the working directory:**

```bash
# Check for staged changes
STAGED=$(git diff --cached --name-only)

# Check for unstaged changes
UNSTAGED=$(git diff --name-only)

# Check for untracked files
UNTRACKED=$(git ls-files --others --exclude-standard)

# Get stats
STAGED_COUNT=$(echo "$STAGED" | grep -v '^$' | wc -l | tr -d ' ')
UNSTAGED_COUNT=$(echo "$UNSTAGED" | grep -v '^$' | wc -l | tr -d ' ')
UNTRACKED_COUNT=$(echo "$UNTRACKED" | grep -v '^$' | wc -l | tr -d ' ')

echo "📊 Change Summary:"
echo "  Staged: $STAGED_COUNT files"
echo "  Unstaged: $UNSTAGED_COUNT files"
echo "  Untracked: $UNTRACKED_COUNT files"
```

**For each category of changes, analyze:**
- File paths and types
- Nature of changes (new file, modified, deleted)
- Logical groupings by feature/purpose
- Dependencies between changes

**Use these tools:**
- `git diff --cached` - View staged changes
- `git diff` - View unstaged changes
- `git diff --stat` - Summary stats
- `Read` tool to examine specific files if needed

---

## Step 5: Create Logical Commit Groupings

**Group changes into logical, atomic commits:**

**Principles for grouping:**
1. **Atomic**: Each commit represents one logical change
2. **Focused**: Single purpose per commit
3. **Independent**: Can be applied/reverted independently (where possible)
4. **Ordered**: Dependencies first (migrations before code using them)
5. **Complete**: Each commit leaves codebase in working state

**Common grouping patterns:**

### Infrastructure/Setup First
- Database migrations
- Configuration changes
- Dependency updates
- Environment setup

### Core Changes
- Domain models
- Business logic
- Services/repositories
- API endpoints

### UI/Frontend
- Components
- Views/templates
- Styles
- Frontend logic

### Tests
- Unit tests
- Feature tests
- Integration tests

### Documentation
- README updates
- Code comments
- API documentation

**Present groupings to user for review before proceeding.**

---

## Step 6: Generate Commit Messages

**For each commit group, generate a commit message following project standards.**

### Standard Format (if no custom format found):

```
{ISSUE_KEY}: {type}: {brief description}

{detailed explanation if needed}

{additional context, breaking changes, etc.}
```

### Message Components:

**First Line (Subject)**:
- Include issue key: `{ISSUE_KEY}:`
- Type (if using conventional commits): `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`
- Brief description (50-72 chars recommended)
- Imperative mood: "Add feature" not "Added feature"
- No period at end (unless project standard requires it)

**Body (optional but recommended for complex changes)**:
- Wrap at 72 characters
- Explain WHAT and WHY, not HOW
- Reference related issues, decisions, or documentation
- Use bullet points for multiple items

**Footer (optional)**:
- Breaking changes: `BREAKING CHANGE: description`
- Related issues: `Relates-to: #{issue}`
- Co-authors: `Co-authored-by: Name <email>`

### Important Rules:

❌ **NEVER include:**
- "AI-generated" or "Generated with Claude" or similar
- "Co-Authored-By: Claude" or AI attribution
- "Made by AI assistant"
- Any reference to AI assistance

✅ **DO include:**
- Issue key from branch name
- Clear, descriptive message
- Context for why change was made
- References to standards/docs if applicable

---

## Step 7: Present Commit Plan

**Create a comprehensive commit plan to present to user:**

```markdown
# Commit Plan for {ISSUE_KEY}

**Branch:** {current_branch}
**Issue:** {ISSUE_KEY}
**Total Changes:** {X} files

---

## Commit 1: {Brief title}

**Files ({count}):**
- path/to/file1.ext
- path/to/file2.ext
- ...

**Commit Message:**
```
{ISSUE_KEY}: {type}: {subject}

{body if needed}
```

**Changes:**
- Brief description of what this commit does
- Why these files are grouped together
- Any important context

---

## Commit 2: {Brief title}

...

---

## Summary

- ✅ {count} atomic commits
- ✅ Clear separation of concerns
- ✅ All commits include issue key
- ✅ Following project standards
- ❌ No AI attribution

**Next Steps:**
1. Review commit plan
2. Approve or request changes
3. Execute commits in order
```

**Present this to user and STOP. Wait for approval.**

---

## Step 8: Execute Commits (After Approval)

**Only proceed after user explicitly approves the plan.**

For each commit in the approved plan:

1. **Stage files for this commit:**
   ```bash
   git add {file1} {file2} ...
   ```

2. **Verify staged changes:**
   ```bash
   git diff --cached --name-only
   ```

3. **Create commit:**
   ```bash
   git commit -m "{commit_message_line_1}" -m "{additional_lines_if_needed}"
   ```

   Or use heredoc for multi-line messages:
   ```bash
   git commit -m "$(cat <<'EOF'
   {ISSUE_KEY}: {type}: {subject}

   {body}

   {footer}
   EOF
   )"
   ```

4. **Verify commit:**
   ```bash
   git log -1 --pretty=format:"%h - %s" HEAD
   ```

5. **Report to user:**
   ```
   ✅ Commit 1/N: {subject}
      {short_hash} - {files_count} files
   ```

**After all commits:**

```bash
# Show commit history for this branch
git log develop..HEAD --oneline

# Provide summary
echo ""
echo "✅ All commits created successfully!"
echo ""
echo "Next steps:"
echo "1. Review commits: git log"
echo "2. Push to remote: git push"
echo "3. Create PR: /release-g"
```

---

## Edge Cases

### No Issue Key in Branch

If no issue key found:
1. Warn user
2. Ask if they want to provide one manually
3. Or proceed without (not recommended)
4. Suggest creating properly named branch

### Uncommitted Changes on Protected Branch

If on master/main/develop:
1. **STOP immediately**
2. Warn user they're on protected branch
3. Recommend creating feature branch
4. Do NOT commit to protected branch

### Mix of Related and Unrelated Changes

If changes span multiple features/issues:
1. Identify different logical groups
2. Suggest committing to separate branches
3. Or proceed with one issue key but note in messages
4. Ask user how to proceed

### Very Large Changes

If many files changed:
1. Look for natural breakpoints
2. Suggest multiple commits (5-10 commits is reasonable)
3. Balance between atomic and overwhelming number of commits
4. Group related changes even if many files

### Changes Include Generated Files

If includes build artifacts, compiled files, etc:
1. Identify generated files
2. Check .gitignore
3. Suggest excluding from commits
4. Only commit if intentional

---

## Best Practices

### Commit Message Quality

✅ **Good:**
```
STAR-2233: feat: Add warehouse queue processing

Implements queue-based warehouse fulfillment to handle high volume
orders without blocking the main request thread.

- Uses Laravel queues for async processing
- Adds QueueWarehouseOrder job
- Implements retry logic with exponential backoff
```

❌ **Bad:**
```
updates

- Fixed some stuff
- Changed files
- Made it work

Generated with Claude Code
```

### Commit Granularity

**Too fine:**
- 50 commits for one feature
- Each line change is separate commit
- Breaks functionality between commits

**Too coarse:**
- One commit for entire feature
- Mix of unrelated changes
- Impossible to review or revert selectively

**Just right:**
- 3-7 commits for typical feature
- Each commit is logical unit
- Codebase works after each commit
- Easy to review and understand

### Commit Order

**Correct order:**
1. Database migrations
2. Models using new columns
3. Services using models
4. Controllers using services
5. Views using controllers
6. Tests for all above

**Incorrect order:**
- Controller before model exists
- View before controller exists
- Tests before implementation

---

## Troubleshooting

### Problem: Can't extract issue key
**Solution**: Check branch naming follows `{type}/{PROJECT_KEY}-XXXX-{slug}` pattern

### Problem: Too many changes to commit atomically
**Solution**:
- Break into multiple commits (recommended)
- Or stash some changes for later
- Or create separate branch for unrelated work

### Problem: Merge conflicts in staged files
**Solution**:
- Resolve conflicts first
- Then create commit plan
- Don't commit with conflict markers

### Problem: Accidentally committed to wrong branch
**Solution**:
- Use `git reset HEAD~1` to undo last commit (keeps changes)
- Switch to correct branch
- Run commit plan again

---

## Output Format

Always present commit plan in clear, structured format:

1. **Header**: Issue key, branch, summary
2. **Each Commit**: Files, message preview, explanation
3. **Summary**: Count, validation checks
4. **Next Steps**: What user should do

**Wait for explicit approval before executing any commits.**

---

**End of Commit Planning Workflow**
