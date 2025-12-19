# Documentation Update Review Checklist

**Task:** {{ISSUE_KEY}} - {{TASK_SUMMARY}}
**Generated:** {{CURRENT_DATE}}
**Mode:** {{UPDATE_MODE}}

---

## Articles Reviewed

| # | Article | Status | Update Type | Output File |
|---|---------|--------|-------------|-------------|
{{#ALL_ARTICLES}}
| {{INDEX}} | {{ARTICLE_NAME}} | {{STATUS}} | {{UPDATE_TYPE}} | {{OUTPUT_FILE}} |
{{/ALL_ARTICLES}}

---

## Articles Updated

{{#ARTICLES_UPDATED}}

### {{INDEX}}. {{ARTICLE_NAME}}

**Update Type:** {{UPDATE_TYPE}}
**Output File:** `{{OUTPUT_FILE}}`

**Sections Changed:**

{{#SECTIONS}}
- [ ] {{SECTION_NAME}} - {{CHANGE_TYPE}}
{{/SECTIONS}}

**Changes Summary:**

{{CHANGES_SUMMARY}}

**Review Status:** [ ] Reviewed by user

---

{{/ARTICLES_UPDATED}}

## Articles Reviewed (No Update)

{{#ARTICLES_NO_UPDATE}}

### {{INDEX}}. {{ARTICLE_NAME}}

**Status:** No update needed
**Reason:** {{REASON}}

**Verification:** [ ] Confirmed still accurate

---

{{/ARTICLES_NO_UPDATE}}

## Articles Skipped

{{#ARTICLES_SKIPPED}}

### {{INDEX}}. {{ARTICLE_NAME}}

**Status:** Skipped
**Reason:** {{REASON}}

**Action Required:** {{ACTION}}

---

{{/ARTICLES_SKIPPED}}

## Review Summary

| Category | Count | Action |
|----------|-------|--------|
| Updated | {{UPDATED_COUNT}} | Review and sync |
| No Update | {{NO_UPDATE_COUNT}} | None required |
| Skipped | {{SKIPPED_COUNT}} | May need follow-up |

---

## Next Steps

1. [ ] Review each updated article in output folder
2. [ ] Compare updates with original knowledge base articles
3. [ ] Make any additional edits needed
4. [ ] Get approval if required
5. [ ] Sync approved updates to knowledge base
6. [ ] Update task documentation (if applicable)
7. [ ] Archive or delete docs-updates folder when complete

---

## Sign-off

| Action | Completed | Date | By |
|--------|-----------|------|-----|
| Generated | [ ] | {{CURRENT_DATE}} | Claude Code |
| Reviewed | [ ] | | |
| Approved | [ ] | | |
| Synced | [ ] | | |
| Archived | [ ] | | |

---

**Output Location:** `{{OUTPUT_FOLDER}}`
