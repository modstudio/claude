# Self-Verification Gate Module

**Module:** Agent-level fact-checking before reporting findings
**Version:** 1.0.0

## Purpose
Ensure every finding reported by a review agent is factually accurate, in scope, and relevant to the changes under review. This gate runs AFTER analysis but BEFORE writing final output.

## Scope
CODE-REVIEW - Used by: all deep review agents

---

## Mandatory Self-Verification Process

After completing your analysis but **BEFORE writing your final output**, you MUST run each candidate finding through this gate. Do not skip this step.

### Gate 1: Re-Read the Actual Code

For every finding you intend to report:
- **Re-read the file at the exact line** you are about to cite
- Confirm the code actually does what you claim it does
- If the code doesn't match your claim, **DROP the finding**

This catches misreads, stale context, and hallucinated line numbers.

### Gate 2: Evidence Check

- Can you **quote the actual problematic code** from the file you just re-read?
- Does the evidence support your stated severity?
- If you cannot point to concrete, real code, **DROP the finding**

### Gate 3: Scope Check

- Is this finding within **YOUR responsibilities** (see your "What You DO" section)?
- If it belongs to another agent's domain (see your "What You DO NOT Do" section), **DROP it** — the other agent will catch it
- If you're unsure, check the boundary: your agent definition is authoritative

### Gate 4: Relevance to Changes

- Is the finding about code that was **actually changed** in this review, or is it a pre-existing issue?
- If task docs or acceptance criteria were provided, is the finding **relevant to the scope** of those requirements?
- Pre-existing issues outside the changed code are out of scope — **DROP them** unless they are CRITICAL and directly triggered by the new changes

### Gate 5: Requirements Alignment

If task docs, acceptance criteria, or functional requirements were provided:
- Does your finding **contradict the stated requirements**? The code may be implementing exactly what the spec asks for — if so, **DROP the finding**
- Does your suggested fix **undo or break a requirement**? For example, if the spec says "use soft deletes" and you suggest hard deletes, your suggestion violates the spec
- When in doubt, **re-read the relevant requirement** before reporting. The task docs are the source of truth for intended behavior
- If you believe the requirement itself is problematic, you may still report the finding but you MUST: (a) acknowledge the requirement exists, (b) frame it as "the spec may need revisiting" rather than "the code is wrong", and (c) set severity to MINOR at most

### Gate 6: Suggestion Quality

- Is your suggested fix **correct and complete**?
- Does the fix introduce new problems?
- Is the fix within the project's patterns and conventions?
- If you're unsure your fix is right, still report the finding but note the uncertainty in the fix

---

## Drop Policy

- Any finding that fails Gates 1-5 must be **silently dropped** — do NOT include it in your output
- Gate 6 failures don't drop the finding, but require a caveat on the suggested fix

---

## Verification Summary Line

At the end of your report, after your summary counts, add:

```
Self-verified: N findings reported, M dropped during self-verification
```

This helps the orchestrator gauge agent confidence and verification rigor.

---

**End of Module**
