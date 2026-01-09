---
name: create-fcbo
description: Create a First-Class Business Object (FCBO) with schema, API, and UI. Use when the user wants to create a new entity, business object, or data model with full CRUD operations.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, mcp__scriptr__sync_file
---

# Create First-Class Business Object (FCBO)

This skill creates a complete business object with schema, REST API, and optional UI page.

## When to Use This Skill

- User asks to "create a business object", "add an entity", or "create a new data type"
- Need full CRUD operations for a new resource
- Building a new feature that requires persistent data

## Usage Patterns

```
/create-fcbo Order
/create-fcbo Product --with-ui
/create-fcbo Receipt --fields="vendorName,amount,date"
```

## Workflow

### Step 1: Gather Requirements

Prompt for:

1. **Object name** (singular, PascalCase): e.g., Order, Product, Receipt
2. **Fields** (name:type): e.g., "name:string, amount:numeric, status:string"
3. **Store name**: e.g., OrdersStore (default: {Object}sStore)
4. **Include UI page?**: Yes/No
5. **Location**: Project-specific or middleware

### Step 2: Generate Components

Create these files in order:

1. **XML Schema** - Data validation and ACL
2. **OpenAPI Spec** - REST API definition
3. **Handlers** - GET, POST, PUT, DELETE
4. **UI Page** - (optional) ntelioUI component
5. **Test Scripts** - curl commands for testing

### Step 3: Files Created

```
setup/schema/{object}.xml              # Schema
openapi/specs/v1/{objects}.json        # API Spec
openapi/handlers/v1/{objects}/
├── get                                # List and Get by key
├── post                               # Create
├── put                                # Update
└── delete                             # Soft delete
client/pages/{Objects}.js              # UI Page (optional)
tests/{objects}/                       # Test scripts
├── create.sh
├── list.sh
├── get.sh
├── update.sh
└── delete.sh
```

## Component Templates

### 1. XML Schema

```xml
<schema>
    <aclGroups>
        <aclGroup name='{object}'>
            <read>authenticated</read>
            <write>authenticated</write>
            <fields>
                <!-- List all custom fields -->
                <field>name</field>
                <field>description</field>
                <field>{status_field}</field>
                <field>isActive</field>
            </fields>
        </aclGroup>
        <defaultAcl>
            <read>authenticated</read>
            <write>authenticated</write>
            <delete>group:admins</delete>
        </defaultAcl>
        <schemaAcl>
            <read>nobody</read>
            <write>nobody</write>
            <delete>nobody</delete>
        </schemaAcl>
    </aclGroups>

    <fields>
        <!-- Custom business fields only -->
        <!-- NEVER define: key, creator, creationDate, lastModifiedBy, lastModifiedDate, versionNumber -->

        <field name='name' type='string'>
            <validation>
                <cardinality min='1' max='1'/>
            </validation>
        </field>

        <field name='description' type='text'>
            <validation>
                <cardinality min='0' max='1'/>
            </validation>
        </field>

        <field name='{object}Status' type='string'>
            <validation>
                <cardinality min='1' max='1'/>
            </validation>
        </field>

        <field name='isActive' type='string'>
            <validation>
                <cardinality min='1' max='1'/>
            </validation>
        </field>
    </fields>
</schema>
```

**Schema Rules:**
- Use `{object}Status` not just `status` (reserved)
- Always include `isActive` for soft deletes
- Never define automatic fields (key, creator, dates, version)
- Use semicolons for multiple ACL groups: `group:admins;group:managers`

### 2. OpenAPI Spec

```json
{
  "openapi": "3.0.3",
  "info": {
    "title": "{Object} API",
    "version": "1.0.0"
  },
  "paths": {
    "/": {
      "get": {
        "summary": "List {objects}",
        "parameters": [
          {"name": "pageNumber", "in": "query", "schema": {"type": "integer"}},
          {"name": "resultsPerPage", "in": "query", "schema": {"type": "integer"}},
          {"name": "query", "in": "query", "schema": {"type": "string"}}
        ]
      },
      "post": {
        "summary": "Create {object}",
        "requestBody": {
          "content": {
            "application/json": {
              "schema": {"$ref": "#/components/schemas/{Object}"}
            }
          }
        }
      }
    },
    "/{key}": {
      "get": {"summary": "Get {object} by key"},
      "put": {"summary": "Update {object}"},
      "delete": {"summary": "Delete {object}"}
    }
  },
  "components": {
    "schemas": {
      "{Object}": {
        "type": "object",
        "properties": {
          "name": {"type": "string"},
          "description": {"type": "string"},
          "{object}Status": {"type": "string"}
        },
        "required": ["name"]
      }
    }
  }
}
```

### 3. Handlers

See `/create-api` skill for handler templates. Key points:
- All handlers use ES5 JavaScript
- Import commons and CustomException
- Return `documents` array (even for single items)
- Use soft deletes (`isActive = "false"`)

### 4. UI Page (ntelioUI)

