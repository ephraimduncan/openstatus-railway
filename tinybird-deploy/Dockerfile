FROM python:3.12-slim AS tools

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates jq \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir "tinybird>=4.6,<5"

FROM tools AS download
ARG OPENSTATUS_REF=48b5a2c4b17e2146a65b66f4f6f68c7cfe73ba8c

WORKDIR /work
# Only packages/tinybird from the OpenStatus repo is needed (datasources, materializations, endpoints).
RUN curl -fsSL "https://github.com/openstatusHQ/openstatus/archive/${OPENSTATUS_REF}.tar.gz" \
    | tar -xz --strip-components=3 --wildcards "openstatus-*/packages/tinybird/*" \
    && rm -rf node_modules src scripts package.json tsconfig.json

FROM scratch AS schema
COPY --from=download /work /

FROM tools
WORKDIR /work
COPY --from=schema / /work/

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
