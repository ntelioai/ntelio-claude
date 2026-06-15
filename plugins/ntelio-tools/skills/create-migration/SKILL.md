---
name: create-migration
description: Create a migration script to propagate infrastructure changes (schemas, stores, channels, groups, pipelines, instructions) to all existing child accounts. Use when modifying or adding any resource that was created at init time.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, mcp__scriptr__sync_file
---

# Create Migration

This skill creates migration scripts that propagate infrastructure changes to all existing child accounts. Child accounts are initialized once at provisioning — any change to init resources, schemas, pipelines, or instructions after that point must be delivered via the migration system.

## When to Use This Skill

Create a migration whenever you change **any** of the following:

| Changed File / Location | Why a Migration Is Needed |
|------------------------|--------------------------|
| `setup/INIT.APP` | New/modified stores, schemas, channels, groups — existing accounts won't receive init changes |
| `ntelioMiddleware/setup/INIT.DEFAULTS` | Same — base init changes don't reach existing accounts |
| `setup/schema/*.xml` | Schema structural changes (new fields, modified ACLs, updated validations) |
| `ntelioMiddleware/setup/schema/*.xml` | Shared middleware schema changes |
| `setup/instructions/*.txt` | AI system prompt changes need propagation to all child accounts |
| `pipeline/*.yaml` | Pipeline changes need to be distributed to child accounts |

**Rule of thumb**: If the resource was created or initialized during account provisioning, changing it on the provisioner only affects new accounts. Existing accounts need a migration.

## Migration Naming Convention

```
YYYYMMDD_NNN_descriptive_name
```

- **YYYYMMDD**: Today's date
- **NNN**: 3-digit zero-padded sequential counter, continuing from the last entry in the manifest
- **descriptive_name**: snake_case summary of what changed

**Examples:**
```
20260615_006_add_customers_schema_and_store
20260615_007_update_food_instructions
20260615_008_update_main_pipeline
```

## Step 1: Determine the Next Migration Number

1. Read `deployment/migration/manifest`
2. Find the last name in the `scripts` array
3. Extract the NNN counter and increment by 1 (zero-padded to 3 digits)
4. Use today's date for YYYYMMDD

```javascript
// Manifest ends with: "20260609_005_update_order_schema"
// Next migration:      "YYYYMMDD_006_your_description"
```

## Step 2: Create the Migration Script

Create the file at `deployment/migration/scripts/YYYYMMDD_NNN_description` (no file extension).

Always create a companion `.metadata` file in the same directory:

**`deployment/migration/scripts/.YYYYMMDD_NNN_description.metadata`**
```json
{"acl":{"read":"nobody","write":"nobody","execute":"nobody"},"contentType":"application/vnd.scriptr-javascript"}
```

---

### Template A: Schema Update

Use when any `setup/schema/*.xml` or `ntelioMiddleware/setup/schema/*.xml` file changes.

```javascript
/**
 * Migration: YYYYMMDD_NNN_description
 *
 * [One-paragraph description of what changed in the schema and why]
 *   1. [Change 1 — field added/modified/removed, regex updated, etc.]
 *   2. [Change 2 if applicable]
 */

var schema = require("schema")
var file = require("file")
var log = require("log")
log.setLevel("DEBUG")

var name = "YYYYMMDD_NNN_description"
var description = "Short description of what this migration does"

function applySchema(schemaName, filePath) {
    var readResult = file.read(filePath)
    if (!readResult || !readResult.content) {
        log.error("Failed to read schema file: " + filePath)
        return false
    }
    var result = schema.update(schemaName, readResult.content)
    if (result.metadata.status === "failure") {
        result = schema.create(schemaName, readResult.content)
    }
    var ok = result.metadata.status === "success"
    log.debug("Schema [" + schemaName + "]: " + (ok ? "ok" : result.metadata.errorDetail))
    return ok
}

var run = function() {
    var schemaList = [
        { name: "SchemaName", file: "/setup/schema/schemaname.xml" }
        // Multiple schemas if needed:
        // { name: "AnotherSchema", file: "/ntelioMiddleware/setup/schema/another.xml" }
    ]

    var notes = []
    var allOk = true

    for (var i = 0; i < schemaList.length; i++) {
        var ok = applySchema(schemaList[i].name, schemaList[i].file)
        notes.push(schemaList[i].name + ": " + (ok ? "ok" : "FAILED"))
        if (!ok) { allOk = false }
    }

    return { success: allOk, notes: notes.join(", ") }
}
```

