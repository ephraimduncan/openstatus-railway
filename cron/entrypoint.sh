#!/bin/sh
# BusyBox crond does not pass the container environment to jobs, so the
# values are written into the job script at start.
set -eu

: "${CRON_SECRET:?CRON_SECRET is required}"
: "${WORKFLOWS_URL:?WORKFLOWS_URL is required (e.g. http://workflows.railway.internal:3000)}"

cat > /usr/local/bin/openstatus-cron <<SCRIPT
#!/bin/sh
path="\$1"
code=\$(curl --fail --silent --show-error --connect-timeout 10 --max-time 60 -o /dev/null -w '%{http_code}' -H "Authorization: ${CRON_SECRET}" "${WORKFLOWS_URL}\${path}") && result=0 || result=\$?
echo "\$(date -u +%FT%TZ) \${path} -> HTTP \${code} (exit \${result})"
exit "\${result}"
SCRIPT
chmod +x /usr/local/bin/openstatus-cron

cat > /etc/crontabs/root <<CRONTAB
*/5 * * * * /usr/local/bin/openstatus-cron /cron/private-location-health
*/10 * * * * /usr/local/bin/openstatus-cron /cron/external-status
0 2 1-7 * * /usr/local/bin/openstatus-cron /cron/uptime-freeze
CRONTAB

export TZ=UTC
echo "openstatus cron sidecar: health every 5 min, external status every 10 min, uptime freeze at 02:00 UTC on days 1-7"
/usr/local/bin/openstatus-cron /cron/private-location-health || true
exec crond -f -l 8 -L /dev/stdout
