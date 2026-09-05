# OpenStatus API server with the self-host settings baked in.
FROM ghcr.io/ephraimduncan/openstatus-server:de39e0e66cf6fca1c5f108ebfd7a57508dc3e787
ENV NODE_ENV=production \
    SELF_HOST=true \
    FLY_REGION=self-hosted \
    UPSTASH_REDIS_REST_URL=http://localhost:6379 \
    UPSTASH_REDIS_REST_TOKEN=placeholder
