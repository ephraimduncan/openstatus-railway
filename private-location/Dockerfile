# OpenStatus ingest server (receives results from probes).
# The upstream server closes idle connections after 60 seconds, and the probes
# send results about every 60 seconds on a kept-alive connection. When a probe
# sends on a connection that the server closes at the same time, the probe
# gets "unexpected EOF" and loses the result. Thus, this file builds the server
# from the same commit with a 2-minute idle timeout. This is longer than the
# 90-second idle timeout of the probes, so the probes close idle connections
# first.
FROM golang:1.26-bookworm AS build
ARG OPENSTATUS_REF=f8057fbe1f17e8eef6b0fc7c28b73cbccdaa0a62
WORKDIR /src
RUN curl -fsSL "https://github.com/openstatusHQ/openstatus/archive/${OPENSTATUS_REF}.tar.gz" \
    | tar -xz --strip-components=3 --wildcards "openstatus-*/apps/private-location/*"
RUN sed -i 's/IdleTimeout:  time.Minute,/IdleTimeout:  2 * time.Minute,/' internal/server/server.go \
    && grep -q 'IdleTimeout:  2 \* time.Minute,' internal/server/server.go \
    && CGO_ENABLED=1 go build -trimpath -ldflags "-s -w" -o private-location ./cmd/server

FROM ghcr.io/openstatushq/openstatus-private-location:f8057fb
COPY --from=build /src/private-location /opt/bin/private-location
ENV GIN_MODE=release
# The server logs every request to stderr, and Railway shows all stderr lines
# as errors. Thus, stderr goes to stdout.
CMD ["sh", "-c", "exec /opt/bin/private-location 2>&1"]
