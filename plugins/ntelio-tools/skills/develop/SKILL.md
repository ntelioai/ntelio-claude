---
name: develop
description: Drive a feature through the full development workflow — PRD, spec, implementation. Enforces the model where each step must exist before the next. Use when the user says "/develop", "/develop 38", or wants to build a feature end-to-end.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent, AskUserQuestion, EnterPlanMode, ExitPlanMode
user-invocable: true
argument: optional issue number or feature description (e.g. "38" or "hypothesis tracker")
---

# Develop Feature

This skill orchestrates the full development workflow: PRD → Spec → Fix.
It enforces the model — you cannot skip steps. Each phase must be completed and approved before the next begins.

## Step 0 — Identify the feature

1. If `$ARGUMENTS` is a number, fetch the issue: `gh issue view $ARGUMENTS --json title,body,comments,labels`
2. If `$ARGUMENTS` is text, search for a matching issue: `gh issue list --search "$ARGUMENTS" --json number,title --limit 5`
3. If no issue exists, tell the user: "No issue found. I'll create one during the PRD phase."

Extract the issue number (if any) and scan comments for existing artifacts:
- Look for `docs/prd/PRD-*.md` links → PRD exists
- Look for `docs/plans/SPEC-*.md` links → Spec exists
- Check if a PR already exists: `gh pr list --search "#{number}" --json number,title --limit 3`

Report what exists and what's missing.

## Step 1 — PRD

**If PRD exists:** Read it, summarize in 3-5 bullets, show wireframes if any, and ask: "PRD already exists. Continue to spec, or update it first?"

**If PRD does not exist:** Tell the user: "Starting with the PRD — I'll ask a few questions to scope the feature."

Then run the `/prd` workflow:
1. Gather context (issue, docs, code)
2. Interview for gaps (2-4 questions per round)
3. Assess wireframe need
4. Write PRD to `docs/prd/PRD-{slug}.md`
5. Link to issue
6. Review gate: summary + wireframes + key decisions

**Do NOT proceed to Step 2 until the user approves the PRD.**

## Step 2 — Spec

**If Spec exists:** Read it, summarize the approach in 3-5 bullets, and ask: "Spec already exists. Continue to implementation, or update it first?"

**If Spec does not exist:** Tell the user: "PRD approved. Now designing the technical spec."

Then run the `/spec` workflow:
1. Read the PRD
2. Analyze existing code patterns
3. Enter plan mode — design schema, API, pipeline, client
4. User approves plan
5. Save to `docs/plans/SPEC-{slug}.md`
6. Link to issue
7. Create sub-issues if >8 files

**Do NOT proceed to Step 3 until the user approves the spec.**

## Step 3 — Implement

Tell the user: "Spec approved. Starting implementation."

Then run the `/fix` workflow:
1. Create branch
2. Implement all phases (backend → pipeline → client) without stopping
3. Test: curl for API, Playwright for new pages
4. Independent review agent
5. Commit, push, open PR
6. Comment on issue

## Step 4 — Done

Report:
- PR URL
- What was built (summary from spec)
- What was tested
- What needs manual verification

## Important

- **Never skip a step.** If the user says "just implement it", explain that the PRD and spec exist to prevent regressions and scope creep, then offer to make them lightweight.
- **Each step has a review gate.** The user must approve before moving on. Don't rush through approvals.
- **If the feature is trivial** (< 4 files, no UI, no ambiguity): tell the user "This looks small enough to skip PRD/spec and go straight to /fix. Want to do that?" Only skip if they agree.
- **Resume where you left off.** If a PRD exists but no spec, start at Step 2. If both exist, start at Step 3.
- **The user drives the pace.** Between steps, wait for explicit approval. Don't auto-advance.
