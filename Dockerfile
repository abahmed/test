FROM golang:alpine AS builder
LABEL maintainer="Abdelrahman Ahmed <a.ahmed1026@gmail.com"

RUN apk update && \
    apk add git build-base && \
    rm -rf /var/cache/apk/* && \
    mkdir -p "/build"

WORKDIR /build
COPY go.mod go.sum /build/
RUN go mod download

COPY . /build/
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a --installsuffix cgo --ldflags="-s"

FROM alpine:latest
RUN apk add --update ca-certificates
COPY --from=builder /build/test /bin/test
RUN echo "test" > README.md
ENTRYPOINT ["/bin/test"]
