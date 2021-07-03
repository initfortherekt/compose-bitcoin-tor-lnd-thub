#!/bin/bash
set -ex

docker-compose down

BITCOIN_IMAGE=$(echo "$(docker images | grep bitcoind |  grep -E -o [0-9a-f]{12})")
LND_IMAGE=$(echo "$(docker images | grep lnd_bitcoin |  grep -E -o [0-9a-f]{12})")
echo "BITCOIN_IMAGE: $BITCOIN_IMAGE"
echo "LND_IMAGE: $LND_IMAGE"

if [[ -n $LND_IMAGE ]]; then
    docker rmi $(docker images | grep lnd_bitcoin |  grep -E -o [0-9a-f]{12})
fi

# if [[ -n $BITCOIN_IMAGE ]]; then
#     docker rmi $(docker images | grep bitcoind |  grep -E -o [0-9a-f]{12})
# fi

docker volume rm compose-bitcoin-tor-lnd-thub_lnd_bitcoin_datadir
docker-compose up

