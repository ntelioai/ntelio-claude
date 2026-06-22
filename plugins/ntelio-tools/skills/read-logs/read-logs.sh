#!/usr/bin/env bash
#
# read-logs.sh — fetch historical script logs from a Scriptr.io / Apstrata
# account via the signed GetScriptLogs REST API.
#
# All you need is the account's DSA authKey + authSecret (the "Subscriber's
# authentication" credentials — NOT the API access / bearer token, which is
# not permitted to call GetScriptLogs as the account owner).
#
# Signature (account-key / "simple" mode), per apstrata/sdk/Connection.js:
#     authSig = MD5(timestamp_ms + authKey + "GetScriptLogs" + authSecret)
# Lowercase hex; the server compares case-insensitively. Request params are
# NOT part of the hash — only timestamp, key, operation, secret.
#
# Usage:
#   read-logs.sh --key <K> --secret <S> [filters]
#
# Filters (all optional):
#   --start <date>       apsdb.startDate — "YYYY-MM-DD" or epoch-ms
#   --end <date>         apsdb.endDate   — "YYYY-MM-DD" or epoch-ms
#   --script <path>      apsdb.scriptName — only logs from this script
#   --level <level>      apsdb.logLevel  — e.g. INFO / WARN / ERROR
#   --request-id <id>    apsdb.requestId — single request correlation id
#
# Other:
#   --base <url>         override base (default https://web.scriptr.io/apsdb/rest)
#   --raw                print the raw JSON response (default: pretty lines)
#   -h | --help
#
set -euo pipefail

KEY=""; SECRET=""
START=""; END=""; SCRIPT_NAME=""; LOG_LEVEL=""; REQUEST_ID=""
BASE="https://web.scriptr.io/apsdb/rest"
RAW=0

usage() { sed -n '2,38p' "$0" | sed 's/^# \{0,1\}//'; }

while [ $# -gt 0 ]; do
  case "$1" in
    --key)        KEY="$2"; shift 2;;
    --secret)     SECRET="$2"; shift 2;;
    --start)      START="$2"; shift 2;;
    --end)        END="$2"; shift 2;;
    --script)     SCRIPT_NAME="$2"; shift 2;;
    --level)      LOG_LEVEL="$2"; shift 2;;
    --request-id) REQUEST_ID="$2"; shift 2;;
    --base)       BASE="$2"; shift 2;;
    --raw)        RAW=1; shift;;
    -h|--help)    usage; exit 0;;
    *) echo "ERROR: unknown arg: $1" >&2; usage; exit 1;;
  esac
done

[ -n "$KEY" ]    || { echo "ERROR: --key required" >&2; exit 1; }
[ -n "$SECRET" ] || { echo "ERROR: --secret required" >&2; exit 1; }

# GetScriptLogs wants apsdb.startDate/endDate as epoch-MILLISECONDS (or YYYY-MM-DD).
# A bare 10-digit epoch-SECONDS value reads as ~1970 and silently disables the
# filter (you get a capped most-recent blob, not your window). Auto-promote
# all-digit 10/11-digit values to ms so callers can't trip on it.
to_ms() {
  case "$1" in
    ''|*[!0-9]*) printf '%s' "$1" ;;          # empty or has non-digits (e.g. a date) — leave as-is
    *) if [ "${#1}" -le 11 ]; then printf '%s000' "$1"; else printf '%s' "$1"; fi ;;
  esac
}
START=$(to_ms "$START")
END=$(to_ms "$END")

# Timestamp in milliseconds (GNU date first, portable fallback otherwise)
TS=$(date +%s%3N 2>/dev/null || true)
case "$TS" in ''|*[!0-9]*) TS=$(( $(date +%s) * 1000 ));; esac

OP="GetScriptLogs"
SIG=$(printf '%s' "${TS}${KEY}${OP}${SECRET}" | md5sum | awk '{print $1}')

# Build request; -G + --data-urlencode handles encoding of filter values.
set -- \
  -G "${BASE}/${KEY}/${OP}" \
  --data-urlencode "apsws.time=${TS}" \
  --data-urlencode "apsws.authSig=${SIG}" \
  --data-urlencode "apsws.responseType=json" \
  --data-urlencode "apsws.authMode=simple"
[ -n "$START" ]      && set -- "$@" --data-urlencode "apsdb.startDate=${START}"
[ -n "$END" ]        && set -- "$@" --data-urlencode "apsdb.endDate=${END}"
[ -n "$SCRIPT_NAME" ] && set -- "$@" --data-urlencode "apsdb.scriptName=${SCRIPT_NAME}"
[ -n "$LOG_LEVEL" ]  && set -- "$@" --data-urlencode "apsdb.logLevel=${LOG_LEVEL}"
[ -n "$REQUEST_ID" ] && set -- "$@" --data-urlencode "apsdb.requestId=${REQUEST_ID}"

RESP=$(curl -sk "$@")

if [ "$RAW" = "1" ]; then
  printf '%s\n' "$RESP"
  exit 0
fi

# GetScriptLogs returns logs as plain "||"-delimited text on success:
#   timestamp || user || level || requestId || scriptName || message
# Only FAILURES come back as a JSON wrapper ({"response":{"metadata":...}}).
case "$RESP" in
  '{'*)
    if command -v jq >/dev/null 2>&1; then
      printf '%s\n' "$RESP" | jq -r '.response.metadata | "ERROR: \(.errorCode // "?") — \(.errorDetail // .errorMessage // "unknown")"'
    else
      printf '%s\n' "$RESP"
    fi
    exit 1
    ;;
esac

if [ -z "$RESP" ]; then
  echo "(no log entries for the given filters)"
  exit 0
fi

# Pretty-print: one meta line + indented message. Long messages (full request
# dumps from the spec-driven API) are truncated; use --raw for the full body.
printf '%s\n' "$RESP" | awk -F'\\|\\|' '
  NF >= 6 {
    msg = $6
    for (i = 7; i <= NF; i++) msg = msg "||" $i
    if (length(msg) > 800) msg = substr(msg, 1, 800) "  … (+" (length(msg) - 800) " chars, use --raw)"
    printf "%s  [%s]  %s  %s\n    %s\n", $1, $3, $5, $4, msg
    next
  }
  { print }  # passthrough for non-conforming lines (e.g. "Open Connection")
'
