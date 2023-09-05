FROM alpine:3.18

ARG CONVOY_VERSION=v0.5.2

RUN apk add --no-cache openssl

WORKDIR /tmp

RUN <<EOF
    set -eux -o pipefail
    wget -qO- https://github.com/rancher/convoy/releases/download/${CONVOY_VERSION}/convoy.tar.gz |
        tar xvz
    sha1sum -c */SHA1SUMS | cut -d: -f1 | xargs -II mv I /usr/local/bin
    find . -delete -mindepth 1
EOF

COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]
