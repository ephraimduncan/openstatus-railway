#!/bin/sh
# BusyBox crond does not pass the container environment to jobs, so the
# values are written into the job script at start.
set -eu

: "${CRON_SECRET:?CRON_SECRET is required}"
: "${WORKFLOWS_URL:?WORKFLOWS_URL is required (e.g. http://workflows.railway.internal:3000)}"

cat > /usr/local/bin/openstatus-cron <<SCRIPT
#!/bin/sh
path="\$1"
: > /tmp/cron.out
code=\$(curl -sS -o /tmp/cron.out -w '%{http_code}' -H "Authorization: ${CRON_SECRET}" "${WORKFLOWS_URL}\${path}" 2>/tmp/cron.err) || code="000"
echo "\$(date -u +%FT%TZ) \${path} -> \${code} \$(head -c 300 /tmp/cron.out) \$(head -c 200 /tmp/cron.err)"
SCRIPT
chmod +x /usr/local/bin/openstatus-cron

cat > /etc/crontabs/root <<CRONTAB
*/5 * * * * /usr/local/bin/openstatus-cron /cron/private-location-health
CRONTAB

echo "openstatus cron sidecar: hitting ${WORKFLOWS_URL}/cron/private-location-health every 5 minutes"
/usr/local/bin/openstatus-cron /cron/private-location-health || true
exec crond -f -l 2 -L /dev/stdout
