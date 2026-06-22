#!/usr/bin/env bash
# save-menu.sh — load a normalized menu JSON into a CommerceGenie catalog via the
# dataObject API (POST /ntelioMiddleware/server/api/core/v1/dataObject).
#
# Input JSON shape (the "AlMassoud" shape the menu-import skill produces):
#   { "restaurant": "...", "menu_type": "...", "url": "...",
#     "categories": [ { "name": "Starters", "items": [ { "name": "Fries", "price": "$3.00" } ] } ] }
#
# Single-price item  -> one "standalone" catalog doc.
# Multi-price item   -> one "parent" doc + N "variant" docs (size axis), e.g. "$3 / $5.5" -> Small/Large.
# The catalog store is in indexableStores, so every create auto-indexes (searchable + RAG).
#
# Auth: --token is a bearer token for the TARGET account — a child account's browser/login
# token (creates in that child's catalog) or the parent/provisioner access token (creates in
# the parent's own catalog). The token's account is where items land.
set -euo pipefail

INSTANCE="api.scriptrapps.io"; STORE="catalog"; SCHEMA="catalog"; SOURCE="menu-import"
DRY=0; MENU=""; TOKEN=""; BUNDLE=""

usage(){ echo "Usage: save-menu.sh --menu <file.json> --bundle <dataBundleKey> --token <bearer> [--instance api.scriptrapps.io] [--source menu-import] [--store catalog] [--dry-run]"; exit 1; }
while [ $# -gt 0 ]; do case "$1" in
  --menu) MENU="$2"; shift 2;; --token) TOKEN="$2"; shift 2;; --bundle) BUNDLE="$2"; shift 2;;
  --instance) INSTANCE="$2"; shift 2;; --source) SOURCE="$2"; shift 2;; --store) STORE="$2"; shift 2;;
  --dry-run) DRY=1; shift;; -h|--help) usage;; *) echo "Unknown arg: $1"; usage;; esac; done
[ -n "$MENU" ] && [ -n "$BUNDLE" ] || usage
[ -f "$MENU" ] || { echo "menu file not found: $MENU"; exit 1; }
[ "$DRY" -eq 1 ] || [ -n "$TOKEN" ] || { echo "--token is required (unless --dry-run)"; exit 1; }
command -v jq >/dev/null || { echo "jq is required (apt-get install jq / brew install jq)"; exit 1; }

