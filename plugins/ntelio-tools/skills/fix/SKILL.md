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

## Step 1 — Read the issue and find the spec

Parse the issue title, body, and comments from the `gh issue view` result above. Understand what needs to be done.

**Check for a linked spec or PRD** in the issue body and comments. Look for references like `docs/plans/SPEC-*.md` or `docs/prd/PRD-*.md`. If found, read them — the spec is the implementation guide. Follow its file list, data model, API design, and test plan. Do not re-design what the spec already decided.

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

**For database changes:**
1. Verify migrations run: connect to SQLite and check schema
2. Test the new queries with sample data

**For client-side changes — decide the testing level:**

Use **curl/manual** when the change is:
- Adding a button, link, or text change to an existing component
- API-only changes with no UI
- Minor CSS tweaks

Use **Playwright** (via the client-debug skill pattern) when the change:
- Creates a new page or significantly changes page layout
- Adds a new interactive component (modal, form, drag-drop)
- Involves multiple UI states (loading, empty, populated, error)
- Is a feature the user would need to visually verify

**Playwright testing steps** (when applicable):
1. Ensure Playwright is available: `NODE_PATH=$(npm root -g) node -e "require('playwright')"`
2. Start a dev server if not running: `python3 -m http.server 8765 &` (or project's serve script)
3. Start the backend server: `node server/index.mjs &`
4. Write a Playwright test script to `/tmp/_fix-test.mjs` that:
   - Opens the page at `http://localhost:8765/index.html#/relevant-route`
   - Logs in if auth is required (use test credentials)
   - Waits for the page to load (networkidle)
   - Takes a screenshot after load
   - Performs the key interactions (click buttons, fill forms, verify DOM state)
   - Takes screenshots at each significant state
   - Captures console errors
5. Run it: `NODE_PATH=$(npm root -g) node /tmp/_fix-test.mjs`
6. Read the screenshots with the Read tool to visually verify
7. If issues found, fix and re-test
8. Clean up: `rm /tmp/_fix-test.mjs`

Show the test output and screenshots in your response. If tests fail, fix the code before proceeding.

## Step 5 — Independent review (mandatory)

Before committing, launch a **fresh Agent** to review the implementation. This agent has NO context from your conversation — it reviews with fresh eyes. This catches issues you've gone blind to.

Use the Agent tool with a prompt like:

```
Review the implementation of issue #{number} on branch {branch}.

1. Read the spec: docs/plans/SPEC-{slug}.md (or PRD if no spec)
2. Read the git diff: run `git diff main --stat` and `git diff main` to see all changes
3. Compare: does the implementation match the spec? Check:
   - Every file listed in the spec — is it created/modified?
   - Every API endpoint — is it wired up correctly?
   - Every UI component — does it match the wireframes?
   - Are there unintended side effects? (modified files not in the spec, removed features, changed behavior in unrelated code)
4. Check for regressions:
   - Were any existing features removed or broken?
   - Were any menu items, routes, or UI elements removed that shouldn't have been?
   - Are there any imports of non-existent modules?
5. Report: list issues found (blocking vs. minor), or confirm "no issues found"
```

**If the agent finds blocking issues, fix them before committing.** Do not skip this step.

## Step 6 — Commit

Stage only the relevant files (never `data/`, `.env`, credentials) and commit:
```
fix: {concise description} (closes #{number})
```

## Step 7 — Push and open a PR

```
git push -u origin {branch}
gh pr create --title "fix: {description}" --body "Closes #{number}\n\n## What\n{changes}\n\n## Test\n{what was tested and results}"
```

## Step 8 — Update the issue

Add a comment to the GitHub issue with useful context for the PR reviewer:
```
gh issue comment {number} --body "PR: #{pr_number}\n\n**Root cause:** {what was wrong}\n**Fix:** {what was changed}\n**Tested:** {what was verified}"
```

## Step 9 — Report back

Show the PR URL and a summary of: what changed, what was tested, what the user needs to configure (if anything).

## Important

- **Do NOT stop mid-implementation.** Complete all phases (backend → pipeline → client) before moving to testing. Do not pause to ask "should I continue?" — run the full spec through to completion.
- If the issue has sub-issues, implement ALL sub-issues in one pass. The branch and PR cover the parent issue.
- If the issue is unclear, ask for clarification BEFORE starting.
- If the fix requires changes outside the issue scope, mention it.
- Do NOT push to `main` directly — always use a PR.
- Do NOT commit without running a real test first.
