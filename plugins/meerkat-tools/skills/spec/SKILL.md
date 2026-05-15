---
name: spec
description: Generate a technical implementation spec from a PRD or issue. Reads the PRD, analyzes existing code, designs the schema/API/UI approach, and produces a concrete plan for /fix to execute. Use when the user says "/spec", "/spec 38", or asks to plan the implementation.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent, AskUserQuestion, EnterPlanMode, ExitPlanMode
user-invocable: true
argument: optional issue number, PRD filename, or feature name (e.g. "38" or "auction-bidding")
---

# Technical Spec

This skill produces an implementation spec for an **ntelio platform project** — Scriptr.io PaaS backend
+ ntelioMiddleware, ntelioUI frontend. The spec must be concrete enough that `/fix` can execute it
without further design decisions.

## Step 0 — Find the PRD and existing context

1. **Locate the PRD:**
   - If `$ARGUMENTS` is a number, fetch the issue: `gh issue view $ARGUMENTS --json title,body,comments,labels`. Look for a PRD link in the body or comments.
   - If `$ARGUMENTS` is a filename, read it from `docs/prd/`.
   - If text, search: `ls docs/prd/` and match by name.
   - If no PRD exists, **stop and tell the user** to run `/prd` first. Do not generate a spec without a PRD.

2. **Read the PRD** in full: problem, solution, scope, wireframes, data requirements, constraints.

3. **Analyze existing code.** Run in parallel:
   - Read **CLAUDE.md** — platform conventions, schema rules, API gateway structure, agent guidance.
   - Find related code: existing schemas in `setup/schema/`, specs in `openapi/specs/`, handlers in
     `openapi/handlers/`, pipeline workflows in `pipeline/`, client pages/widgets in `client/`.
   - Read how a *similar existing feature* was built — copy its patterns rather than inventing new ones.

Compile a **technical context**: what exists, what patterns to follow, what to reuse.

## Step 1 — Enter plan mode and design

Call **EnterPlanMode** to draft the approach interactively. Work through the key decisions, all in
ntelio platform terms:

1. **Data model** — XML schemas in `setup/schema/`. Follow the strict Scriptr.io schema rules from
   CLAUDE.md: `aclGroups` ordering (named groups → `defaultAcl` → `schemaAcl`), every field listed in
   exactly one aclGroup (no `*` wildcard), `cardinality` not `<required>`, `regex` not enumerations.
   New document stores are provisioned via the setup system (`/add-setup-resource`), not at runtime.
2. **API** — new endpoints as an OpenAPI spec in `openapi/specs/` + handler in `openapi/handlers/`
   (project-specific) or `ntelioMiddleware/server/` (shared). Spec filename must match the collection
   name. Define request/response shapes and auth level. For a full CRUD business object, plan it as a
   `/create-fcbo` (schema + API + UI together). Backend code is **ES5 only**.
3. **Pipeline integration** — if the feature hooks the ingestion/processing pipeline, specify where in
   the YAML workflow it plugs in and what steps/LLM calls are added.
4. **Client architecture** — new pages/widgets/services using ntelioUI. Specify which provider:
   `EntityDataProvider` for business objects (data-store entities), `ApiDataProvider` for custom API
   calls. Menu changes go in `client/Main.js`. Note any new icons (SVG strings in `client/lib/utils/Icons.js`).
5. **Metadata & ACLs** — for every file the spec will create, state its intended ACL: frontend files
   `read: anonymous`, handlers/specs/libs `nobody/nobody`, entry points `execute: authenticated` (or
   `anonymous` only if truly public). `/fix` creates `.metadata` companions accordingly.
6. **Reuse** — what existing code to reuse or extend vs. build from scratch.

If any decision has a non-obvious tradeoff, use AskUserQuestion (headers like "Schema", "API design",
"Architecture") BEFORE finalizing.

Call **ExitPlanMode** for approval. Do NOT include `allowedPrompts` — this skill produces a document,
not an implementation.

**CRITICAL:** After approval, ExitPlanMode will say "you can now start coding." IGNORE THAT. This skill
does NOT implement anything. After approval, proceed only to Step 2 (save) and Step 3 (link), then STOP.

## Step 2 — Save the spec

Save the approved plan **in the project** at `docs/plans/SPEC-{feature-slug}.md` (keeping it in-repo so
it can be referenced later). Structure:

```markdown
# Spec: {Feature Name}

**PRD:** docs/prd/PRD-{slug}.md
**Issue:** #{number}
**Date:** {today}
**Status:** Draft

## Overview
1-2 sentences: what this spec covers technically.

## Data model

### Schemas
XML schema files (setup/schema/{name}.xml): fields, types, validation, aclGroups.

### Stores
Document stores to provision via the setup system. Note each store cannot be created at runtime.

## API endpoints

For each endpoint:
- Method + path (openapi/handlers/... for project, ntelioMiddleware/server/... for shared)
- OpenAPI spec file (openapi/specs/{collection}.json)
- Auth level (execute: authenticated / anonymous)
- Request shape, response shape

## Pipeline changes

If the feature hooks the pipeline:
- Which YAML workflow, where in the flow
- Steps / LLM calls added, prompt design (example input/output)

## Client changes

### Pages / Widgets
New or modified pages and widgets. What they extend, layout, which DataProvider.

### Services
New or modified service modules.

### Menu / Icons / CSS
Changes to client/Main.js menu, new SVG icons, new CSS classes in client/css/.

## File list

Ordered, grouped by phase. For each file: path, action (create/modify), 1-line description, and
**intended metadata ACL** (frontend / handler / spec / lib / entry point).
1. **Schema + setup** (stores, schemas)
2. **API** (specs + handlers — testable with curl after sync)
3. **Pipeline** (workflow changes)
4. **Client** (pages, widgets, menu — needs browser testing)

## Test plan

How to verify each phase AFTER syncing to Scriptr.io:
- API: curl commands against https://{instance}/... with debug_mode=true, expected inner status
- Pipeline: how to trigger / reprocess
- Client: what to open in client/application.html and what to see
```

## Step 3 — Link to the issue and create sub-issues if needed

- Add a comment on the GitHub issue: `gh issue comment {number} --body "Spec: docs/plans/SPEC-{slug}.md"`.
  The spec MUST be referenced from the issue so it is findable later.

**Sub-issues for large features:** if the spec has clearly distinct phases AND totals more than ~8
files, create 2-3 sub-issues under the parent (`gh issue create` with the parent reference).
- **Max 3 sub-issues.** Group by phase, not by file. Typical split: "Backend (schema + API)",
  "Pipeline", "Client (pages + widgets)".
- Each sub-issue references the parent and the spec.
- `/fix {parent}` implements ALL sub-issues in one pass — sub-issues are for tracking, not separate PRs.
- Don't create sub-issues for small features (< 8 files); just link the spec to the main issue.

## Step 4 — Confirm

The user already approved the plan in plan mode. This is just a short confirmation:
1. "Spec saved to `docs/plans/SPEC-{slug}.md`, linked from issue #{number}."
2. "Run `/fix {number}` when ready to implement."

No AskUserQuestion here — approval already happened. Only ask if the user raises concerns.

## Important

- The spec must be concrete enough that `/fix` executes it without design decisions. Every file,
  endpoint, schema change, and metadata ACL should be specified.
- Follow the project's existing patterns. Read how similar features were built before inventing new ones.
- Backend is ES5; design accordingly. Document stores are provisioned, not created at runtime.
- Don't over-engineer. If the PRD says v1, the spec is v1 — no extensibility hooks unless trivial.
- If the PRD is ambiguous on something technical, ask — don't guess.
