# Task Planning Templates

This directory contains standardized templates for task planning documentation.

## Purpose

These templates are used by the Task Planning Skill to create consistent documentation structure for all tasks in `${PROJECT_TASK_DOCS_DIR}/{PROJECT_KEY}-XXXX/` folders.

## Template Structure

```
${PROJECT_TASK_DOCS_DIR}/{ISSUE_KEY}-{slug}/
├── 00-status.md                  # Status & Overview (central tracking)
├── 01-task-description.md        # Task Description (high-level overview)
├── 02-functional-requirements.md # Functional Requirements (detailed)
├── 03-implementation-plan.md     # Technical Implementation Plan
├── 04-todo.md                    # Implementation Checklist
└── logs/                         # Activity logs
    ├── decisions.md              # Architectural decisions (ADR-style)
    └── review.md                 # External review feedback
```

## Template Files

### Root Documents
- `00-status.md` - Status & Overview (central tracking document)
- `01-task-description.md` - Task Description (high-level overview)
- `02-functional-requirements.md` - Functional Requirements (detailed)
- `03-implementation-plan.md` - Technical Implementation Plan
- `04-todo.md` - Implementation Checklist

### Logs Subfolder
- `logs/decisions.md` - Decision Log (ADR-style)
- `logs/review.md` - External Review Feedback

## Usage

**Manual**: Copy all templates to new `${PROJECT_TASK_DOCS_DIR}/{PROJECT_KEY}-XXXX/` folder and fill in placeholders.

**Automated**: Use `/plan-task-g` slash command - all templates (including logs folder) are created automatically.

## When Docs Are Created

All documents are created at the start of planning, even if initially empty:
- **Root docs**: Created with boilerplate during Phase 1 (Discovery)
- **logs/decisions.md**: Created empty, populated during Phase 2-3 (Requirements/Planning)
- **logs/review.md**: Created empty, populated during code review skill

## Placeholders

Templates use these placeholders:
- `${ISSUE_KEY}` - Issue key (e.g., STAR-2235)
- `${TASK_SUMMARY}` - Task title from YouTrack
- `${PROJECT_NAME}` - Project name
- `${CURRENT_DATE}` - Current date (YYYY-MM-DD)
- `${GIT_BRANCH}` - Git branch name
- `${PROJECT_*}` - Various project config values

## Customization

Templates can be modified to fit project needs. Keep structure consistent:
- Numbered files indicate processing order
- 00-status.md is always the entry point
- logs/ folder contains append-only activity logs
- All files should reference each other

## Version

Last Updated: 2025-12-10
