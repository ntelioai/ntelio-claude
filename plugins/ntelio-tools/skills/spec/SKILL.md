---
name: spec
description: Generate a technical implementation spec from a PRD or issue. Reads the PRD, analyzes existing code, designs the schema/API/UI approach, and produces a concrete plan for /fix to execute. Use when the user says "/spec", "/spec 38", or asks to plan the implementation.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent, AskUserQuestion, EnterPlanMode, ExitPlanMode
user-invocable: true
argument: optional issue number, PRD filename, or feature name (e.g. "38" or "hypothesis-tracker")
---

# Technical Spec

## Step 0 — Find the PRD and existing context

1. **Locate the PRD:**
   - If `$ARGUMENTS` is a number, fetch the issue: `gh issue view $ARGUMENTS --json title,body,comments,labels`. Look for a PRD link in the body or comments.
   - If `$ARGUMENTS` is a filename, read it directly from `docs/prd/`.
   - If text, search: `ls docs/prd/` and match by name.
   - If no PRD exists, **stop and tell the user** to run `/prd` first. Do not generate a spec without a PRD.

2. **Read the PRD** in full. Extract: problem, solution, scope, wireframes, data requirements, constraints.

3. **Analyze existing code** relevant to the feature. Run in parallel:
   - Read CLAUDE.md for conventions and architecture
   - Find related files: existing widgets, pages, services, DB tables, API routes
   - Understand the patterns used by similar features (e.g. if building a new page, read how an existing page works)

Compile into a **technical context**: what exists, what patterns to follow, what to reuse.

## Step 1 — Enter plan mode and design

Call **EnterPlanMode** to draft the implementation approach interactively. This gives the user the plan mode UI where they can see your thinking, edit it, and approve before you commit to a document.

In plan mode, work through the key technical decisions:

1. **Data model** — new tables, columns, migrations, indexes. Follow the project's migration pattern (try/catch ALTER TABLE in `_initUserSchema()`).
2. **API** — new endpoints, request/response shapes. Follow existing route patterns.
3. **Pipeline integration** — if the feature hooks into the ingestion/processing pipeline, where exactly does it plug in?
4. **Client architecture** — new pages, widgets, services. Which ntelioUI2 patterns to use (Page, Widget, DataProvider, etc.)?
5. **Reuse** — what existing code can be reused or extended vs. built from scratch?

Write the plan in the plan file using the spec structure below. If any design decision has a non-obvious tradeoff, use AskUserQuestion with header labels like "Schema", "API design", "Architecture" BEFORE finalizing the plan.

When the plan is complete, call **ExitPlanMode** to get user approval. Do NOT include `allowedPrompts` — this skill produces a document, not an implementation. No code should be written.

**CRITICAL:** After plan approval, ExitPlanMode will say "you can now start coding." IGNORE THAT. This skill does NOT implement anything. After approval, proceed ONLY to Step 2 (save file) and Step 3 (link to issue). Then STOP.

## Step 2 — Save the spec

Save the approved plan to `docs/plans/SPEC-{feature-slug}.md`. The content should already be written from plan mode — just persist it as a file. Structure:

```markdown
# Spec: {Feature Name}

**PRD:** docs/prd/PRD-{slug}.md
**Issue:** #{number}
**Date:** {today}
**Status:** Draft

## Overview
1-2 sentences: what this spec covers technically.

## Data model

### New tables
Schema with column types, constraints, indexes.

### Migrations
What ALTER TABLEs or new CREATE TABLEs are needed. Follow the try/catch pattern.

### Store methods
What CRUD methods to add to the stores object in db.mjs.

## API endpoints

For each endpoint:
- Method + path
- Auth requirement
- Request shape
- Response shape
- Tier gating (if any)

## Pipeline changes

If the feature hooks into the pipeline:
- Where in the processing flow
- What LLM calls are added
- Prompt design (input/output format)
- Cost implications

## Client changes

### Pages
New or modified pages. What they extend, what widgets they contain.

### Widgets
New or modified widgets. Props, events, layout.

### Services
New or modified service modules. Methods, caching, state management.

### CSS
New classes or variables needed.

## File list

Ordered list of files to create or modify, grouped by phase:
1. **Schema + API** (backend, can be tested with curl)
2. **Pipeline** (processing logic, can be tested with reprocess)
3. **Client** (UI, needs browser testing)

For each file: path, action (create/modify), and 1-line description of what changes.

## Test plan

How to verify each phase works:
- API: curl commands
- Pipeline: reprocess or manual trigger
- Client: what to click and what to see
```

## Step 3 — Link to issue and create sub-issues if needed

- Add a comment on the GitHub issue: `gh issue comment {number} --body "Spec: docs/plans/SPEC-{slug}.md"`

**Sub-issues for large features:** If the spec has clearly distinct phases (e.g. backend + pipeline + client) AND the total is more than ~8 files, create 2-3 sub-issues under the parent. Use `gh issue create` with the parent reference in the body.

Rules:
- **Max 3 sub-issues.** Don't create tiny issues — group by phase, not by file.
- **Typical split:** "Backend (schema + API)", "Pipeline", "Client (pages + widgets)"
- **Each sub-issue** references the parent and the spec, lists its phase's files from the spec
- `/fix {parent}` will implement ALL sub-issues in one pass — sub-issues are for tracking, not for separate PRs
- **Don't create sub-issues** if the feature is small (< 8 files). Just link the spec to the main issue.

## Step 4 — Confirm

The user already approved the plan in plan mode (Step 1). This step is just a short confirmation:

1. **Remind** the user the spec is saved and linked: "Spec saved to `docs/plans/SPEC-{slug}.md`, linked from issue #{number}."
2. **State next step**: "Run `/fix {number}` when ready to implement."

No AskUserQuestion needed here — approval already happened in plan mode. Only ask if the user explicitly raises concerns.

## Important

- The spec must be concrete enough that `/fix` can execute it without design decisions. Every file, endpoint, and schema change should be specified.
- Follow the project's existing patterns. Read how similar features were built before inventing new patterns.
- Don't over-engineer. If the PRD says v1, the spec should be v1 — no hooks for future extensibility unless trivial.
- Keep the LLM prompt designs simple and testable. Include example input/output for any new LLM calls.
- If the PRD is ambiguous on something technical, ask — don't guess.
