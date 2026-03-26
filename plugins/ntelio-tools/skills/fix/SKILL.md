---
name: fix
description: Fix a specific GitHub issue by number. Use when the user says "/fix 42" or "fix issue #42". Reads the issue, creates a branch, implements, tests, commits, and opens a PR.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent, AskUserQuestion
user-invocable: true
argument: issue number (e.g. "42")
---

# Fix GitHub Issue #$ARGUMENTS

## Step 0 — Warm up permissions

Before doing anything else, run all of these commands in a **single parallel batch** so the user can approve them once and walk away:

```
gh issue view $ARGUMENTS --json title,body,comments,labels
git status
git checkout main
echo "permissions warm-up"
curl --version
```

If the project has a server start script (e.g. `./server.sh`), include that too. The goal: **every tool permission the workflow will need gets requested NOW, not drip-fed later.**

## Step 1 — Read the issue

Parse the issue title, body, and comments from the `gh issue view` result above. Understand what needs to be done.

## Step 2 — Create a branch

Branch from `main`:
```
git checkout main && git pull && git checkout -b fix/issue-{number}-{short-slug}
```
Keep the slug to 3-4 words max.

## Step 3 — Implement the fix

Read relevant code, understand the context, make the changes. Follow CLAUDE.md conventions. Keep changes minimal and focused.

## Step 4 — Test the fix

This is NOT optional. "It imports cleanly" is not a test. You must verify the actual behavior:

**For API/server changes:**
1. Start the server: `node server/index.mjs &` (or the project's start script)
2. Wait for it to be ready
3. Hit the new/changed endpoints with `curl` and verify correct responses
4. Test both happy path and error cases
5. Kill the server when done

**For client-side changes:**
1. Use Playwright or a headless browser to verify the UI behavior
2. Or if purely logic, write a quick Node script that imports and exercises the changed code

**For database changes:**
1. Verify migrations run: connect to SQLite and check schema
2. Test the new queries with sample data

Show the test output in your response. If tests fail, fix the code before proceeding.

## Step 5 — Commit

Stage only the relevant files (never `data/`, `.env`, credentials) and commit:
```
fix: {concise description} (closes #{number})
```

## Step 6 — Push and open a PR

```
git push -u origin {branch}
gh pr create --title "fix: {description}" --body "Closes #{number}\n\n## What\n{changes}\n\n## Test\n{what was tested and results}"
```

## Step 7 — Update the issue

Add a comment to the GitHub issue with useful context for the PR reviewer:
```
gh issue comment {number} --body "PR: #{pr_number}\n\n**Root cause:** {what was wrong}\n**Fix:** {what was changed}\n**Tested:** {what was verified}"
```

## Step 8 — Report back

Show the PR URL and a summary of: what changed, what was tested, what the user needs to configure (if anything).

## Important

- If the issue is unclear, ask for clarification BEFORE starting.
- If the fix requires changes outside the issue scope, mention it.
- Do NOT push to `main` directly — always use a PR.
- Do NOT commit without running a real test first.
