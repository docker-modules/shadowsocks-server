FROM alpine
LABEL maintainer="lomocc <constlomo@gmail.com>"

ARG SHADOWSOCKS_LIBEV_RELEASE_URL="https://github.com/shadowsocks/shadowsocks-libev/releases/download/v3.2.0/shadowsocks-libev-3.2.0.tar.gz"

RUN set -ex \
    # Build environment setup
    && apk add --no-cache --virtual .build-deps \
    autoconf \
    automake \
    build-base \
    c-ares-dev \
    libev-dev \
    libtool \
    libsodium-dev \
    linux-headers \
    mbedtls-dev \
    pcre-dev \
    && cd /tmp \
    && wget -O shadowsocks-libev.tar.gz $SHADOWSOCKS_LIBEV_RELEASE_URL && mkdir shadowsocks-libev \
    && tar -xvf shadowsocks-libev.tar.gz -C shadowsocks-libev --strip-components 1 \
    && cd shadowsocks-libev \
    && ./configure --prefix=/usr --disable-documentation \
    && make install \
    && apk del .build-deps \
    # Runtime dependencies setup
    && apk add --no-cache \
    rng-tools \
    $(scanelf --needed --nobanner /usr/bin/ss-* \
    | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
    | sort -u) \
    && rm -rf /tmp/*

USER nobody

ENV SERVER      0.0.0.0
ENV PORT        8388
ENV METHOD      aes-256-gcm
ENV PASSWORD	123456
ENV TIMEOUT     300
ENV DNS         8.8.8.8

EXPOSE $PORT/tcp
EXPOSE $PORT/udp

CMD ss-server -s "$SERVER" \
    -p "$PORT" \
    -m "$METHOD"      \
    -k "$PASSWORD"    \
    -t "$TIMEOUT"     \
    -d "$DNS"    \
    -u                \
    --fast-open