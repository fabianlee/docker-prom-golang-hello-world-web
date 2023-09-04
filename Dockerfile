#
# builder image
# https://hub.docker.com/_/golang/tags?page=1&name=buster
FROM golang:1.20.5-buster as builder
RUN mkdir /build
ADD src/*.go /build/
WORKDIR /build

# accept override of value from --build-args
ARG MY_VERSION=0.1.1
ENV MY_VERSION=$MY_VERSION

# accept override of value from --build-args
ARG MY_BUILDTIME=now
ENV MY_BUILDTIME=$MY_BUILDTIME

# create module, fetch dependencies, then build
RUN go mod init fabianlee.org/docker-golang-hello-world-web \
   && go get -d -u ./... \
   && CGO_ENABLED=0 GOOS=linux go build -ldflags "-X main.Version=${MY_VERSION} -X main.BuildTime=${MY_BUILDTIME}" -a -o fabianlee.org/main .


#
# generate small final image for end users
#
#FROM alpine:3.13.5
# could have used either alpine or busybox
# busybox-glibc (versus musl) has better compatability with Debian peers
# https://hub.docker.com/_/busybox/
FROM busybox:1.36.1-glibc

# copy golang binary into container
WORKDIR /root
COPY --from=builder /build/fabianlee.org/main .

# executable
ENTRYPOINT [ "./main" ]
