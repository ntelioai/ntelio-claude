---
name: fix-issues
description: Find and fix all open GitHub issues labeled `claude` or with @claude mentions. Use when the user says "/fix-issues" to batch-process issues autonomously.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent, AskUserQuestion
user-invocable: true
---

# Fix All @claude GitHub Issues

## Step 0 — Warm up permissions

Run all of these in a **single parallel batch** so the user approves once:

```
gh issue list --state open --label claude --json number,title
git status
git checkout main
echo "permissions warm-up"
curl --version
node -e "console.log('node ok')"
```

If the project has a server start script, include it. **Every permission the workflow needs gets requested NOW.**

## Step 1 — Find eligible issues

```
gh issue list --state open --label claude --json number,title,body,labels
gh issue list --state open --search "@claude in:comments" --json number,title,body,labels
```
Combine and deduplicate.

## Step 2 — Show the list and confirm

Display all found issues (number + title). If more than 5, ask before proceeding. If none found, say so and stop.

## Step 3 — For each issue

a. Read the full issue: `gh issue view {number}`
b. Create a branch: `fix/issue-{number}-{short-slug}` from `main`
c. Implement the fix following CLAUDE.md conventions
d. **Test the fix** — This is NOT optional:
   - For API changes: start server, `curl` the endpoints, verify responses
   - For client changes: use Playwright or a Node script to exercise the code
   - For DB changes: verify schema and test queries
   - Show test output. If tests fail, fix before committing.
e. Commit: `fix: {description} (closes #{number})`
f. Push and open PR:
   ```
   gh pr create --title "fix: {description}" --body "Closes #{number}\n\n## What\n{changes}\n\n## Test\n{what was tested}"
   ```
g. Comment on the issue with context for the reviewer:
   ```
   gh issue comment {number} --body "PR: #{pr_number}\n\n**Root cause:** {what was wrong}\n**Fix:** {what was changed}\n**Tested:** {what was verified}"
   ```
h. Switch back to `main` before the next issue

## Step 4 — Summary

After all issues, show a table:
- Issue # | Title | PR URL | Status (fixed / skipped / needs-clarification)

## Important

- Always return to `main` between issues.
- If an issue is unclear, skip it and mark "needs-clarification".
- Do NOT push to `main` directly.
- Stop and ask if more than 5 issues found.
- Do NOT commit without a real test passing first.
