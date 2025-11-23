---
description: Evaluate an external code review independently (global multi-project)
---

# External Code Review Evaluation

I'll evaluate an external code review and independently determine what changes are actually needed.

**Purpose:** Critical evaluation of external reviews (from other developers, AI tools, automated linters, etc.)

**Approach:** I will NOT blindly accept suggestions. Instead, I'll:
1. Detect project context and available tools
2. Load relevant standards and history
3. Analyze current code independently
4. Evaluate each suggestion critically
5. Record evaluation for circular review

---

## Phase 0: Project Context Already Loaded

**Project context was loaded by `/code-review-g` before mode selection.**

Available from project context:
- Issue key: `{ISSUE_KEY}` (from branch name)
- Project: `{PROJECT_CONTEXT.project.name}`
- Standards: `{PROJECT_CONTEXT.standards.location}`
- Storage: `${WIP_ROOT}/{ISSUE_KEY}-{slug}/external-review-log.md`
  - Where `WIP_ROOT` from `~/.claude/config/global.yaml` (default: `~/.wip`)
- Citation format: `{PROJECT_CONTEXT.citation_format.*}`
- Test commands: `{PROJECT_CONTEXT.test_commands.*}`

**Ready to proceed with external review evaluation.**

---

## Phase 1: Load Project Standards

**Use project context to load correct standards:**

### 1.1 Project-Specific Standards

**Load standards from project context:**
```bash
# Project context already identified standards location
STANDARDS_DIR="${PROJECT_CONTEXT.standards.location}"

# Read key standard files (from project config)
for file in "${PROJECT_CONTEXT.standards.files[@]}"; do
  echo "Loading: $file"
  cat "$file"
done

# Load main guide if exists
if [ -f "${PROJECT_CONTEXT.standards.main_guide}" ]; then
  cat "${PROJECT_CONTEXT.standards.main_guide}"
fi
```

**Citation format (from project):**
Use `PROJECT_CONTEXT.citation_format` for proper references:
- Architecture: `${PROJECT_CONTEXT.citation_format.architecture}`
- Style: `${PROJECT_CONTEXT.citation_format.style}`
- Testing: `${PROJECT_CONTEXT.citation_format.testing}`

### 1.2 Business Context

**Load context based on project configuration:**

**A) Check for YouTrack MCP (if project uses it):**
```bash
# If project has YouTrack integration
if [ "${PROJECT_CONTEXT.mcp_tools}" contains "youtrack" ]; then
  # Use mcp__youtrack__get_issue tool
  # Get issue description, acceptance criteria, linked articles
fi
```

**B) Check task documentation directory:**
```bash
# Load .wip root from global config
WIP_ROOT="$HOME/.wip"  # From ~/.claude/config/global.yaml

# Find task folder
TASK_FOLDER=$(find "$WIP_ROOT" -type d -name "${ISSUE_KEY}*" 2>/dev/null | head -1)

# Read specification.md, notes.md, and other .md files
if [ -n "$TASK_FOLDER" ]; then
  ls -la "$TASK_FOLDER/"
  cat "$TASK_FOLDER/specification.md" 2>/dev/null || echo "No spec yet"
fi
```

**C) Check project business docs (if configured):**
```bash
# Some projects have business documentation
if [ -n "${PROJECT_CONTEXT.documentation.business_docs}" ]; then
  # Read relevant business docs
  # Example: storage/app/youtrack_docs/ for Starship
fi
```

**D) Git commit messages (fallback):**
```bash
git log --grep="$ISSUE_KEY" --format="%B" | head -50
```

**E) Ask user (last resort):**
> "I don't have business context for {ISSUE_KEY}. Can you provide:
> - What problem this solves
> - Key acceptance criteria
> - Any constraints"

**STOP - Standards loaded, ready for external review**

---

## Phase 2: Load Current Code State

### 2.1 Discover Changed Files

```bash
# Get current branch
BRANCH=$(git branch --show-current)

# Determine base branch (project-specific)
if git show-ref --quiet refs/heads/develop; then
  BASE="develop"
elif git show-ref --quiet refs/heads/main; then
  BASE="main"
else
  BASE="master"
fi

# Get diff statistics
git diff $BASE --stat
git diff $BASE --name-status

# Include staged/unstaged/untracked
git status --short
```

**Output:**
```markdown
**Changed Files:**
- Modified: {count} files
- Added: {count} files
- Deleted: {count} files
- Total lines: +{added} -{removed}

**Files by type:**
- Backend: {list}
- Frontend: {list}
- Tests: {list}
- Config/Migrations: {list}
```

### 2.2 Load Technical Context

