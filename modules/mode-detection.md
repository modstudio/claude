# Auto-Detecting Planning Mode

**Module:** Planning Mode Detection
**Version:** 2.0.0

---

## Analyzing Current Context

```bash
# Get current git state
BRANCH=$(get_current_branch)
ISSUE_KEY=$(extract_issue_key_from_branch)

# Detect git workflow state
GIT_STATE=$(detect_git_state)

# Suggest planning mode based on context
SUGGESTED_MODE=$(suggest_planning_mode)
```

---

## Detection Results

**Current Branch:** `${BRANCH:-not in git repo}`
**Issue Key:** `${ISSUE_KEY:-none found}`
**Git State:** `${GIT_STATE:-unknown}`

---

## Planning Mode Suggestion

Based on the current context:

**Suggested Mode:** **${SUGGESTED_MODE}**

### Reasoning

```bash
# Check for existing work
if [ -n "$ISSUE_KEY" ]; then
  TASK_FOLDER=$(find_task_folder "$ISSUE_KEY" 2>/dev/null || echo "")
  COMMITS_AHEAD=$(count_commits_ahead "$PROJECT_BASE_BRANCH" 2>/dev/null || echo "0")
  UNCOMMITTED=$(count_uncommitted_changes 2>/dev/null || echo "0")

  if [ "$COMMITS_AHEAD" -gt 0 ] || [ "$UNCOMMITTED" -gt 0 ]; then
    REASON="Found existing work on branch ($COMMITS_AHEAD commits, $UNCOMMITTED uncommitted changes)"
    SUGGESTED_MODE="in_progress"
  elif [ -n "$TASK_FOLDER" ]; then
    REASON="Planning docs exist at $TASK_FOLDER, but no code changes yet"
    SUGGESTED_MODE="default"
  else
    REASON="Feature branch detected with issue key $ISSUE_KEY, no existing work"
    SUGGESTED_MODE="default"
  fi
else
  REASON="No issue key in branch name - exploratory work"
  SUGGESTED_MODE="greenfield"
fi

echo "Reason: $REASON"
```

---

## Mode Descriptions

### Default Mode
- **When:** Normal workflow, issue exists in YouTrack, starting fresh
- **Process:** Fetch from YouTrack → Plan → Get approval → Implement
- **Use if:** You have an issue key and haven't started coding yet

### Greenfield Mode
- **When:** Exploratory work, prototypes, no issue yet
- **Process:** Gather context from user → Plan → Formalize later
- **Use if:** Experimenting or no YouTrack issue exists yet

### In Progress Mode
- **When:** Resuming work, need to sync docs with implementation
- **Process:** Review existing work → Compare docs vs code → Sync → Continue
- **Use if:** You've already started coding or have commits/changes

---

## Confidence Level

```bash
case "$GIT_STATE" in
  both|commits)
    echo "Confidence: HIGH - Clear evidence of active work"
    ;;
  uncommitted)
    echo "Confidence: MEDIUM - Uncommitted changes detected"
    ;;
  clean)
    if [ -n "$ISSUE_KEY" ]; then
      echo "Confidence: HIGH - Clean state with issue key"
    else
      echo "Confidence: MEDIUM - No issue key detected"
    fi
    ;;
esac
```

---

## Next Step

Present the suggested mode to the user using **AskUserQuestion** tool, allowing them to confirm or choose a different mode.
