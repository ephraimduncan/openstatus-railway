#!/bin/bash
# Railway caps containers at 1000 PIDs (threads included). Tinybird spawns
# `clickhouse local` helpers that each start a 512-thread scheduler pool by
# default, so force a small config on every `local` invocation and pass
# everything else (server, client, keeper, ...) straight through.
real=/usr/bin/clickhouse.real
if [ "$1" = "local" ]; then
  shift
  exec -a "$0" "$real" local --config-file /etc/clickhouse-local-railway.xml "$@"
fi
exec -a "$0" "$real" "$@"
