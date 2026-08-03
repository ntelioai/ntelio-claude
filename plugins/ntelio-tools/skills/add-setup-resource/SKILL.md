---
name: add-setup-resource
description: Explains how to add new resources (schemas, stores, groups, channels) to the ntelioMiddleware initialization system. Use when implementing new features that require database stores, document schemas, user groups, or messaging channels.
allowed-tools: Read, Grep, Glob, Write, Edit
---

# Add Setup Resource

This skill guides you through adding new infrastructure resources to the initialization system for ntelioMiddleware-based projects.

## When to Use This Skill

- Adding a new data entity that requires an XML schema
- Implementing role-based access that needs user groups
- Setting up real-time features that need messaging channels
- Planning infrastructure for a new business object

## STOP — before you add a *store*

Stores and schemas are **independent**. A store holds MANY document types,
selected at query time with `schema="..."`. A schema can be reused across
stores. A store is a *database* in the NoSQL sense — **not** a table, not a type.

Adding a store is the **exception**, not a step in the workflow. A new schema in
an existing store is the norm. Check, in order:

1. Which existing store already holds the most closely related data?
2. Does `schema="yourType"` in that store do the job? (It almost always does.)
3. Master–detail? Co-locating both sides in one store lets a SINGLE query load
   them (`schema="master" OR schema="detail"`), then join in script — instead of
   two round trips.

