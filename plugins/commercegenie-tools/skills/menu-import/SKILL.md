---
name: menu-import
description: Build a CommerceGenie bot catalog from ANY menu link — static HTML, images (OCR), a JSON feed, or a JS/SPA ordering platform (Omega, Foodics, Chatfood, Deliverect…). You (Claude) extract the menu by whatever means works (render with Playwright, hit the underlying API, read images), normalize it, then load it into the catalog with save-menu.sh. Use when standing up a demo store catalog from a restaurant/shop link.
allowed-tools: Bash, Read, WebFetch, Write
---

# Menu Import — link → catalog

You are Claude Code with a full toolbox. The goal: get a clean catalog into a
CommerceGenie account from a menu link, **by any means necessary**. Don't be limited
by a rigid parser — if the page is a JS app, render it; if it's an image, read it; if
there's an API behind it, call it. The bundled `save-menu.sh` is *only* the
deterministic last step (build the catalog docs + POST them so you don't hand-roll
dozens of curls). The hard part — extraction — is yours.

---

## Inputs to collect

1. **The menu link.**
2. **A bearer token for the target account** — the token's account is the destination
   (a child account's browser/login token → that child's catalog; the parent token →
   the parent's own catalog). Ask if you don't have it; never guess it.
3. **`dataBundleKey`** — the bot's bundle (default **`product-catalog`**).
4. **Instance** — default `api.scriptrapps.io`.

---

## Step 1 — Get the menu data (any means)

Look at what the link actually serves (`curl -sI`, `curl -s … | head`) and pick the
cheapest path that gets **complete, accurate** items + prices:

- **Static HTML** — menu is in the markup. WebFetch (ask for structured items) or
  curl + strip tags.
- **Image(s)** — the URL is an image, or the menu is photos. Download
  (`curl -o /tmp/menu-1.png …`) and **Read** each with vision; transcribe faithfully
  (don't invent items/prices; note anything unreadable).
- **JSON feed** — curl it and map the fields.
- **JS / SPA ordering platforms** — the menu loads from an API *after* render, so the
  raw HTML is an empty shell. Options, in order of preference:
  1. **Hit the underlying API directly.** Inspect the SPA's network calls and replay
     the menu request with curl (handle CSRF/cookies/headers as the app does).
  2. **Render it** — drive a headless browser with Playwright (via Bash, or the
     `client-debug` skill) and read the rendered DOM or capture the XHR JSON.
  3. **Platform shortcut** if recognized (see below).

### Known platform: Omega (very common in MENA)
Sites like `order.<brand>.com` are often **white-labeled Omega** (AngularJS shell with
`omConfig` / `ng-*` markers). The custom domain hides the API, **but the same menu is
served at `menu.omegasoftware.ca/<slug>`** (slug is usually the brand, e.g.
`order.malakaltawouk.com` → `menu.omegasoftware.ca/malakaltawouk`).

For Omega, **don't scrape** — reuse the built-in importer, which already does the
CSRF → `getRestaurantMenu` → normalize dance:
```bash
curl -s -X POST "https://<instance>/ntelioMiddleware/server/api/app/v1/catalog/import-from-url" \
  -H "Authorization: bearer <TARGET_TOKEN>" -H "Content-Type: application/json" \
  -d '{"url":"https://menu.omegasoftware.ca/<slug>","dataBundleKey":"<bundle>"}'
```
(That importer writes straight to the catalog — for Omega you can skip Steps 2–3.) If
the slug isn't obvious, open the page (Playwright) and read it from `omConfig`, or test
`menu.omegasoftware.ca/<guess>` (a valid page returns 200 + a `laravel_session` cookie).

---

## Step 2 — Normalize to the catalog shape

Emit one JSON file (`Write /tmp/menu.json`). Canonical shape (see `AlMassoud.json`):

```json
{ "restaurant": "…", "menu_type": "…", "url": "…",
  "categories": [ { "name": "Starters", "items": [
    { "name": "Fries", "price": "$3.00" },
    { "name": "Grilled Potatoes", "price": "$3.00 / $5.50" },
    { "name": "Taouk", "price_regular": "$5.25", "price_xl": "$7.50" }
  ] } ] }
```

Prices — keep them as **strings**; `save-menu.sh` handles all three shapes:
- single `price` → a **standalone** item;
- `price` with `" / "` → **size variants**, labels inferred by count (2→Small/Large,
  3→Small/Medium/Large);
- **`price_<size>` keys** (e.g. `price_regular`, `price_xl`) → variants with **those
  names** (Regular/XL).
Real menus mix these — that's fine. `description` is optional (the name is reused;
the catalog requires a description).

---

## Step 3 — Load (dry-run, then real)

```bash
DIR="$(dirname "$0")"   # this skill's folder
"$DIR/save-menu.sh" --menu /tmp/menu.json --bundle product-catalog --dry-run   # eyeball the split
"$DIR/save-menu.sh" --menu /tmp/menu.json --bundle product-catalog --token "<TARGET_TOKEN>"
```
`save-menu.sh`: standalone vs parent+Size-variant docs (linked by `parentKey`, with
`optionDefs`/`optionValues`), sets required fields, POSTs to the dataObject API; the
`catalog` store auto-indexes each create. Prints `created=… (standalone/parents/variants), errors=…`.

For a quick one-off you can also POST items yourself via the **`scriptr` MCP sync/test
tool** — but for a whole menu, `save-menu.sh` is the deterministic path.

---

## Step 4 — Verify & reset

- 0 errors expected; on an error it prints the item + raw API response (usual cause:
  bad/expired token, or a missing required field).
- Confirm in WhatsApp / the admin Catalog page; a multi-price item should offer the
  size picker.
- **Re-running duplicates** (no name dedupe). To wipe a bundle and re-import cleanly,
  use `debug/deleteCatalogBundle` (scoped to one `dataBundleKey`) — or just import into
  a throwaway bundle while testing.

## Notes
- **Token account = destination.** No cross-account flag; point the token at where the
  items should land.
- Validate prices after extraction (a wrong OCR digit or a missed size column is the
  most common defect) — the dry-run output is there to catch exactly that.
