#!/bin/sh
# If ClickHouse does not accept connections when tinybird_server starts, the
# server does not open port 8001, but its process continues to run. Thus,
# supervisord does not start it again. This script waits for ClickHouse first.
until curl -sf --max-time 2 -o /dev/null http://localhost:8123/ping; do
  sleep 1
done
exec tinybird_server --port 8001 --config /etc/tinybird-settings.py
