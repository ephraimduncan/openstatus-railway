FROM python:3.12-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates jq \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir "tinybird>=4.6,<5"

ARG OPENSTATUS_REF=de39e0e66cf6fca1c5f108ebfd7a57508dc3e787

WORKDIR /work
# Only packages/tinybird from the OpenStatus repo is needed (datasources, materializations, endpoints).
RUN curl -fsSL "https://github.com/ephraimduncan/openstatus/archive/${OPENSTATUS_REF}.tar.gz" \
    | tar -xz --strip-components=3 --wildcards "openstatus-*/packages/tinybird/*" \
    && rm -rf node_modules src scripts package.json tsconfig.json


COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
