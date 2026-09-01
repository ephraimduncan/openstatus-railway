# OpenStatus status page with the self-host settings baked in.
FROM ghcr.io/openstatushq/openstatus-status-page:latest
ENV HOSTNAME=:: \
    NODE_ENV=production \
    SELF_HOST=true \
    FLY_REGION=self-hosted \
    AUTH_TRUST_HOST=true \
    UPSTASH_REDIS_REST_URL=http://localhost:6379 \
    UPSTASH_REDIS_REST_TOKEN=placeholder
