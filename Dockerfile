# Build goss and packer-provisioner-goss with musl
FROM golang:1.13-alpine3.10 as build_musl_bins
ARG GOSS_VER=0.3.11
ENV GO111MODULE=on
RUN apk --no-cache --upgrade --virtual=build_environment add binutils && \
    go get github.com/aelsabbahy/goss/cmd/goss@v${GOSS_VER} && \
    strip $GOPATH/bin/* && \
    cp ${GOPATH}/pkg/mod/github.com/aelsabbahy/goss@v${GOSS_VER}/extras/dgoss/dgoss ${GOPATH}/bin/ && \
    go clean -cache -modcache && \
    apk --no-cache del build_environment

# Use Node LTS release, based on alpine
FROM node:lts-alpine

# Get binaries from musl based container
COPY --from=build_musl_bins /go/bin/goss /go/bin/dgoss /bin/

# Install netcat
RUN apk --no-cache --update add netcat-openbsd && \
    rm -rf /var/cache/apk/*

