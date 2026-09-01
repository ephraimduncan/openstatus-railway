FROM python:3.12-slim

ARG OPENSTATUS_REF=main

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates jq \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir "tinybird>=4.6,<5"

WORKDIR /work
# Only packages/tinybird from the OpenStatus repo is needed (datasources, materializations, endpoints).
RUN curl -fsSL "https://github.com/openstatusHQ/openstatus/archive/refs/heads/${OPENSTATUS_REF}.tar.gz" \
    | tar -xz --strip-components=3 --wildcards "openstatus-*/packages/tinybird/*" \
    && rm -rf node_modules src scripts package.json tsconfig.json \
    && ls

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
