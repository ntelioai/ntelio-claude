---
name: sync
description: Sync files to Scriptr.io platform. Use when the user wants to deploy, sync, or upload files to their Scriptr.io instance.
allowed-tools: Read, Write, Bash, Glob, mcp__scriptr__sync_file
---

# Scriptr.io File Sync

This skill syncs local files to Scriptr.io platform for deployment.

## When to Use This Skill

- User says "sync", "deploy", or "upload" files to Scriptr.io
- After creating or modifying backend scripts/handlers
- After updating API specs or schemas
- When user wants to test changes on the server

## Usage Patterns

```
/sync path/to/file.js
/sync openapi/handlers/v1/orders/post
/sync setup/schema/order.xml
/sync client/pages/*.js
```

## CRITICAL: Metadata Files

**Before syncing ANY file, ensure its `.metadata` file exists.** The MCP sync tool reads metadata files to determine content type and ACL permissions.

### Why Metadata Matters

| Content Type | Behavior |
|-------------|----------|
| `application/vnd.scriptr-javascript` | Server-side script (ES5, executable) |
| `application/javascript` | Browser JavaScript (ES6, served as static) |
| `text/html` | HTML page served to browser |
| `text/css` | CSS stylesheet served to browser |

### Metadata File Format

For file `filename.ext`, create `.filename.ext.metadata` in same directory:

```json
{"acl":{"read":"anonymous","write":"nobody","execute":"nobody"},"contentType":"application/javascript"}
```

### ACL Rules

| Permission | `anonymous` | `authenticated` | `nobody` |
|------------|-------------|-----------------|----------|
| **read** | Anyone can fetch | Auth required | Cannot read |
| **execute** | Public endpoint | Protected endpoint | Not an endpoint |

### Metadata by File Type

| File Location | Content Type | ACL Read | ACL Execute |
|--------------|--------------|----------|-------------|
| `client/**/*.js` | `application/javascript` | `anonymous` | `nobody` |
| `**/*.html` | `text/html` | `anonymous` | `nobody` |
| `**/*.css` | `text/css` | `anonymous` | `nobody` |
| `openapi/handlers/**/*` | `application/vnd.scriptr-javascript` | `nobody` | `authenticated` |
| `**/lib/*.js` (server) | `application/vnd.scriptr-javascript` | `nobody` | `nobody` |

### Creating Metadata Files

**ALWAYS create metadata when creating new files:**

```bash
# Browser JavaScript (client-side)
echo '{"acl":{"read":"anonymous","write":"nobody","execute":"nobody"},"contentType":"application/javascript"}' > .filename.js.metadata

# Server-side API endpoint
echo '{"acl":{"read":"nobody","write":"nobody","execute":"authenticated"},"contentType":"application/vnd.scriptr-javascript"}' > .filename.metadata

# Public API endpoint (webhooks)
echo '{"acl":{"read":"nobody","write":"nobody","execute":"anonymous"},"contentType":"application/vnd.scriptr-javascript"}' > .filename.metadata

# HTML page
echo '{"acl":{"read":"anonymous","write":"nobody","execute":"nobody"},"contentType":"text/html"}' > .filename.html.metadata
```

## Workflow

### Step 1: Identify Files to Sync

Parse the user's request to determine:
- Single file path
- Multiple file paths (space-separated)
- Glob pattern (e.g., `*.js`, `handlers/**/*`)

### Step 2: Verify Metadata Files Exist

For each file to sync, check if `.filename.ext.metadata` exists.

**If metadata exists:** Use it as-is.

**If metadata is missing:** Try to infer the correct metadata based on file location and extension:

#### Auto-Create Rules (High Confidence)

| File Pattern | Content Type | ACL | Auto-Create? |
|-------------|--------------|-----|--------------|
| `client/**/*.js` | `application/javascript` | read:anonymous, execute:nobody | ✅ Yes |
| `client/**/*.html` | `text/html` | read:anonymous, execute:nobody | ✅ Yes |
| `client/**/*.css` | `text/css` | read:anonymous, execute:nobody | ✅ Yes |
| `static/**/*` | Based on extension | read:anonymous, execute:nobody | ✅ Yes |
| `**/*.json` | `application/json` | read:anonymous, execute:nobody | ✅ Yes |
| `**/*.xml` | `text/xml` | read:anonymous, execute:nobody | ✅ Yes |
| `openapi/handlers/**/*` | `application/vnd.scriptr-javascript` | read:nobody, execute:authenticated | ✅ Yes |
| `ntelioMiddleware/server/handlers/**/*` | `application/vnd.scriptr-javascript` | read:nobody, execute:authenticated | ✅ Yes |
| `vscodePlugin/**/*` | `application/vnd.scriptr-javascript` | read:nobody, execute:authenticated | ✅ Yes |
| `setup/**/*` (no ext) | `application/vnd.scriptr-javascript` | read:nobody, execute:authenticated | ✅ Yes |

#### Ask User (Uncertain Cases)

For files that don't match the patterns above, **ask the user** using AskUserQuestion:

```
File: path/to/unknown/file.js

I need to create a metadata file for this. What type of file is this?

Options:
1. Browser JavaScript (ES6, served to browser)
2. Server-side Scriptr.io script (ES5, API endpoint - protected)
3. Server-side Scriptr.io script (ES5, API endpoint - public)
4. Server-side library (ES5, not directly callable)
```

Then ask about ACL if needed:
```
Should this file be:
1. Public (anyone can access/execute)
2. Protected (requires authentication)
3. Internal only (not directly accessible)
```

#### Auto-Create Metadata Code

When auto-creating, use Write tool:

