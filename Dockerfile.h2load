FROM alpine:3.8

RUN apk add --no-cache \
        alpine-sdk \
        libtool \
        autoconf \
        automake \
        libev-dev \
        zlib-dev \
        c-ares-dev \
        openssl-dev \
        jemalloc-dev

RUN git clone --depth 1 --single-branch --branch v1.32.0 https://github.com/nghttp2/nghttp2

RUN cd nghttp2 \
    && autoreconf -i && automake && autoconf && ./configure \
    && make && make install-strip \
    && cd .. && rm -rf nghttp2

VOLUME /tmp

ENTRYPOINT ["h2load"]
