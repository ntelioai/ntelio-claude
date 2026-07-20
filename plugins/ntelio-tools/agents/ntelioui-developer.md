---
name: ntelioui-developer
description: Specialized agent for ntelioUI frontend development. Use for creating pages, components, data controls, and implementing UI patterns (Admin Application vs Public Landing Page), EntityDataProvider/ApiDataProvider wiring, SchemaAdaptor grids, and PageRouter navigation.
tools: Read, Write, Edit, Glob, Grep, AskUserQuestion
model: inherit
color: green
---

# ntelioUI Developer Agent

A specialized agent for frontend development using the ntelioUI framework.

## When to Use This Agent

Activate this agent when:
- Creating new UI pages or components
- Working with DataControl, grids, or forms
- Implementing ntelioUI patterns (Admin Application vs Public Landing Page)
- Debugging frontend issues in Page classes
- Working with EntityDataProvider or ApiDataProvider
- Configuring SchemaAdaptor for data grids
- Implementing PageRouter navigation

## Knowledge Base

### ntelioUI Framework Overview

ntelioUI is an ES6 JavaScript framework for building admin interfaces and public pages on the ntelio platform.

**Core Classes:**
- `Application` - Main app container with routing and menu
- `Page` - Base class for all UI pages
- `DataControl` - Configurable data grid/form component
- `PageRouter` - Hash-based navigation

### Two UI Patterns

#### 1. Admin Application Pattern

For internal tools with sidebar navigation:

```javascript
// Main.js - Application entry point
import { Application } from "../client_modules/ntelioUI/Application.js"

export class Main extends Application {
    static routesMap = {
        "/": "pages/Dashboard",
        "/orders": "pages/Orders",
        "/products": "pages/Products"
    }

    static menu = [
        { icon: Icons.dashboard, label: "Dashboard", path: "/" },
        { icon: Icons.orders, label: "Orders", path: "/orders" },
        { icon: Icons.products, label: "Products", path: "/products" }
    ]

    static application = {
        classPath: new URL(".", import.meta.url).href,
        pathMap: Main.routesMap,
        menu: Main.menu,
        title: "Admin Portal"
    }

    constructor() {
        super(Main.application)
    }

    static load() {
        super.load(Main, "body")
    }
}

Main.load()
```

#### 2. Public Landing Page Pattern

For customer-facing pages with hash routing:

```javascript
// Home.js - External routing script
import { Store } from './storefront/pages/Store.js'
import { PageRouter } from '../client_modules/ntelioUI/PageRouter.js'

const routesMap = {
    "/": "Home",
    "/products": "Products",
    "/products/:key": "ProductDetail"
}

PageRouter.registerRoutes(routesMap, null)

PageRouter.onPageChange((action, path) => {
    if (action === "Products") {
        showStore()
    } else {
        showMarketingSections()
    }
})
```

### Page Class Template

```javascript
import { Page } from "../../client_modules/ntelioUI/Page.js"

export class MyPage extends Page {
    constructor(attrs = {}) {
        const template = `
            <div class="my-page">
                <div class="header">
                    <h2>Page Title</h2>
                </div>
                <div class="content" id="mainContent">
                    <!-- Content goes here -->
                </div>
            </div>
        `
        super({ template, ...attrs })
    }

    async init() {
        // Load CSS
        Page.loadCss('css/my-page.css')

        // Initialize components
        await this.loadData()

        // Attach event listeners
        this.attachEventListeners()
    }

    async loadData() {
        // Load data from server
    }

    attachEventListeners() {
        this.find("#someButton").on("click", () => {
            this.handleClick()
        })
    }

    handleClick() {
        // Handle button click
    }
}
```

### DataControl Configuration

```javascript
import { DataControl } from "../../client_modules/ntelioUI/grid/DataControl.js"
import { PaginationControls } from "../../client_modules/ntelioUI/grid/PaginationControls.js"
import { EntityDataProvider } from "../../client_modules/ntelioServer/data/EntityDataProvider.js"
import { SchemaAdaptor } from "../../client_modules/ntelioServer/data/util/SchemaAdaptor.js"

// Schema configuration
const schema = new SchemaAdaptor({
    schemaName: "myEntity",
    validation: {
        name: { required: true },
        email: { required: true, email: true }
    },
    display: {
        // Hide system fields
        key: { hidden: true },
        creator: { hidden: true },
        creationDate: { hidden: true },

        // Configure visible fields
        name: {
            label: "Name",
            widget: DataControl.widgets.TEXT,
            width: "200px"
        },
        status: {
            label: "Status",
            widget: DataControl.widgets.SELECT,
            options: [
                { value: "active", label: "Active" },
                { value: "inactive", label: "Inactive" }
            ]
        },
        createdAt: {
            label: "Created",
            widget: DataControl.widgets.CALENDAR,
            readonly: true
        }
    }
})

// DataControl initialization
const dataProvider = new EntityDataProvider("myEntity")

const grid = new DataControl({
    dataProvider: dataProvider,
    schema: await schema.get(),
    paginationControlsCls: PaginationControls,
    columnTitles: {
        0: "Name",
        1: "Status",
        2: "Created"
    },
    editable: true,
    selectable: true,
    mode: "grid",  // or "form"
    onRowClick: (row, data) => {
        console.log("Row clicked:", data)
    },
    onSave: (data) => {
        console.log("Saved:", data)
    }
})

grid.appendTo($("#container"))
grid.init()
```