**Use project-configured MCP tools:**
```bash
# Check what MCP tools are available from project context
if [ "${PROJECT_CONTEXT.mcp_tools}" contains "laravel-boost" ]; then
  # Laravel-specific context
  mcp__laravel-boost__application-info  # Get package versions
  mcp__laravel-boost__database-schema   # Get DB structure
  mcp__laravel-boost__list-routes       # Get routes
fi

if [ "${PROJECT_CONTEXT.mcp_tools}" contains "playwright" ]; then
  # Frontend testing capability available
fi
```

**Tech stack from project:**
- Backend: `${PROJECT_CONTEXT.tech_stack.backend}`
- Frontend: `${PROJECT_CONTEXT.tech_stack.frontend}`

**STOP - Context loaded, ready for review text**

---

## Phase 3: User Pastes External Review

**Now please paste the external code review text below:**

*Waiting for you to paste the review...*

---

## Phase 4: Parse External Review

**Once review is provided:**

### 4.1 Extract Suggestions
- Parse review text
- Identify individual suggestions
- Extract file/line references
- Categorize by severity (if provided)
- Note reviewer source/tool

### 4.2 Load Previous External Review History

**Load past evaluations for THIS task (circular review):**

```bash
# Load .wip root from global config
WIP_ROOT="$HOME/.wip"  # From ~/.claude/config/global.yaml

# Find task folder
TASK_FOLDER=$(find "$WIP_ROOT" -type d -name "${ISSUE_KEY}*" 2>/dev/null | head -1)

if [ -n "$TASK_FOLDER" ]; then
  REVIEW_FILE="$TASK_FOLDER/external-review-log.md"

  if [ -f "$REVIEW_FILE" ]; then
    echo "✅ Found previous external review evaluations"
    cat "$REVIEW_FILE"
  else
    echo "ℹ️ No previous external review record (will create new)"
  fi
else
  echo "⚠️ Task folder not found in $WIP_ROOT"
fi
```

**Why load now:**
- ✅ User has pasted external review - we know what to compare against
- ✅ Can check for duplicate suggestions
- ✅ Can maintain consistency with past decisions
- ✅ Can reference past accept/reject reasoning
- ✅ Circular review - learn from past evaluations

### 4.3 Check for Duplicates

**Now compare new suggestions with past evaluations:**

```bash
# For each suggestion in new external review
for suggestion in "${NEW_SUGGESTIONS[@]}"; do
  # Search in previous evaluations
  grep -i "${suggestion_keyword}" "$REVIEW_FILE"
done
```

**If duplicate found:**
```markdown
**⚠️ DUPLICATE DETECTED**

This suggestion appears similar to:
- Review #{N} ({date}): {ACCEPTED/REJECTED} because {reason}

**Current options:**
1. **AUTO-SKIP** if context unchanged (reference previous decision)
2. **RE-EVALUATE** if code changed since last review
3. **FLAG** if past decision seems wrong now (circular review)

**Decision:** {explain}

**Circular Review Note:**
If we made a mistake in Review #{N}, document the learning here.
```

---

## Phase 5: Independent Analysis

For EACH suggestion from external review:

### 5.1 Verify the Issue

**Read actual code:**
```bash
# Navigate to file and read relevant sections
cat {file} | sed -n '{start},{end}p'
```

**Questions:**
- Does the issue actually exist?
- Is it accurately described?
- What's the actual impact?

### 5.2 Check Against Project Standards

**Reference loaded standards using project citation format:**

```bash
# Use project-specific citation format
ARCH_FORMAT="${PROJECT_CONTEXT.citation_format.architecture}"
STYLE_FORMAT="${PROJECT_CONTEXT.citation_format.style}"
TEST_FORMAT="${PROJECT_CONTEXT.citation_format.testing}"
```

**Check against project standards:**
- Read standard files from `PROJECT_CONTEXT.standards.files[]`
- Does this violate documented rules?
- Use project citation format for references

**Examples (varies by project):**
- Starship: `[ARCH §Backend: Controllers]`
- Alephbeis: `[ARCH: "Controllers thin; delegate to Commands"]`
- Generic: `[PSR-12]`, `[ESLint]`, etc.

### 5.3 Evaluate the Suggested Fix

**Questions:**
- Is the proposed fix correct?
- Does it align with project architecture?
- Are there better alternatives?
- Would it introduce new problems?

**If Laravel project with Boost MCP:**
```bash
# Test suggested fix with tinker
mcp__laravel-boost__tinker
{paste suggested code snippet}
# Verify it actually works
```

### 5.4 Cross-Reference with Previous Decisions

