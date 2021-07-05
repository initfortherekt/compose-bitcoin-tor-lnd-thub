#!/bin/bash
set -e

if [ -f /bitcoin.conf ]; then
    mkdir -p /data
    mv /bitcoin.conf /data/bitcoin.conf 
fi

chown -R bitcoin:bitcoin /data
ln -sfn /data /home/bitcoin/.bitcoin
chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin

RPCAUTH_BTCRPC_CONFIG_EXISTS="$(grep -c 'rpcauth=btcrpc:' /data/bitcoin.conf)" || true

RPCAUTH_LND_CONFIG_EXISTS="$(grep -c 'rpcauth=lnd:' /data/bitcoin.conf)" || true

if [[ $RPCAUTH_BTCRPC_CONFIG_EXISTS -eq 0 ]]; then
    echo "adding btcrpc rpcauth configuration to bitcoin.conf"
    readarray -t RPC_AUTH_LINES_BTCRPC < <(python3 /usr/local/bin/rpcauth.py btcrpc $RPCAUTH_PASSWORD_FOR_USER_BTCRPC | awk 'NR == 2 || NR == 4')
    printf "${RPC_AUTH_LINES_BTCRPC[0]}\n# password: ${RPC_AUTH_LINES_BTCRPC[1]}\n" >> "/data/bitcoin.conf"
fi

if [[ $RPCAUTH_LND_CONFIG_EXISTS -eq 0 ]]; then
    echo "adding lnd rpcauth configuration to bitcoin.conf"
    readarray -t RPC_AUTH_LINES_LND < <(python3 /usr/local/bin/rpcauth.py lnd $RPCAUTH_PASSWORD_FOR_USER_LND | awk 'NR == 2 || NR == 4')
    printf "${RPC_AUTH_LINES_LND[0]}\n# password: ${RPC_AUTH_LINES_LND[1]}\n" >> "/data/bitcoin.conf"
fi

echo "Finished bitcoin.conf RPCauth configuration"

exec gosu bitcoin "$@"
