# OpenStatus ingest server (receives results from probes).
# The server logs every request to stderr, and Railway shows all stderr lines
# as errors. Thus, stderr goes to stdout.
FROM ghcr.io/openstatushq/openstatus-private-location:f8057fb
ENV GIN_MODE=release
CMD ["sh", "-c", "exec /opt/bin/private-location 2>&1"]
