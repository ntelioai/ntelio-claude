# ntelio Claude Code Plugin - Implementation Plan

## Overview

A shared Claude Code plugin providing skills, agents, and documentation for all ntelio-based projects. The plugin lives in `ntelioMiddleware/.claude/` and is symlinked to consuming projects.

## Architecture

```
ntelioMiddleware/.claude/              # Shared plugin (canonical)
├── skills/
│   ├── create-api/
│   │   └── SKILL.md                   # API creation skill
│   ├── create-fcbo/
│   │   └── SKILL.md                   # Business object skill
│   ├── sync/
│   │   └── SKILL.md                   # Scriptr.io sync skill
│   └── test-api/
│       └── SKILL.md                   # API testing skill
├── agents/
│   └── ntelioui-developer.md          # Frontend agent definition
├── docs/
│   └── scriptr.io/                    # Platform reference (move here)
└── settings.json                      # Shared settings template

commerceGenie/.claude/                  # Project-specific
├── skills/
│   └── prd-writer/                    # Keep project-specific skills
├── settings.local.json                # Project overrides
└── -> ntelioMiddleware/.claude/       # Symlink to shared (planned)
```

## Skills Implementation

### 1. /create-api

**Purpose**: Create a new API endpoint following the API Gateway patterns.

**Inputs**:
- Collection name (e.g., "orders", "products")
- Endpoint path (e.g., "/list", "/{key}/details")
- HTTP method (GET, POST, PUT, DELETE)
- Location: CommerceGenie-specific (`openapi/`) or shared (`ntelioMiddleware/`)

**Outputs**:
- OpenAPI spec entry or new spec file
- Handler file with ES5 boilerplate
- Reminder to sync files

**Template Sources**:
- `/docs/guides/api-gateway-guide.md` - Routing patterns
- Existing handlers as examples

---

### 2. /create-fcbo

**Purpose**: Create a full First-Class Business Object end-to-end.

**Inputs**:
- Object name (e.g., "Receipt", "Order")
- Fields definition (name, type, required)
- Store name
- Whether to include UI page

**Outputs**:
1. XML Schema (`setup/schema/{object}.xml`)
2. OpenAPI Spec (`openapi/specs/v1/{collection}.json`)
3. Handlers (get, post, put, delete)
4. UI Page (`client/pages/{Object}.js`) - optional
5. Main.js menu entry - optional

**Template Sources**:
- `/docs/guides/business-object-guide.md` - Full process
- `/docs/guides/data-stores-guide.md` - Schema patterns

---

### 3. /sync

**Purpose**: Streamline file sync to Scriptr.io.

**Inputs**:
- File path(s) to sync
- Optional: remote path override

**Actions**:
1. Validate file exists
2. Determine remote path (project-relative)
3. Call MCP scriptr.sync_file
4. Report success/failure

**Configuration**:
- Reads from `scriptrExtensionConfig.json` for credentials
- Respects `.scriptrIgnore` patterns

---

### 4. /test-api

**Purpose**: Test an API endpoint with debug mode.

**Inputs**:
- API path (e.g., `/v1/waba/flows/list`)
- HTTP method
- Request body (JSON)
- Optional: specific assertions

**Actions**:
1. Build full URL with `?debug_mode=true`
2. Execute via MCP scriptr.test_api or curl
3. Parse response, extract:
   - Inner handler status (not gateway status)
   - Script logs
   - Error details
4. Format output for readability

---

## Agents Implementation

### ntelioui-developer

**Purpose**: Specialized agent for frontend development using ntelioUI framework.

**When to Use**:
- Creating new UI pages (DataControl, forms, grids)
- Implementing ntelioUI components
- Fixing frontend issues in Page classes
- Working with EntityDataProvider/ApiDataProvider

**Knowledge Base**:
- ntelioUI patterns (Admin Application vs Public Landing Page)
- DataControl configuration
- SchemaAdaptor usage
- EntityDataProvider/ApiDataProvider patterns
- PageRouter and routing

