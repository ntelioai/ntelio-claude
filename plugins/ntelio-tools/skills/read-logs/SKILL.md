---
name: read-logs
description: Read historical script execution logs from a Scriptr.io / Apstrata account (server-side API and WhatsApp logs). Use when the user wants to read, fetch, tail, or debug platform logs, investigate an error/request, or see what a script logged. Filters by date range, script name, log level, and request id.
allowed-tools: Bash, Read, AskUserQuestion
---

# Read Scriptr.io Script Logs

Fetches historical script logs via the signed Apstrata `GetScriptLogs` REST API.
This is the **only** way to read logs that weren't produced by a call you just
made yourself (a WhatsApp webhook, a cron, a past request). For logs of a single
endpoint *you* invoke right now, `?debug_mode=true` on that call is simpler — use
this skill for everything else.

The bundled `read-logs.sh` does the signing and pretty-prints results.

---

## Step 1: Get credentials (authKey + authSecret)

Logs require the account's **DSA credentials** (Settings → "Subscriber's
authentication": an authKey + authSecret). The API access / bearer token used by
`/sync` and `/test-api` **cannot** read logs — account owners may only use
signatures, not tokens, so the bearer token returns `PERMISSION_DENIED`.

How to obtain key/secret depends on the project — **check the project's own
`CLAUDE.md`**. Note a project may deliberately route *some* accounts through a
server-side handler instead of signing here, so the secret never leaves the
platform (e.g. CommerceGenie fetches a subaccount's logs via its parent's
`provisioning/accounts/logs` handler, and reserves this skill for the parent's own
DSA creds). Prefer that when it exists; don't extract a secret just to sign locally.
If the project doesn't document it and you don't already have them, ask:

```
AskUserQuestion: "Which account's logs, and what is its authKey + authSecret?"
```

Never print the authSecret back to the user.

---

## Step 2: Decide the filters (always bound the date range)

A single account logs **thousands of lines per day** (a week ≈ 8k lines / ~800 KB),
so **always pass `--start`** (and usually `--end`) to keep the result small.
Filtering happens server-side, so narrow before fetching, don't download-then-grep.

| Flag | Purpose | Format |
|------|---------|--------|
| `--start` | start of window (**recommended, almost always set**) | `YYYY-MM-DD` or epoch-ms |
| `--end` | end of window | `YYYY-MM-DD` or epoch-ms |
| `--script` | only one script (see names below) | exact script name |
| `--level` | only this level | `INFO` / `WARN` / `ERROR` |
| `--request-id` | one request's full trace | request id (from a prior line) |

**Script names** (`--script`) are NOT full handler paths. The useful ones:

- `ntelioMiddleware/server/api` — all spec-driven (authenticated) API calls
- `ntelioMiddleware/server/public/api` — public/anonymous spec-driven API calls
- `ntelioMiddleware/connectors/whatsapp/callback` — WhatsApp inbound callback
  (an account may also show `.../whatsapp/ingest` and `.../whatsapp/processInbound`
  for the queued processing stages)

Typical debugging flow: start broad with `--level ERROR` over a date window to
find the failing request, then re-run with that line's `--request-id` to get its
full trace.

---

## Step 3: Run

```bash
# Make executable on first use (plugin downloads don't preserve the +x bit)
chmod +x .claude/skills/read-logs/read-logs.sh

# Errors only, since yesterday
.claude/skills/read-logs/read-logs.sh \
  --key <AUTHKEY> --secret <AUTHSECRET> \
  --start 2026-06-14 --level ERROR

# One WhatsApp inbound message and everything it logged
.claude/skills/read-logs/read-logs.sh \
  --key <AUTHKEY> --secret <AUTHSECRET> \
  --start 2026-06-15 --script ntelioMiddleware/connectors/whatsapp/callback

# Full trace of a single request once you have its id
.claude/skills/read-logs/read-logs.sh \
  --key <AUTHKEY> --secret <AUTHSECRET> \
  --start 2026-06-15 --request-id 559b500c-69f3-c8d0-85dd-f33dc4ca6702
```

Add `--raw` to get the untouched response (full, untruncated message bodies)
instead of the pretty view.

---

## Step 4: Read the output

Pretty mode prints one entry as:

```
<timestamp>  [<level>]  <scriptName>  <requestId>
    <message>     (truncated past 800 chars — use --raw for the full body)
```

- "(no log entries for the given filters)" → the window/filters matched nothing;
  widen the date range or drop a filter.
- "ERROR: INVALID_SIGNATURE" → wrong authSecret (or a token was passed as the
  secret). Re-check the DSA credentials.
- "ERROR: PERMISSION_DENIED" → an access/bearer token was used; owners must sign.

---

## How it works (reference)

Signed `GET https://web.scriptr.io/apsdb/rest/{authKey}/GetScriptLogs` with:

```
apsws.time      = <epoch ms>
apsws.authSig   = MD5(time + authKey + "GetScriptLogs" + authSecret)   # lowercase hex
apsws.authMode  = simple
apsws.responseType = json
apsdb.startDate / endDate / scriptName / logLevel / requestId   # filters
```

Only `time + authKey + operation + authSecret` is hashed — request params are
**not** part of the signature (per `apstrata/sdk/Connection.js`). On success the
body is plain `||`-delimited text (`timestamp||user||level||requestId||scriptName||message`),
one entry per line; only failures return a JSON `{response:{metadata:…}}` wrapper.
