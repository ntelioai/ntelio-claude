---
name: fix
description: Fix a specific GitHub issue by number. Use when the user says "/fix 42" or "fix issue #42". Reads the issue, creates a branch, implements, syncs to Scriptr.io, tests, commits, and opens a PR.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent, AskUserQuestion
user-invocable: true
argument: issue number (e.g. "42")
---

# Fix GitHub Issue #$ARGUMENTS

This skill fixes issues on **ntelio platform projects** — Scriptr.io PaaS backend + ntelioMiddleware,
ntelioUI frontend (artbound, commerceGenie, expenseGenie, etc.). The backend runs **on Scriptr.io**,
not locally: nothing is testable until it is **synced**.

## Step 0 — Warm up permissions

Before doing anything else, run all of these in a **single parallel batch** so the user can approve once and walk away:

```
gh issue view $ARGUMENTS --json title,body,comments,labels
git status
git checkout main
cat scriptrExtensionConfig.json
ls setup/sync/ 2>/dev/null
curl --version
```

`scriptrExtensionConfig.json` holds `instanceUrl` and `accessToken` — needed for every sync and test.
The goal: **every tool permission the workflow needs gets requested NOW, not drip-fed later.**

## Step 1 — Read the issue and find the spec

Parse the issue title, body, and comments. Understand what needs to be done.

**Check for a linked spec or PRD** in the issue body and comments — references like `docs/plans/SPEC-*.md`
or `docs/prd/PRD-*.md`. If found, read them — the spec is the implementation guide. Follow its file
list, data model, API design, and test plan. Do not re-design what the spec already decided.

Also read **CLAUDE.md** — it carries the project-specific conventions (schema rules, API prefix, theme,
menu file, sync scripts).

## Step 2 — Create a branch

```
git checkout main && git pull && git checkout -b fix/issue-{number}-{short-slug}
```
Keep the slug to 3-4 words max.

## Step 3 — Implement the fix

Read relevant code, follow CLAUDE.md conventions, keep changes minimal and focused.

**Route work to the specialized agents** — they carry platform knowledge you should not duplicate:
- **Backend** (Scriptr.io scripts, handlers, libraries, schemas) → `scriptrio-developer` agent. CLAUDE.md
  mandates this for all server-side work.
- **Frontend** (ntelioUI pages, widgets, services) → `ntelioui-developer` agent.
- **Pipeline** (YAML ingestion/processing workflows) → `pipeline-developer` agent.

**Platform rules that are NOT optional:**

1. **ES5 only on the backend.** Scriptr.io runs ES5: `var` only, `function(){}` not arrow fns, callbacks
   not async/await, string concatenation not template literals, no destructuring/spread. ES6 is fine in
   `client/`.
2. **Every new file needs a `.metadata` companion.** When creating any file, follow the `/create-file`
   skill's rules to also create `.{filename}.metadata` with the correct ACLs and content type:
   - Frontend (`client/**`, HTML/CSS/JS/SVG/XML) → `read: anonymous`, `execute: nobody`
   - Backend handlers (`openapi/handlers/**`), specs (`openapi/specs/**`), libraries (`**/lib/**`) →
     `read: nobody`, `execute: nobody` (loaded via `require()`, never called directly)
   - Backend entry points → `execute: authenticated` (or `anonymous` only if genuinely public)
   - When unsure of the permission level, **ask the user** before writing the metadata.
3. **APIs follow the spec+handler pattern.** New endpoints = an OpenAPI spec in `openapi/specs/` plus a
   handler in `openapi/handlers/` (project-specific) or `ntelioMiddleware/server/` (shared). Use the
   `/create-api` skill's structure. For a full business object (schema + API + UI), use `/create-fcbo`.
4. **New stores/schemas/groups/channels** go through the ntelioMiddleware setup system — see the
   `/add-setup-resource` skill. Document stores cannot be created programmatically at runtime.
5. **Config values** (keys, secrets, settings) → use the `/configure` skill, never hardcode.

**Do NOT stop mid-implementation.** Complete all phases (backend → pipeline → client) before testing.

## Step 4 — Sync to Scriptr.io

**This is mandatory and easy to forget.** The backend runs on Scriptr.io — until you sync, every test
runs against the OLD remote code, not your changes.

Sync every created or modified file (NOT `.metadata` files — those travel with their parent):

```
./setup/sync/sync-file.sh <path>      # if the project has sync scripts
```

If there are no sync scripts, use the `/sync` skill (MCP `scriptr` sync). Sync backend files, schemas,
specs, handlers, AND client files. Verify each sync reports success.

