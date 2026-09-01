# Tinybird Local with a single persistent volume.
# Railway attaches one volume per service; Tinybird Local keeps state in three
# directories, so the entrypoint symlinks them into the volume mounted at /data.
FROM tinybirdco/tinybird-local:latest
COPY entrypoint.sh /railway-entrypoint.sh
RUN chmod +x /railway-entrypoint.sh
CMD ["/railway-entrypoint.sh"]