**Check for consistency:**
```markdown
**Previous External Review History:**
- {date}: Similar suggestion about {topic} - {ACCEPTED/REJECTED}
- Reasoning then: {why}

**Impact on current decision:**
- ✅ Same context → Maintain consistency
- ⚠️ Different context → Explain why decision differs
- ❌ Past decision was wrong → Document learning
```

### 5.5 Determine Priority

**Classification:**
- **CRITICAL:** Must fix before merge (correctness, security, data loss)
- **MAJOR:** Should fix before merge (substantial issues)
- **MINOR:** Nice to have (small improvements)
- **OPTIONAL:** Trivial (style preferences)
- **NOT AN ISSUE:** False positive (reject)

---

## Phase 6: Generate Evaluation Report

**Create comprehensive report:**

```markdown
# External Review Evaluation for {ISSUE_KEY}

**Date:** {timestamp}
**Branch:** {branch-name}
**External Reviewer:** {source}
**Evaluator:** Claude Code

---

## Executive Summary

**Suggestions Analyzed:** {count}
- ✅ **ACCEPTED:** {count}
- ⚠️ **MODIFIED:** {count}
- ❌ **REJECTED:** {count}

**Critical Issues Confirmed:** {count}
**Recommendation:** {APPLY CHANGES / NO ACTION NEEDED / PARTIAL APPLICATION}

---

## Context

**Project Type:** {Laravel/Node/etc}
**Standards Used:** {.ai/rules, CONTRIBUTING.md, PSR-12, etc}
**Previous Reviews:** {count} (see {REVIEW_FILE})
**Files Changed:** {count} (+{added} -{removed} lines)

---

## Analysis Results

{For each suggestion...}

### Suggestion #{N}: {Title}

**External Review Says:**
> {Quote original suggestion}

**My Analysis:**

**Issue Verification:** ✅ CONFIRMED / ⚠️ PARTIALLY VALID / ❌ NOT AN ISSUE

**Details:**
- **Actual code:** `{file}:{line}`
```{language}
{actual current code}
```

- **Is this actually a problem?** {Yes/No with reasoning}
- **Does it violate project standards?** {Yes/No}
  - If Yes: **Violation:** {[STANDARD §section] - specific rule text}
- **Business impact:** {None/Low/Medium/High}
- **Technical impact:** {None/Low/Medium/High}

**Evaluation of Suggested Fix:**
{If issue confirmed}
- **External suggestion:** {their fix}
- **Is this fix correct?** {Yes/No with reasoning}
- **Better alternative?** {If yes, provide}
- **Risks:** {Any risks from the change}

**Cross-Reference:**
{If similar issue evaluated before}
- Previous decision: {ACCEPT/REJECT}
- Consistency: {Maintained/Changed - why}

**Final Decision:** ✅ ACCEPT / ⚠️ MODIFY / ❌ REJECT

**Reasoning:**
{2-3 sentences explaining the decision}

{If ACCEPT:}
**Action Required:**
```{language}
{exact code change needed}
```

{If MODIFY:}
**My Recommended Change:**
```{language}
{alternative solution}
```
**Why this is better:** {explanation}

{If REJECT:}
**Why Not Needed:** {explanation}

---

{Repeat for all suggestions...}

---

## Summary of Decisions

### ACCEPTED Suggestions
1. #{N}: {title} - {brief reason} - Violation: {[STANDARD §X]}

### MODIFIED Suggestions
1. #{N}: {title} - Original: {brief} → Better: {brief}

### REJECTED Suggestions
1. #{N}: {title} - {brief reason why not needed}

---

## Action Plan

### CRITICAL (Must fix before merge)
```bash
# 1. {Description} - Violation: {[STANDARD §X]}
{command or code change}
```

### RECOMMENDED (Should fix)
- [ ] {Change 1} - Violation: {[STANDARD §X]}
- [ ] {Change 2} - {justification}

### OPTIONAL (Nice to have)
- [ ] {Improvement 1}

### NO ACTION NEEDED
- ~~{Rejected 1}~~ - Not an issue because {reason}
- ~~{Rejected 2}~~ - Intentional project pattern

---

## Verification Plan

{If changes will be applied}

**Tests to run (from project context):**
```bash
# Unit tests
${PROJECT_CONTEXT.test_commands.unit}

