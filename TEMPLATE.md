# Deploy and Host openstatus on Railway

openstatus is an open-source status page and uptime monitoring platform. It runs HTTP, TCP, DNS, ICMP and gRPC checks from probes you control, records response times and uptime, alerts your team over email, Slack, Discord, PagerDuty and more, and publishes branded status pages with incidents, maintenance windows and subscriber updates.

## About Hosting openstatus

This template deploys the complete openstatus stack inside one Railway project, with nothing running outside it. It creates the dashboard, the public status page, the API server, the workflows worker, a libSQL database on a volume, a Tinybird Local analytics engine on a volume, the ingest server and a monitoring probe, a cron sidecar that drives scheduled jobs, and two one-shot jobs that migrate the database and load the analytics schema. Secrets are generated at deploy time. After the first deploy you open the dashboard, take the magic link from its logs, create your workspace, and run one `os-admin setup` command from the cron service to unlock every feature and register the probe. Status pages are mapped to a hostname with `os-admin page-domain`.

## Common Use Cases

- A branded public status page for your product with incident and maintenance communication
- Uptime and latency monitoring of internal services that public monitoring vendors cannot reach
- Keeping monitoring data on your own infrastructure for compliance or cost reasons

## Dependencies for openstatus Hosting

- libSQL server (application database, persisted on a Railway volume)
- Tinybird Local (ClickHouse-based analytics for check results, persisted on a Railway volume)
- The openstatus container images published on GitHub Container Registry

### Implementation Details

Every service that needs fixed settings is built from a one-line Dockerfile in the template repository so that only secrets and cross-service references remain as variables. Tinybird Local is tuned to fit Railway's 1000-process limit per container. Operations that openstatus normally performs through its cloud (workspace limits, probe registration, status page hostnames) are exposed as commands:

```
railway ssh -s cron -- os-admin setup <workspace-id>
railway ssh -s cron -- os-admin page-domain <slug> <status-page-hostname>
```

Source, upgrade notes and the full guide: https://github.com/ephraimduncan/openstatus-railway

## Why Deploy openstatus on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying openstatus on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