```javascript
// Browser resource (client-side JS, HTML, CSS)
Write(".filename.ext.metadata", '{"acl":{"read":"anonymous","write":"nobody","execute":"nobody"},"contentType":"application/javascript"}')

// Server-side API handler (protected)
Write(".filename.metadata", '{"acl":{"read":"nobody","write":"nobody","execute":"authenticated"},"contentType":"application/vnd.scriptr-javascript"}')

// Server-side API handler (public webhook)
Write(".filename.metadata", '{"acl":{"read":"nobody","write":"nobody","execute":"anonymous"},"contentType":"application/vnd.scriptr-javascript"}')

// Server-side library (not an entry point)
Write(".filename.metadata", '{"acl":{"read":"nobody","write":"nobody","execute":"nobody"},"contentType":"application/vnd.scriptr-javascript"}')
```

**Always inform the user when metadata is auto-created:**
```
⚠️ Created missing metadata file: .filename.ext.metadata
   Type: Browser JavaScript
   ACL: read=anonymous, execute=nobody
```

### Step 3: Load Credentials

Look for `scriptrExtensionConfig.json` in the project root:

```json
{
  "instanceUrl": "your-instance.scriptrapps.io",
  "accessToken": "your-access-token"
}
```

**Credential resolution:**
1. Read `scriptrExtensionConfig.json` from project root
2. If file not found or missing fields, **ask the user** using AskUserQuestion for the instance URL and access token

**How credentials are used per sync method:**
- **MCP tool**: You (the agent) must read `scriptrExtensionConfig.json`, extract `instanceUrl` and `accessToken`, and pass them as parameters to the MCP tool call
- **sync-file.sh**: The script reads `scriptrExtensionConfig.json` on its own — you just run the bash command with the file path, no need to pass credentials

In both cases, **always print the credentials to the user before syncing** for transparency:
```
Syncing to: {instanceUrl}
Token: {first 8 chars}...{last 4 chars}
```

### Step 4: Validate Files

For each file path:
1. Check if file exists
2. Check if file matches `.scriptrIgnore` patterns (skip if matched)
3. Determine the remote path (project-relative)

### Step 5: Sync Files

Both sync methods automatically read the `.metadata` file from the same directory as the target file. They extract `contentType` and `acl` (read/write/execute) and send them with the sync request. **You do NOT need to manually read or pass ACL values** — just ensure the `.metadata` file exists (Step 2).

**Method 1: MCP Tool (Recommended)**

```
mcp__scriptr__sync_file({
  file_path: "/absolute/path/to/file",
  remote_path: "relative/path/on/scriptr",
  instance_url: "instance.scriptrapps.io",
  access_token: "token"
})
```

**Method 2: sync-file.sh (Shell script)**

```bash
./setup/sync/sync-file.sh <file_path>
```

- Reads credentials from `scriptrExtensionConfig.json` automatically
- Reads `.metadata` file and sends ACLs
- Respects `.scriptrIgnore` patterns
- Use this when MCP is not available

### Step 6: Report Results

Display sync results:
- ✓ Successfully synced files
- ✗ Failed files with error messages
- Total count

## Path Resolution Rules

| Local Path | Remote Path |
|------------|-------------|
| `client/pages/Store.js` | `client/pages/Store.js` |
| `openapi/handlers/v1/orders/post` | `openapi/handlers/v1/orders/post` |
| `setup/schema/order.xml` | `setup/schema/order.xml` |
| `ntelioMiddleware/server/handlers/v1/waba/list/post` | `ntelioMiddleware/server/handlers/v1/waba/list/post` |

Files sync to their exact relative path from project root.

## Ignore Patterns

Respect `.scriptrIgnore` file (gitignore syntax):

Default ignores:
- `node_modules/`
- `.git/`
- `.DS_Store`
- `*.log`
- `scriptrExtensionConfig.json`
- `.claude/`

## Error Handling

### Missing Credentials
```
Error: scriptrExtensionConfig.json not found.

Create this file in your project root:
{
  "instanceUrl": "your-instance.scriptrapps.io",
  "accessToken": "your-access-token"
}
```

### File Not Found
```
Error: File not found: path/to/missing/file.js
```

### Sync Failed
```
Error syncing path/to/file.js: [error message from Scriptr.io]
```

## Examples

### Sync Single File
```
User: /sync openapi/handlers/v1/orders/post
Assistant: Syncing file to Scriptr.io...
✓ Synced: openapi/handlers/v1/orders/post → openapi/handlers/v1/orders/post
```

### Sync Multiple Files
```
User: /sync openapi/specs/v1/orders.json openapi/handlers/v1/orders/post openapi/handlers/v1/orders/get
Assistant: Syncing 3 files to Scriptr.io...
✓ openapi/specs/v1/orders.json
✓ openapi/handlers/v1/orders/post
✓ openapi/handlers/v1/orders/get
All 3 files synced successfully.
```

### Sync with Glob Pattern
```
User: /sync openapi/handlers/v1/orders/*
Assistant: Found 4 files matching pattern...
✓ openapi/handlers/v1/orders/get
✓ openapi/handlers/v1/orders/post
✓ openapi/handlers/v1/orders/put
✓ openapi/handlers/v1/orders/delete
All 4 files synced successfully.
```

## Post-Sync Verification

After syncing, suggest testing:
```
Files synced. To test the endpoint:
curl -X POST "https://instance.scriptrapps.io/openapi/handlers/v1/orders?debug_mode=true" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}'
```

## Related Skills

- `/test-api` - Test synced endpoints
- `/create-api` - Create new API endpoints (then sync)
