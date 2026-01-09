# Configure Skill

Add configuration values to the ntelio platform's 3-layer configuration system.

## Activation

This skill activates when the user wants to:
- Add a new configuration value or setting
- Configure an API key, secret, or credential
- Add feature-specific settings
- Understand where configuration should go

## Configuration System Overview

```
ENV files (values)  →  CONFIG files (structure)  →  Resolved Config
     ↓                        ↓                           ↓
 {{PLACEHOLDER}}      server.tools.myKey        actual value at runtime
```

## Decision Tree: Where Does It Go?

### Step 1: Is it a VALUE or STRUCTURE?

**VALUES** (ENV files) - The actual data:
- API keys, tokens, secrets
- Environment-specific URLs
- Feature flags
- Schema/store names

**STRUCTURE** (CONFIG files) - How values are organized:
- Nested object hierarchy
- Placeholder references `{{VALUE_NAME}}`
- Default values
- Section groupings

### Step 2: Which ENV File?

| Type | File | Git Status | Example |
|------|------|------------|---------|
| Secrets, API keys | `ENV.dev` / `ENV.prod` | **Gitignored** | `OPENAI_API_KEY: "sk-..."` |
| Environment-specific (non-secret) | `ENV.dev` / `ENV.prod` | **Gitignored** | `SUBDOMAIN: "myapp-dev"` |
| Shared across all environments | `ENV` | Versioned | `DEFAULT_LLM_MODEL: "gpt-4o"` |
| Schema names | `ENV` | Versioned | `MY_SCHEMA: "my_schema"` |
| Store names | `ENV` | Versioned | `MY_STORE: "MyStore"` |

**Always update `ENV.template`** to document new values for other developers.

### Step 3: Which CONFIG File?

| Type | File | Location |
|------|------|----------|
| Middleware-level (shared across all ntelio projects) | `CONFIG.DEFAULTS` | `ntelioMiddleware/server/CONFIG.DEFAULTS` |
| Project-specific | `CONFIG.APP` | Project root `/CONFIG.APP` |

### Step 4: Which SECTION of CONFIG?

#### Server Section (`server.*`)

```javascript
server: {
    // Core identity
    url: "https://{{SUBDOMAIN}}.scriptrapps.io",
    subdomain: "{{SUBDOMAIN}}",
    token: "{{ANON_TOKEN}}",

    // Logging
    logChannel: "{{LOG_CHANNEL}}",
    logLevel: "{{LOG_LEVEL}}",
    realTimeLogging: "{{REALTIME_LOGGING}}",

    // Schema references - naming convention: {name}SchemaName
    historySessionSchemaName: "{{HISTORY_SESSION_SCHEMA}}",
    ragDocumentSchemaName: "{{RAG_DOCUMENT_SCHEMA}}",
    myFeatureSchemaName: "{{MY_FEATURE_SCHEMA}}",  // ADD NEW SCHEMAS HERE

    // Store references - naming convention: {Name}StoreName
    RAGStoreName: "{{RAG_STORE}}",
    sessionStoreName: "{{SESSION_STORE}}",
    MyFeatureStoreName: "{{MY_FEATURE_STORE}}",  // ADD NEW STORES HERE

    // External APIs/Tools - grouped under tools.*
    tools: {
        openAIApiKey: "{{OPENAI_API_KEY}}",
        openAIUrl: "{{OPENAI_API_URL}}",
        googleSearchApiKey: "{{GOOGLE_SEARCH_API_KEY}}",
        myApiKey: "{{MY_API_KEY}}"  // ADD NEW API KEYS HERE
    },

    // Feature-specific groups - create new objects for feature areas
    whatsapp: {
        apiVersion: "{{WHATSAPP_API_VERSION}}",
        accessToken: "{{WHATSAPP_ACCESS_TOKEN}}"
    },
    ecommerce: {
        taxRate: "{{ECOMMERCE_TAX_RATE}}",
        currency: "{{ECOMMERCE_CURRENCY}}"
    },
    myFeature: {  // ADD NEW FEATURE GROUPS HERE
        setting1: "{{MY_FEATURE_SETTING1}}",
        setting2: "{{MY_FEATURE_SETTING2}}"
    }
}
```

**Server section placement rules:**
| Config Type | Location | Naming Convention |
|-------------|----------|-------------------|
| Schema reference | `server.{name}SchemaName` | camelCase + "SchemaName" |
| Store reference | `server.{Name}StoreName` | PascalCase + "StoreName" |
| External API key | `server.tools.{service}ApiKey` | service + "ApiKey" |
| External API URL | `server.tools.{service}Url` | service + "Url" |
| Feature settings | `server.{featureName}.{setting}` | Group related settings |
| Logging | `server.logChannel`, `server.logLevel` | Existing keys |

#### AI Section (`ai.*`)

```javascript
ai: {
    url: "{{AI_SERVER_URL}}",
    cluster: "{{AI_CLUSTER}}",
    defaultConfig: {
        modelName: "{{DEFAULT_LLM_MODEL}}",
        temperature: 0.5,
        maxTokens: 4096  // ADD MODEL DEFAULTS HERE
    },
    // Provider-specific settings
    providers: {
        openai: { /* settings */ },
        anthropic: { /* settings */ }
    }
}
```

