---
name: create-file
description: ALWAYS use when creating any new file in a Scriptr.io project. Every file MUST have a companion .metadata file with correct ACLs and content type. This skill determines the right metadata and creates both the file and its .metadata companion.
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# Create File with Metadata

**Every file on Scriptr.io requires a companion `.metadata` file.** This skill ensures that whenever a file is created, its metadata is created alongside it with the correct ACLs and content type.

## MANDATORY RULE

**Never create a file without also creating its `.metadata` companion.** If you are about to use the Write tool to create a new file, you MUST also create the corresponding `.{filename}.metadata` file in the same directory.

## Metadata Naming Convention

For any file `path/to/filename.ext`, the metadata file is `path/to/.filename.ext.metadata`:

```
openapi/handlers/v1/orders/post    → openapi/handlers/v1/orders/.post.metadata
client/pages/Store.js              → client/pages/.Store.js.metadata
setup/schema/order.xml             → setup/schema/.order.xml.metadata
config/Server                      → config/.Server.metadata
```

## Sync Behavior

**CRITICAL: Metadata files are NEVER synced to Scriptr.io directly.** When you sync a main file, the sync process:
1. Reads the `.metadata` file from the same directory
2. Extracts the ACLs and content type
3. Sends them as part of the main file's sync request

The metadata travels WITH the file, not as a separate upload. Never add `.metadata` files to a sync operation.

## Two Categories of Files

### 1. Static/Editor Files (HTML, CSS, JS, images, markdown, yaml, json, xml)

Files served to browsers or opened in the Scriptr.io IDE. They include the `userConfig` field.

**Template:**
```json
{"acl":{"read":"anonymous","write":"nobody","execute":"nobody"},"contentType":"<mime-type>","userConfig":"/*#*SCRIPTR_PLUGIN*#*{\"metadata\":{\"name\":\"CodeMirrorArbitraryFile\",\"plugindata\":{}}}*#*#*/"}
```

**ACL is always the same** for static files: `read: anonymous`, `write: nobody`, `execute: nobody`.

**Content type by extension:**

| Extension | contentType |
|-----------|-------------|
| `.html` | `text/html` |
| `.css` | `text/css` |
| `.js` (frontend) | `application/javascript` |
| `.json` | `application/json` |
| `.xml` | `application/xml` |
| `.md` | `text/x-gfm` |
| `.yaml` / `.yml` | `text/plain` |
| `.txt` | `text/plain` |
| `.svg` | `image/svg+xml` |
| `.woff` / `.woff2` | `font/woff2` |

**Binary images (jpg, png, gif, ico, webp) cannot be synced - do NOT create metadata for them.**

### 2. Scriptr Backend Scripts (handlers, libraries, config)

Server-side scripts executed by the Scriptr.io runtime. They do **NOT** include `userConfig`.

**Template:**
```json
{"acl":{"read":"nobody","write":"nobody","execute":"<level>"},"contentType":"application/vnd.scriptr-javascript"}
```

**Execute levels:**

| Level | Meaning | Use For |
|-------|---------|---------|
| `anonymous` | Anyone can call directly | Public endpoints: webhooks, login, registration, storefront, public data |
| `authenticated` | Requires valid auth token | Protected endpoints: user data, settings, CRUD operations |
| `group:admin` | Admin users only | Admin operations: subscription management, provisioning |
| `nobody` | Cannot be called directly, only via `require()` | Libraries, helpers, utilities, config modules |
| `scriptr` | Platform owner only | Platform config: CONFIG.APP, CONFIG.MASTER |

## Permission Decision Tree

```
Is it a frontend/static file? (HTML, CSS, browser JS, SVG images, markdown, yaml, json, xml)
  └─ YES → read: anonymous, write: nobody, execute: nobody + userConfig
  └─ NO → Is it a binary image file? (jpg, png, ico, gif, webp)
       └─ YES → STOP. Binary files cannot be synced. Do NOT create metadata.
       └─ NO → Is it a Scriptr backend script?
            └─ YES → contentType: application/vnd.scriptr-javascript, NO userConfig
                 └─ Is it an entry point? (server/api, server/public/api)
                 │    └─ YES → execute: authenticated or anonymous (entry points are the ONLY
                 │         scripts users call directly)
                 │    └─ NO → Is it loaded via require() or file.read()?
                 │         └─ YES → execute: nobody (this includes ALL openapi/handlers,
                 │              ALL openapi/specs, ALL lib/ files, ALL config modules)
                 │         └─ NO → Is it a setup/admin script?
                 │              └─ YES → execute: group:admin
                 │              └─ NO → Is it a public endpoint?
                 │                   └─ YES → execute: anonymous
                 │                   └─ NO → execute: authenticated
                 └─ Is it a platform config?
                      └─ YES → execute: scriptr
```