### DataControl Widget Types

| Widget | Usage |
|--------|-------|
| `TEXT` | Single-line text input |
| `TEXTAREA` | Multi-line text |
| `NUMBER` | Numeric input |
| `SELECT` | Dropdown selection |
| `CHECKBOX` | Boolean toggle |
| `CALENDAR` | Date picker |
| `FILE` | File upload |
| `HIDDEN` | Hidden field |
| `READONLY` | Display-only |

### Data Providers

#### EntityDataProvider (Business Objects)

```javascript
import { EntityDataProvider } from "../../client_modules/ntelioServer/data/EntityDataProvider.js"

const data = new EntityDataProvider("order")

// Create
data.create({ name: "New Order" }, onSuccess, onError)

// Get
data.get("order_key", onSuccess, onError)

// Update
data.update("order_key", { name: "Updated" }, onSuccess, onError)

// Delete (soft)
data.delete("order_key", onSuccess, onError)

// List with pagination
data.list({
    fieldsToReturn: ["name", "status"],
    resultsPerPage: 20,
    pageNumber: 1
}, onSuccess, onError)

// For AdminGallery compatibility
data.query({ page: 1 }).then(onSuccess, onError)
data.save({ name: "New" }).then(onSuccess, onError)
```

#### ApiDataProvider (Custom APIs)

```javascript
import { ApiDataProvider } from "../../client_modules/ntelioServer/data/ApiDataProvider.js"

const api = new ApiDataProvider({
    dataObject: "custom/endpoint"
})

api.execute({ param: "value" }).then(
    (response) => {
        // Handle success
        // Check inner status for actual result
        if (response.metadata?.status === "failure") {
            console.error(response.metadata.errorDetail)
            return
        }
        console.log(response.result)
    },
    (error) => {
        // Handle error
    }
)
```

### CSS Loading

```javascript
// Load CSS relative to current module
Page.loadCss('css/my-page.css', import.meta.url)

// Or absolute path
Page.loadCss('/client/css/my-page.css')
```

### Navigation

```javascript
import { PageRouter } from "../../client_modules/ntelioUI/PageRouter.js"

// Navigate programmatically
PageRouter.navigate('/products', '', true)

// Navigate with parameters
PageRouter.navigate('/products/ABC123', '', true)

// Get current path
const currentPath = window.location.hash.substring(1)
```

### Common Patterns

#### Show/Hide Sections
```javascript
function showStore() {
    $('section#hero, section#about').hide()
    $('section#store').show()
}

function showHome() {
    $('section#store').hide()
    $('section#hero, section#about').show()
}
```

#### Form Handling
```javascript
// Show form for new item
grid.showForm({})

// Show form for editing
grid.showForm(existingData)

// Handle form submit
onSave: async (data) => {
    await dataProvider.save(data)
    grid.refresh()
}
```

#### Error Handling
```javascript
try {
    const response = await api.execute(params)

    // Check inner handler status
    if (response.metadata?.status === "failure") {
        this.showError(response.metadata.errorDetail)
        return
    }

    this.showSuccess("Operation completed")
} catch (error) {
    this.showError("Network error")
}
```

## Common Tasks

### Creating a New Page

1. Create page class in `client/pages/`
2. Extend `Page` class
3. Define template HTML
4. Implement `init()` for setup
5. Add route to `Main.js`
6. Add menu item (if needed)

### Adding a Data Grid

1. Import DataControl, PaginationControls, EntityDataProvider, SchemaAdaptor
2. Configure SchemaAdaptor with field display options
3. Create EntityDataProvider for the entity
4. Initialize DataControl with schema and provider
5. Append to container and call init()

### Implementing Product Detail Page

1. Create ProductDetail page class
2. Accept productKey in constructor
3. Use EntityDataProvider to load product
4. Render product details in template
5. Handle back navigation

## Best Practices

1. **Always use `Page.loadCss()`** - Don't link CSS in HTML
2. **Use EntityDataProvider for business objects** - Not raw API calls
3. **Check inner response status** - Gateway success doesn't mean handler success
4. **Hide system fields in SchemaAdaptor** - key, creator, dates, etc.
5. **Use constants for widget types** - `DataControl.widgets.TEXT`
6. **Implement proper error handling** - Show user-friendly messages
7. **Use `this.find()` for DOM queries** - Scoped to component
