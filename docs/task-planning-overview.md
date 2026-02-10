# Task Planning Skill: A Human-AI Project Management System

## Executive Summary

This task planning skill represents a paradigm shift from simple "plan mode" to a **comprehensive project management system** purpose-built for the intersection of human intelligence and AI capabilities.

Where standard plan mode produces a single document and moves on, this skill creates a **living documentation ecosystem** that supports the entire development lifecycle - from initial discovery through implementation, review, and completion.

---

## The Core Philosophy

### Separation of Concerns

Unlike monolithic planning approaches, this skill recognizes that different aspects of a task require different types of thinking, documentation, and interaction:

```
Standard Plan Mode          |  Task Planning Skill
----------------------------|----------------------------------------
Single plan document        |  Specialized documents by purpose:
                            |
"Here's what we'll do"      |  00-status.md         -> Where are we?
                            |  01-task-description  -> What is this task?
                            |  02-requirements.md   -> What do we need?
                            |  03-plan.md           -> How will we build it?
                            |  04-todo.md           -> What's left to do?
                            |  logs/decisions.md    -> Why did we decide X?
                            |  logs/review.md       -> What did reviewers say?
```

Each document serves a distinct purpose, can be updated independently, and provides a clear audit trail.

---

## The Interactive Human-AI Skill

### Phase-Based Collaboration

The skill doesn't just plan - it creates a **structured dialogue** between developer and AI agent:

```
+----------------------------------------------------------------+
|                    DISCOVERY PHASE                              |
|  +----------+    Questions    +----------+                      |
|  |  Human   | <-------------> |   AI     |                      |
|  |Developer |    Answers      |  Agent   |                      |
|  +----------+                 +----------+                      |
|       |                            |                            |
|       |  "What's the context?"     |  Fetches from YouTrack     |
|       |  "Any related issues?"     |  Searches knowledge base   |
|       |  "Existing patterns?"      |  Explores codebase         |
|       v                            v                            |
|  +----------------------------------------------------------+  |
|  |              02-functional-requirements.md                |  |
|  |  * Business context captured                              |  |
|  |  * Uncertainties documented as questions                  |  |
|  |  * Acceptance criteria defined                            |  |
|  +----------------------------------------------------------+  |
+----------------------------------------------------------------+
                              |
                              v
+----------------------------------------------------------------+
|                    PLANNING PHASE                               |
|                                                                 |
|  Human provides:           AI provides:                         |
|  * Constraints             * Pattern analysis                   |
|  * Preferences             * Risk assessment                    |
|  * Domain knowledge        * Implementation options             |
|  * Final decisions         * Technical recommendations          |
|                                                                 |
|       v                            v                            |
|  +----------------------------------------------------------+  |
|  |              03-implementation-plan.md                    |  |
|  |  * Phased approach with clear steps                       |  |
|  |  * Files to create/modify identified                      |  |
|  |  * Testing strategy defined                               |  |
|  |  * Risks documented                                       |  |
|  +----------------------------------------------------------+  |
|                                                                 |
|  +----------------------------------------------------------+  |
|  |              logs/decisions.md                            |  |
|  |  * ADR-style decision records                             |  |
|  |  * Rationale preserved for future reference               |  |
|  |  * Alternatives considered documented                     |  |
|  +----------------------------------------------------------+  |
+----------------------------------------------------------------+
                              |
                              v
+----------------------------------------------------------------+
|                  IMPLEMENTATION PHASE                           |
|                                                                 |
|  +----------+  Progress Updates  +----------+                   |
|  |  Human   | <----------------> |   AI     |                   |
|  |Developer |  Step Approvals    |  Agent   |                   |
|  +----------+                    +----------+                   |
|                                                                 |
|  Single-Step Rule: AI reports -> describes next -> waits        |
|                                                                 |
|       v                            v                            |
|  +----------------------------------------------------------+  |
|  |              00-status.md (continuously updated)          |  |
|  |  * Current phase clearly marked                           |  |
|  |  * Blockers surfaced immediately                          |  |
|  |  * Progress visible at a glance                           |  |
|  +----------------------------------------------------------+  |
|                                                                 |
|  +----------------------------------------------------------+  |
|  |              04-todo.md (real-time checklist)             |  |
|  |  * Granular task tracking                                 |  |
|  |  * Completion status per item                             |  |
|  |  * New discoveries added as found                         |  |
|  +----------------------------------------------------------+  |
+----------------------------------------------------------------+
                              |
                              v
+----------------------------------------------------------------+
|                    REVIEW PHASE                                 |
|                                                                 |
|  External reviews (human, AI, tools) are evaluated:             |
|                                                                 |
|  +----------------------------------------------------------+  |
|  |              logs/review.md                               |  |
|  |  * All review feedback recorded                           |  |
|  |  * Accept/Reject decisions with rationale                 |  |
|  |  * Prevents circular reviews (same points re-raised)      |  |
|  |  * Calibrates future reviewer expectations                |  |
|  +----------------------------------------------------------+  |
+----------------------------------------------------------------+
```

---

## What Makes This Superior

### 1. Persistent Context Across Sessions

**Standard Plan Mode:**
- Context lost when conversation ends
- Must re-explain task each session
- No memory of decisions made

**Task Planning Skill:**
- All context persisted in `${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/`
- Any session can resume with full context
- Decisions preserved in decision log
- Progress tracked across days/weeks

