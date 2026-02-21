#!/bin/bash

# Self-contained script to sync a file to scriptr.io
# Reads .metadata files for ACL and content type
# Usage: ./sync-file.sh <file_path> [project_root]
#   file_path    - path to the file to sync
#   project_root - (optional) project root directory, defaults to current working directory

# Check if file path is provided
if [ $# -eq 0 ]; then
    echo "Error: Please provide a file path as an argument"
    echo "Usage: $0 <file_path> [project_root]"
    exit 1
fi

FILE_PATH="$1"
PROJECT_ROOT="${2:-$(pwd)}"

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File '$FILE_PATH' does not exist"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed"
    echo "Please install jq: brew install jq (macOS) or apt-get install jq (Linux)"
    exit 1
fi

# --- Config ---
CONFIG_FILE="$PROJECT_ROOT/scriptrExtensionConfig.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: scriptrExtensionConfig.json not found at $PROJECT_ROOT"
    exit 1
fi
INSTANCE_URL=$(jq -r '.instanceUrl' "$CONFIG_FILE")
ACCESS_TOKEN=$(jq -r '.accessToken' "$CONFIG_FILE")
if [ "$INSTANCE_URL" = "null" ] || [ -z "$INSTANCE_URL" ]; then
    echo "Error: instanceUrl not found in configuration"
    exit 1
fi
if [ "$ACCESS_TOKEN" = "null" ] || [ -z "$ACCESS_TOKEN" ]; then
    echo "Error: accessToken not found in configuration"
    exit 1
fi

# --- Remote path ---
FILE_ABS_PATH=$(cd "$(dirname "$FILE_PATH")" && pwd)/$(basename "$FILE_PATH")
PROJECT_ROOT_ABS=$(cd "$PROJECT_ROOT" && pwd)
REMOTE_PATH="${FILE_ABS_PATH#$PROJECT_ROOT_ABS/}"
REMOTE_PATH="${REMOTE_PATH#/}"
REMOTE_PATH="${REMOTE_PATH//\\/\/}"

# --- Ignore check ---
BUILTIN_IGNORE=("node_modules/" ".git/" ".DS_Store" "*.log" ".scriptrIgnore" "scriptrExtensionConfig.json")
for pattern in "${BUILTIN_IGNORE[@]}"; do
    case "$pattern" in
        */) [[ "$REMOTE_PATH" == "${pattern%/}/"* ]] && echo "Ignored: $REMOTE_PATH" && exit 0 ;;
        *"*"*) [[ "$(basename "$REMOTE_PATH")" == $pattern ]] && echo "Ignored: $REMOTE_PATH" && exit 0 ;;
        *) [[ "$(basename "$REMOTE_PATH")" == "$pattern" ]] && echo "Ignored: $REMOTE_PATH" && exit 0 ;;
    esac
done
if [ -f "$PROJECT_ROOT/.scriptrIgnore" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -z "$line" ] && continue
        [[ "$line" == "!"* ]] && continue
        case "$line" in
            */) [[ "$REMOTE_PATH" == "${line%/}/"* ]] && echo "Ignored by .scriptrIgnore: $REMOTE_PATH" && exit 0 ;;
            *"*"*) [[ "$REMOTE_PATH" == $line || "$(basename "$REMOTE_PATH")" == $line ]] && echo "Ignored by .scriptrIgnore: $REMOTE_PATH" && exit 0 ;;
            *) [[ "$REMOTE_PATH" == "$line" || "$(basename "$REMOTE_PATH")" == "$line" || "$REMOTE_PATH" == "$line/"* ]] && echo "Ignored by .scriptrIgnore: $REMOTE_PATH" && exit 0 ;;
        esac
    done < "$PROJECT_ROOT/.scriptrIgnore"
fi

