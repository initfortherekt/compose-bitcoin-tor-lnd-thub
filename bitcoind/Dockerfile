FROM ubuntu:20.04 as verifier

RUN set -e \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates wget gnupg2

ARG BITCOIN_VERSION
ENV BITCOIN_VERSION=$BITCOIN_VERSION

ARG BITCOIN_PLATFORM
ENV BITCOIN_PLATFORM=$BITCOIN_PLATFORM

ARG BITCOIN_URL=https://bitcoincore.org/bin/bitcoin-core-$BITCOIN_VERSION
ARG BITCOIN_RPCAUTH_URL=https://github.com/bitcoin/bitcoin/blob/$BITCOIN_VERSION/share/rpcauth/rpcauth.py

ARG BITCOIN_TARBALL_NAME=bitcoin-$BITCOIN_VERSION-$BITCOIN_PLATFORM.tar.gz
ARG BITCOIN_TARBALL_URL=$BITCOIN_URL/$BITCOIN_TARBALL_NAME
ARG BITCOIN_SIGNATURES=$BITCOIN_URL/SHA256SUMS.asc

ARG BITCOIN_GPG_KEY=01EA5486DE18A882D4C2684590C8019E36C2E964

# install bitcoin binaries
COPY rpcauth.py /tmp
RUN set -ex \
    && echo "BITCOIN_VERSION ARG: $BITCOIN_VERSION" \
    && echo "BITCOIN_PLATFORM ARG: $BITCOIN_PLATFORM" \
    && echo "BITCOIN_SIGNATURES ARG: $BITCOIN_SIGNATURES" \
    && cd /tmp \
	&& wget -q "$BITCOIN_TARBALL_URL" \
	&& wget -q "$BITCOIN_SIGNATURES" \
    && wget -q "$BITCOIN_RPCAUTH_URL" \
    && found=''; \
        for server in \
            ha.pool.sks-keyservers.net \
            hkp://keyserver.ubuntu.com:80 \
            hkp://p80.pool.sks-keyservers.net:80 \
            ipv4.pool.sks-keyservers.net \
            keys.gnupg.net \
       		pgp.mit.edu \
     	; do \
     		echo "Fetching GPG key $BITCOIN_GPG_KEY from $server"; \
     		gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$BITCOIN_GPG_KEY" && found=yes && break; \
     	done; \
     	test -z "$found" && echo >&2 "error: failed to fetch GPG key $BITCOIN_GPG_KEY" && exit 1; \
    gpg --verify SHA256SUMS.asc \
    && sha256sum -c --ignore-missing SHA256SUMS.asc \
    && mkdir -p /tmp/bin \
    && mv rpcauth.py $BITCOIN_TARBALL_NAME /tmp/bin \
    && cd /tmp/bin \
	&& tar -xzvf $BITCOIN_TARBALL_NAME -C /tmp/bin --strip-components=2 "bitcoin-$BITCOIN_VERSION/bin/bitcoin-cli" "bitcoin-$BITCOIN_VERSION/bin/bitcoind" "bitcoin-$BITCOIN_VERSION/bin/bitcoin-wallet" 

FROM ubuntu:20.04
COPY --from=verifier "/tmp/bin" /usr/local/bin
RUN set -e \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates gosu python3 \
    && groupadd -g 1000 -r bitcoin && useradd -r -m -u 1000 -g bitcoin bitcoin

# ENV BITCOIN_NETWORK=mainnet
# ENV BITCOIN_WALLETDIR=/walletdata
# ENV HIDDENSERVICE_NAME=BTC-P2P,BTC-RPC
# ENV BTC-P2P_HIDDENSERVICE_VIRTUAL_PORT=8333
# ENV BTC-P2P_HIDDENSERVICE_PORT=8333
# ENV BTC-RPC_HIDDENSERVICE_VIRTUAL_PORT=8332
# ENV BTC-RPC_HIDDENSERVICE_PORT=8332

COPY bitcoin-entrypoint.sh /entrypoint.sh
COPY bitcoin.conf /bitcoin.conf

RUN set -e \
    && echo "DOCKERFILE: ls output: $(ls)"

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8332 8333 18332 18333 18443 18444
CMD ["bitcoind"]