**Resolving schema names:** When `INIT.APP`/`INIT.DEFAULTS` uses `{{PLACEHOLDER}}` syntax, look up the resolved value in the `ENV` file. For example: `ORDERS_SCHEMA: "order"` → use `"order"` as the schema name in the migration.

**Schema file paths:** Always include the leading `/`. Use the same path that `INIT.APP`/`INIT.DEFAULTS` specifies in the `file` field of the schema entry.

---

### Template B: Store Creation

Use when a new store is added to `INIT.APP` or `INIT.DEFAULTS`.

```javascript
/**
 * Migration: YYYYMMDD_NNN_description
 *
 * Creates [StoreName] document store for [feature / purpose].
 */

var stores = require("store")
var log = require("log")
log.setLevel("DEBUG")

var name = "YYYYMMDD_NNN_description"
var description = "Create [StoreName] store"

var run = function() {
    var notes = []
    var allOk = true

    var storeList = [
        {
            name: "StoreName",
            acl: {
                saveDocumentACL: "authenticated",
                deleteDocumentACL: "nobody",
                queryACL: "authenticated",
                getAttachmentACL: "nobody"
            }
        }
    ]

    for (var i = 0; i < storeList.length; i++) {
        try {
            var result = stores.create(storeList[i].name, storeList[i].acl)
            var ok = result.metadata.status === "success"
            if (!ok && result.metadata.errorCode === "STORE_ALREADY_EXISTS") {
                ok = true
                notes.push(storeList[i].name + ": already exists (ok)")
            } else {
                notes.push(storeList[i].name + ": " + (ok ? "created" : "FAILED - " + result.metadata.errorCode))
            }
            if (!ok) { allOk = false }
        } catch (e) {
            notes.push(storeList[i].name + ": FAILED - " + e.message)
            allOk = false
        }
    }

    return { success: allOk, notes: notes.join(", ") }
}
```

**ACL values:** Use the `acls` override from the INIT entry if present, otherwise use `INIT.DEFAULTS.defaultACL` (`nobody` save/delete, `authenticated` query).

---

### Template C: Channel Creation

Use when a new channel is added to `INIT.APP` or `INIT.DEFAULTS`.

```javascript
/**
 * Migration: YYYYMMDD_NNN_description
 *
 * Creates [channelName] pub/sub channel for [purpose].
 */

var channel = require("channel")
var log = require("log")
log.setLevel("DEBUG")

var name = "YYYYMMDD_NNN_description"
var description = "Create [channelName] pub/sub channel"

var run = function() {
    var notes = []
    var allOk = true

    var channelList = [
        {
            name: "channelName",
            options: {
                subscribeACL: "authenticated",
                publishACL: "authenticated"
            }
        }
    ]

    for (var i = 0; i < channelList.length; i++) {
        try {
            var result = channel.create(channelList[i].name, channelList[i].options)
            var ok = result.metadata.status === "success"
            if (!ok && result.metadata.errorCode === "CHANNEL_ALREADY_EXISTS") {
                ok = true
                notes.push(channelList[i].name + ": already exists (ok)")
            } else {
                notes.push(channelList[i].name + ": " + (ok ? "created" : "FAILED - " + result.metadata.errorCode))
            }
            if (!ok) { allOk = false }
        } catch (e) {
            notes.push(channelList[i].name + ": FAILED - " + e.message)
            allOk = false
        }
    }

    return { success: allOk, notes: notes.join(", ") }
}
```

---

### Template D: Group Creation

Use when a new user group is added to `INIT.APP` or `INIT.DEFAULTS`.

