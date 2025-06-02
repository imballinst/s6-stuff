# Use your favorite image
FROM golang:1.24 AS build
WORKDIR /workspace

# Copy the Go one.
COPY s6-test/go.mod s6-test/go.sum ./
RUN go mod download
COPY s6-test/*.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o /s6test

# Copy the Node one.
FROM node:20 AS nodebuild
WORKDIR /workspace

RUN mkdir node-prisma
COPY ./node-prisma/index.js ./node-prisma/package.json ./node-prisma/yarn.lock ./node-prisma/.yarnrc.yml node-prisma/
COPY ./node-prisma/.yarn node-prisma/.yarn
RUN cd node-prisma && ls -al && yarn workspaces focus

# Runtime image.
FROM alpine AS runtime
ARG S6_OVERLAY_VERSION=3.2.1.0

WORKDIR /workspace

RUN apk update && apk add xz nodejs

COPY --from=build s6test s6test
RUN chmod +x ./s6test

RUN mkdir node-prisma
COPY --from=nodebuild /workspace/node-prisma/ node-prisma

COPY s6-test/s6-app-1/type /etc/s6-overlay/s6-rc.d/s6-app-1/type
COPY s6-test/s6-app-1/run /etc/s6-overlay/s6-rc.d/s6-app-1/run
COPY s6-test/s6-app-1/contents.d /etc/s6-overlay/s6-rc.d/user/contents.d/
COPY s6-test/s6-app-1/dependencies.d /etc/s6-overlay/s6-rc.d/s6-app-1/dependencies.d/

COPY s6-test/s6-app-2/type /etc/s6-overlay/s6-rc.d/s6-app-2/type
COPY s6-test/s6-app-2/run /etc/s6-overlay/s6-rc.d/s6-app-2/run
COPY s6-test/s6-app-2/contents.d /etc/s6-overlay/s6-rc.d/user/contents.d/
COPY s6-test/s6-app-2/dependencies.d /etc/s6-overlay/s6-rc.d/s6-app-2/dependencies.d/

RUN cd /workspace/node-prisma && pwd && ls -al

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

ENTRYPOINT ["/init"]