# Tinybird Local with a single persistent volume, sized for Railway.
# - Railway attaches one volume per service; Tinybird Local keeps state in two
#   directories (ClickHouse data and Redis metadata), so the entrypoint symlinks
#   them into the volume mounted at /data.
# - Railway limits a container to 1000 PIDs (threads included). ClickHouse and
#   nginx size themselves from the host's core count, so the server pools are
#   capped, every `clickhouse local` helper Tinybird spawns gets a small config
#   through a wrapper around the binary, and the Kafka connector and MCP server
#   (unused by OpenStatus) stay off.
# - Railway bills memory. OpenStatus sends data only through the Events API.
#   Thus, tinybird-settings.py starts no CSV import worker, and the object
#   store (used only for file imports) and the ClickHouse watchdog stay off.
#   setup.sh stops the setup process after it makes the workspace.
#   MALLOC_ARENA_MAX limits each process to 2 malloc arenas (the default is 8
#   for each CPU core), and PYTHON_CPU_COUNT sizes the Python pools for 2 CPUs.
# - server.sh starts the Tinybird API only after ClickHouse accepts
#   connections (see the script).
# - This file changes files in the base image, and the upstream `latest` tag
#   changes frequently. Thus, FROM uses one known digest. To upgrade, change
#   the digest.
FROM tinybirdco/tinybird-local:latest@sha256:c3fe9709224e6898f89b1dc1073d0046e665d2dc571c5c93ef13c807b6bb15f4
ENV PYTHON_CPU_COUNT=2 \
    MALLOC_ARENA_MAX=2 \
    CLICKHOUSE_WATCHDOG_ENABLE=0
COPY tinybird-settings.py /etc/tinybird-settings.py
COPY clickhouse-railway.xml /etc/clickhouse-server/config.d/zz-railway.xml
COPY clickhouse-users-railway.xml /etc/clickhouse-server/users.d/zz-railway.xml
COPY clickhouse-local-railway.xml /etc/clickhouse-local-railway.xml
COPY clickhouse-wrapper.sh /usr/local/sbin/clickhouse-wrapper.sh
COPY entrypoint.sh /railway-entrypoint.sh
COPY setup.sh /usr/local/sbin/tinybird-setup.sh
COPY server.sh /usr/local/sbin/tinybird-server.sh
RUN chmod +x /railway-entrypoint.sh /usr/local/sbin/clickhouse-wrapper.sh /usr/local/sbin/tinybird-setup.sh /usr/local/sbin/tinybird-server.sh \
    && mv /usr/bin/clickhouse /usr/bin/clickhouse.real \
    && cp /usr/local/sbin/clickhouse-wrapper.sh /usr/bin/clickhouse \
    && sed -i 's/^worker_processes .*/worker_processes 2;/' /etc/nginx/nginx.conf \
    && sed -i '/^\[program:tinybird-kafka\]/a autostart=false' /etc/supervisor/conf.d/supervisord.conf \
    && sed -i '/^\[program:tinybird-mcp\]/a autostart=false' /etc/supervisor/conf.d/supervisord.conf \
    && sed -i '/^\[program:object-storage\]/a autostart=false' /etc/supervisor/conf.d/supervisord.conf \
    && sed -i '/^\[program:object-storage-init\]/a autostart=false' /etc/supervisor/conf.d/supervisord.conf \
    && sed -i 's#^command=python /app/tinybird-local/setup\.pyc$#command=/usr/local/sbin/tinybird-setup.sh#' /etc/supervisor/conf.d/supervisord.conf \
    && sed -i 's#^command=tinybird_server --port 8001$#command=/usr/local/sbin/tinybird-server.sh#' /etc/supervisor/conf.d/supervisord.conf
CMD ["/railway-entrypoint.sh"]
