FROM golang:alpine as builder
WORKDIR /azcopy

ARG AZCOPY_VERSION=10.21.0
ENV AZCOPY_VERSION=$AZCOPY_VERSION

RUN \
  apk --no-cache add curl patch && \
  curl -LO https://github.com/Azure/azure-storage-azcopy/archive/v${AZCOPY_VERSION}.tar.gz && \
  curl -LO https://patch-diff.githubusercontent.com/raw/Azure/azure-storage-azcopy/pull/2393.patch && \
  tar zxf v${AZCOPY_VERSION}.tar.gz --strip-components=1 && \
  patch -p1 -i 2393.patch && \
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
