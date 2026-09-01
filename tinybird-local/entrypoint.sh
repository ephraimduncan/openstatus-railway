#!/bin/sh
set -eu
DATA_ROOT="${TB_DATA_ROOT:-/data}"

link_dir() {
  src="$1"; dest="$DATA_ROOT/$2"
  mkdir -p "$dest"
  if [ -L "$src" ]; then
    return
  fi
  if [ -d "$src" ] && [ -n "$(ls -A "$src" 2>/dev/null)" ] && [ -z "$(ls -A "$dest" 2>/dev/null)" ]; then
    cp -a "$src/." "$dest/"
  fi
  rm -rf "$src"
  ln -s "$dest" "$src"
}

link_dir /var/lib/clickhouse clickhouse
link_dir /redis-data redis
link_dir /var/lib/minio minio

echo "tinybird-local: state persisted under $DATA_ROOT (clickhouse, redis, minio)"
exec /usr/bin/supervisord