Accounts have a **per-account store cap**. commerceGenie is at ~40 stores, nearly
all holding one schema, because this check didn't exist. `openapi/lib/sites/
siteTemplates` is the counter-example that got it right: user templates live in
the *existing* sites store under `schema="template"`, and the reasoning is
recorded in the file.

Add a store only for a genuinely different lifecycle, ACL regime, or scale — and
record the reason next to the `INIT.APP` entry.

## Two Non-Negotiable Rules

1. **The init entry ships in the SAME commit as the code that uses the resource.** A resource whose only provisioning is a one-off `setup/apply*` script is a bug: new accounts will never get it. One-off apply scripts are dev-time conveniences only — fold them into init (+ migration) and delete them before merge.
2. **Existing child accounts do NOT receive init changes.** Pair every init change with a migration in the same PR — use the `/create-migration` skill.

## Child vs Parent Resources

This skill covers **child-account (tenant) resources** — the ones INIT.APP/INIT.DEFAULTS provision into every business account.

**Parent/provisioner-only resources** (cross-tenant stores like `BusinessAccounts` or the MCP OAuth stores, service users, platform webhook config) do NOT belong in INIT.APP or in migrations — child accounts must never host them. Their home is **`setup/initParent`**: add an idempotent section (create-or-tolerate-exists, like the existing ones) and re-run `initParent` on the provisioner to apply. If your resource is only ever read/written by handlers that execute in the parent's own data context (provisioning, unified payment, ingress routing/demux, operator tooling), it's a parent resource.

## Quick Reference

### Files to Modify

| Resource Type | ENV File | INIT File | Schema Location |
|--------------|----------|-----------|-----------------|
| Schema | `ENV` | `setup/INIT.APP` | `setup/schema/*.xml` |
| Store | `ENV` | `setup/INIT.APP` | N/A |
| Group | N/A | `setup/INIT.APP` | N/A |
| Channel | `ENV` | `setup/INIT.APP` | N/A |
| TS Store | `ENV` | `setup/INIT.APP` | `setup/schema/ts/*` |
| Parent-only resource | `ENV` (if configurable) | `setup/initParent` | `setup/schema/*.xml` |

### Resource Naming Conventions

```
Schemas:    PascalCase singular    → Catalog, Order, WabaFlow
Stores:     PascalCaseStore        → CatalogStore, OrdersStore
Groups:     camelCase              → catalogAdmins, orderManagers
Channels:   camelCase              → orderNotifications, inventoryUpdates
ENV vars:   SCREAMING_SNAKE_CASE   → CATALOG_SCHEMA, ORDERS_STORE
```

## Step-by-Step: Adding a New Resource

### Step 1: Define ENV Variables

Add placeholders to the `ENV` file at project root:

```javascript
// ENV file - add your new variables
var ENV = {
    // ... existing variables ...

    // New schema
    INVENTORY_SCHEMA: "Inventory",

    // New store
    INVENTORY_STORE: "InventoryStore",

    // New channel (if needed)
    INVENTORY_CHANNEL: "inventoryUpdates"
};
```

### Step 2: Create XML Schema (if needed)

Create the schema file at `setup/schema/inventory.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<schema>
    <!-- ACL Groups define field-level access -->
    <aclGroups>
        <aclGroup name='inventory'>
            <read>authenticated</read>
            <write>group:inventoryAdmins;group:admins</write>
            <fields>
                <field>sku</field>
                <field>quantity</field>
                <field>location</field>
            </fields>
        </aclGroup>
    </aclGroups>

    <!-- Default document-level ACL -->
    <defaultAcl>
        <read>authenticated</read>
        <write>group:inventoryAdmins;group:admins</write>
        <delete>group:admins</delete>
    </defaultAcl>

    <!-- Schema ACL (who can modify the schema itself) -->
    <schemaAcl>
        <read>nobody</read>
        <write>nobody</write>
    </schemaAcl>

    <!-- Field definitions -->
    <fields>
        <!-- Required: key field for document identification -->
        <field name='key' type='string' unique='true'/>

        <!-- Business fields -->
        <field name='sku' type='string'/>
        <field name='productName' type='string'/>
        <field name='quantity' type='numeric'/>
        <field name='location' type='string'/>
        <field name='lastUpdated' type='date'/>

        <!-- Soft delete support -->
        <field name='isActive' type='string'/>
    </fields>
</schema>
```

### Step 3: Create Metadata File for Schema

Create `.inventory.xml.metadata` in the same directory:

```json
{"acl":{"read":"anonymous","write":"nobody","execute":"nobody"},"contentType":"text/xml"}
```

### Step 4: Update INIT.APP

Edit `setup/INIT.APP` to register your resources:

```javascript
var INIT = {
    _extends: "/ntelioMiddleware/setup/INIT.DEFAULTS",

    // Add new groups (if needed)
    groups: [
        // ... existing groups ...
        { name: "inventoryAdmins", tag: "CREATE_INVENTORY_ADMINS_GROUP" }
    ],

    // Add new schemas
    schemas: [
        // ... existing schemas ...
        { name: "{{INVENTORY_SCHEMA}}", file: "setup/schema/inventory.xml", tag: "CREATE_INVENTORY_SCHEMA" }
    ],

    // Add new stores
    stores: [
        // ... existing stores ...
        { name: "{{INVENTORY_STORE}}", tag: "CREATE_INVENTORY_STORE" }
    ],

    // Add new channels (if needed for real-time features)
    channels: [
        // ... existing channels ...
        {
            name: "{{INVENTORY_CHANNEL}}",
            options: {
                subscribeACL: "authenticated",
                publishACL: "group:inventoryAdmins;group:admins"
            },
            tag: "CREATE_INVENTORY_CHANNEL"
        }
    ]
};
```

### Step 5: Sync and Run Init

```bash
# Sync the new schema file
./setup/sync/sync-file.sh setup/schema/inventory.xml

# Sync the updated INIT.APP
./setup/sync/sync-file.sh setup/INIT.APP

# Sync ENV if modified
./setup/sync/sync-file.sh ENV

# Run initialization (creates all resources)
curl -X POST "https://yourinstance.scriptrapps.io/ntelioMiddleware/setup/init" \
  -H "Authorization: bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

## Resource Types Explained

### Schemas

Define document structure and access control:

```javascript
// In INIT.APP schemas array
{
    name: "{{INVENTORY_SCHEMA}}",      // ENV placeholder for schema name
    file: "setup/schema/inventory.xml", // Path to XML schema file
    tag: "CREATE_INVENTORY_SCHEMA"      // Unique tag for logging/tracking
}
```

**Schema Field Types:**
| Type | Description | Example |
|------|-------------|---------|
| `string` | Text up to 255 chars | `sku`, `status` |
| `text` | Long text (searchable) | `description`, `notes` |
| `numeric` | Numbers | `quantity`, `price` |
| `date` | ISO date format | `createdDate`, `lastUpdated` |
| `file` | Binary attachments | `receipt`, `image` |

### Stores

Document storage containers:

```javascript
// In INIT.APP stores array
{
    name: "{{INVENTORY_STORE}}",   // ENV placeholder for store name
    tag: "CREATE_INVENTORY_STORE"  // Unique tag for logging
}
```

**Store naming patterns:**
- `BotsStore` - Bot configurations
- `CatalogStore` - Product catalog
- `OrdersStore` - Order records
- `SiteAssetsStore` - File storage (no schema)

### Groups

User groups for access control:

```javascript
// In INIT.APP groups array
{
    name: "inventoryAdmins",           // Group name (used in ACLs)
    tag: "CREATE_INVENTORY_ADMINS_GROUP"  // Unique tag
}
```

**Common group patterns:**
- `admins` - Full system access
- `{feature}Admins` - Feature-specific admin access
- `{feature}Users` - Feature read/limited write access

### Channels

Real-time messaging channels:

```javascript
// In INIT.APP channels array
{
    name: "{{INVENTORY_CHANNEL}}",
    options: {
        subscribeACL: "authenticated",     // Who can listen
        publishACL: "group:inventoryAdmins" // Who can send
    },
    tag: "CREATE_INVENTORY_CHANNEL"
}
```

### Time Series Stores

For analytics and event logging:

```javascript
// In INIT.APP tsStores array
{
    name: "{{INVENTORY_EVENTS_TS_STORE}}",
    file: "setup/schema/ts/InventoryEvents",  // TS schema definition
    tag: "NEW_TS_STORE:InventoryEvents"
}
```

## Merge Behavior

When INIT.APP extends INIT.DEFAULTS:

### Arrays Merge by Name

```javascript
// INIT.DEFAULTS
groups: [
    { name: "admins", tag: "BASE_ADMINS" }
]

// INIT.APP
groups: [
    { name: "admins", tag: "APP_ADMINS" },      // OVERRIDES base (same name)
    { name: "inventoryAdmins", tag: "NEW" }     // ADDS (new name)
]

// Result
groups: [
    { name: "admins", tag: "APP_ADMINS" },      // Overridden
    { name: "inventoryAdmins", tag: "NEW" }     // Added
]
```

### Objects Deep Merge

```javascript
// INIT.DEFAULTS
configuration: {
    "setting1": "value1"
}

// INIT.APP
configuration: {
    "setting1": "newValue",  // Overrides
    "setting2": "value2"     // Adds
}
```

## Common Patterns

### Business Object (FCBO) Resources

A First-Class Business Object typically needs:

```javascript
// For a "Supplier" business object:

// 1. ENV variables
SUPPLIER_SCHEMA: "Supplier",
SUPPLIER_STORE: "SuppliersStore",

// 2. Schema file: setup/schema/supplier.xml

// 3. INIT.APP entries
schemas: [
    { name: "{{SUPPLIER_SCHEMA}}", file: "setup/schema/supplier.xml", tag: "CREATE_SUPPLIER_SCHEMA" }
],
stores: [
    { name: "{{SUPPLIER_STORE}}", tag: "CREATE_SUPPLIER_STORE" }
],
groups: [
    { name: "supplierAdmins", tag: "CREATE_SUPPLIER_ADMINS_GROUP" }
]
```

### Real-Time Feature Resources

For features needing live updates:

```javascript
// 1. ENV variables
ORDER_NOTIFICATIONS_CHANNEL: "orderNotifications",

// 2. INIT.APP channel
channels: [
    {
        name: "{{ORDER_NOTIFICATIONS_CHANNEL}}",
        options: {
            subscribeACL: "authenticated",
            publishACL: "authenticated"
        },
        tag: "CREATE_ORDER_NOTIFICATIONS_CHANNEL"
    }
]
```

### Analytics/Logging Resources

For event tracking:

```javascript
// 1. ENV variables
ORDER_EVENTS_TS_STORE: "OrderEventsTS",

// 2. TS schema file: setup/schema/ts/OrderEvents

// 3. INIT.APP tsStores
tsStores: [
    { name: "{{ORDER_EVENTS_TS_STORE}}", file: "setup/schema/ts/OrderEvents", tag: "NEW_TS_STORE:OrderEvents" }
]
```

## Checklist: Adding a New Resource

### Schema Checklist
- [ ] ENV variable defined (e.g., `MY_SCHEMA: "MySchema"`)
- [ ] XML schema file created at `setup/schema/myschema.xml`
- [ ] Metadata file created at `setup/schema/.myschema.xml.metadata`
- [ ] Schema registered in `INIT.APP` schemas array
- [ ] ACL groups defined appropriately
- [ ] Required fields have `type` attribute
- [ ] `key` field defined with `unique='true'`
- [ ] `isActive` field for soft deletes (recommended)

### Store Checklist
- [ ] ENV variable defined (e.g., `MY_STORE: "MyStore"`)
- [ ] Store registered in `INIT.APP` stores array
- [ ] Unique tag assigned

### Group Checklist
- [ ] Group name follows convention (camelCase)
- [ ] Group registered in `INIT.APP` groups array
- [ ] Group referenced in schema ACLs where needed
- [ ] Unique tag assigned

### Channel Checklist
- [ ] ENV variable defined
- [ ] Channel registered in `INIT.APP` channels array
- [ ] subscribeACL set appropriately
- [ ] publishACL set appropriately
- [ ] Unique tag assigned

### Post-Setup Checklist
- [ ] All files synced to Scriptr.io
- [ ] Init endpoint called successfully
- [ ] Resources verified in Scriptr.io console
- [ ] API handlers updated to use new stores/schemas

## Troubleshooting

### "Schema file not found"
- Verify file path in INIT.APP matches actual location
- Check file is synced to Scriptr.io
- Path should be relative to project root

### "Store already exists"
- This is normal and not an error
- Init is idempotent - safe to re-run

### "Missing config value for placeholder"
- Add the missing variable to ENV file
- Sync ENV file to Scriptr.io

### "Invalid schema XML"
- Validate XML syntax
- Check all required attributes present
- Verify field types are valid

## Reference Links

- [Setup Documentation](ntelioMiddleware/docs/setup.md) - Full init system docs
- [Scriptr.io Schema Guide](docs/scriptr.io/docs/modules/12-schema.md) - Schema module reference
