---
name: create-api
description: Create a new API endpoint with OpenAPI spec and handler. Use when the user wants to create a new REST endpoint, add an API, or implement a new backend route.
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion, mcp__scriptr__sync_file
---

# Create API Endpoint

This skill creates new API endpoints following the ntelio API Gateway patterns.

## When to Use This Skill

- User asks to "create an API", "add an endpoint", or "implement a route"
- Need to add CRUD operations for a resource
- Creating new backend functionality

## Usage Patterns

```
/create-api orders list POST
/create-api products/{key} GET
/create-api waba/flows/create POST
/create-api sites/render/{key} GET --location=openapi
```

## Workflow

### Step 1: Gather Information

Ask for missing information:

1. **Collection name** (e.g., orders, products, waba)
2. **Endpoint path** (e.g., list, create, {key}, {key}/details)
3. **HTTP method** (GET, POST, PUT, DELETE)
4. **Location**: Project-specific (`openapi/`) or shared middleware (`ntelioMiddleware/`)

**Decision guide for location:**
- Project-specific features → `openapi/`
- Reusable/generic features → `ntelioMiddleware/server/`
- Default to project-specific if unsure

### Step 2: Determine File Paths

Based on collection and location:

**Project-specific (openapi/):**
```
Spec: openapi/specs/v1/{collection}.json
Handler: openapi/handlers/v1/{collection}/{endpoint_path}/{method}
```

**Shared middleware (ntelioMiddleware/):**
```
Spec: ntelioMiddleware/server/apispecs/v1/{collection}.json
Handler: ntelioMiddleware/server/handlers/v1/{collection}/{endpoint_path}/{method}
```

### Step 3: Create/Update OpenAPI Spec

If spec file doesn't exist, create it:

```json
{
  "openapi": "3.0.3",
  "info": {
    "title": "{Collection} API",
    "version": "1.0.0",
    "description": "API for managing {collection}"
  },
  "paths": {},
  "components": {
    "securitySchemes": {
      "BearerAuth": {
        "type": "http",
        "scheme": "bearer"
      }
    }
  }
}
```

Add the new path entry:

```json
"/{endpoint}": {
  "{method}": {
    "summary": "{Description}",
    "operationId": "{operationId}",
    "security": [{"BearerAuth": []}],
    "parameters": [
      // Add path params like {key}
    ],
    "requestBody": {
      // For POST/PUT
    },
    "responses": {
      "200": {
        "description": "Success"
      }
    }
  }
}
```

### Step 4: Create Handler File

Create handler with ES5 boilerplate:

```javascript
require("/ntelioMiddleware/server/commons").importPackages(["config", "logger"], this)

var CustomException = require("/ntelioMiddleware/server/CustomException").CustomException

/**
 * Handler for {METHOD} /{collection}/{endpoint}
 * {Description}
 */
function call(params, pathParams, spec) {
    try {
        // Input validation
        if (!params.requiredField) {
            throw new CustomException("requiredField is required", 400)
        }

        // Your implementation here
        var documents = require("document")
        var store = documents.getInstance("{StoreName}")

        // Example: List operation
        var result = store.query({
            fields: "*",
            query: 'isActive = "true"',
            pageNumber: params.pageNumber || 1,
            resultsPerPage: params.resultsPerPage || 20,
            count: true
        })

        return {
            result: {
                documents: result.result.documents || [],
                count: result.result.count
            },
            metadata: {
                status: "success",
                statusCode: 200
            }
        }

    } catch (e) {
        if (e instanceof CustomException) {
            return {
                metadata: {
                    status: "failure",
                    statusCode: e.statusCode || 500,
                    errorCode: e.errorCode || "ERROR",
                    errorDetail: e.message
                }
            }
        }

        log.error("Handler error: " + e.message)
        return {
            metadata: {
                status: "failure",
                statusCode: 500,
                errorCode: "INTERNAL_SERVER_ERROR",
                errorDetail: "An unexpected error occurred"
            }
        }
    }
}
```

### Step 5: Remind to Sync

After creating files, remind user:

```
Files created:
- {spec_path}
- {handler_path}

To deploy, run:
/sync {spec_path} {handler_path}

To test:
/test-api {METHOD} /{collection}/{endpoint}
```

## Handler Templates

