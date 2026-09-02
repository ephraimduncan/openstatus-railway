# OpenStatus status page with the self-host settings baked in.
FROM ghcr.io/openstatushq/openstatus-status-page:latest
ENV HOSTNAME=:: \
    NODE_ENV=production \
    SELF_HOST=true \
    FLY_REGION=self-hosted \
    AUTH_TRUST_HOST=true \
    UPSTASH_REDIS_REST_URL=http://localhost:6379 \
    UPSTASH_REDIS_REST_TOKEN=placeholder
# Next.js only treats middleware rewrites as internal when the request origin is
# trusted from the Host header (Vercel turns this on automatically). Without it,
# the custom-domain rewrite is proxied back through the public domain and fails.
RUN sed -i 's/"trustHostHeader":false/"trustHostHeader":true/' /app/apps/status-page/server.js \
    && grep -q '"trustHostHeader":true' /app/apps/status-page/server.js
