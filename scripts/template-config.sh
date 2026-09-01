#!/bin/sh
# Prints a Railway template's serializedConfig (services, variables, volumes)
# so the generated template can be checked against .railway/railway.ts.
# Usage: scripts/template-config.sh <template-code>   (needs RAILWAY_API_TOKEN or a logged-in CLI)
set -eu
code="${1:?template code required}"
token="${RAILWAY_API_TOKEN:-$(python3 -c 'import json,os;print(json.load(open(os.path.expanduser("~/.railway/config.json")))["user"]["token"])')}"
curl -s https://backboard.railway.com/graphql/v2 \
  -H "Authorization: Bearer ${token}" -H "Content-Type: application/json" \
  --data "{\"query\":\"{ template(code: \\\"${code}\\\") { name code status serializedConfig } }\"}" \
  | python3 -m json.tool
