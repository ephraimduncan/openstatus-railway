# OpenStatus dashboard with the self-host settings baked in, so the Railway
# template only carries secrets and cross-service references.
FROM ghcr.io/ephraimduncan/openstatus-dashboard:de39e0e66cf6fca1c5f108ebfd7a57508dc3e787
ENV HOSTNAME=:: \
    NODE_ENV=production \
    SELF_HOST=true \
    FLY_REGION=self-hosted \
    AUTH_TRUST_HOST=true \
    UPSTASH_REDIS_REST_URL=http://localhost:6379 \
    UPSTASH_REDIS_REST_TOKEN=placeholder