URL="https://$INSTANCE/ntelioMiddleware/server/api/core/v1/dataObject"
slug(){ echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'; }
sizes_for(){ case "$1" in 2) echo "Small Large";; 3) echo "Small Medium Large";; 4) echo "Small Medium Large XL";; *) seq 1 "$1" | sed 's/^/Size /' | tr '\n' ' ';; esac; }
post(){ # $1 = json doc -> echoes API response (or a dry stub)
  if [ "$DRY" -eq 1 ]; then echo "$1" | jq -c . ; echo '{"metadata":{"statusCode":201},"_dry":true}'; return; fi
  curl -s -X POST "$URL" -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" -d "$1"; }
extract_key(){ jq -r '.result.key // ([.. | objects | select(has("key") and (has("data") or has("versionNumber"))) | .key] | first) // empty' 2>/dev/null; }
ok(){ echo "$1" | grep -q '"statusCode":201\|"status":"success"\|"_dry":true'; }

OKC=0; ERRC=0; STAND=0; PAR=0; VAR=0; CI=0
while IFS= read -r item; do
  CI=$((CI+1))
  name=$(jq -r '.name' <<<"$item"); category=$(jq -r '.category' <<<"$item"); desc=$(jq -r '.description // .name' <<<"$item")
  extId="$(slug "$SOURCE")-$(slug "$category")-$CI"
  nvar=$(jq '.variants | length' <<<"$item")

  if [ "${nvar:-0}" -le 1 ]; then
    pr=$(jq -r '.variants[0].price // 0' <<<"$item")
    doc=$(jq -n --arg st "$STORE" --arg sc "$SCHEMA" --arg n "$name" --arg sku "$extId" --arg d "$desc" \
      --arg b "$BUNDLE" --argjson pr "${pr:-0}" --arg cat "$category" --arg src "$SOURCE" --arg eid "$extId" \
      '{storeName:$st,"meta.schema":$sc,name:$n,sku:$sku,description:$d,dataBundleKey:$b,price:$pr,
        category:$cat,productType:"standalone",indexable:"true",source:$src,externalProductId:$eid}')
    if ok "$(post "$doc")"; then OKC=$((OKC+1)); STAND=$((STAND+1)); echo "  • $name ($category) — standalone \$$pr";
    else ERRC=$((ERRC+1)); echo "  x $name ($category) — FAILED" >&2; fi
  else
    # Sizes: use the variants' explicit labels if every one has one (price_* shape),
    # else infer from the count (the "/"-joined-price shape).
    given=$(jq '[.variants[].size | select(.!=null)] | length' <<<"$item")
    if [ "$given" -eq "$nvar" ]; then read -ra SZ <<< "$(jq -r '[.variants[].size] | join(" ")' <<<"$item")";
    else read -ra SZ <<< "$(sizes_for "$nvar")"; fi
    PR=(); while IFS= read -r x; do [ -n "$x" ] && PR+=("$x"); done < <(jq -r '.variants[].price' <<<"$item")
    minpr=$(printf '%s\n' "${PR[@]}" | sort -n | head -1)
    vals=$(printf '%s\n' "${SZ[@]:0:$nvar}" | jq -R . | jq -s .)
    optdefs=$(jq -n --argjson v "$vals" '[{name:"Size",values:$v}]')
    pdoc=$(jq -n --arg st "$STORE" --arg sc "$SCHEMA" --arg n "$name" --arg sku "P-$extId" --arg d "$desc" \
      --arg b "$BUNDLE" --argjson pr "$minpr" --arg cat "$category" --argjson od "$optdefs" --arg src "$SOURCE" --arg eid "$extId" \
      '{storeName:$st,"meta.schema":$sc,name:$n,sku:$sku,description:$d,dataBundleKey:$b,price:$pr,priceFrom:$pr,
        category:$cat,productType:"parent",indexable:"true",optionDefs:($od|tostring),optionValues:"",source:$src,externalProductId:$eid}')
    presp=$(post "$pdoc"); pkey=$(echo "$presp" | extract_key); [ "$DRY" -eq 1 ] && pkey="DRYKEY"
    if [ -z "$pkey" ]; then ERRC=$((ERRC+1)); echo "  x $name ($category) — PARENT FAILED: $presp" >&2; continue; fi
    PAR=$((PAR+1)); OKC=$((OKC+1)); echo "  • $name ($category) — $nvar size variants"
    vi=0
    for pr in "${PR[@]}"; do
      vi=$((vi+1)); size="${SZ[$((vi-1))]}"
      vdoc=$(jq -n --arg st "$STORE" --arg sc "$SCHEMA" --arg n "$name - $size" --arg sku "$extId-$vi" --arg d "$desc" \
        --arg b "$BUNDLE" --argjson pr "$pr" --arg cat "$category" --arg pk "$pkey" --arg size "$size" --arg src "$SOURCE" --arg eid "$extId" --arg vid "$extId-$vi" \
        '{storeName:$st,"meta.schema":$sc,name:$n,sku:$sku,description:$d,dataBundleKey:$b,price:$pr,category:$cat,
          productType:"variant",parentKey:$pk,indexable:"false",optionValues:({Size:$size}|tostring),source:$src,externalProductId:$eid,externalVariantId:$vid}')
      if ok "$(post "$vdoc")"; then OKC=$((OKC+1)); VAR=$((VAR+1)); echo "      - $size \$$pr";
      else ERRC=$((ERRC+1)); echo "      x $size FAILED" >&2; fi
    done
  fi
done < <(jq -c '
  def num: (gsub("[^0-9.]";"") | if .=="" then null else tonumber end);
  def sizelabel: ({"regular":"Regular","reg":"Regular","xl":"XL","xlarge":"XL","small":"Small","sm":"Small","large":"Large","lg":"Large","medium":"Medium","med":"Medium"}[.]) // ((.[0:1]|ascii_upcase)+(.[1:]));
  .categories[] as $c | $c.items[]
  | ((.price // "") | tostring) as $p
  | { category:$c.name, name:.name, description:(.description // null),
      variants:(
        if $p != "" then ($p | split("/") | map({size:null, price:(.|num)}) | map(select(.price!=null)))
        else [ to_entries[] | select(.key|startswith("price_")) | {size:((.key|sub("^price_";""))|sizelabel), price:(.value|num)} | select(.price!=null) ]
        end
      ) }' "$MENU")

echo ""
echo "Done -> created=$OKC (standalone=$STAND, parents=$PAR, variants=$VAR), errors=$ERRC"
[ "$DRY" -eq 1 ] && echo "(dry-run: nothing was sent)"
exit 0