```javascript
/**
 * Migration: YYYYMMDD_NNN_description
 *
 * Creates [groupName] user group for [purpose].
 */

var user = require("user")
var log = require("log")
log.setLevel("DEBUG")

var name = "YYYYMMDD_NNN_description"
var description = "Create [groupName] user group"

var run = function() {
    var notes = []
    var allOk = true

    var groupList = ["groupName"]

    for (var i = 0; i < groupList.length; i++) {
        try {
            var result = user.createGroup(groupList[i])
            var ok = result.metadata.status === "success"
            if (!ok && result.metadata.errorCode === "GROUP_ALREADY_EXISTS") {
                ok = true
                notes.push(groupList[i] + ": already exists (ok)")
            } else {
                notes.push(groupList[i] + ": " + (ok ? "created" : "FAILED - " + result.metadata.errorCode))
            }
            if (!ok) { allOk = false }
        } catch (e) {
            notes.push(groupList[i] + ": FAILED - " + e.message)
            allOk = false
        }
    }

    return { success: allOk, notes: notes.join(", ") }
}
```

---

### Template E: Pipeline Propagation

Use when `pipeline/*.yaml` files change. Pipelines are stored as documents in the pipelines store (not as raw files) — the migration reads the YAML from disk and writes it into the store under the pipeline's document key, preserving any existing metadata fields.

```javascript
/**
 * Migration: YYYYMMDD_NNN_description
 *
 * Reloads updated pipeline definitions into the pipelines store.
 *   1. [pipeline file] — [reason for the change]
 */

require("/ntelioMiddleware/server/commons").importPackages(["config", "logger"], this)
var documents = require("document")
var file = require("file")
var log = require("log")
log.setLevel("DEBUG")

var name = "YYYYMMDD_NNN_description"
var description = "Reload updated pipeline YAML into pipelines store"

function reloadPipeline(pipelineKey, pipelineFile) {
    var readRes = file.read(pipelineFile)
    var yamlContent = (readRes && typeof readRes === "object") ? readRes.content : readRes
    if (!yamlContent || yamlContent.length === 0) {
        log.error("Empty or missing content: " + pipelineFile)
        return false
    }

    var storeName = config.server.pipelinesStoreName || "pipelines"
    var store = documents.getInstance(storeName)

    // Preserve existing metadata fields so we don't overwrite title/description/enabled
    var existing = null
    try { existing = store.get(pipelineKey) } catch (e) {}
    var prev = (existing && existing.result) ? existing.result : {}

    // "status" is a Scriptr-reserved field — skip it even if declared in schema
    var doc = {
        key:         pipelineKey,
        definition:  yamlContent,
        title:       prev.title       || pipelineKey,
        description: prev.description || "Pipeline reloaded from " + pipelineFile,
        enabled:     prev.enabled     || "true"
    }

    var saveResult = store.save(doc)
    var ok = !!(saveResult && saveResult.result)
    log.debug("Pipeline [" + pipelineKey + "]: " + (ok ? "ok" : "FAILED"))
    return ok
}

var run = function() {
    var pipelineList = [
        { key: "main-pipeline", file: "/pipeline/main-pipeline.yaml" }
        // Add other changed pipelines here:
        // { key: "auzaatar", file: "/pipeline/auzaatar.yaml" }
    ]

    var notes = []
    var allOk = true

    for (var i = 0; i < pipelineList.length; i++) {
        var ok = reloadPipeline(pipelineList[i].key, pipelineList[i].file)
        notes.push(pipelineList[i].key + ": " + (ok ? "ok" : "FAILED"))
        if (!ok) { allOk = false }
    }

    return { success: allOk, notes: notes.join(", ") }
}
```

**Pipeline key:** Matches the document key used in the pipelines store. The default pipeline key is `"main-pipeline"`. Check the bot configuration or existing store documents to confirm the key for industry-specific pipelines.

---

### Template F: Combined Migration

When a single change touches multiple resource types (e.g., new schema + new store, or schema update + instructions update):