# All tests (if needed)
${PROJECT_CONTEXT.test_commands.all}
```

**Standards check (from project context):**
```bash
# Linter commands (if configured)
${PROJECT_CONTEXT.linter_commands}
```

**Manual verification:**
- [ ] {Specific checks needed}

---

## External Review Meta-Evaluation

**Review Source:** {Tool/Person name}
**Quality Score:** ⭐⭐⭐⭐⭐ ({N}/5)

**Strengths:**
- {What they caught well}

**Weaknesses:**
- {What they misunderstood}
- {False positives}

**Patterns Identified:**
- {Recurring themes in their suggestions}

**Would use again?** {Yes/No/Maybe - why}

**Recommendations for reviewer:**
{What they should learn about this project}

---

## Circular Review Notes

{Compare to past evaluations if exist}

**Consistency check:**
- ✅ Decisions align with previous reviews
- ⚠️ Decision changed from previous: {explain why}
- ❌ Found error in past evaluation: {what we learned}

**Learning from this review:**
- {What this teaches about external review quality}
- {What this teaches about our code patterns}
- {Calibration adjustments needed}

---
```

**STOP - Review report before finalizing**

---

## Phase 7: Record Evaluation (MANDATORY)

**Write evaluation to permanent record:**

### 7.1 Storage Location

```bash
# Load .wip root from global config
WIP_ROOT="$HOME/.wip"  # From ~/.claude/config/global.yaml

# Find or create task folder
TASK_FOLDER=$(find "$WIP_ROOT" -type d -name "${ISSUE_KEY}*" 2>/dev/null | head -1)

# If not found, create with basic naming (should include slug from branch)
if [ -z "$TASK_FOLDER" ]; then
  BRANCH=$(git branch --show-current)
  SLUG=$(echo "$BRANCH" | sed "s/^[^/]*\/${ISSUE_KEY}-//")
  TASK_FOLDER="$WIP_ROOT/${ISSUE_KEY}-${SLUG}"
  mkdir -p "$TASK_FOLDER"
fi

REVIEW_FILE="$TASK_FOLDER/external-review-log.md"
```

**Storage location:**
- Always: `${WIP_ROOT}/{ISSUE_KEY}-{slug}/external-review-log.md`
- Configuration: `~/.claude/config/global.yaml` (`storage.wip_root`)

### 7.2 Create or Append Record

**If file doesn't exist, create with header:**
```markdown
# External Review Evaluations for {ISSUE_KEY}

**Project:** {project name from git remote or directory}
**Issue Pattern:** {STAR/GH/JIRA/etc}

This file tracks all external code review evaluations for this issue.

**Purpose:**
- Historical record of review decisions
- Learning reference for circular code review
- Consistency checker for similar suggestions
- Audit trail for changes

**How to use:**
- Read before evaluating new external reviews
- Check for duplicate suggestions
- Maintain consistency with past decisions
- Learn patterns about external review quality

---

```

**Append new review section:**

```markdown
## Review #{N} - {DATE} {TIME}

**Reviewer:** {External source}
**Branch:** {branch-name}
**Commit Range/State:** {git info}
**Evaluator:** Claude Code (external review workflow)

### Context
- **Project Type:** {language/framework}
- **Files Changed:** {count} (+{added} -{removed})
- **External Review Source:** {AI tool/human/linter}
- **Standards Applied:** {.ai/rules, CONTRIBUTING, PSR-12, etc}

### Evaluation Summary

**Suggestions Analyzed:** {count}
- ✅ ACCEPTED: {count}
- ⚠️ MODIFIED: {count}
- ❌ REJECTED: {count}

**Critical Issues Found:** {count}
**Changes Applied:** {Yes/No}
**Tests Run:** {Yes/No - results}

### Detailed Decisions

#### ACCEPTED

##### #{N}: {Title}
**External Review Said:**
> {quote}

**Why ACCEPTED:**
- Violation: {[STANDARD §section] or reasoning}
- Impact: {description}
- Fix: {what was done}

**Applied:**
```{language}
// File: {path}:{line}
{actual code change}
```

**Lesson Learned:**
{What this teaches us}

---

#### MODIFIED

##### #{N}: {Title}
**External Review Said:**
> {quote}

**Why MODIFIED:**
- Issue was real: {yes, because...}
- But fix was wrong: {why}
- Better approach: {reference to standards}

**Applied Instead:**
```{language}
{our alternative}
```

**Lesson Learned:**
{What this teaches}

---

#### REJECTED

##### #{N}: {Title}
**External Review Said:**
> {quote}

**Why REJECTED:**
- ❌ {Reason: not an issue / intentional / misunderstanding}
- Evidence: {[STANDARD §X] or code reference}
- Impact: None

**Lesson Learned:**
{What this teaches}

**Pattern to Teach:**
{What external reviewers should know about our codebase}

---

### Patterns Identified

**External Review Strengths:**
- {Good catches}

**External Review Weaknesses:**
- {Misunderstandings}
- {False positives pattern}

### Cross-Review Analysis

**Compared to previous reviews:**
- Similar suggestions: {list}
- Consistency: {maintained/changed - why}
- New insights: {anything new}

### Verification Results

{If tests/checks run}
**Tests:** {results}
**Standards:** {linter results}

### Meta-Evaluation

**Quality Score:** ⭐⭐⭐⭐⭐ ({N}/5)
- Accuracy: {valid suggestions / total}
- Relevance: {understanding of project}
- Usefulness: {value added}

**Would use again?** {Yes/No/Maybe - why}

---

```

