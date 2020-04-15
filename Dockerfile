FROM ubuntu:18.04

ARG VERSION=master

ENV HOME /safenode
WORKDIR /safenode

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libgomp1 \
      pkg-config \
      m4 \
      autoconf \
      libtool \
      automake \
      curl \
      ca-certificates && \
    curl -L https://github.com/Fair-Exchange/safecoin/archive/$VERSION.tar.gz | tar xz --strip-components=1 && \
    CONFIGURE_FLAGS="--disable-man --disable-zmq" CXXFLAGS="-Os -ffunction-sections -fdata-sections -Wl,--gc-sections" ./zcutil/build.sh --disable-tests -j$(nproc) && \
    strip -s -R .comment ./src/safecoind && strip -s -R .comment ./src/safecoin-cli && \
    apt-get purge -y \
      build-essential \
      pkg-config \
      m4 \
      autoconf \
      libtool \
      automake && \
    apt-get -y autoremove && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/* && \
    mv ./src/safecoind /usr/bin/safecoind && \
    mv ./src/safecoin-cli /usr/bin/safecoin-cli && \
    mv ./zcutil/fetch-params.sh /usr/bin/fetch-params.sh && \
    rm -rf .[!.]* ..?* *

COPY setup-safenode.sh /usr/bin/setup-safenode.sh
COPY docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

CMD ["docker-entrypoint.sh"]