**Tools Available**:
- Read, Write, Edit, Glob, Grep
- (No Bash - frontend doesn't need shell)

**Agent Definition Location**: `ntelioMiddleware/.claude/agents/ntelioui-developer.md`

---

## Documentation Consolidation

### Current State
```
commerceGenie/
├── docs/ai/scriptr.io/docs/       # Aug 21 - older
├── docs/scriptr.io/docs/          # Dec 8 - newer copy
└── CLAUDE.md                      # References both (inconsistent)
```

### Target State
```
ntelioMiddleware/
├── .claude/docs/scriptr.io/       # Canonical location (shared)
│   ├── basics.md
│   ├── built-in-objects.md
│   ├── handling-files.md
│   ├── rt-and-queuing.md
│   └── modules/
│       ├── 00-basics.md
│       ├── 04-document.md
│       └── ... (18 modules)
│
commerceGenie/
├── docs/guides/                   # Keep project guides
├── docs/prd/                      # Keep PRDs
└── CLAUDE.md                      # Update references
```

### Migration Steps
1. Move `docs/scriptr.io/docs/` to `ntelioMiddleware/.claude/docs/scriptr.io/`
2. Delete `docs/ai/scriptr.io/docs/` (older duplicate)
3. Update CLAUDE.md references
4. Symlink from consuming projects if needed

---

## Project Integration

### For CommerceGenie
```bash
# Keep existing skills
# Add symlink to shared plugin docs
ln -s ../ntelioMiddleware/.claude/docs .claude/shared-docs
```

### CLAUDE.md Updates
Add section for plugin:
```markdown
## Claude Code Plugin

This project uses the shared ntelio Claude Code plugin from ntelioMiddleware.

### Available Skills
- `/create-api` - Create API endpoint (spec + handler)
- `/create-fcbo` - Create full business object
- `/sync` - Sync files to Scriptr.io
- `/test-api` - Test API with debug mode
- `/prd-writer` - Create PRDs (project-specific)

### Available Agents
- `scriptrio-developer` - Backend Scriptr.io development
- `ntelioui-developer` - Frontend ntelioUI development
- `pipeline-developer` - YAML pipeline workflows
```

---

## Implementation Order

### Phase 1: Foundation
1. Create `ntelioMiddleware/.claude/` directory structure
2. Create `/sync` skill (simplest, immediate utility)
3. Create `/test-api` skill (pairs with sync)

### Phase 2: Core Skills
4. Create `/create-api` skill (most requested)
5. Create `ntelioui-developer` agent

### Phase 3: Advanced
6. Create `/create-fcbo` skill (complex, comprehensive)
7. Consolidate Scriptr.io documentation
8. Update CLAUDE.md files across projects

### Phase 4: Polish
9. Add skill examples/templates
10. Create settings.json template
11. Document symlink setup for other projects

---

## Questions for Validation

Before implementation:

1. **Skill Invocation**: Should skills prompt for missing inputs or require all params upfront?
   - Recommended: Prompt interactively for better UX

2. **Sync Credential Handling**: Where should Scriptr.io credentials live?
   - Option A: `scriptrExtensionConfig.json` (current)
   - Option B: `.claude/settings.local.json`
   - Recommended: Keep current approach, skill reads from scriptrExtensionConfig.json

3. **FCBO Scope**: Should `/create-fcbo` include test scripts?
   - Recommended: Yes, generate curl test scripts

4. **Agent Toolset**: Should `ntelioui-developer` have Bash access for npm/build commands?
   - Recommended: No, keep it pure frontend (no build process in Scriptr.io)

---

## Success Criteria

- [x] All 5 skills implemented and working (sync, test-api, create-api, create-fcbo, prd-writer)
- [x] ntelioui-developer agent provides accurate UI guidance
- [x] Documentation consolidated (single source of truth in plugin)
- [x] CLAUDE.md updated with plugin documentation
- [x] Plugin installed from GitHub marketplace

---

## File Checklist

### New Files Created (in ntelio-claude GitHub repo)
- [x] `plugins/ntelio-tools/skills/create-api/SKILL.md`
- [x] `plugins/ntelio-tools/skills/create-fcbo/SKILL.md`
- [x] `plugins/ntelio-tools/skills/sync/SKILL.md`
- [x] `plugins/ntelio-tools/skills/test-api/SKILL.md`
- [x] `plugins/ntelio-tools/skills/prd-writer/SKILL.md`
- [x] `agents/ntelioui-developer.md`

### Files Moved
- [x] `commerceGenie/docs/scriptr.io/docs/` -> `ntelio-claude/docs/scriptr.io/`

### Files Deleted
- [x] `commerceGenie/docs/ai/scriptr.io/docs/` (duplicate)

### Files Updated
- [x] `commerceGenie/CLAUDE.md` (add plugin section, fix references)
- [ ] `ntelioMiddleware/README.md` (add plugin section) - optional
