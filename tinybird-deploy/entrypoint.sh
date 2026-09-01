#!/bin/sh
# One-shot job: loads the OpenStatus Tinybird project (datasources, materialized
# views, endpoints) into the tinybird-local service and exits 0. Re-run it
# (Railway "Redeploy") after upgrading OpenStatus to apply schema changes.
set -eu

: "${TB_HOST:?TB_HOST is required (e.g. http://tinybird-local.railway.internal:7181)}"
: "${TB_TOKEN:?TB_TOKEN is required (the tinybird-local workspace token)}"
export TB_VERSION_WARNING=0

echo "Waiting for Tinybird Local at ${TB_HOST} ..."
i=0
until curl -sf "${TB_HOST}/tokens" >/dev/null 2>&1; do
  i=$((i+1))
  if [ "$i" -gt 120 ]; then
    echo "Tinybird Local did not become healthy in time" >&2
    exit 1
  fi
  sleep 5
done
echo "Tinybird Local is up."

echo "Deploying OpenStatus Tinybird project (tb deploy = deployment create --wait --auto) ..."
cd /work
tb --cloud --host "${TB_HOST}" --token "${TB_TOKEN}" deploy

echo "Deployments:"
tb --cloud --host "${TB_HOST}" --token "${TB_TOKEN}" deployment ls || true

code=$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer ${TB_TOKEN}" \
  "${TB_HOST}/v0/pipes/endpoint__http_metrics_1d__v1.json?monitorId=1")
if [ "$code" != "200" ]; then
  echo "Verification query returned HTTP ${code}; the deployment is not live" >&2
  exit 1
fi
echo "Verification query returned 200. Tinybird is ready."
