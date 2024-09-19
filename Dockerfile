FROM alpine:latest as builder
WORKDIR /app
COPY . ./
# This is where one could build the application code as well.

# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM alpine:latest
RUN apk update && apk add ca-certificates iptables ip6tables && rm -rf /var/cache/apk/*

# Copy binary to production image.
# COPY --from=builder /app/start.sh /app/start.sh

# Copy Tailscale binaries from the tailscale image on Docker Hub.
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscaled /app/tailscaled
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscale /app/tailscale
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

RUN ch

# Run on container startup.
CMD ["/app/tailscaled", "--state=/var/lib/tailscale/tailscaled.state", "--socket=/var/run/tailscale/tailscaled.sock", "&", "/app/tailscale", "up", "--authkey=$TAILSCALE_AUTHKEY", "--hostname=fly-app", "/app/my-app"]