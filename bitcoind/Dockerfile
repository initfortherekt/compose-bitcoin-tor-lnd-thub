FROM debian:buster-slim as builder

RUN set -e \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu wget

ENV BITCOIN_VERSION=0.21.1
ENV BITCOIN_URL=https://bitcoincore.org/bin/bitcoin-core-0.21.1/bitcoin-0.21.1-x86_64-linux-gnu.tar.gz
ENV BITCOIN_SHA256=366eb44a7a0aa5bd342deea215ec19a184a11f2ca22220304ebb20b9c8917e2b


# install bitcoin binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO bitcoin.tar.gz "$BITCOIN_URL" \
	&& echo "$BITCOIN_SHA256 bitcoin.tar.gz" | sha256sum -c - \
	&& mkdir bin \
	&& tar -xzvf bitcoin.tar.gz -C /tmp/bin --strip-components=2 "bitcoin-$BITCOIN_VERSION/bin/bitcoin-cli" "bitcoin-$BITCOIN_VERSION/bin/bitcoind" "bitcoin-$BITCOIN_VERSION/bin/bitcoin-wallet" \
	&& cd bin \
	&& wget -qO gosu "https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64" \
	&& echo "0b843df6d86e270c5b0f5cbd3c326a04e18f4b7f9b8457fa497b0454c4b138d7 gosu" | sha256sum -c -

# FROM python as rpc_generator
# COPY bitcoin.conf /tmp/bitcoin.conf
# RUN cd /tmp \
# 	&& wget -qO rpcauth.py https://raw.githubusercontent.com/bitcoin/bitcoin/0.21/share/rpcauth/rpcauth.py \
# 	&& apt-get update \
# 	&& apt-get install -qq --no-install-recommends diceware \
# 	&& sed -i '/rpcuser=lnd/,+3d' ./bitcoin.conf \
# 	&& RPCLNDAUTH=$(python ./rpcauth.py lnd $(diceware -n 5 -d- --no-caps)) \
# 	&& RPCLNDPASS=$(echo "$RPCLNDAUTH" | tail -n 1) \ 
# 	&& RPCLNDAUTH=$(echo "$RPCLNDAUTH" | grep rpcauth) \
# 	&& echo "# lnd RPC password: $RPCLNDPASS" >> bitcoin.conf \
# 	&& echo $RPCLNDAUTH >> bitcoin.conf \
# 	&& cat bitcoin.conf
	


FROM debian:buster-slim
COPY --from=builder "/tmp/bin" /usr/local/bin

RUN chmod +x /usr/local/bin/gosu && groupadd -g 1000 -r bitcoin && useradd -r -m -u 1000 -g bitcoin bitcoin

ENV BITCOIN_NETWORK=mainnet
ENV BITCOIN_WALLETDIR=/walletdata
ENV HIDDENSERVICE_NAME=BTC-P2P,BTC-RPC
ENV BTC-P2P_HIDDENSERVICE_VIRTUAL_PORT=8333
ENV BTC-P2P_HIDDENSERVICE_PORT=8333
ENV BTC-RPC_HIDDENSERVICE_VIRTUAL_PORT=8332
ENV BTC-RPC_HIDDENSERVICE_PORT=8332

COPY bitcoin-entrypoint.sh /entrypoint.sh
COPY bitcoin.conf /bitcoin.conf

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8332 8333 18332 18333 18443 18444
CMD ["bitcoind"]
