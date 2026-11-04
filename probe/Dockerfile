# OpenStatus probe. The image has only a `latest` tag, thus the digest selects
# the build from the same week as the other services.
# The probe logs every check to stderr, and Railway shows all stderr lines as
# errors. The upstream image has no shell, thus the binary runs on Alpine with
# stderr sent to stdout.
FROM ghcr.io/openstatushq/private-location@sha256:60b10bbe1875ed2148b44eef49e418005ded3537d196dd3ca32dc50382f3d8cd AS probe

FROM alpine:3.21
COPY --from=probe /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=probe /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=probe /opt/bin/private /opt/bin/private
WORKDIR /opt/bin
ENV TZ=UTC \
    USER=1000 \
    GIN_MODE=release
CMD ["sh", "-c", "exec /opt/bin/private 2>&1"]
