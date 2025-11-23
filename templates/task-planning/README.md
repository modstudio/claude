# Task Planning Templates

This directory contains standardized templates for task planning documentation.

## Purpose

These templates are used by the Task Planning Workflow (`.ai/workflows/task-planning.md`) to create consistent documentation structure for all tasks in `.wip/{PROJECT_KEY}-XXXX/` folders.

## Template Files

- `00-status.md` - Status & Overview (central tracking document)
- `01-functional-requirements.md` - Business Requirements
- `02-decisions.md` - Decision Log (ADR-style)
- `03-implementation-plan.md` - Technical Implementation Plan
- `04-task-description.md` - Task Summary (for YouTrack)
- `05-todo.md` - Implementation Checklist

## Usage

**Manual**: Copy all templates to new `.wip/{PROJECT_KEY}-XXXX/` folder and fill in placeholders.

**Automated**: Use `/plan-task` slash command - templates are copied automatically.

## Placeholders

Templates use these placeholders:
- `XXXX` - Issue number (e.g., 2235)
- `[Title]` - Task title from YouTrack
- `YYYY-MM-DD` - Current date
- `[Description]` - Descriptive text
- `{type}` - Branch type (feature, fix, etc.)
- `{slug}` - Issue slug from YouTrack

## Customization

Templates can be modified to fit project needs. Keep structure consistent:
- Numbered files (00-05) indicate processing order
- 00-status.md is always the entry point
- All files should reference each other

## Version

Last Updated: 2025-11-14
