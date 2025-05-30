# Use your favorite image
FROM golang:1.24 AS build
WORKDIR /workspace

COPY go.mod go.sum ./
RUN go mod download
COPY *.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o /s6test

FROM alpine AS runtime
ARG S6_OVERLAY_VERSION=3.2.1.0

WORKDIR /workspace

RUN apk update && apk add xz

COPY --from=build s6test s6test
RUN chmod +x ./s6test

COPY s6-app-1/type /etc/s6-overlay/s6-rc.d/s6-app-1/type
COPY s6-app-1/run /etc/s6-overlay/s6-rc.d/s6-app-1/run
COPY s6-app-1/contents.d /etc/s6-overlay/s6-rc.d/user/contents.d/
COPY s6-app-1/dependencies.d /etc/s6-overlay/s6-rc.d/s6-app-1/dependencies.d/

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

ENTRYPOINT ["/init"]