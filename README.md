# OpenStatus on Railway

Self-host [OpenStatus](https://github.com/openstatusHQ/openstatus) (status pages + uptime monitoring) with one click. Everything runs inside a single Railway project: the database, the dashboard, the status pages, the background workers, the monitoring probe, the scheduler and the Tinybird analytics engine. No external accounts are required to get a working instance.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/__TEMPLATE_CODE__?utm_medium=integration&utm_source=button&utm_campaign=openstatus)

## What gets deployed

| Service | Built from | Role |
|---|---|---|
| `dashboard` | `dashboard/Dockerfile` (upstream `openstatus-dashboard` image + self-host settings) | Admin UI (public) |
| `status-page` | `status-page/Dockerfile` | Public status pages |
| `server` | `server/Dockerfile` | REST / ConnectRPC / MCP API (public) |
| `workflows` | `workflows/Dockerfile` | Background jobs, alerting, cron endpoints (volume) |
| `private-location` | `private-location/Dockerfile` | Ingest server: receives check results from probes (public, for extra probes) |
| `probe` | `ghcr.io/openstatushq/private-location` | The monitoring probe that runs your checks |
| `cron` | `cron/Dockerfile` | Scheduler sidecar + `os-admin` toolbox |
| `libsql` | `libsql/Dockerfile` (upstream `libsql-server` image) | Application database (volume) |
| `db-migrate` | `ghcr.io/openstatushq/openstatus-db-migrate` | One-shot schema migration (exits when done) |
| `tinybird-local` | `tinybird-local/Dockerfile` (upstream `tinybird-local` image) | Time-series analytics (ClickHouse, volume) |
| `tinybird-deploy` | `tinybird-deploy/Dockerfile` | One-shot job that loads the OpenStatus analytics schema |

The wrapper Dockerfiles are one `FROM` plus `ENV` lines. They exist because Railway's template generator only keeps variables that reference other services, so every fixed setting (ports, `SELF_HOST`, dummy Upstash values, and so on) lives in the image and the template carries just six inputs.

All secrets (`AUTH_SECRET`, `CRON_SECRET`, the probe key) are generated at deploy time. The Tinybird tokens are fixed defaults because Tinybird Local only accepts tokens in its own signed format; the service is private-network only. See [Rotate the Tinybird tokens](#rotate-the-tinybird-tokens).

Tinybird Local is the heaviest service (about 1 GB of RAM at rest). Plan for a Hobby plan or higher.

## First login

1. Wait until `db-migrate` and `tinybird-deploy` show **Completed** and the other services are green. The first deploy takes a few minutes because Railway builds the three helper images.
2. Open the `dashboard` domain and go to `/login`. Enter your email and request a magic link.
3. The link is not emailed. Open the `dashboard` service logs and copy the line that starts with `>>> Magic Link:` into your browser.
4. Create your workspace.

## Unlock features and connect the probe

Self-hosted workspaces start with empty limits. Run the toolbox once from the `cron` service (Railway CLI, or the service's shell in the dashboard):

```bash
railway ssh -s cron -- os-admin workspaces        # find your workspace id (usually 1)
railway ssh -s cron -- os-admin setup 1           # limits + team plan + registers the probe
```

`setup` creates a private location named `railway` that uses the bundled `probe` service. Assign monitors to it when you create them; the probe picks up new monitors within 10 minutes (restart the `probe` service to skip the wait).

Prefer the UI? Create a private location under **Settings → Private Locations**, copy its token, and set it as `OPENSTATUS_KEY` on the `probe` service. Railway redeploys the probe automatically.

## Publish a status page

On Railway a status page is served on a hostname, not on a path. After creating a page in the dashboard, map a hostname to it:

```bash
railway ssh -s cron -- os-admin page-domain <slug> <status-page-domain>
```

`<status-page-domain>` is the Railway domain of the `status-page` service, or a custom domain you added to that service under **Settings → Networking**. One hostname per page; for several pages add several custom domains (wildcard domains are supported by Railway) and map each one. The dashboard's "custom domain" form is wired to Vercel and does not work self-hosted, which is why the toolbox exists.

## Optional integrations

Add these variables to the `dashboard` service and Railway redeploys it:

- **GitHub / Google login:** `AUTH_GITHUB_ID`, `AUTH_GITHUB_SECRET`, `AUTH_GOOGLE_ID`, `AUTH_GOOGLE_SECRET`. Callback URLs are `https://<dashboard-domain>/api/auth/callback/github` and `.../google`.
- **Any OIDC provider:** `AUTH_OIDC_ISSUER`, `AUTH_OIDC_ID`, `AUTH_OIDC_SECRET`, optional `AUTH_OIDC_NAME`.
- **Notification emails:** set `RESEND_API_KEY` to a real [Resend](https://resend.com) key. It is referenced by the other services, so change it in one place.
- **AI assistant:** `AI_BASE_URL`, `AI_API_KEY`, `AI_MODEL` (any OpenAI-compatible endpoint whose model supports tool calling).
- **API keys for the public API:** `UNKEY_API_ID` and `UNKEY_TOKEN` on `dashboard` and `server`.

## Upgrading

The OpenStatus images track the `latest` tag. To upgrade:

1. Redeploy `db-migrate` and wait for **Completed**.
2. Redeploy `dashboard`, `status-page`, `server`, `workflows`, `private-location` and `probe`.
3. Redeploy `tinybird-deploy` so new analytics pipes are created.

## Rotate the Tinybird tokens

Generate a new pair and set them on the `tinybird-local` service (every consumer references those variables):

```bash
pip install tinybird
tb --output=json local generate-tokens
# set TB_LOCAL_WORKSPACE_TOKEN and TB_LOCAL_USER_TOKEN on tinybird-local, then redeploy tinybird-deploy
```

## Known limitations

- Only private locations work self-hosted. OpenStatus's public regions are cloud infrastructure and are not available.
- The dashboard's custom-domain form talks to Vercel; use `os-admin page-domain` instead.
- Status-page IP restriction trusts `X-Forwarded-For` and should not be relied on.
- API keys need Unkey; without it the REST API cannot authenticate.
- Never expose `tinybird-local` or `libsql` publicly. They have no authentication beyond their tokens.

## Toolbox reference

```
os-admin workspaces | users | probes | pages
os-admin setup <workspace-id>
os-admin limits <workspace-id>
os-admin plan <workspace-id> [free|starter|team|scale]
os-admin register-probe <workspace-id> [name]
os-admin page-domain <slug> <hostname>
os-admin tinybird-tokens
os-admin sql "<statement>"
```

## For maintainers of this template

The whole project is defined in [`.railway/railway.ts`](.railway/railway.ts) (Railway Infrastructure as Code, CLI 5.42 or newer). To reproduce the reference project:

```bash
npm install
railway init --name openstatus
railway config plan
railway config apply
railway domain -s dashboard -p 3000
railway domain -s status-page -p 3000
railway domain -s server -p 3000
railway domain -s private-location -p 8080
```

Generate the template from the project (`railway templates create --project <id> --json`) and open the editor URL it prints. Railway drops literal values when it generates a template, so fill in these six variables in the composer, then publish with `railway templates publish <id> --category Observability --readme-file README.md`:

| Service | Variable | Default to enter | Description to enter |
|---|---|---|---|
| `dashboard` | `AUTH_SECRET` | `${{secret(32)}}` | Auth.js secret, generated for you |
| `dashboard` | `RESEND_API_KEY` | `re_placeholder_not_configured` | Optional. Set a real Resend key to send notification emails; the magic link is printed in the dashboard logs either way |
| `workflows` | `CRON_SECRET` | `${{secret(32)}}` | Shared secret between the apps, the ingest server and the cron sidecar, generated for you |
| `probe` | `OPENSTATUS_KEY` | `${{secret(32)}}` | Private location token, generated for you; `os-admin setup` registers it |
| `tinybird-local` | `TB_LOCAL_WORKSPACE_TOKEN` | the workspace token from `.railway/railway.ts` | Tinybird Local workspace token (must be a `tb local generate-tokens` token) |
| `tinybird-local` | `TB_LOCAL_USER_TOKEN` | the user token from `.railway/railway.ts` | Tinybird Local user token |

Every other variable is a `${{service.VAR}}` reference and survives generation. `scripts/template-config.sh <code>` prints a template's stored configuration so you can check it.

OpenStatus is AGPL-3.0 licensed; this repository only contains deployment configuration (MIT).
