# OpenStatus ingest server (receives results from probes).
# 39780ae is f8057fb with one change to this service (openstatusHQ/openstatus#3025):
# the server keeps idle connections longer than the probes. With the f8057fb
# server, the remote probes lose some results with "unexpected EOF".
# The server logs every request to stderr, and Railway shows all stderr lines
# as errors. Thus, stderr goes to stdout.
FROM ghcr.io/openstatushq/openstatus-private-location:39780ae
ENV GIN_MODE=release
CMD ["sh", "-c", "exec /opt/bin/private-location 2>&1"]
