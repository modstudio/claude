# Review Log - ${ISSUE_KEY}

**Task:** ${TASK_SUMMARY}
**Project:** ${PROJECT_NAME}
**Created:** ${CURRENT_DATE}

This file tracks all external code review evaluations for this task.

---

## Purpose

This file serves as:
- **Historical record** of review decisions for this issue
- **Learning reference** for circular code review process
- **Consistency checker** for similar suggestions across reviews
- **Audit trail** for what changes were/weren't made and why
- **Knowledge base** for understanding external review quality

---

## How to Use

**Before evaluating a new external review:**
1. Read this file to see what was previously evaluated
2. Check for duplicate suggestions
3. Understand past reasoning for consistency
4. Learn from previous accept/reject patterns

**After evaluating an external review:**
1. Append new review section (don't replace)
2. Document all decisions with reasoning
3. Capture lessons learned
4. Meta-evaluate the external reviewer

**For circular review (reviewing the reviewer):**
1. Periodically review past evaluations
2. Check if decisions were correct
3. Identify patterns in your own evaluation process
4. Improve calibration over time

---

## Template Structure

Each review section should include:
- Context (project type, files changed, external reviewer)
- Summary (accept/modify/reject counts)
- Detailed decisions (each suggestion with reasoning)
- Patterns identified (reviewer strengths/weaknesses)
- Cross-review analysis (consistency with past reviews)
- Verification results (tests, standards checks)
- Meta-evaluation (quality score, would use again)

---

## Review History

{Reviews will be appended below in chronological order}

---

## Review #1 - {DATE} {TIME}

**Reviewer:** {External source - AI tool/human/linter/etc}
**Branch:** {branch-name}
**Commit Range/State:** {git commit hash or range}
**Evaluator:** Claude Code (external review workflow)

### Context

- **Project Type:** {Laravel/Node.js/Python/etc}
- **Files Changed:** {count} files (+{added} -{removed} lines)
- **External Review Source:** {Specific tool or person name}
- **External Review Focus:** {What they were reviewing for}
- **Standards Applied:** {.ai/rules, CONTRIBUTING.md, PSR-12, etc}

### Evaluation Summary

**Suggestions Analyzed:** {count}
- ✅ **ACCEPTED:** {count} ({percentage}%)
- ⚠️ **MODIFIED:** {count} ({percentage}%)
- ❌ **REJECTED:** {count} ({percentage}%)

**Critical Issues Found:** {count}
**Changes Applied:** {Yes/No}
**Tests Run:** {Yes/No} - {results}

### Detailed Decisions

#### ACCEPTED Suggestions

##### #1: {Original suggestion title/summary}

**External Review Said:**
> {Quote the original suggestion verbatim}

**Why ACCEPTED:**
- **Violation:** {[STANDARD §section-name] - specific rule text OR reasoning}
- **Impact:** {Business/technical impact description}
- **Fix:** {What was done to address it}

**Applied:**
```{language}
// File: {path/to/file.ext}:{line-number}
{actual code change that was made}
```

**Verification:**
- {Test results, linter output, manual checks}

**Lesson Learned:**
{What this teaches us about external review quality or our code patterns}

---

##### #2: {Another accepted suggestion}
{...repeat structure...}

---

#### MODIFIED Suggestions

##### #3: {Original suggestion title/summary}

**External Review Said:**
> {Quote the original suggestion}

**Why MODIFIED:**
- **Issue was real:** {Yes, because...}
- **But fix was wrong:** {Why their proposed fix wouldn't work or violates standards}
- **Better approach:** {Reference to [STANDARD §section] or architectural reason}

**Applied Instead:**
```{language}
// File: {path/to/file.ext}:{line-number}
{our alternative solution}
```

**Why this is better:**
{Explanation of why our approach is superior}

**Verification:**
- {Test results, linter output, manual checks}

**Lesson Learned:**
{What this teaches us}

---

##### #4: {Another modified suggestion}
{...repeat structure...}

---

#### REJECTED Suggestions

##### #5: {Original suggestion title/summary}

**External Review Said:**
> {Quote the original suggestion}

**Why REJECTED:**
- ❌ **Primary reason:** {Not an issue / Intentional pattern / Misunderstanding / etc}
- **Evidence:** {[STANDARD §section] OR actual code showing it's correct}
- **Impact:** None - no change needed

**Actual Code:**
```{language}
// File: {path/to/file.ext}:{line-number}
{show the code they flagged is actually correct}
```

**Lesson Learned:**
{What this teaches us about external review limitations or our patterns}

**Pattern to Teach External Reviewers:**
{If applicable - what they should know about our codebase for future reviews}

---

##### #6: {Another rejected suggestion}
{...repeat structure...}

---

### Patterns Identified

**External Review Strengths:**
- {What they caught well}
- {Useful perspectives they brought}
- {Types of issues they excel at finding}

**External Review Weaknesses:**
- {What they misunderstood about our project}
- {What they missed that should have been caught}
- {False positive patterns}
- {Architectural misunderstandings}

**Recommendation for Future:**
{Should we use this reviewer again? For what types of reviews?}

### Cross-Review Analysis

**Compared to previous reviews:**
- Similar suggestions: {List any suggestions that appeared in previous reviews}
- Consistency: {Did we maintain consistency with past decisions? Why/why not?}
- New insights: {Anything new learned in this review}
- Pattern evolution: {How our patterns or standards have evolved}

**Circular Review (reviewing our own evaluation):**
- {Any second thoughts about decisions made?}
- {Any patterns in our own evaluation to be aware of?}
- {Calibration notes for future evaluations}

### Verification Results

**Tests Run:**
```bash
{test commands executed}
```

**Results:**
- ✅ All tests passed: {count} tests
- ❌ Tests failed: {count} - {brief description}
- ⚠️ Warnings: {any warnings or notices}

**Standards Check:**
```bash
{linter/static analysis commands}
```

**Results:**
- ✅ {Tool}: Clean / {score}
- ⚠️ {Tool}: {issues found}

**Manual Verification:**
- [ ] {Specific manual check performed}
- [ ] {Another manual verification}

### Meta-Evaluation

**External Review Quality Score:** ⭐⭐⭐⭐⭐ ({N}/5 stars)

**Scoring breakdown:**
- **Accuracy:** {valid suggestions / total suggestions} = {percentage}%
- **Relevance:** {How well they understood our codebase} - {1-5 rating}
- **Usefulness:** {How much value they added} - {1-5 rating}
- **Efficiency:** {Signal-to-noise ratio} - {1-5 rating}

**Would use this reviewer again?** {Yes / No / Maybe}

**Why/Why not:**
{Reasoning for the decision}

**Best use cases for this reviewer:**
{What types of reviews would benefit from this source}

**Avoid for:**
{What types of reviews this source is not good at}

**Recommendations for external reviewer:**
{What they should improve or learn about our codebase}

### Summary

**Total time spent:** {estimate}
**Value delivered:** {High/Medium/Low}
**Key takeaway:** {One-sentence summary of this review}

---

## Review #2 - {DATE} {TIME}

{Next review would be appended here following the same structure...}

---

## Circular Review Log

{This section tracks reviews OF the reviews - meta-meta-evaluation}

### Circular Review #{N} - {DATE}

**Reviewing:** Review #1, #2, #3
**Evaluator:** {Person or AI reviewing past decisions}

**Findings:**
- ✅ Correct decisions: {list}
- ⚠️ Questionable decisions: {list with reasoning}
- ❌ Wrong decisions: {list with what we learned}

**Calibration adjustments:**
- {What we learned about our evaluation process}
- {Changes to make in future evaluations}

**Institutional knowledge gained:**
- {Patterns about external review quality}
- {Patterns about our own code quality}
- {Better ways to evaluate}

---

## Statistics Summary

**Total Reviews:** {count}
**Total Suggestions Analyzed:** {count}

**Overall Acceptance Rate:**
- ✅ ACCEPTED: {count} ({percentage}%)
- ⚠️ MODIFIED: {count} ({percentage}%)
- ❌ REJECTED: {count} ({percentage}%)

**By External Reviewer:**
| Reviewer | Reviews | Suggestions | Accept Rate | Quality Score |
|----------|---------|-------------|-------------|---------------|
| {name}   | {count} | {count}     | {percent}%  | {N}/5 ⭐      |

**Most Common Acceptance Reasons:**
1. {Violation type} - {count} times
2. {Violation type} - {count} times
3. {Violation type} - {count} times

**Most Common Rejection Reasons:**
1. {Reason} - {count} times
2. {Reason} - {count} times
3. {Reason} - {count} times

**Learning Trends:**
- {How our evaluation has improved}
- {Recurring patterns in external reviews}
- {Areas where we're most/least receptive}

---

## Notes for Future Evaluations

**Things to watch for:**
- {Patterns we've identified}
- {Common false positives}
- {Areas where we tend to agree/disagree}

**Calibration notes:**
- {Are we too strict? Too lenient?}
- {Biases to be aware of}
- {Standards that have evolved}

**Best practices discovered:**
- {What works well in evaluations}
- {What to avoid}
- {Efficient evaluation patterns}

---

**Last updated:** {timestamp}
**Total evaluation record size:** {lines} lines across {count} reviews