## Step 5 — Test the fix

This is NOT optional. "It imports cleanly" is not a test. Verify actual behavior.

**For API / backend changes:**
1. Sync first (Step 4).
2. Hit the endpoint with `curl` against the live instance, with debug mode:
   ```
   curl -X POST "https://{instance}/openapi/handlers/v1/{endpoint}?debug_mode=true" \
     -H "Authorization: Bearer {token}" -H "Content-Type: application/json" -d '{...}'
   ```
   Shared/middleware endpoints live under `https://{instance}/ntelioMiddleware/server/api/core/v1/...`.
   The `/test-api` skill does this for you and parses the response.
3. **Check the INNER status.** Scriptr.io wraps responses: the outer `response.metadata.status` is just
   the gateway ("success" if the handler ran at all). The real result is
   `response.result.metadata.status`. A "failure" there with an `errorCode`/`errorDetail` is a real bug.
4. Test happy path AND error cases. `debug_mode=true` returns server-side `scriptLog` — read it.

**For schema / data changes:**
- Confirm the store exists and the schema synced. Create a document via the dataObject endpoint and
  read it back. Watch for `INVALID_SCHEMA` and `STORE_NOT_FOUND` errors.

**For client-side changes — decide the testing level:**

Use **curl / manual** when the change is a button/link/text addition, an API-only change, or a minor
CSS tweak.

Use **Playwright** (via the `/client-debug` skill) when the change creates a new page, adds a new
interactive component, involves multiple UI states, or is something the user would visually verify.
`/client-debug` launches a dev server, runs Playwright against `client/application.html`, captures
screenshots and console errors, and fixes issues in a loop. Use it rather than hand-rolling a server.

Show test output and screenshots in your response. If tests fail, fix the code, **re-sync**, and re-test.

## Step 6 — Independent review (mandatory)

Before committing, launch a **fresh Agent** with no context from this conversation:

```
Review the implementation of issue #{number} on branch {branch}.

1. Read the spec: docs/plans/SPEC-{slug}.md (or PRD if no spec) and CLAUDE.md.
2. Read the diff: `git diff main --stat` and `git diff main`.
3. Spec match: every file, endpoint, schema change, and UI component in the spec — present and correct?
4. Metadata & ACL audit (Scriptr.io):
   - Does EVERY new file have a companion .{name}.metadata file?
   - Backend handlers / openapi specs / lib files → read: nobody, execute: nobody?
   - Backend entry points → execute: authenticated, and ONLY anonymous if genuinely public?
   - Frontend files (client/**) → read: anonymous, execute: nobody?
   - No backend script accidentally readable (read: anonymous) or exposed (execute: anonymous)?
5. ES5 compliance: any arrow functions, const/let, template literals, async/await, destructuring,
   or spread in backend (Scriptr.io) code? Flag every occurrence.
6. Regressions: removed handlers/routes/menu items in client/Main.js, broken require() paths,
   files modified outside the issue scope, imports of non-existent modules.
7. Report blocking vs. minor issues, or confirm "no issues found".
```

**If the agent finds blocking issues, fix them, re-sync, and re-test before committing.**

## Step 7 — Commit

Stage only relevant files (never `data/`, `ENV`, `scriptrExtensionConfig.json`, credentials). Include
`.metadata` files for any new files. Commit:
```
fix: {concise description} (closes #{number})
```

## Step 8 — Push and open a PR

```
git push -u origin {branch}
gh pr create --title "fix: {description}" --body "Closes #{number}\n\n## What\n{changes}\n\n## Test\n{what was tested against the live instance, including endpoints and results}"
```

## Step 9 — Update the issue

```
gh issue comment {number} --body "PR: #{pr_number}\n\n**Root cause:** {what was wrong}\n**Fix:** {what changed}\n**Synced & tested:** {endpoints/pages verified on the live instance}"
```

## Step 10 — Report back

Show the PR URL and a summary: what changed, what was synced and tested, what the user must configure
or verify manually (e.g. a store to create in the console, a config value to set).

## Important

- **Sync before every test.** An untested-because-unsynced change is the #1 failure mode here.
- **Do NOT stop mid-implementation.** Run the full spec through to completion before testing.
- If the issue has sub-issues, implement ALL of them in one pass. The branch and PR cover the parent.
- If the issue is unclear, ask BEFORE starting.
- Do NOT push to `main` directly — always use a PR.
- Do NOT commit without a real test against the live instance.
