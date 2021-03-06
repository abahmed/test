FROM golang:alpine AS builder

ARG RELEASE_VERSION="nothing"

LABEL maintainer="Abdelrahman Ahmed <a.ahmed1026@gmail.com"

RUN apk update && \
    apk add git build-base && \
    rm -rf /var/cache/apk/* && \
    mkdir -p "/build"

WORKDIR /build
COPY go.mod go.sum /build/
RUN go mod download
RUN echo ${RELEASE_VERSION} > version
RUN cat version
COPY . /build/
RUN cat version.txt
RUN sed -i 's/dev/'"${RELEASE_VERSION}"'/g' version.txt
RUN cat version.txt
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a --installsuffix cgo --ldflags="-s"

FROM alpine:latest
RUN apk add --update ca-certificates
COPY --from=builder /build/test /bin/test
COPY --from=builder /build/version /bin/version
RUN cat /bin/version
ENTRYPOINT ["/bin/test"]
