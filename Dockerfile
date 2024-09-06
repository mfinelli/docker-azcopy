FROM golang:alpine as source
WORKDIR /azcopy

ARG AZCOPY_VERSION=10.26.0
ENV AZCOPY_VERSION=$AZCOPY_VERSION
ENV AZCOPY_URLBASE=https://github.com/Azure/azure-storage-azcopy

RUN \
  apk --no-cache add curl patch && \
  curl -LO ${AZCOPY_URLBASE}/archive/v${AZCOPY_VERSION}.tar.gz && \
  tar zxf v${AZCOPY_VERSION}.tar.gz --strip-components=1 && \
  rm v${AZCOPY_VERSION}.tar.gz && \
  go mod vendor

FROM source as builder

RUN \
  go build -o azcopy -mod=readonly -ldflags="-s -w" && \
  ./azcopy --version

FROM alpine
LABEL org.opencontainers.image.source https://github.com/mfinelli/docker-azcopy
COPY entrypoint.sh /entrypoint.sh
COPY --from=source /azcopy/ /usr/src/azcopy
COPY --from=builder /azcopy/azcopy /usr/local/bin
ENTRYPOINT ["/entrypoint.sh"]
CMD ["azcopy"]
