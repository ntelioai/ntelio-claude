---
name: client-debug
description: Debug client-side HTML/JS code in a headless browser. Use when the user says "debug", "test in browser", or points to a client-side file (.html, client/**/*.js) and wants to verify it works. Launches a dev server, runs Playwright tests, captures screenshots and console errors, fixes issues in a closed loop.
allowed-tools: Read, Grep, Glob, Write, Edit, Bash, AskUserQuestion, TodoWrite
---

# Client-Side Debug Skill

Debug client-side code using Playwright in a headless browser. This creates a closed loop: open page → capture errors/screenshots → fix code → re-test.

## Activation

This skill activates when:
- User says "debug", "test in browser", "check client side", or similar
- User points to a `.html` file or a file under `client/`, `examples/`, or `static/`
- User reports a visual bug or says something "doesn't look right"

## Step 0: First-Run Setup

On first use, ensure `serve.sh` is executable (plugin downloads don't preserve permissions):

```bash
chmod +x .claude/skills/client-debug/serve.sh
```

## Step 1: Preflight Checks

### 1a. Check Playwright Installation

Playwright is installed **globally**. Node doesn't resolve global packages by default, so always use `NODE_PATH` when running Playwright scripts.

Run this check first:

```bash
NODE_PATH=$(npm root -g) node -e "require('playwright')" 2>&1
```

**If Playwright is NOT installed**, stop and tell the user:

> Playwright is not installed globally. Install it with:
> ```bash
> npm install -g playwright
> npx playwright install
> ```

Do NOT proceed until Playwright is available.

### 1b. Check Dev Server

Check if an HTTP server is running on the expected port:

```bash
lsof -ti:8765 2>/dev/null && echo "RUNNING" || echo "NOT_RUNNING"
```

**Default port: 8765.** Adjust if the user specifies a different port.

**If NOT running**, start it in the background:

```bash
nohup .claude/skills/client-debug/serve.sh /path/to/project/root > /tmp/client-debug-server.log 2>&1 &
```

Wait a moment, then verify it started:

```bash
sleep 1 && lsof -ti:8765 2>/dev/null && echo "RUNNING" || echo "FAILED"
```

If it failed, check the log at `/tmp/client-debug-server.log` and report the error to the user.

**If RUNNING**, proceed silently.

## Step 2: Determine Target URL

Convert the local file path to a URL served by the dev server.

**Path resolution rules:**
- The dev server root is the parent directory where the server was started
- Typical pattern: file at `/Volumes/dev/ntelioUI/ntelioUI2/examples/foo/index.html` → `http://localhost:8765/ntelioUI2/examples/foo/index.html`
- If the file is an HTML file, use it directly
- If the file is a JS module file, find the HTML file that loads it (check for `<script>` tags or look for an `index.html` in the same or parent directory)

**To find the HTML entry point for a JS file:**
1. Check for `index.html` in the same directory
2. Check parent directory for `index.html`
3. Search for HTML files that import the JS file: `grep -r "src.*filename.js" --include="*.html"`

## Step 3: Write and Run Debug Script

Create a Playwright test script tailored to the target page. The script MUST:

1. **Capture ALL console messages** (log, warn, error, info)
2. **Capture page errors** (uncaught exceptions)
3. **Load the page** and wait for network idle
4. **Take a screenshot** after page load
5. **Check for errors** in console output
6. **Interact with the page** if the user described specific behavior to test
7. **Take screenshots** at each significant step
8. **Report a clear summary** of what works and what's broken

### Script Template

```javascript
import { chromium } from 'playwright';

const TARGET_URL = '{{URL}}';
const SCREENSHOT_DIR = '{{SCRATCHPAD_PATH}}';

async function run() {
    const browser = await chromium.launch({ headless: true });
    const page = await (await browser.newContext({
        viewport: { width: 1280, height: 800 }
    })).newPage();

    const consoleMessages = [];
    const consoleErrors = [];

    page.on('console', msg => {
        consoleMessages.push({ type: msg.type(), text: msg.text() });
        if (msg.type() === 'error') consoleErrors.push(msg.text());
    });
    page.on('pageerror', err => {
        consoleErrors.push(`PAGE ERROR: ${err.message}`);
    });

    try {
        const response = await page.goto(TARGET_URL, {
            waitUntil: 'networkidle',
            timeout: 15000
        });
        await page.waitForTimeout(1000);

        console.log(`\nPage loaded: HTTP ${response.status()}`);

        // Screenshot after load
        await page.screenshot({
            path: `${SCREENSHOT_DIR}/debug-load.png`,
            fullPage: true
        });

        // Report console errors
        if (consoleErrors.length > 0) {
            console.log(`\n❌ ${consoleErrors.length} CONSOLE ERROR(S):`);
            consoleErrors.forEach(e => console.log(`  → ${e}`));
        } else {
            console.log('\n✅ No console errors');
        }

        // Report all console messages
        if (consoleMessages.length > 0) {
            console.log('\n--- Console Output ---');
            consoleMessages.forEach(m => console.log(`  [${m.type}] ${m.text}`));
        }

        // === ADD INTERACTION TESTS HERE ===
        // Based on what the user wants to test, add clicks, form fills, etc.

    } catch (err) {
        console.log(`\n❌ FATAL: ${err.message}`);
        try {
            await page.screenshot({
                path: `${SCREENSHOT_DIR}/debug-error.png`,
                fullPage: true
            });
        } catch(e) {}
    } finally {
        await browser.close();
    }
}

run().catch(e => { console.error(e); process.exit(1); });
```

### Script Execution

Playwright is installed globally. Use `NODE_PATH` so Node can resolve it from any directory:

1. Write the script to a temp file (e.g., `/tmp/_debug-test.mjs`)
2. Run it: `NODE_PATH=$(npm root -g) node /tmp/_debug-test.mjs`
3. Read the output
4. Read the screenshot(s) to visually inspect
5. Clean up the temp script: `rm /tmp/_debug-test.mjs`

**IMPORTANT:** Always prefix `node` with `NODE_PATH=$(npm root -g)` when running Playwright scripts. This lets Node find the global Playwright package from any working directory. The script can be saved anywhere (e.g., `/tmp/`) — it does NOT need to be inside a project with a local `node_modules`.

## Step 4: Analyze and Report

After running the script, provide a clear report:

### Report Format

```
## Debug Results: {filename}

**URL:** http://localhost:8765/path/to/file
**Status:** HTTP {code}

### Console Errors
- {list any errors, or "None"}

### Visual Check
{Describe what the screenshot shows — layout issues, missing content, etc.}

### Issues Found
1. **{Issue}** — {root cause} → {file:line to fix}
2. ...

### Suggested Fixes
{Describe what needs to change}
```

Always show the screenshot to the user using the Read tool so they can see it.

## Step 5: Fix and Re-test Loop

If issues are found:

1. **Fix the code** — edit the source files directly
2. **Re-run the debug script** — verify the fix works
3. **Show the new screenshot** — confirm visually
4. **Repeat** until all issues are resolved

Track progress with TodoWrite for multiple issues.

## Step 6: Server Management

- **Start the server automatically** in the background when it's not running (see Step 1b)
- **Check if running** at the beginning of each debug session
- **If already running**, the bundled `serve.sh` detects this and skips starting a duplicate
- **To stop the server**, run: `kill $(lsof -ti:8765)`

### Bundled serve.sh

Located at `.claude/skills/client-debug/serve.sh`. Features:
- Accepts project root dir and port as arguments
- Detects if server is already running (no duplicates)
- Defaults to port 8765
- Uses Python's `http.server` (no dependencies)

## Common Patterns

### Testing a Widget Example
```
Target: ntelioUI2/examples/core/widget-basics/index.html
URL: http://localhost:8765/ntelioUI2/examples/core/widget-basics/index.html
Focus: Console errors, widget lifecycle, event system
```

### Testing a Modal/Dialog
```
Target: ntelioUI2/examples/dialogs/modal-examples/index.html
URL: http://localhost:8765/ntelioUI2/examples/dialogs/modal-examples/index.html
Focus: Open/close behavior, backdrop cleanup, positioning, event flow
```

### Testing a Landing Page
```
Target: index.html (project root)
URL: http://localhost:8765/index.html
Focus: Layout, responsive behavior, navigation links, asset loading
```

### Testing a Storefront
```
Target: client/storefront/store.html
URL: http://localhost:8765/client/storefront/store.html
Focus: Product loading, routing, API calls, cart behavior
```

## Key Rules

1. **Always check Playwright first** — don't waste time if it's not installed
2. **Start the server automatically** — launch it in the background if not already running
3. **Always read screenshots** — visual verification catches what code analysis misses
4. **Always clean up test scripts** — remove `_debug-test.mjs` after each run
5. **Fix at the source** — don't work around issues, fix the actual code
6. **Re-test after every fix** — confirm the fix works before reporting success
7. **Use the scratchpad for screenshots** — keep the project clean
8. **Report clearly** — the user needs to know what's broken and what you fixed