### 7.3 Write File

Use Write tool to create/update the file with appended content.

**STOP - Confirm record written successfully**

```bash
# Verify file created
ls -lh "$REVIEW_FILE"
wc -l "$REVIEW_FILE"

# Show location
echo "✅ Evaluation recorded: $REVIEW_FILE"
```

---

## Phase 8: Apply Changes (Optional)

**Ask user:**
> "Evaluation complete. Would you like me to:
> - [ ] Apply all ACCEPTED changes now
> - [ ] Apply CRITICAL changes only
> - [ ] Show patches for manual review
> - [ ] Skip implementation (use report only)"

**If approved:**
1. Apply changes using Edit tool
2. Run verification tests
3. Report results

**STOP - Changes applied, tests run**

---

## Phase 9: Final Summary

```markdown
# External Review Evaluation Complete

**Summary:**
- Analyzed: {count} suggestions
- Accepted: {count}
- Modified: {count}
- Rejected: {count}

**Changes Applied:** {Yes/No}

**Evaluation Record:**
- Saved to: `{REVIEW_FILE}`
- Review #{N} in the series
- {lines} lines added to permanent record

**Next Steps:**
{If changes applied}
- [ ] Review applied changes
- [ ] Run full test suite
- [ ] Commit changes

{If no changes}
- External review did not identify actionable issues
- See evaluation record for details

**Circular Review:**
- This evaluation is now part of the permanent record
- Future reviews will reference these decisions
- Consistency maintained across {N} total reviews
```

---

## Evaluation Principles

**I will ACCEPT suggestions when:**
- ✅ Real issue confirmed by inspecting actual code
- ✅ Violates documented project standards
- ✅ Breaks language/framework best practices
- ✅ Creates security vulnerability
- ✅ Causes actual bugs or errors
- ✅ Impacts business requirements

**I will REJECT suggestions when:**
- ❌ Issue doesn't exist in actual code
- ❌ It's an intentional project pattern
- ❌ External reviewer misunderstood architecture
- ❌ It's stylistic preference without substance
- ❌ Change would violate project standards
- ❌ Based on outdated information
- ❌ Would introduce new problems

**I will MODIFY suggestions when:**
- ⚠️ Issue is real BUT proposed fix is wrong/incomplete
- ⚠️ Better solution exists that aligns with project patterns
- ⚠️ Fix needed but different approach required
- ⚠️ Suggestion addresses symptom not root cause

**Critical Evaluation Criteria:**
1. **Evidence-based** - Verify every claim against actual code
2. **Standards-aligned** - Match project conventions
3. **Context-aware** - Consider business requirements
4. **Risk-conscious** - Evaluate impact of changes
5. **Independently verified** - Don't trust, verify
6. **Historically consistent** - Align with past decisions

**Circular Review Principle:**
- We review external reviews (this workflow)
- We record our evaluations (Phase 7)
- We review our past evaluations (Phase 1)
- We improve our evaluation process over time
- We build institutional knowledge

**I am NOT:**
- ❌ A rubber stamp for external reviews
- ❌ Obligated to implement all suggestions
- ❌ Deferring to external authority without verification

**I AM:**
- ✅ An independent evaluator
- ✅ Responsible for code quality
- ✅ Guardian of project standards
- ✅ Final decision maker on changes
- ✅ Building learning feedback loop

---

## Project Configuration

**All project-specific settings come from `/project-context` workflow:**

- **Standards:** Loaded from `PROJECT_CONTEXT.standards.files[]`
- **Citation format:** `PROJECT_CONTEXT.citation_format.*`
- **Test commands:** `PROJECT_CONTEXT.test_commands.*`
- **MCP tools:** `PROJECT_CONTEXT.mcp_tools[]`
- **Storage location:** `${WIP_ROOT}/{ISSUE_KEY}-{slug}/external-review-log.md` (from `~/.claude/config/global.yaml`)
- **Tech stack:** `PROJECT_CONTEXT.tech_stack.*`

**To add a new project:**
Edit `~/.claude/workflows/project-context.md` and add project configuration.

---

**Now waiting for external code review text to evaluate...**
