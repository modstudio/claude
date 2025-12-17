# Task Checklist - ${ISSUE_KEY}

**Task:** ${TASK_SUMMARY}
**Project:** ${PROJECT_NAME}
**Branch:** `${GIT_BRANCH}`
**Last Updated:** ${CURRENT_DATE}

---

## Planning Phase

### Discovery & Context Gathering
- [ ] Fetch issue from YouTrack
- [ ] Review project standards and architecture
- [ ] Search knowledge base for related documentation
- [ ] Identify similar past implementations
- [ ] Load project configuration

### Requirements Analysis
- [ ] Extract acceptance criteria from issue
- [ ] Identify functional requirements
- [ ] Identify non-functional requirements
- [ ] List edge cases to handle
- [ ] Document open questions
- [ ] Get clarification from stakeholders

### Technical Planning
- [ ] Design technical approach
- [ ] Document architectural decisions
- [ ] Identify files to create/modify/delete
- [ ] Plan database schema changes
- [ ] Define testing strategy
- [ ] Review against architecture standards
- [ ] Review against style guide

### Review & Approval
- [ ] Present plan to stakeholders
- [ ] Address feedback and concerns
- [ ] Get final approval to proceed
- [ ] Create feature branch

---

## Implementation Phase

### Setup
- [ ] Create/checkout feature branch: `${GIT_BRANCH}`
- [ ] Ensure task docs folder exists and is gitignored
- [ ] Update local dependencies if needed

### Core Implementation

#### Phase 1: [First component/feature]
- [ ] Implement [specific functionality]
- [ ] Add input validation
- [ ] Add error handling
- [ ] Write unit tests
- [ ] Test manually

#### Phase 2: [Second component/feature]
- [ ] Implement [specific functionality]
- [ ] Add input validation
- [ ] Add error handling
- [ ] Write unit tests
- [ ] Test manually

#### Phase 3: [Third component/feature]
- [ ] Implement [specific functionality]
- [ ] Add input validation
- [ ] Add error handling
- [ ] Write unit tests
- [ ] Test manually

### Database Changes
- [ ] Create migration files
- [ ] Test migration up
- [ ] Test migration down (rollback)
- [ ] Verify schema changes in database
- [ ] Update models/entities
- [ ] Test database queries

### Integration
- [ ] Integrate all components
- [ ] Wire up dependencies
- [ ] Configure routing/endpoints
- [ ] Add middleware/guards if needed
- [ ] Test integration points

---

## Testing Phase

### Automated Testing
- [ ] Write/update unit tests
- [ ] Run unit test suite: `${PROJECT_TEST_CMD_UNIT}`
- [ ] Write/update integration tests
- [ ] Run full test suite: `${PROJECT_TEST_CMD_ALL}`
- [ ] Verify test coverage meets target (80%+)
- [ ] Fix any failing tests

### Manual Testing
- [ ] Test happy path scenarios
- [ ] Test error scenarios
- [ ] Test edge cases
- [ ] Test with different user roles/permissions
- [ ] Test on different browsers (if applicable)
- [ ] Test responsive design (if applicable)
- [ ] Performance testing
- [ ] Security testing

### Code Quality
- [ ] Run linter/formatter
- [ ] Fix linting errors
- [ ] Run static analysis
- [ ] Address code quality issues
- [ ] Review code for security vulnerabilities

---

## Documentation Phase

### Code Documentation
- [ ] Add/update docblocks for classes
- [ ] Add/update docblocks for methods
- [ ] Add inline comments for complex logic
- [ ] Update type hints/annotations
- [ ] Remove debug code and console.logs

### User Documentation
- [ ] Update API documentation
- [ ] Update user guides
- [ ] Add usage examples
- [ ] Document configuration options
- [ ] Update README if needed

### Task Documentation
- [ ] Update 00-status.md with final status
- [ ] Complete decision log
- [ ] Document any deviations from plan
- [ ] List follow-up tasks if any
- [ ] Add lessons learned

---

## Review Phase

### Self Review
- [ ] Review all changed files
- [ ] Check for commented-out code
- [ ] Check for debug statements
- [ ] Check for hardcoded values
- [ ] Verify error messages are helpful
- [ ] Verify logging is appropriate

### Pre-Commit Checklist
- [ ] All tests passing
- [ ] No linting errors
- [ ] Code reviewed personally
- [ ] Documentation updated
- [ ] No sensitive data in code
- [ ] Migrations tested
- [ ] Ready for peer review

---

## Commit & Push

### Prepare Commits
- [ ] Stage changes in logical groups
- [ ] Create clear, descriptive commit messages
- [ ] Reference issue key in commits
- [ ] Verify no unintended files staged

### Push & Create PR
- [ ] Push branch to remote
- [ ] Create pull request
- [ ] Add PR description with context
- [ ] Link to YouTrack issue
- [ ] Request reviewers
- [ ] Add appropriate labels

---

## Post-Implementation

### Code Review
- [ ] Address reviewer comments
- [ ] Make requested changes
- [ ] Re-request review
- [ ] Get approval from reviewers

### Deployment
- [ ] Merge to ${PROJECT_BASE_BRANCH}
- [ ] Verify CI/CD pipeline passes
- [ ] Monitor deployment
- [ ] Verify in staging environment
- [ ] Deploy to production (if applicable)

### Verification
- [ ] Verify feature works in production
- [ ] Monitor for errors/issues
- [ ] Check performance metrics
- [ ] Gather user feedback

### Cleanup
- [ ] Update YouTrack issue status
- [ ] Close pull request
- [ ] Delete feature branch (local and remote)
- [ ] Archive task folder or update for next iteration
- [ ] Document lessons learned

---

## Notes

Add any additional notes, reminders, or context here.

---

**Created:** ${CURRENT_DATE}
**Issue:** [${ISSUE_KEY}](${PROJECT_YOUTRACK_URL}/issue/${ISSUE_KEY})
