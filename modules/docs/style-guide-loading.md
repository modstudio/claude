# Module: style-guide-loading

## Purpose
Discover and load documentation style guides for consistent knowledge base updates.

## Scope
DOCS - Used by: update-docs skills (task-mode, article-mode)

## Mode
READ-ONLY

---

## When to Use
- Before creating or updating any knowledge base article
- At the start of update-docs skill
- When verifying documentation changes against project standards

---

## Inputs
- `PROJECT_KB_LOCATION` - Knowledge base directory from project config
- `PROJECT_STANDARDS_DIR` - Standards directory (may contain doc guidelines)

---

## Instructions

### Step 1: Locate Style Guide

Style guides can be in multiple locations:

```bash
# Primary: Dedicated doc style guide
STYLE_GUIDE_PRIMARY="$PROJECT_KB_LOCATION/Documentation-Style-Guide.md"

# Secondary: Within standards directory
STYLE_GUIDE_SECONDARY="$PROJECT_STANDARDS_DIR/50-documentation.md"

# Tertiary: Project root
STYLE_GUIDE_TERTIARY="$PROJECT_ROOT/docs/STYLE_GUIDE.md"

# Find first available
STYLE_GUIDE=""
for guide in "$STYLE_GUIDE_PRIMARY" "$STYLE_GUIDE_SECONDARY" "$STYLE_GUIDE_TERTIARY"; do
  if [[ -f "$guide" ]]; then
    STYLE_GUIDE="$guide"
    break
  fi
done
```

### Step 2: Load Style Guide Content

```bash
if [[ -n "$STYLE_GUIDE" ]]; then
  echo "Loading style guide from: $STYLE_GUIDE"
  # Read the style guide content
else
  echo "No style guide found - using default guidelines"
fi
```

### Step 3: Extract Key Rules

From the style guide, identify:

**Writing Style:**
- Tone (formal/conversational)
- Voice (active/passive)
- Tense (present/past)
- Person (first/second/third)

**Formatting:**
- Header conventions (sentence case, title case)
- Code block formatting
- List styles
- Link conventions

**Structure:**
- Required sections
- Section ordering
- Section templates

---

## Default Guidelines (When No Style Guide Found)

If no project-specific style guide exists, apply these defaults:

### Writing Style
- Use **present tense** for all implemented features
- Use **active voice** where possible
- Write for **non-technical users** when appropriate
- Keep language **clear and accessible**
- Avoid jargon or explain when used

### Formatting
- Use **sentence case** for headers
- Use **code blocks** for all code examples
- Use **tables** for structured data
- Use **numbered lists** for sequential steps
- Use **bullet lists** for non-sequential items

### Required Elements
- **Summary of Changes** at end of every updated document
- **Code verification status** noting which files were reviewed
- **Date of update** in metadata or summary

---

## Output Format

After loading style guide, present summary:

```markdown
## Documentation Style Guide

**Source:** {path to style guide or "Using defaults"}

### Key Rules
- Tense: {Present/Past}
- Voice: {Active/Passive}
- Audience: {Technical/Non-technical/Mixed}

### Required Sections
- {List required sections for articles}

### Verification
- [ ] Style guide loaded
- [ ] Key rules understood
- [ ] Ready to apply to documentation
```

---

## Integration with Update Workflows

Reference this module in update-docs workflows:

```markdown
## Step X: Load Documentation Standards

{{MODULE: ~/.claude/modules/docs/style-guide-loading.md}}

Before making any updates, ensure style guide rules are loaded and understood.
```

---

## Outputs
- `STYLE_GUIDE`: Path to loaded style guide (or empty)
- `STYLE_GUIDE_LOADED`: true/false
- Key rules extracted and ready for application

---

**End of Module**