**IMPORTANT: Scriptr.io scripts run with owner privileges by default.** `require()` and `file.read()` bypass ACLs entirely. This means handlers and specs can safely be `execute/read: nobody` since they're accessed by server-side code, not directly by users. Only entry points (`server/api`, `server/public/api`) need execute permissions because they're the scripts users call directly via HTTP.

**When you are uncertain about the permission level, ALWAYS ask the user using AskUserQuestion before creating the metadata.**

## Auto-Mapping by File Location

Use this table to determine metadata automatically when the file's location makes its purpose clear:

| File Location Pattern | Category | Execute | Confidence |
|----------------------|----------|---------|------------|
| `client/**/*` | Static | `nobody` | High - auto-create |
| `static/**/*` | Static | `nobody` | High - auto-create |
| `*.html` (root) | Static | `nobody` | High - auto-create |
| `openapi/lib/**/*` | Backend library | `nobody` | High - auto-create |
| `app/lib/**/*` | Backend library | `nobody` | High - auto-create |
| `app/ai-tools/**/*` | Backend library | `nobody` | High - auto-create |
| `setup/schema/**/*.xml` | Static (XML) | `nobody` | High - auto-create |
| `openapi/specs/**/*.json` | Backend (JSON) | `nobody` | High - auto-create (read: nobody) |
| `openapi/handlers/**/*` | Backend handler | `nobody` | High - auto-create (loaded via require) |
| `app/scripts/**/*` | Backend handler | `authenticated` | Medium - verify with user |
| `config/*` | Backend | Varies | Low - always ask user |
| `setup/*` (non-schema) | Backend | Varies | Low - always ask user |

**When confidence is "Low" or "Medium", ask the user before creating metadata.**

## Complete Copy-Paste Templates

### Frontend HTML
```json
{"acl":{"read":"anonymous","write":"nobody","execute":"nobody"},"contentType":"text/html","userConfig":"/*#*SCRIPTR_PLUGIN*#*{\"metadata\":{\"name\":\"CodeMirrorArbitraryFile\",\"plugindata\":{}}}*#*#*/"}
```

### Frontend CSS
```json
{"acl":{"read":"anonymous","write":"nobody","execute":"nobody"},"contentType":"text/css","userConfig":"/*#*SCRIPTR_PLUGIN*#*{\"metadata\":{\"name\":\"CodeMirrorArbitraryFile\",\"plugindata\":{}}}*#*#*/"}
```

### Frontend JavaScript
```json
{"acl":{"read":"anonymous","write":"nobody","execute":"nobody"},"contentType":"application/javascript","userConfig":"/*#*SCRIPTR_PLUGIN*#*{\"metadata\":{\"name\":\"CodeMirrorArbitraryFile\",\"plugindata\":{}}}*#*#*/"}
```

### JSON (frontend configs)
```json
{"acl":{"read":"anonymous","write":"nobody","execute":"nobody"},"contentType":"application/json","userConfig":"/*#*SCRIPTR_PLUGIN*#*{\"metadata\":{\"name\":\"CodeMirrorArbitraryFile\",\"plugindata\":{}}}*#*#*/"}
```

### JSON (backend specs - openapi/specs)
```json
{"acl":{"read":"nobody","write":"nobody","execute":"nobody"},"contentType":"application/json","userConfig":"/*#*SCRIPTR_PLUGIN*#*{\"metadata\":{\"name\":\"CodeMirrorArbitraryFile\",\"plugindata\":{}}}*#*#*/"}
```

### XML (schemas)
```json
{"acl":{"read":"anonymous","write":"nobody","execute":"nobody"},"contentType":"application/xml","userConfig":"/*#*SCRIPTR_PLUGIN*#*{\"metadata\":{\"name\":\"CodeMirrorArbitraryFile\",\"plugindata\":{}}}*#*#*/"}
```

### Markdown
```json
{"acl":{"read":"anonymous","write":"nobody","execute":"nobody"},"contentType":"text/x-gfm","userConfig":"/*#*SCRIPTR_PLUGIN*#*{\"metadata\":{\"name\":\"CodeMirrorArbitraryFile\",\"plugindata\":{}}}*#*#*/"}
```

