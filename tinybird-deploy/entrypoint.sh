#!/bin/sh
# One-shot job: loads the OpenStatus Tinybird project (datasources, materialized
# views, endpoints) into the tinybird-local service and exits 0. Re-run it
# (Railway "Redeploy") after upgrading OpenStatus to apply schema changes.
set -eu

: "${TB_HOST:?TB_HOST is required (e.g. http://tinybird-local.railway.internal:7181)}"
: "${TB_TOKEN:?TB_TOKEN is required (the tinybird-local workspace token)}"
export TB_VERSION_WARNING=0

# nginx answers /tokens before the API is up, so wait for an authenticated
# API call to succeed instead.
echo "Waiting for Tinybird Local at ${TB_HOST} ..."
i=0
until [ "$(curl -s -o /dev/null -w '%{http_code}' "${TB_HOST}/v0/workspace?token=${TB_TOKEN}")" = "200" ]; do
  i=$((i+1))
  if [ "$i" -gt 180 ]; then
    echo "Tinybird Local did not become ready in time (or TB_TOKEN is not accepted)" >&2
    exit 1
  fi
  sleep 5
done
sleep 5
echo "Tinybird Local is up."

cd /work
attempt=1
until tb --cloud --host "${TB_HOST}" --token "${TB_TOKEN}" deploy; do
  if [ "$attempt" -ge 3 ]; then
    echo "tb deploy failed ${attempt} times" >&2
    exit 1
  fi
  attempt=$((attempt+1))
  echo "tb deploy failed, retrying in 30s (attempt ${attempt}/3) ..."
  sleep 30
done

echo "Deployments:"
tb --cloud --host "${TB_HOST}" --token "${TB_TOKEN}" deployment ls || true

code=$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer ${TB_TOKEN}" \
  "${TB_HOST}/v0/pipes/endpoint__http_metrics_1d__v1.json?monitorId=1")
if [ "$code" != "200" ]; then
  echo "Verification query returned HTTP ${code}; the deployment is not live" >&2
  exit 1
fi
echo "Verification query returned 200. Tinybird is ready."
