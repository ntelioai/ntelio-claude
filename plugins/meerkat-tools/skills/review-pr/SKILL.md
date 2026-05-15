---
name: review-pr
description: Review a GitHub PR as an external reviewer. Reads the diff, finds the linked spec/PRD, checks for regressions, metadata/ACL hygiene, and code quality, and produces a structured review. Designed to keep the human reviewer in the loop — presents findings and asks for the reviewer's judgment, never auto-approves.
allowed-tools: Bash, Read, Glob, Grep, Agent, AskUserQuestion
user-invocable: true
argument: PR number (e.g. "45")
---

# Review PR #$ARGUMENTS

You are helping a **human reviewer** evaluate this PR on an **ntelio platform project** (Scriptr.io
backend + ntelioMiddleware, ntelioUI frontend). Your job is to gather context, surface issues, and
present findings clearly — but the human makes the final call. Do not approve or merge. Do not say
"LGTM" on behalf of the reviewer.

## Step 0 — Gather everything

Run all of these in a **single parallel batch**:

```
gh pr view $ARGUMENTS --json title,body,baseRefName,headRefName,additions,deletions,files,comments,reviews
gh pr diff $ARGUMENTS
git log --oneline -20
```

## Step 1 — Find the spec and context

From the PR body and linked issue:

1. **Find the issue number** — look for "Closes #N", "Fixes #N", or issue references.
2. **Find the spec/PRD** — if an issue is linked, run `gh issue view {N} --json body,comments` and look
   for `docs/plans/SPEC-*.md` or `docs/prd/PRD-*.md`. Read them if found. Also note CLAUDE.md conventions.
3. **Summarize for the reviewer** — a short (5-8 line) context block: what the PR should do (from
   issue/spec), key design decisions from the spec, file/line counts.

## Step 2 — Automated checks

Launch **three parallel Agent subagents** for independent analysis.

### Agent A — Regression check

```
Review PR #$ARGUMENTS for regressions and unintended side effects on an ntelio platform project.

1. Run `gh pr diff $ARGUMENTS` to get the full diff.
2. For every MODIFIED file (not new files), check:
   - Were existing functions, API handlers, or exported symbols REMOVED?
   - Were require() / import paths changed in a way that breaks other consumers?
   - Were default behaviors changed?
3. For every DELETED file, check if anything still require()s or imports it.
4. Look for files modified that seem UNRELATED to the PR description.
5. Client navigation — in client/Main.js, were any menu items or routes removed?
6. API surface — were any OpenAPI specs (openapi/specs/**) or handlers (openapi/handlers/**) removed
   or renamed? A spec filename must still match its collection name.
7. Check for hardcoded URLs, instance names, tokens, or config that changed.

Report each finding as:
- FAIL: {description} — something removed/broken that shouldn't have been
- WARN: {description} — suspicious change, reviewer should look
- PASS: {area} — checked, no issues

Be specific: file path, line number, before vs. after.
```

### Agent B — Metadata & ACL audit (Scriptr.io)

```
Audit PR #$ARGUMENTS for Scriptr.io file metadata and permission correctness.

On Scriptr.io, every file has a companion .{filename}.metadata file that sets its ACLs and content
type. Wrong ACLs either expose code/endpoints publicly or break the app. Check the diff thoroughly.

1. Run `gh pr diff $ARGUMENTS --name-only` to list changed files, and `gh pr diff $ARGUMENTS` for content.
2. EVERY new non-metadata file MUST have a companion .metadata file added in the same PR:
   - For new file `dir/name.ext`, confirm `dir/.name.ext.metadata` is also added.
   - FAIL for any new file with no metadata companion.
   - (Binary images — png/jpg/gif/ico/webp — are the exception: they cannot be synced, no metadata.)
3. Permissions must match the file's role:
   - Frontend / static (client/**, *.html, *.css, browser *.js, *.svg, schemas *.xml) →
     read: anonymous, write: nobody, execute: nobody. FAIL if read: nobody (browser can't fetch it).
   - Backend API handlers (openapi/handlers/**), OpenAPI specs (openapi/specs/**), and libraries
     (**/lib/**, app/ai-tools/**) → read: nobody, write: nobody, execute: nobody. They are loaded via
     require()/file.read() with owner privileges — they must NOT be directly callable.
     FAIL if a handler/lib/spec has execute: authenticated or execute: anonymous, or read: anonymous.
   - Backend entry points (the scripts users actually call over HTTP) → execute: authenticated.
     execute: anonymous is allowed ONLY if the endpoint is genuinely public (webhook, login,
     registration, public storefront). WARN on every execute: anonymous and ask the reviewer to
     confirm the endpoint is meant to be public.
   - Admin-only scripts → execute: group:admin. Platform config → execute: scriptr.
4. A .metadata file must NEVER itself be the target of a sync, and should be committed alongside
   its parent.
5. Backend script source must not be world-readable: FAIL any backend .metadata with read: anonymous.

Report each finding as FAIL / WARN / PASS, with file path and the offending ACL value.
```

