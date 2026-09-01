# Tinybird Local with a single persistent volume, sized for Railway.
# - Railway attaches one volume per service; Tinybird Local keeps state in two
#   directories (ClickHouse data and Redis metadata), so the entrypoint symlinks
#   them into the volume mounted at /data.
# - Railway limits a container to 1000 PIDs (threads included). ClickHouse and
#   nginx size themselves from the host's core count, so the server pools are
#   capped, every `clickhouse local` helper Tinybird spawns gets a small config
#   through a wrapper around the binary, and the Kafka connector and MCP server
#   (unused by OpenStatus) stay off.
FROM tinybirdco/tinybird-local:latest
COPY clickhouse-railway.xml /etc/clickhouse-server/config.d/zz-railway.xml
COPY clickhouse-users-railway.xml /etc/clickhouse-server/users.d/zz-railway.xml
COPY clickhouse-local-railway.xml /etc/clickhouse-local-railway.xml
COPY clickhouse-wrapper.sh /usr/local/sbin/clickhouse-wrapper.sh
COPY entrypoint.sh /railway-entrypoint.sh
RUN chmod +x /railway-entrypoint.sh /usr/local/sbin/clickhouse-wrapper.sh \
    && mv /usr/bin/clickhouse /usr/bin/clickhouse.real \
    && cp /usr/local/sbin/clickhouse-wrapper.sh /usr/bin/clickhouse \
    && sed -i 's/^worker_processes .*/worker_processes 2;/' /etc/nginx/nginx.conf \
    && sed -i '/^\[program:tinybird-kafka\]/a autostart=false' /etc/supervisor/conf.d/supervisord.conf \
    && sed -i '/^\[program:tinybird-mcp\]/a autostart=false' /etc/supervisor/conf.d/supervisord.conf
CMD ["/railway-entrypoint.sh"]
