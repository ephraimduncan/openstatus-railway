FROM alpine:3.21
RUN apk add --no-cache curl jq
COPY os-admin /usr/local/bin/os-admin
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /usr/local/bin/os-admin /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
