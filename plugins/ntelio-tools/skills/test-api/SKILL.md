---
name: test-api
description: Test Scriptr.io API endpoints with debug mode enabled. Use when the user wants to test, debug, or verify an API endpoint is working correctly.
allowed-tools: Read, Bash, mcp__scriptr__test_api
---

# API Endpoint Tester

This skill tests Scriptr.io API endpoints with debug mode for detailed logging.

## When to Use This Skill

- User says "test", "try", or "call" an API endpoint
- After syncing files to verify they work
- When debugging API issues
- When user wants to see server-side logs

## Usage Patterns

```
/test-api POST /v1/orders/list
/test-api GET /v1/orders/ABC123
/test-api POST /v1/orders/create {"name": "Test Order"}
/test-api waba/flows/list {"botKey": "my_bot"}
```

## Workflow

### Step 1: Parse Request

Extract from user input:
- **HTTP Method**: GET, POST, PUT, DELETE (default: POST)
- **Endpoint Path**: API path (with or without prefix)
- **Request Body**: JSON payload (optional)

### Step 2: Build Full URL

Construct the full API URL:

```
Base patterns:
- CommerceGenie: https://{instance}/openapi/handlers/v1/{endpoint}
- Middleware: https://{instance}/ntelioMiddleware/server/api/core/v1/{endpoint}
```

Auto-detect based on path:
- Starts with `waba/`, `forms/`, `databundle/` → Middleware
- Otherwise → CommerceGenie (openapi)

### Step 3: Add Debug Mode

Append `?debug_mode=true` for verbose server logs.

### Step 4: Execute Request

Use MCP tool or curl:

```bash
curl -X {METHOD} "{URL}?debug_mode=true" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{BODY}'
```

### Step 5: Parse Response

**CRITICAL**: Scriptr.io wraps responses - check the INNER status:

```json
{
  "response": {
    "metadata": {
      "status": "success"
    },
    "result": {
      "metadata": {
        "status": "failure",
        "errorCode": "BOT_NOT_FOUND",
        "errorDetail": "Bot not found"
      }
    }
  }
}
```

The outer `metadata.status` is the gateway status (always success if handler ran).
The inner `result.metadata.status` is the ACTUAL handler status - check this one.

### Step 6: Display Results

Format output clearly showing success/failure and any server logs.

## Common Error Codes

| Error Code | Meaning |
|------------|---------|
| `API_DEFINITION_NOT_FOUND` | OpenAPI spec file missing or wrong path |
| `HANDLER_NOT_FOUND` | Handler file missing or wrong location |
| `VALIDATION_ERROR` | Request doesn't match OpenAPI spec |
| `STORE_NOT_FOUND` | Document store doesn't exist |
| `DOCUMENT_NOT_FOUND` | Record with given key not found |
| `AUTHENTICATION_REQUIRED` | Missing or invalid auth token |

## Examples

### Test List Endpoint
```
User: /test-api POST waba/flows/list {"botKey": "demo_bot"}
Assistant: Testing POST /ntelioMiddleware/server/api/core/v1/waba/flows/list...

Result: success
Response:
{
  "flows": [
    {"id": "flow_123", "name": "Order Flow"},
    {"id": "flow_456", "name": "Support Flow"}
  ]
}
```

### Test with Path Parameter
```
User: /test-api GET /v1/orders/ORD-123
Assistant: Testing GET /openapi/handlers/v1/orders/ORD-123...

Result: success
Response:
{
  "documents": [{
    "key": "ORD-123",
    "status": "pending",
    "total": 150.00
  }]
}
```

### Debug a Failing Endpoint
```
User: /test-api POST orders/create {"invalid": "data"}
Assistant: Testing POST /openapi/handlers/v1/orders/create...

Result: failure
Error: VALIDATION_ERROR - Required field 'name' is missing

Server Logs:
[18:09:03] ERROR: Validation failed in orders/create
[18:09:03] DEBUG: Missing fields: name, amount
```

## Related Skills

- `/sync` - Sync files before testing
- `/create-api` - Create new API endpoints
