---
name: prd
description: Generate a lightweight PRD for a feature. Gathers context from GitHub issues and docs, interviews the user to fill gaps, writes a focused PRD, and runs a review gate. Use when the user says "/prd", "/prd 30", or asks to write requirements for a feature.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent, AskUserQuestion
user-invocable: true
argument: optional issue number or feature name (e.g. "30" or "geography markers")
---

# Write PRD

## Step 0 — Gather existing context

Search for existing material about this feature. Run these in parallel:

1. **GitHub issue** — If `$ARGUMENTS` is a number, run `gh issue view $ARGUMENTS --json title,body,comments,labels`. If it's text, search: `gh issue list --search "$ARGUMENTS" --json number,title,body --limit 5`
2. **Docs** — Search `docs/` for related files: `grep -rl "$ARGUMENTS" docs/`, check `docs/prd/` for an
   existing PRD and `docs/roadmap/` for matching plans. Also read **CLAUDE.md** for project context.
3. **Code** — Quick scan for existing implementation: related schemas in `setup/schema/`, API specs in
   `openapi/specs/`, pipeline workflows in `pipeline/`, client pages/widgets in `client/`.

Compile what you find into a **context brief**: what's known, what's built, what's missing.

## Step 1 — Interview (fill the gaps)

**This is the REQUIREMENTS GATHERING phase.** Tell the user: "I'm going to ask a few questions to fill in the gaps before writing the PRD."

Based on the context brief, identify what's NOT yet clear. Ask the user **only about gaps** — skip anything already answered by the issue, docs, or code.

Use AskUserQuestion with concrete, specific questions. Use header labels like "Location", "Data", "Scope", "Tier" — short nouns that describe the topic, NOT "Interview" or "Question 1".

Never ask vague questions like "describe your feature." Instead ask things like:

- "What triggers this? User clicks X, auto on page load, background job?"
- "Where does this live — new page, existing page section, overlay, widget?"
- "What data drives it? We already have X in the DB — is that enough or do we need Y?"
- "What's the minimum useful version? All of this, or would just X be enough for v1?"

**Question categories** (ask only what's missing):

1. **Goal** — What problem does this solve? What does success look like?
2. **Experience** — What does the user see/do? Where in the app? What's the interaction?
3. **Data** — What data is needed? Do we have it? What's the source?
4. **Scope** — What's in v1 vs later? What's explicitly out?
5. **Constraints** — Tier gating? Performance requirements? Platform limits?

Ask 2-4 questions per round. Do multiple rounds if needed, but prefer fewer rounds with well-chosen questions. If the issue + docs already cover most of it, you may need zero or one round.

**IMPORTANT:** Resolve ALL requirements questions in this step. Do not mix requirements gathering with the review gate in Step 5 — they are different phases. If you discover data model or scoping questions while writing the PRD, come back here and ask them BEFORE writing, not after.

## Step 2 — Assess wireframe need

Decide whether ASCII wireframes are needed. The rule:

- **Creating a new UI component or page** (new card type, new page, new panel) → wireframe required
- **Adding to or composing existing components** (new button, new field, new link, content change) → skip wireframe
- **Significantly changing the layout or interaction of an existing component** → wireframe required

If wireframes are needed, create them in the PRD using ASCII art. Show the key states (empty, loaded, interactive).

## Step 3 — Write the PRD

Save **in the project** at `docs/prd/PRD-{feature-slug}.md` — never to an external Claude plans
directory. Keeping the PRD in-repo means it can be referenced from the issue and revisited later.
Structure:

```markdown
# PRD: {Feature Name}

**Issue:** #{number} (if exists)
**Date:** {today}
**Status:** Draft

## Problem
2-3 sentences. What's broken or missing? Who feels the pain?

## Solution
High-level approach in 3-5 sentences. What will we build?

## User stories
As a {user}, I want {action} so that {benefit}.
(Primary flows only — 3-5 stories max)

## In scope (v1)
Bulleted list of what's included.

## Out of scope
Bulleted list of what's explicitly NOT in this version and why.

## Wireframes
(Only if Step 2 determined they're needed)
ASCII wireframes showing key states.

## Success criteria
How do we know this works? Measurable where possible.

## Data requirements
What data is needed, where it comes from, any new tables/fields.

## Constraints
Tier gating, performance, platform limits, dependencies.
```

That's it. No competitive analysis, no appendix, no market context, no changelog.

## Step 4 — Link to GitHub issue

The PRD MUST be referenced from a GitHub issue so it is findable later.
- If a GitHub issue exists, add a comment linking to the PRD: `gh issue comment {number} --body "PRD: docs/prd/PRD-{slug}.md"`
- If no issue exists, create one: `gh issue create --title "{feature name}" --body "PRD: docs/prd/PRD-{slug}.md\n\n{1-line summary}"`

## Step 5 — Review gate

**This is the PRD REVIEW phase — clearly separate from the interview.** Tell the user: "The PRD is written. Here's a review of the key decisions — please confirm or push back."

First, give a plain text summary:

1. **Summarize** the PRD in 3-5 bullet points (the essence, not a rehash)
2. **Show wireframes inline** — if the PRD includes wireframes, display them directly in the conversation. Wireframes are a major part of what the PRD provides and the user must see and react to them without opening a separate file.
3. **List key decisions** you made:
   - "I scoped out X for v1 — because Y"
   - "I assumed Z based on the issue"
   - "Data model: chose A over B because C"

Then use AskUserQuestion with headers like "PRD Review" or "Confirm" — labels that make it obvious this is review, not requirements gathering. Only ask about decisions where you genuinely need confirmation — things where you made a judgment call that could reasonably go either way.

Do NOT re-ask requirements questions here. If you realize you're missing requirements info, go back to Step 1 instead.

If the user requests changes, update the PRD and re-run the review gate.

## Important

- Keep it lightweight. A PRD should take 5-10 minutes, not an hour.
- The PRD is a communication tool for the `/spec` skill — write for a technical reader.
- Don't invent requirements the user didn't express. When in doubt, ask.
- Don't duplicate information already in the GitHub issue — reference it.
- If the feature is trivial (< 1 day of work, no UI, no ambiguity), tell the user a PRD is overkill and suggest going straight to `/spec` or `/fix`.