```javascript
/**
 * Migration: YYYYMMDD_NNN_description
 *
 * [Overall description]
 *   1. [Resource 1 change]
 *   2. [Resource 2 change]
 */

var schema = require("schema")
var stores = require("store")
var file = require("file")
var log = require("log")
log.setLevel("DEBUG")

var name = "YYYYMMDD_NNN_description"
var description = "..."

function applySchema(schemaName, filePath) {
    var readResult = file.read(filePath)
    if (!readResult || !readResult.content) { return false }
    var result = schema.update(schemaName, readResult.content)
    if (result.metadata.status === "failure") {
        result = schema.create(schemaName, readResult.content)
    }
    return result.metadata.status === "success"
}

var run = function() {
    var notes = []
    var allOk = true

    // — Schemas —
    var schemaOk = applySchema("SchemaName", "/setup/schema/schemaname.xml")
    notes.push("schema/SchemaName: " + (schemaOk ? "ok" : "FAILED"))
    if (!schemaOk) { allOk = false }

    // — Stores —
    try {
        var storeResult = stores.create("StoreName", {
            saveDocumentACL: "authenticated",
            deleteDocumentACL: "nobody",
            queryACL: "authenticated",
            getAttachmentACL: "nobody"
        })
        var storeOk = storeResult.metadata.status === "success" ||
                      storeResult.metadata.errorCode === "STORE_ALREADY_EXISTS"
        notes.push("store/StoreName: " + (storeOk ? "ok" : "FAILED - " + storeResult.metadata.errorCode))
        if (!storeOk) { allOk = false }
    } catch (e) {
        notes.push("store/StoreName: FAILED - " + e.message)
        allOk = false
    }

    return { success: allOk, notes: notes.join(", ") }
}
```

---

## Step 3: Update the Manifest

Edit `deployment/migration/manifest` and append the new migration name to the `scripts` array:

```javascript
var scripts = [
    // ... existing entries (do not modify) ...
    "20260609_005_update_order_schema",
    "YYYYMMDD_NNN_your_description"   // ← append here
];
```

**Order matters.** Scripts run in array order. Always append to the end; never reorder existing entries.

## Step 4: Sync Files to Scriptr.io

After creating the migration, sync these files:

```bash
# 1. The new migration script
./setup/sync/sync-file.sh deployment/migration/scripts/YYYYMMDD_NNN_description

# 2. The updated manifest
./setup/sync/sync-file.sh deployment/migration/manifest

# 3. The changed source file(s) that triggered the migration
./setup/sync/sync-file.sh setup/schema/changed-schema.xml
# or
./setup/sync/sync-file.sh setup/instructions/changed.txt
# or
./setup/sync/sync-file.sh pipeline/main-pipeline.yaml
# or
./setup/sync/sync-file.sh setup/INIT.APP
```

## Complete Workflow

```
1. A tracked file is created or modified
   ↓
2. Read manifest → find last NNN → increment
   ↓
3. Create migration script: deployment/migration/scripts/YYYYMMDD_NNN_name
4. Create .metadata companion for the script
   ↓
5. Update deployment/migration/manifest — append to scripts[]
   ↓
6. Sync: migration script + manifest + changed source file(s)
```

**Do not run `runMigration` — it is triggered as part of the code deployment process and must be run on demand by the team.**

## Migration Checklist

- [ ] Migration file created at `deployment/migration/scripts/YYYYMMDD_NNN_name` (no extension)
- [ ] `.YYYYMMDD_NNN_name.metadata` companion created in the same directory
- [ ] Migration name appended to `manifest.scripts[]` (at the end)
- [ ] Script has `var name`, `var description`, `var run = function() { return { success, notes }; }`
- [ ] Schema file paths use leading `/` (e.g., `/setup/schema/foo.xml`)
- [ ] All operations are idempotent — "already exists" errors treated as success
- [ ] Schema name resolved from ENV (not the `{{PLACEHOLDER}}` literal)
- [ ] Migration script + manifest synced to Scriptr.io
- [ ] Changed source files (schema XML, instructions, pipeline, INIT.APP) also synced

## Reference: Existing Migrations

| Migration | Type | What It Does |
|-----------|------|-------------|
| `20260326_000` | Bootstrap | Creates migration schema + MigrationsStore |
| `20260326_001` | Schema | Adds imageFile field to 4 industry schemas |
| `20260424_002` | Schema | Removes currency, adds wabaProductId, makes description required |
| `20260601_003` | Schema | Expands site templateType regex to all current templates |
| `20260601_004` | Schema | Bot schema updates |
| `20260609_005` | Schema | Adds orderStatus to order schema for fulfillment lifecycle |