### GET (List)
```javascript
function call(params, pathParams, spec) {
    try {
        var documents = require("document")
        var store = documents.getInstance("{StoreName}")

        // Check for single item by key
        if (pathParams && pathParams.key) {
            var result = store.get(pathParams.key)
            if (!result.result || result.result.isActive !== "true") {
                throw new CustomException("Not found", 404)
            }
            return {
                result: { documents: [result.result] },
                metadata: { status: "success" }
            }
        }

        // List with pagination
        var filter = {
            fields: "*",
            query: 'isActive = "true"',
            pageNumber: params.pageNumber || 1,
            resultsPerPage: params.resultsPerPage || 20,
            sort: "creationDate<date:DESC>",
            count: true
        }

        var result = store.query(filter)

        return {
            result: {
                documents: result.result.documents || [],
                count: result.result.count
            },
            metadata: { status: "success" }
        }
    } catch (e) {
        // Error handling...
    }
}
```

### POST (Create)
```javascript
function call(params, pathParams, spec) {
    try {
        // Validation
        if (!params.name) {
            throw new CustomException("name is required", 400)
        }

        var documents = require("document")
        var store = documents.getInstance("{StoreName}")

        var newDoc = {
            name: params.name,
            // ... other fields
            isActive: "true"
        }

        var result = store.save(newDoc)

        return {
            result: {
                key: result.result.document.key,
                document: result.result.document
            },
            metadata: { status: "success" }
        }
    } catch (e) {
        // Error handling...
    }
}
```

### PUT (Update)
```javascript
function call(params, pathParams, spec) {
    try {
        if (!pathParams || !pathParams.key) {
            throw new CustomException("key is required", 400)
        }

        var documents = require("document")
        var store = documents.getInstance("{StoreName}")

        // Verify exists
        var existing = store.get(pathParams.key)
        if (!existing.result || existing.result.isActive !== "true") {
            throw new CustomException("Not found", 404)
        }

        var updateData = {
            key: pathParams.key
        }

        // Update only provided fields
        if (params.name !== undefined) updateData.name = params.name
        // ... other fields

        var result = store.save(updateData)

        return {
            result: { document: result.result.document },
            metadata: { status: "success" }
        }
    } catch (e) {
        // Error handling...
    }
}
```

### DELETE (Soft Delete)
```javascript
function call(params, pathParams, spec) {
    try {
        if (!pathParams || !pathParams.key) {
            throw new CustomException("key is required", 400)
        }

        var documents = require("document")
        var store = documents.getInstance("{StoreName}")

        // Verify exists
        var existing = store.get(pathParams.key)
        if (!existing.result || existing.result.isActive !== "true") {
            throw new CustomException("Not found", 404)
        }

        // Soft delete
        store.save({
            key: pathParams.key,
            isActive: "false"
        })

        return {
            result: { message: "Deleted successfully" },
            metadata: { status: "success" }
        }
    } catch (e) {
        // Error handling...
    }
}
```

## Key Rules

1. **Spec filename = Collection name** (first URL segment after version)
2. **Handler path mirrors API path** (no `{key}` folders)
3. **Handler files have NO extension** (just `get`, `post`, `put`, `delete`)
4. **Use ES5 JavaScript** (no arrow functions, const/let, template literals)
5. **Always return `documents` array** (even for single items)
6. **Use soft deletes** (`isActive = "false"`)

## Examples

### Create Orders List API
```
User: /create-api orders list POST
Assistant: Creating API endpoint...

Location: openapi/ (project-specific)
Spec: openapi/specs/v1/orders.json
Handler: openapi/handlers/v1/orders/list/post

[Creates spec and handler files]

Files created. To deploy:
/sync openapi/specs/v1/orders.json openapi/handlers/v1/orders/list/post
```

### Create WABA Flow API (middleware)
```
User: /create-api waba/flows/create POST --location=middleware
Assistant: Creating API endpoint...

Location: ntelioMiddleware/server/ (shared)
Spec: ntelioMiddleware/server/apispecs/v1/waba.json
Handler: ntelioMiddleware/server/handlers/v1/waba/flows/create/post

[Creates/updates spec and handler]
```

## Related Skills

- `/sync` - Deploy created files
- `/test-api` - Test the endpoint
- `/create-fcbo` - Create full business object with UI
