---
name: sync
description: Sync files to Scriptr.io platform. Use when the user wants to deploy, sync, or upload files to their Scriptr.io instance.
allowed-tools: Read, Bash, Glob, mcp__scriptr__sync_file
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

## Workflow

### Step 1: Identify Files to Sync

Parse the user's request to determine:
- Single file path
- Multiple file paths (space-separated)
- Glob pattern (e.g., `*.js`, `handlers/**/*`)

### Step 2: Load Credentials

Read credentials from `scriptrExtensionConfig.json` in project root:

```json
{
  "instanceUrl": "your-instance.scriptrapps.io",
  "accessToken": "your-access-token"
}
```

If credentials file not found, prompt user to create it.

### Step 3: Validate Files

For each file path:
1. Check if file exists
2. Check if file matches `.scriptrIgnore` patterns (skip if matched)
3. Determine the remote path (project-relative)

### Step 4: Sync Files

For each valid file, call the MCP sync tool:

```
mcp__scriptr__sync_file({
  file_path: "/absolute/path/to/file",
  remote_path: "relative/path/on/scriptr",
  instance_url: "instance.scriptrapps.io",
  access_token: "token"
})
```

### Step 5: Report Results

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