```javascript
import { Page } from "../../client_modules/ntelioUI/Page.js"
import { DataControl } from "../../client_modules/ntelioUI/grid/DataControl.js"
import { PaginationControls } from "../../client_modules/ntelioUI/grid/PaginationControls.js"
import { EntityDataProvider } from "../../client_modules/ntelioServer/data/EntityDataProvider.js"
import { SchemaAdaptor } from "../../client_modules/ntelioServer/data/util/SchemaAdaptor.js"

export class {Objects} extends Page {
    constructor(attrs) {
        const template = `
        <div class="card content">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">{Objects}</h5>
                <button class="btn btn-primary btn-sm" id="addBtn">
                    <i class="fas fa-plus"></i> Add {Object}
                </button>
            </div>
            <div class="card-body">
                <div id="{objects}Control"></div>
            </div>
        </div>
        `
        super({ template: template, ...attrs })
    }

    async init() {
        Page.loadCss('css/{objects}.css')

        var schema = new SchemaAdaptor({
            schemaName: "{objects}",
            validation: {
                name: { required: true }
            },
            display: {
                // Hide automatic fields
                key: { hidden: true },
                creator: { hidden: true },
                creationDate: { hidden: true },
                lastModifiedBy: { hidden: true },
                lastModifiedDate: { hidden: true },
                versionNumber: { hidden: true },
                latest: { hidden: true },
                isActive: { hidden: true },

                // Configure visible fields
                name: {
                    label: "Name",
                    widget: DataControl.widgets.TEXT
                },
                description: {
                    label: "Description",
                    widget: DataControl.widgets.TEXTAREA
                },
                {object}Status: {
                    label: "Status",
                    widget: DataControl.widgets.SELECT,
                    options: [
                        { value: "active", label: "Active" },
                        { value: "inactive", label: "Inactive" }
                    ]
                }
            }
        })

        const dataProvider = new EntityDataProvider("{object}")

        const gridControl = new DataControl({
            dataProvider: dataProvider,
            schema: await schema.get(),
            paginationControlsCls: PaginationControls,
            columnTitles: {
                0: "Name",
                1: "Description",
                2: "Status"
            },
            editable: true,
            selectable: true,
            mode: "grid"
        })

        gridControl.appendTo(this.find("#{objects}Control"))
        gridControl.init()

        // Add button handler
        this.find("#addBtn").on("click", () => {
            gridControl.showForm({})
        })
    }
}
```

### 5. Test Scripts

```bash
#!/bin/bash
# tests/{objects}/create.sh

AUTH_TOKEN=$(jq -r '.accessToken' scriptrExtensionConfig.json)
INSTANCE=$(jq -r '.instanceUrl' scriptrExtensionConfig.json)

curl -X POST "https://$INSTANCE/openapi/handlers/v1/{objects}?debug_mode=true" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test {Object}",
    "description": "Created by test script",
    "{object}Status": "active"
  }'
```

## Field Types

| Type | Schema Type | UI Widget |
|------|-------------|-----------|
| Short text | `string` | `TEXT` |
| Long text | `text` | `TEXTAREA` |
| Number | `numeric` | `NUMBER` |
| Date | `date` | `CALENDAR` |
| Selection | `string` | `SELECT` |
| Boolean | `string` ("true"/"false") | `CHECKBOX` |
| File | `file` | `FILE` |

## Main.js Integration

Add to application routes and menu:

```javascript
// In Main.js
static routesMap = {
    // ... existing routes
    "/{objects}": "pages/{Objects}"
}

static menu = [
    // ... existing menu items
    {
        icon: Icons.{objectIcon},
        label: "{Objects}",
        path: "/{objects}"
    }
]
```

## Complete Example

### Create "Receipt" Business Object

```
User: /create-fcbo Receipt --fields="vendorName:string,totalAmount:numeric,receiptDate:date,status:string" --with-ui
Assistant: Creating Receipt business object...

Gathering requirements:
- Object: Receipt (singular), Receipts (plural)
- Store: ReceiptsStore
- Fields: vendorName, totalAmount, receiptDate, receiptStatus, isActive

Creating files:
1. setup/schema/receipt.xml - Schema created
2. openapi/specs/v1/receipts.json - API spec created
3. openapi/handlers/v1/receipts/get - List/Get handler created
4. openapi/handlers/v1/receipts/post - Create handler created
5. openapi/handlers/v1/receipts/put - Update handler created
6. openapi/handlers/v1/receipts/delete - Delete handler created
7. client/pages/Receipts.js - UI page created
8. tests/receipts/*.sh - Test scripts created

To deploy:
/sync setup/schema/receipt.xml
/sync openapi/specs/v1/receipts.json
/sync openapi/handlers/v1/receipts/get
/sync openapi/handlers/v1/receipts/post
/sync openapi/handlers/v1/receipts/put
/sync openapi/handlers/v1/receipts/delete

To test:
/test-api POST receipts {"name": "Test Receipt", "totalAmount": 100}

Don't forget to:
1. Create the ReceiptsStore in Scriptr.io console
2. Add route to Main.js
```

## Related Skills

- `/create-api` - Create individual API endpoints
- `/sync` - Deploy files to Scriptr.io
- `/test-api` - Test created endpoints
- `/prd-writer` - Document requirements before building