### YAML
```json
{"acl":{"read":"anonymous","write":"nobody","execute":"nobody"},"contentType":"text/plain","userConfig":"/*#*SCRIPTR_PLUGIN*#*{\"metadata\":{\"name\":\"CodeMirrorArbitraryFile\",\"plugindata\":{}}}*#*#*/"}
```

### Images (SVG only)
```json
{"acl":{"read":"anonymous","write":"nobody","execute":"nobody"},"contentType":"image/svg+xml","userConfig":"/*#*SCRIPTR_PLUGIN*#*{\"metadata\":{\"name\":\"CodeMirrorArbitraryFile\",\"plugindata\":{}}}*#*#*/"}
```

**Note: Binary image files (PNG, JPEG, GIF, ICO, WebP) are NOT supported by the sync process. Only SVG (text-based) images can be synced and need metadata. Do NOT create metadata for binary images.**

### Backend Handler (openapi/handlers - loaded via require)
```json
{"acl":{"read":"nobody","write":"nobody","execute":"nobody"},"contentType":"application/vnd.scriptr-javascript"}
```
**This is the correct template for ALL openapi/handlers.** Handlers are loaded via `require()` from entry points, never called directly.

### Backend Entry Point (authenticated)
```json
{"acl":{"read":"nobody","write":"nobody","execute":"authenticated"},"contentType":"application/vnd.scriptr-javascript"}
```

### Backend Entry Point (public)
```json
{"acl":{"read":"nobody","write":"nobody","execute":"anonymous"},"contentType":"application/vnd.scriptr-javascript"}
```

### Backend Script (admin only)
```json
{"acl":{"read":"nobody","write":"nobody","execute":"group:admin"},"contentType":"application/vnd.scriptr-javascript"}
```

### Backend Library/Helper (require() only)
```json
{"acl":{"read":"nobody","write":"nobody","execute":"nobody"},"contentType":"application/vnd.scriptr-javascript"}
```

### Platform Config
```json
{"acl":{"read":"nobody","write":"nobody","execute":"scriptr"},"contentType":"application/vnd.scriptr-javascript"}
```

## Common Mistakes

| Mistake | Why It's Wrong | Fix |
|---------|---------------|-----|
| Creating a file without its `.metadata` | File gets unpredictable platform defaults | Always create both files together |
| Handler with `execute: authenticated` | Handlers are loaded via require(), not called directly | `execute: nobody` for all handlers |
| Spec with `read: anonymous` | Specs are loaded via file.read() with owner privileges | `read: nobody` |
| Library with `execute: authenticated` | Directly callable as API, bypassing intended usage | `execute: nobody` |
| Config with `execute: anonymous` | Exposes configuration publicly | `execute: nobody` or `execute: scriptr` |
| Frontend file with `read: nobody` | Browser cannot fetch it | `read: anonymous` |
| Backend script with `read: anonymous` | Source code readable by anyone | `read: nobody` |
| Syncing a `.metadata` file | Metadata is consumed by sync tool, not uploaded separately | Never sync `.metadata` files |
| Missing `userConfig` on static files | IDE won't use correct editor | Add `userConfig` field |
| Adding `userConfig` on backend scripts | Unnecessary, only for IDE editor files | Omit `userConfig` |
| Creating metadata for binary images | Binary files (jpg, png, gif, ico) can't be synced | Only create metadata for SVG images |

## Audit Checklist

To find permission issues across a project:

```bash
# 1. Files missing metadata
find . -not -name ".*" -not -path "./.git/*" -type f | while read f; do
  dir=$(dirname "$f"); base=$(basename "$f")
  [ ! -f "$dir/.$base.metadata" ] && echo "MISSING: $f"
done

# 2. Backend libs with wrong execute permission
grep -rl '"execute":"authenticated"' --include="*.metadata" app/lib/ openapi/lib/

# 3. Frontend files with wrong permissions
grep -rl '"execute":"authenticated"' --include="*.metadata" client/ static/
grep -rl '"read":"nobody"' --include="*.metadata" client/ static/

# 4. Backend scripts unexpectedly exposed as anonymous
grep -rl '"execute":"anonymous"' --include="*.metadata" openapi/handlers/ app/scripts/
```

## Related Skills

- `/sync` - Sync files to Scriptr.io (reads metadata during sync)
- `/create-api` - Create new API endpoints (should invoke this skill for metadata)
- `/create-fcbo` - Create business objects (should invoke this skill for metadata)
- `/add-setup-resource` - Add infrastructure resources
