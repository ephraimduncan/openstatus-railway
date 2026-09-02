# Template composer values

Railway drops literal variable values and service regions when it generates a template.
After `railway templates create`, open the draft in the editor and paste each block below into
that service's **raw editor** (Variables tab). Services not listed here need no changes.

## dashboard

```
PORT="3000"
AUTH_URL="https://${{RAILWAY_PUBLIC_DOMAIN}}"
AUTH_SECRET="${{secret(32)}}"
CRON_SECRET="${{workflows.CRON_SECRET}}"
DATABASE_URL="${{libsql.DATABASE_URL}}"
TINYBIRD_URL="${{tinybird-local.TINYBIRD_URL}}"
RESEND_API_KEY="re_placeholder_not_configured"
NEXT_PUBLIC_URL="https://${{RAILWAY_PUBLIC_DOMAIN}}"
TINY_BIRD_API_KEY="${{tinybird-local.TB_LOCAL_WORKSPACE_TOKEN}}"
```

## workflows

```
PORT="${{dashboard.PORT}}"
SITE_URL="https://${{dashboard.RAILWAY_PUBLIC_DOMAIN}}"
CRON_SECRET="${{secret(32)}}"
DATABASE_URL="${{libsql.DATABASE_URL}}"
TINYBIRD_URL="${{tinybird-local.TINYBIRD_URL}}"
WORKFLOWS_URL="http://${{RAILWAY_PRIVATE_DOMAIN}}:3000"
RESEND_API_KEY="${{dashboard.RESEND_API_KEY}}"
TINY_BIRD_API_KEY="${{tinybird-local.TB_LOCAL_WORKSPACE_TOKEN}}"
```

## probe

```
OPENSTATUS_KEY="${{secret(32)}}"
OPENSTATUS_INGEST_URL="${{private-location.INGEST_URL}}"
```

## tinybird-local

```
TINYBIRD_URL="http://${{RAILWAY_PRIVATE_DOMAIN}}:7181"
TB_LOCAL_USER_TOKEN="p.eyJ1IjogIjI2OTVhNDEzLTllMTctNDE1YS1hOWFmLTJmMzMxZWMyYzViOCIsICJpZCI6ICIyZDk1YjY1My1hMTA4LTRkZTUtYjc4Mi01ZjE1OTNhZmIwZGUiLCAiaG9zdCI6IG51bGx9.RLsa0HY5A7pP5FnytWFTIwHRIwtacPmKKeaoF6_2L9M"
TB_LOCAL_WORKSPACE_TOKEN="p.eyJ1IjogIjIzZTE0YmFkLWFlYmQtNGVjMi04MTVkLTMyYmI0ZDllNmI0ZCIsICJpZCI6ICJlZjc2NTEwMi0yM2Y1LTQ5OGQtYTMyZS0zMGJkMWRmNzBkNTciLCAiaG9zdCI6IG51bGx9.crYr6k4p1CXjb4bJ3grPMmRDOz4fIoU-fgdJ420bnvo"
```

## Regions (service settings, not variables)

| Service | Region |
|---|---|
| `probe` | leave on the default region (US East, Virginia) |
| `probe-us-west` | US West (California) |
| `probe-eu-west` | EU West (Amsterdam) |
| `probe-asia` | Southeast Asia (Singapore) |

## Variable descriptions (optional, shown in the deploy dialog)

| Variable | Description |
|---|---|
| dashboard.PORT | Keep 3000; the Next.js apps call themselves on localhost:3000 |
| dashboard.AUTH_SECRET | Auth.js signing secret, generated for you |
| dashboard.RESEND_API_KEY | Optional Resend key for notification emails; the magic link is printed in the dashboard logs either way |
| workflows.CRON_SECRET | Shared secret between the apps, the ingest server and the cron sidecar, generated for you |
| probe.OPENSTATUS_KEY | Private location token, generated for you; the regional probes derive theirs from it |
| tinybird-local.TB_LOCAL_WORKSPACE_TOKEN | Tinybird Local workspace token shared with the apps; must come from `tb local generate-tokens` |
| tinybird-local.TB_LOCAL_USER_TOKEN | Tinybird Local user token; must come from `tb local generate-tokens` |

Then publish:

```
railway templates publish <template-id> --category Observability \
  --description "Status pages and uptime monitoring, self-hosted entirely on Railway" \
  --readme-file TEMPLATE.md --image https://www.openstatus.dev/icon.png
```
