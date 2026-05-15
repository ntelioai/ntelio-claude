---
name: review-pr
description: Review a GitHub PR as an external reviewer. Reads the diff, finds the linked spec/PRD, checks for regressions and code quality, and produces a structured review. Designed to keep the human reviewer in the loop — presents findings and asks for the reviewer's judgment, never auto-approves.
allowed-tools: Bash, Read, Glob, Grep, Agent, AskUserQuestion
user-invocable: true
argument: PR number (e.g. "45")
---

# Review PR #$ARGUMENTS

You are helping a **human reviewer** evaluate this PR. Your job is to gather context, surface issues, and present findings clearly — but the human makes the final call. Do not approve or merge. Do not say "LGTM" on behalf of the reviewer.

## Step 0 — Gather everything

Run all of these in a **single parallel batch**:

```
gh pr view $ARGUMENTS --json title,body,baseRefName,headRefName,additions,deletions,files,comments,reviews
gh pr diff $ARGUMENTS
git log --oneline -20
```

## Step 1 — Find the spec and context

From the PR body and linked issue:

1. **Find the issue number** — look for "Closes #N", "Fixes #N", or issue references in the PR body.
2. **Find the spec/PRD** — if an issue is linked, run `gh issue view {N} --json body,comments` and look for references to `docs/plans/SPEC-*.md` or `docs/prd/PRD-*.md`. Read them if found.
3. **Summarize for the reviewer** — write a short (5-8 line) context block:
   - What this PR is supposed to do (from issue/spec)
   - Key design decisions from the spec (if any)
   - Number of files changed, lines added/removed

This context block is for the reviewer so they don't have to hunt for plan docs.

## Step 2 — Automated checks

Launch **two parallel Agent subagents** for independent analysis:

### Agent A — Regression check

```
Review PR #$ARGUMENTS for regressions and unintended side effects.

1. Run `gh pr diff $ARGUMENTS` to get the full diff
2. For every MODIFIED file (not new files), check:
   - Were any existing functions, routes, menu items, or UI elements REMOVED?
   - Were any imports changed that could break other consumers?
   - Were any default behaviors changed?
3. For every DELETED file, check if anything still imports or references it
4. Look for files modified that seem UNRELATED to the PR description
5. Check the auth-guard.js PUBLIC_ROUTES — were any public routes removed?
6. Check the nav menu in main.js — were any menu items removed?
7. Check for any hardcoded URLs, paths, or config that changed

Report each finding as:
- FAIL: {description} — something was removed/broken that shouldn't have been
- WARN: {description} — suspicious change, reviewer should look
- PASS: {area} — checked, no issues

Be specific: file path, line number, what was there before, what's there now.
```

### Agent B — Code quality check

```
Review PR #$ARGUMENTS for code quality issues.

1. Run `gh pr diff $ARGUMENTS` to get the full diff
2. Check for:
   - Dead imports (importing modules that don't exist or aren't used)
   - Copy-pasted code blocks (>5 lines duplicated from elsewhere in the codebase)
   - Syntax errors in JS (unclosed brackets, missing commas in objects/arrays)
   - Console.log left in production code
   - Hardcoded secrets, API keys, or credentials
   - TODO/FIXME/HACK comments added without issue references
   - CSS classes or variables that don't follow the project's --tm-* / .tm-* convention
3. If a spec exists, check completeness:
   - Every file listed in the spec's "File list" — is it in the PR?
   - Every API endpoint in the spec — is it implemented?
   - Any files in the PR that are NOT in the spec (scope creep)?

Report each finding as:
- FAIL: {description} — broken code or missing spec requirement
- WARN: {description} — style issue or potential problem
- PASS: {area} — checked, no issues

Be specific: file path, line number, what's wrong.
```

## Step 3 — Compile the review

Combine both agents' results into a structured review. Format:

```
## PR Review: #{pr_number} — {title}

### Context
{context block from Step 1}

### Regression Check
{Agent A findings, grouped by FAIL/WARN/PASS}

### Code Quality
{Agent B findings, grouped by FAIL/WARN/PASS}

### Spec Completeness
{if spec exists: what's implemented vs. what's missing}
{if no spec: "No spec linked — review based on PR description only"}

### Files Changed
{table: filename | action | verdict | notes}

### Overall
- Blocking issues: {count}
- Warnings: {count}
- Clean: {count}
```

## Step 4 — Ask the reviewer

Present the compiled review to the human and ask:

Use **AskUserQuestion** with:

```
Here's the review for PR #{pr_number}. {count} blocking issues, {count} warnings.

{If blocking issues exist:}
The blocking issues are:
1. {issue}
2. {issue}

{Always end with:}
What's your call?
- "approve" — I'll post an approval review on the PR
- "request changes" — I'll post the review as change requests
- "comment" — I'll post findings as a comment only
- "skip" — don't post anything
```

**Do NOT auto-approve.** Even if there are zero issues found, still ask. The human reviewer may have context you don't.

## Step 5 — Post the review

Based on the reviewer's decision:

- **approve**: `gh pr review $ARGUMENTS --approve --body "{summary}"`
- **request changes**: `gh pr review $ARGUMENTS --request-changes --body "{full review}"`
- **comment**: `gh pr review $ARGUMENTS --comment --body "{full review}"`
- **skip**: Do nothing, just confirm.

Include the full structured review in the body (abbreviated for approve — just the summary line).

## Important

- **You are a tool for the reviewer, not a replacement.** Never make the merge/approve decision yourself.
- **Bias toward surfacing, not suppressing.** When in doubt, WARN rather than PASS. False negatives (missed regressions) are far worse than false positives (extra warnings).
- **The context block matters.** A reviewer opening a PR cold should be able to understand what it does from your summary alone — they shouldn't need to go find the issue or spec.
- **Watch for the patterns that burned us before:** removed menu items, removed routes from auth-guard, removed features that weren't in scope to remove, files modified outside the spec scope.
