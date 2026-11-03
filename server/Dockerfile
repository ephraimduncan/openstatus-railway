# OpenStatus API server with the self-host settings baked in.
FROM ghcr.io/openstatushq/openstatus-server:f8057fb
ENV NODE_ENV=production \
    SELF_HOST=true \
    FLY_REGION=self-hosted \
    UPSTASH_REDIS_REST_URL=http://localhost:6379 \
    UPSTASH_REDIS_REST_TOKEN=placeholder
