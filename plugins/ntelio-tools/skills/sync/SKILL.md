---
name: sync
description: Sync files to Scriptr.io platform. Use when the user wants to deploy, sync, or upload files to their Scriptr.io instance.
allowed-tools: Read, Write, Glob, Grep, AskUserQuestion, mcp__scriptr__sync_file
---

# Sync Files to Scriptr.io

Follow these steps **in order**. Be action-oriented — sync files quickly, only ask questions when information is missing.

---

## Step 1: Determine file(s) to sync

- **If the user provided a path** (e.g. `/sync openapi/handlers/v1/orders/post`) → use it directly.
- **If the user provided a glob** (e.g. `/sync client/pages/*.js`) → resolve it with the Glob tool.
- **If no path was given** (`/sync` with no args) → ask:

```
AskUserQuestion: "What file or pattern would you like to sync?"
Options:
- Let user type a path or glob
```

---

## Step 2: Find credentials

Search for `scriptrExtensionConfig.json` starting from the current working directory, then walking up parent directories to the git root. The file contains:

```json
{
  "instanceUrl": "myapp.scriptrapps.io",
  "accessToken": "the-token"
}
```

**If found** → read `instanceUrl` and `accessToken` silently. Do NOT ask the user anything.

**If NOT found** → use AskUserQuestion to collect both values:

```
AskUserQuestion: "I couldn't find scriptrExtensionConfig.json. What is your Scriptr.io instance URL?"
  Options: (let user type, e.g. "myapp.scriptrapps.io")

AskUserQuestion: "What is your access token?"
  Options: (let user type)
```

Before syncing, print credentials for transparency:
```
Syncing to: {instanceUrl}
Token: {first 8 chars}...{last 4 chars}
```

---

## Step 3: Validate files exist

For each resolved file path:
1. Confirm the file exists (Glob or Read).
2. Skip files matching `.scriptrIgnore` patterns (default ignores: `node_modules/`, `.git/`, `.DS_Store`, `*.log`, `scriptrExtensionConfig.json`, `.claude/`).
3. If a file doesn't exist, report it and continue with the rest.

---

## Step 4: Ensure metadata

For each file `dir/filename.ext`, check if `dir/.filename.ext.metadata` exists.

**If metadata exists** → use it as-is.

**If metadata is missing** → auto-create it using these rules:

| File Pattern | contentType | ACL (read / execute) |
|---|---|---|
| `client/**/*.js` | `application/javascript` | anonymous / nobody |
| `**/*.html` | `text/html` | anonymous / nobody |
| `**/*.css` | `text/css` | anonymous / nobody |
| `**/*.json` | `application/json` | anonymous / nobody |
| `**/*.xml` | `text/xml` | anonymous / nobody |
| `static/**/*` | by extension | anonymous / nobody |
| `openapi/handlers/**/*` | `application/vnd.scriptr-javascript` | nobody / authenticated |
| `ntelioMiddleware/server/handlers/**/*` | `application/vnd.scriptr-javascript` | nobody / authenticated |
| `vscodePlugin/**/*` | `application/vnd.scriptr-javascript` | nobody / authenticated |
| `setup/**/*` (no ext) | `application/vnd.scriptr-javascript` | nobody / authenticated |
| `**/lib/*.js` (server) | `application/vnd.scriptr-javascript` | nobody / nobody |

All metadata files use `"write":"nobody"`.

**Metadata file format:**
```json
{"acl":{"read":"VALUE","write":"nobody","execute":"VALUE"},"contentType":"VALUE"}
```

When auto-creating, inform the user:
```
Created metadata: .filename.ext.metadata (type: application/javascript, execute: nobody)
```

**If the file doesn't match any pattern** → ask via AskUserQuestion:
```
AskUserQuestion: "What type of file is {path}?"
Options:
1. "Browser resource" — JS/HTML/CSS served to browser (read: anonymous, execute: nobody)
2. "API endpoint (protected)" — server-side, requires auth (read: nobody, execute: authenticated)
3. "API endpoint (public)" — server-side webhook, no auth (read: nobody, execute: anonymous)
4. "Server library" — server-side, not directly callable (read: nobody, execute: nobody)
```

---

## Step 5: Sync via MCP

For each file, call:

```
mcp__scriptr__sync_file({
  file_path: "/absolute/path/to/file",
  remote_path: "relative/path/from/project/root",
  instance_url: "instance.scriptrapps.io",
  access_token: "token"
})
```

The remote path equals the file's path relative to the project root (e.g. `client/pages/Store.js` → `client/pages/Store.js`).

The MCP tool reads the `.metadata` file automatically to send ACL and content type — you do NOT need to pass those.

---

## Step 6: Report results

Show a summary:
```
✓ synced: openapi/handlers/v1/orders/post
✓ synced: openapi/handlers/v1/orders/get
✗ failed: path/to/broken.js — [error message]

2/3 files synced successfully.
```

If any synced files are API endpoints (`openapi/handlers/**` or similar), suggest:
```
Use /test-api to verify your endpoints.
```
