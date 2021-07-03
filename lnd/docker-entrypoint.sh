#!/bin/bash 
set -x

#mkdir -p "$LND_DATA"

# removing noseedbackup=1 flag, adding it below if needed for legacy
# /var/lib/tor/hidden_services/lnd


echo "***** settting HIDDENSERVICE_ONION *****"
HIDDENSERVICE_ONION="$(head -n 1 "/var/lib/tor/hidden_services/lnd/hostname"):9735"
ONION_CONFIG_EXISTS="$(grep -c '.onion:9735' /data/lnd.conf)"

if [[ $ONION_CONFIG_EXISTS -eq 0 ]]; then
    echo "adding external ip configuration to lnd.conf for $HIDDENSERVICE_ONION"
    echo "externalip=$HIDDENSERVICE_ONION" >> "/data/lnd.conf"
fi

ln -sfn "$LND_DATA" /root/.lnd
ln -sfn "$LND_BITCOIND" /root/.bitcoin

exec "lnd"