### Agent C — Code quality check

```
Review PR #$ARGUMENTS for code quality on an ntelio platform project.

1. Run `gh pr diff $ARGUMENTS` to get the full diff.
2. ES5 compliance — Scriptr.io backend code (openapi/handlers/**, openapi/specs handlers,
   ntelioMiddleware/server/**, app/**, **/lib/** server scripts, setup/**) MUST be ES5:
   - FAIL on arrow functions, const/let, template literals, async/await, destructuring, spread,
     or class syntax in any backend file.
   - Client code (client/**) may use ES6 — do not flag it there.
3. Check for:
   - Dead imports / require() of modules that don't exist or aren't used
   - Copy-pasted blocks (>5 lines duplicated from elsewhere)
   - Syntax errors (unclosed brackets, missing commas)
   - console.log / debug logging left in
   - Hardcoded secrets, API keys, tokens, or instance URLs (should come from config / ENV)
   - module.exports / exports usage in Scriptr.io scripts (NOT supported — FAIL)
   - TODO/FIXME/HACK comments added without an issue reference
4. If a spec exists, check completeness:
   - Every file in the spec's "File list" — is it in the PR?
   - Every API endpoint (spec + handler) in the spec — implemented?
   - Any files in the PR NOT in the spec (scope creep)?

Report each finding as FAIL / WARN / PASS, with file path and line number.
```

## Step 3 — Compile the review

Combine all three agents' results into a structured review:

```
## PR Review: #{pr_number} — {title}

### Context
{context block from Step 1}

### Regression Check
{Agent A findings, grouped by FAIL/WARN/PASS}

### Metadata & ACL Audit
{Agent B findings, grouped by FAIL/WARN/PASS}

### Code Quality
{Agent C findings, grouped by FAIL/WARN/PASS}

### Spec Completeness
{if spec exists: what's implemented vs. missing}
{if no spec: "No spec linked — review based on PR description only"}

### Files Changed
{table: filename | action | metadata? | verdict | notes}

### Overall
- Blocking issues: {count}
- Warnings: {count}
- Clean: {count}
```

## Step 4 — Ask the reviewer

Present the compiled review and ask, using **AskUserQuestion**:

```
Here's the review for PR #{pr_number}. {count} blocking issues, {count} warnings.

{If blocking issues exist, list them:}
1. {issue}
2. {issue}

What's your call?
- "approve" — I'll post an approval review on the PR
- "request changes" — I'll post the review as change requests
- "comment" — I'll post findings as a comment only
- "skip" — don't post anything
```

**Do NOT auto-approve.** Even with zero issues found, still ask — the reviewer may have context you don't.

## Step 5 — Post the review

Based on the reviewer's decision:

- **approve**: `gh pr review $ARGUMENTS --approve --body "{summary}"`
- **request changes**: `gh pr review $ARGUMENTS --request-changes --body "{full review}"`
- **comment**: `gh pr review $ARGUMENTS --comment --body "{full review}"`
- **skip**: Do nothing, just confirm.

Include the full structured review in the body (abbreviated for approve — just the summary line).

## Important

- **You are a tool for the reviewer, not a replacement.** Never make the merge/approve decision yourself.
- **Bias toward surfacing, not suppressing.** When in doubt, WARN rather than PASS. A missed regression
  or an accidentally public endpoint is far worse than an extra warning.
- **The context block matters.** A reviewer opening the PR cold should understand it from your summary
  alone — without hunting for the issue or spec.
- **Watch the patterns that burn ntelio projects:** missing `.metadata` files, a handler/lib exposed
  with `execute: authenticated`/`anonymous`, a backend script readable with `read: anonymous`, ES6 in
  backend code, removed menu items in `client/Main.js`, renamed OpenAPI specs breaking the gateway.
