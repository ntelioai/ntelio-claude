# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working in the **ntelio-claude** repository — the source of the shared Claude Code plugin marketplace for ntelio platform development.

## What This Repo Is

A Claude Code **plugin marketplace** consumed by every ntelio project (commerceGenie, privateGPT, themeerkat, …). Users install from it via:

```
claude plugin install ntelio-tools@ntelio-claude
```

Changes here reach users **only when they update their installed plugin**, and Claude Code only offers an update **when the plugin's version number increases**.

## Structure

```
.claude-plugin/marketplace.json      # Marketplace manifest — lists every plugin WITH ITS VERSION
plugins/
  ntelio-tools/                      # Core platform plugin (skills, agents, MCP servers)
    .claude-plugin/plugin.json       # Plugin manifest — name, VERSION, description
    skills/                          # /sync, /create-api, /create-migration, /add-setup-resource, …
    agents/                          # scriptrio-developer, pipeline-developer, ntelioui-developer
    servers/                         # MCP server definitions
  commercegenie-tools/               # CommerceGenie-specific skills
  meerkat-tools/                     # Feature-workflow skills (prd, spec, develop, review-pr, fix)
docs/                                # Shared reference docs (scriptr.io modules, guides)
```

## RULE: Every Change Bumps the Version — No Exceptions

Any change inside a plugin directory (skill, agent, server, docs it ships) MUST, **in the same commit**:

1. Bump `version` in that plugin's `.claude-plugin/plugin.json`
2. Bump the matching entry in `.claude-plugin/marketplace.json` (same value — the two must never diverge)

Without the bump, installed copies never learn an update exists and the change silently reaches no one.

**Versioning (semver-ish):**
- **Patch** (1.9.0 → 1.9.1): typo/doc fixes, small wording changes inside an existing skill
- **Minor** (1.9.0 → 1.10.0): new skill/agent/server, new sections or rules in existing ones
- **Major** (1.x → 2.0.0): removed/renamed skills or agents, breaking workflow changes

After pushing, tell the team to run their plugin update so the change actually lands.

## Agent Definitions

Agents live in `plugins/<plugin>/agents/*.md` with YAML frontmatter (`name`, `description`, optional `tools`, `model`, `color`). **Never** keep agent definitions in personal `~/.claude/agents/` — user-level copies shadow the plugin's and drift silently.

## Skill Conventions

- Each skill is `plugins/<plugin>/skills/<name>/SKILL.md` with frontmatter (`name`, `description`, `allowed-tools`).
- Write descriptions that state **when to trigger** — they're the matching surface.
- Cross-reference sibling skills where workflows pair (e.g. `/add-setup-resource` ↔ `/create-migration`).
