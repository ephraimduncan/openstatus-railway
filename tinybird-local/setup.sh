#!/bin/sh
# Tinybird's setup.pyc makes the workspace and the tokens. Then it stays in
# memory (approximately 450 MB) only to send responses to /tokens, and no
# service in this stack uses /tokens. This script stops setup.pyc after a
# request to /tokens is successful. The script stops with exit code 0, thus
# supervisord does not start setup.pyc again.
python /app/tinybird-local/setup.pyc &
pid=$!
until curl -sf -o /dev/null http://localhost:8000/tokens; do
  kill -0 "$pid" 2>/dev/null || exit 1
  sleep 2
done
kill "$pid"
