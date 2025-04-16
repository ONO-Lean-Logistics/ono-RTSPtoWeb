# syntax=docker/dockerfile:1

FROM --platform=${BUILDPLATFORM} golang:1.24-alpine AS builder

RUN apk add git

WORKDIR /go/src/app
COPY . .

ARG TARGETOS TARGETARCH TARGETVARIANT

ENV CGO_ENABLED=0
RUN go mod download && \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOARM=${TARGETVARIANT#"v"} go build -a -o rtsp

FROM alpine:3.21

WORKDIR /app

RUN mkdir -p /app/rtsp/
COPY --from=builder /go/src/app/rtsp /app/rtsp
COPY --from=builder /go/src/app/web /app/web

ENV GO111MODULE="on"
ENV GIN_MODE="release"

CMD ["./rtsp", "--config=/app/rtsp/config.json"]