### 2. Separation of Concerns

**Standard Plan Mode:**
- Single document mixes everything
- Hard to find specific information
- Updates affect entire plan

**Task Planning Skill:**
- Each document has one purpose
- Quick access to specific information
- Independent updates without side effects
- Clear audit trail

### 3. Human-AI Collaboration Model

**Standard Plan Mode:**
- AI produces, human accepts/rejects
- Binary interaction
- Human expertise underutilized

**Task Planning Skill:**
- Structured dialogue at each phase
- Human provides domain knowledge, AI provides analysis
- Questions surfaced and answered collaboratively
- Decisions documented with both perspectives

### 4. Multi-Modal Operation

**Standard Plan Mode:**
- One mode: "Plan this"

**Task Planning Skill:**
- **Default Mode**: Planning (existing tasks + new tasks)
- **In Progress Mode**: Reconciliation (sync docs with implementation)
- Mode detected automatically or selected explicitly

### 5. Integration with Development Lifecycle

**Standard Plan Mode:**
- Disconnected from actual development
- No link to issue tracking
- No connection to code reviews

**Task Planning Skill:**
- YouTrack integration for issue context
- Knowledge base integration for domain rules
- Code review skill integration
- Git branch management
- Test execution integration

---

## The Document Ecosystem

```
${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/
|
+-- 00-status.md                 <- ENTRY POINT
|   * Current phase & progress
|   * Quick status for any stakeholder
|   * Links to all other documents
|
+-- 01-task-description.md
|   * Concise summary
|   * Suitable for YouTrack sync
|   * High-level overview
|
+-- 02-functional-requirements.md
|   * Business context & user stories
|   * Acceptance criteria
|   * Uncertainties & questions
|
+-- 03-implementation-plan.md
|   * Technical approach
|   * Phased breakdown
|   * Files to modify
|   * Risk assessment
|
+-- 04-todo.md
|   * Granular implementation checklist
|   * Real-time progress tracking
|   * Discovered items added dynamically
|
+-- logs/
    +-- decisions.md
    |   * ADR-style decision records
    |   * Why we chose X over Y
    |   * Context for future maintainers
    |
    +-- review.md
        * All code review feedback
        * Accept/reject decisions
        * Prevents circular reviews
```

---

## Key Benefits

### For Developers

- **Never lose context**: Resume any task instantly
- **Clear next steps**: Always know what to do next
- **Decision support**: AI analysis + human judgment
- **Progress visibility**: Track completion at any granularity

### For Teams

- **Knowledge transfer**: New team members can understand any task
- **Audit trail**: Full history of decisions and changes
- **Review efficiency**: Reviews build on previous feedback
- **Consistent process**: Same skill across all tasks

### For AI Agents

- **Structured input**: Clear documents to work with
- **Bounded scope**: Each phase has defined outputs
- **Human guidance**: Explicit approval points
- **Context preservation**: Can resume without re-discovery

---

## The Human-AI Partnership

This skill embodies a specific philosophy about human-AI collaboration:

```
+------------------------------------------------------------+
|                                                            |
|   HUMAN STRENGTHS              AI STRENGTHS                |
|   ---------------              ------------                |
|   * Domain expertise           * Pattern recognition       |
|   * Business judgment          * Comprehensive search      |
|   * Priority decisions         * Consistent documentation  |
|   * Creative solutions         * Tireless analysis         |
|   * Stakeholder context        * Code exploration          |
|   * Final authority            * Risk identification       |
|                                                            |
|                    +---------+                             |
|                    | SYNERGY |                             |
|                    +---------+                             |
|                                                            |
|   The skill creates structured touchpoints where        |
|   human insight and AI capability combine:                 |
|                                                            |
|   * Discovery: AI gathers, human validates                 |
|   * Planning: AI analyzes, human decides                   |
|   * Implementation: AI executes, human approves            |
|   * Review: AI evaluates, human accepts/rejects            |
|                                                            |
+------------------------------------------------------------+
```

---

## Comparison Summary

| Aspect | Standard Plan Mode | Task Planning Skill |
|--------|-------------------|----------------------|
| **Documents** | 1 monolithic plan | 7+ specialized documents |
| **Persistence** | Session only | Permanent in `${PROJECT_TASK_DOCS_DIR}/` |
| **Context** | Lost between sessions | Preserved across sessions |
| **Collaboration** | AI produces, human accepts | Structured dialogue |
| **Modes** | Single mode | Default, In Progress |
| **Integration** | Standalone | YouTrack, KB, Git, Tests |
| **Decisions** | Implicit | Explicit decision log |
| **Reviews** | Not supported | Full review skill |
| **Progress** | Not tracked | Real-time status & todo |
| **Resume** | Start over | Instant context reload |

---

## Conclusion

This task planning skill transforms AI assistance from a simple "give me a plan" interaction into a **comprehensive project management partnership**. It recognizes that:

1. **Tasks are complex** - requiring multiple types of documentation
2. **Development is iterative** - requiring persistent context
3. **Humans and AI have different strengths** - requiring structured collaboration
4. **Quality requires review** - requiring feedback integration

The result is a system where human developers and AI agents work together effectively, each contributing their unique capabilities, with full documentation of the journey from idea to implementation.

---

*This skill is purpose-built for the intersection of human intelligence and AI capability - neither replacing the other, but amplifying both.*
