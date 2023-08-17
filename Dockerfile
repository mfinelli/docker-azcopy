FROM golang:alpine as builder
WORKDIR /azcopy

ARG AZCOPY_VERSION=10.20.1
ENV AZCOPY_VERSION=$AZCOPY_VERSION

RUN \
  apk --no-cache add curl && \
  curl -LO https://github.com/Azure/azure-storage-azcopy/archive/v${AZCOPY_VERSION}.tar.gz && \
  tar zxf v${AZCOPY_VERSION}.tar.gz --strip-components=1 && \
  go mod vendor && \
  go build -o azcopy -mod=readonly -ldflags="-s -w" && \
  ./azcopy --version

FROM alpine
LABEL org.opencontainers.image.source https://github.com/mfinelli/docker-azcopy
COPY entrypoint.sh /entrypoint.sh
COPY --from=builder /azcopy/LICENSE /usr/share/azcopy
COPY --from=builder /azcopy/azcopy /usr/local/bin
ENTRYPOINT ["/entrypoint.sh"]
CMD ["azcopy"]