# --- Metadata ---
FILE_DIR=$(dirname "$FILE_PATH")
FILE_BASE=$(basename "$FILE_PATH")
METADATA_FILE="$FILE_DIR/.$FILE_BASE.metadata"
METADATA_CONTENT_TYPE=""
ACL_READ=""
ACL_WRITE=""
ACL_EXECUTE=""
if [ -f "$METADATA_FILE" ]; then
    echo "  Metadata: $METADATA_FILE (found)"
    METADATA_CONTENT_TYPE=$(jq -r '.contentType // empty' "$METADATA_FILE" 2>/dev/null)
    ACL_READ=$(jq -r '.acl.read // empty' "$METADATA_FILE" 2>/dev/null)
    ACL_WRITE=$(jq -r '.acl.write // empty' "$METADATA_FILE" 2>/dev/null)
    ACL_EXECUTE=$(jq -r '.acl.execute // empty' "$METADATA_FILE" 2>/dev/null)
fi

# --- Content type fallback ---
FILE_EXT="${FILE_PATH##*.}"
CONTENT_TYPE="application/vnd.scriptr-javascript"
case "$FILE_EXT" in
    js) CONTENT_TYPE="application/vnd.scriptr-javascript" ;;
    html|htm) CONTENT_TYPE="text/html" ;;
    css) CONTENT_TYPE="text/css" ;;
    json) CONTENT_TYPE="application/json" ;;
    xml) CONTENT_TYPE="text/xml" ;;
    txt|text) CONTENT_TYPE="text/plain" ;;
esac
[ -n "$METADATA_CONTENT_TYPE" ] && CONTENT_TYPE="$METADATA_CONTENT_TYPE"

# --- ACL defaults ---
if [ -z "$ACL_READ" ] || [ -z "$ACL_WRITE" ] || [ -z "$ACL_EXECUTE" ]; then
    if [ "$CONTENT_TYPE" = "application/vnd.scriptr-javascript" ]; then
        ACL_READ="${ACL_READ:-nobody}"
        ACL_WRITE="${ACL_WRITE:-nobody}"
        ACL_EXECUTE="${ACL_EXECUTE:-authenticated}"
    else
        ACL_READ="${ACL_READ:-anonymous}"
        ACL_WRITE="${ACL_WRITE:-nobody}"
        ACL_EXECUTE="${ACL_EXECUTE:-nobody}"
    fi
fi

echo "Syncing file to scriptr.io..."
echo "  Local: $FILE_PATH"
echo "  Remote: $REMOTE_PATH"
echo "  Instance: $INSTANCE_URL"
echo "  Content-Type: $CONTENT_TYPE"
echo "  ACL: read=$ACL_READ, write=$ACL_WRITE, execute=$ACL_EXECUTE"

# --- Sync ---
FILE_CONTENT=$(cat "$FILE_PATH")
REQUEST_DATA="scriptName=$(printf '%s' "$REMOTE_PATH" | jq -sRr @uri)"
REQUEST_DATA="${REQUEST_DATA}&script=$(printf '%s' "$FILE_CONTENT" | jq -sRr @uri)"
REQUEST_DATA="${REQUEST_DATA}&contentType=$(printf '%s' "$CONTENT_TYPE" | jq -sRr @uri)"
REQUEST_DATA="${REQUEST_DATA}&aclRead=$(printf '%s' "$ACL_READ" | jq -sRr @uri)"
REQUEST_DATA="${REQUEST_DATA}&aclWrite=$(printf '%s' "$ACL_WRITE" | jq -sRr @uri)"
REQUEST_DATA="${REQUEST_DATA}&aclExecute=$(printf '%s' "$ACL_EXECUTE" | jq -sRr @uri)"

RESPONSE=$(curl -s -X POST \
    -H "Authorization: bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "$REQUEST_DATA" \
    "https://$INSTANCE_URL/vscodePlugin/scripts" 2>&1)

if [ $? -ne 0 ]; then
    echo "Error: Failed to connect to scriptr.io"
    echo "$RESPONSE"
    exit 1
fi
if echo "$RESPONSE" | grep -q '"errorDetail"'; then
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.response.metadata.errorDetail // .message // "Unknown error"' 2>/dev/null)
    echo "Error: Failed to save script: $ERROR_MSG"
    exit 1
fi

echo "✓ Successfully synced $FILE_PATH to scriptr.io as $REMOTE_PATH"
