# OpenStatus workflows with the self-host settings baked in. Runs as root so
# the libSQL embedded replica can write to the Railway volume at /app/data.
ARG OPENSTATUS_IMAGE=ghcr.io/openstatushq/openstatus-workflows:latest
FROM ${OPENSTATUS_IMAGE}
ENV NODE_ENV=production \
    SELF_HOST=true \
    FLY_REGION=self-hosted \
    UPSTASH_REDIS_REST_URL=http://localhost:6379 \
    UPSTASH_REDIS_REST_TOKEN=placeholder
USER 0:0