#### Client Section (`client.*`)

```javascript
client: {
    // Logging
    logChannel: "{{LOG_CHANNEL}}",

    // Admin UI settings
    admin: {
        restApiBaseUrl: "https://{{SUBDOMAIN}}.scriptrapps.io/ntelioMiddleware/server/api",
        theme: "light",
        pageSize: 20  // ADD ADMIN UI SETTINGS HERE
    },

    // Public UI settings
    storefront: {
        itemsPerPage: 12,
        showOutOfStock: false  // ADD STOREFRONT SETTINGS HERE
    },

    // Static values (no placeholder needed)
    productTypes: ["physical", "digital", "service"],
    supportedCurrencies: ["USD", "EUR", "GBP"]
}
```

**Client section placement rules:**
| Config Type | Location |
|-------------|----------|
| Admin dashboard settings | `client.admin.*` |
| Public storefront settings | `client.storefront.*` |
| Static lists/enums | `client.{listName}` |
| Logging | `client.logChannel` |

## Complete Example: Adding a New Feature Config

**Scenario:** Add Stripe payment configuration

### 1. Add values to ENV files

```javascript
// ENV (versioned) - shared non-secrets
var values = {
    // ... existing values ...
    STRIPE_CURRENCY: "USD",
    STRIPE_WEBHOOK_PATH: "/webhooks/stripe"
}
```

```javascript
// ENV.prod (gitignored) - secrets
var values = {
    // ... existing values ...
    STRIPE_SECRET_KEY: "sk_live_...",
    STRIPE_PUBLISHABLE_KEY: "pk_live_...",
    STRIPE_WEBHOOK_SECRET: "whsec_..."
}
```

```javascript
// ENV.template (versioned) - documentation
var values = {
    // ... existing values ...
    STRIPE_SECRET_KEY: "<your-stripe-secret-key>",
    STRIPE_PUBLISHABLE_KEY: "<your-stripe-publishable-key>",
    STRIPE_WEBHOOK_SECRET: "<your-stripe-webhook-secret>",
    STRIPE_CURRENCY: "USD",
    STRIPE_WEBHOOK_PATH: "/webhooks/stripe"
}
```

### 2. Add structure to CONFIG.APP

```javascript
// CONFIG.APP
var CONFIG = {
    _extends: "/ntelioMiddleware/server/CONFIG.DEFAULTS",

    server: {
        // Feature group for Stripe
        stripe: {
            secretKey: "{{STRIPE_SECRET_KEY}}",
            webhookSecret: "{{STRIPE_WEBHOOK_SECRET}}",
            webhookPath: "{{STRIPE_WEBHOOK_PATH}}",
            currency: "{{STRIPE_CURRENCY}}"
        }
    },

    client: {
        // Client-safe Stripe config (publishable key only!)
        stripe: {
            publishableKey: "{{STRIPE_PUBLISHABLE_KEY}}",
            currency: "{{STRIPE_CURRENCY}}"
        }
    }
}
```

### 3. Access in code

**Server-side (ES5):**
```javascript
require("/ntelioMiddleware/server/commons").importPackages(["config"], this);

var stripeKey = config.server.stripe.secretKey;
var currency = config.server.stripe.currency;
```

**Client-side (ES6):**
```javascript
import { CONFIG } from '/ntelioMiddleware/config/Client.js';

const stripeKey = CONFIG.stripe.publishableKey;  // Safe - publishable key only
const currency = CONFIG.stripe.currency;
```

## Security Rules

1. **NEVER put secrets in `ENV` (base file)** - it's versioned
2. **NEVER put secret keys in `client.*`** - exposed to browser
3. **ALWAYS add new values to `ENV.template`** - documentation for team
4. **Use `{{PLACEHOLDER}}`** syntax in CONFIG files, never hardcode values

## Common Patterns

### Adding a new external API integration
1. `ENV.{env}`: Add API key/secret
2. `ENV`: Add base URL if same across environments
3. `CONFIG.APP`: Add `server.tools.{service}ApiKey` and `server.tools.{service}Url`

### Adding a new schema/store
1. `ENV`: Add `MY_SCHEMA: "my_schema"` and `MY_STORE: "MyStore"`
2. `CONFIG.APP`: Add `server.mySchemaName: "{{MY_SCHEMA}}"` and `server.MyStoreName: "{{MY_STORE}}"`

### Adding feature flags
1. `ENV`: Add `FEATURE_X_ENABLED: "true"`
2. `CONFIG.APP`: Add `server.features.featureX: "{{FEATURE_X_ENABLED}}"`

### Adding client-only static config
1. `CONFIG.APP` only: Add directly to `client.*` without placeholder (no ENV needed)
```javascript
client: {
    supportedLanguages: ["en", "es", "fr"]  // Static, no placeholder
}
```

## Output Format

When helping users add configuration, provide:

1. **File edits needed** - which files to modify
2. **Exact code snippets** - copy-paste ready
3. **Access pattern** - how to use the config in code
4. **Security note** - if handling secrets
