# Update Plan Command

## Purpose
This command ensures that the development plan is always kept up to date after any significant work or changes.

## Instructions for Claude
After completing any development work, architectural changes, bug fixes, or feature implementations, you MUST:

1. **Read the current PLAN.md** to understand the existing state
2. **Update the "Completed Tasks ✅" section** with what was just accomplished
3. **Update the session notes** with a new entry for the current date/session
4. **Modify the "Ready for next session" line** to reflect the next logical step
5. **Update any "In Progress" or "Upcoming Tasks" sections** as needed
6. **Add any new insights or technical decisions** discovered during the work

## When to Use
- After implementing new features
- After major refactoring or architecture changes
- After fixing significant bugs
- After adding new dependencies or tools
- After completing testing work
- At the end of any substantial coding session

## Format for Session Notes
```markdown
### YYYY-MM-DD Session N - [Brief Description]
- **Key accomplishment**: Brief description of main work
- Detailed bullet points of what was done
- Any technical decisions made
- Any problems encountered and solved
- **Ready for next session**: Next logical step
```

## Remember
The PLAN.md file is our project's memory and roadmap. Keeping it updated ensures continuity between sessions and helps track our progress toward the final AI-powered photo transformation app.