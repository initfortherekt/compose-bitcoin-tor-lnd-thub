#!/bin/bash
set -e

mkdir -p /data
mv /bitcoin.conf /data/bitcoin.conf  

chown -R bitcoin:bitcoin /data
ln -sfn /data /home/bitcoin/.bitcoin 
chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin

# if [[ "$BITCOIN_WALLETDIR" ]] && [[ "$BITCOIN_NETWORK" ]]; then
# 	WALLETDIR="$BITCOIN_WALLETDIR/${BITCOIN_NETWORK}"
# 	WALLETFILE="${WALLETDIR}/wallet.dat"
# 	mkdir -p "$WALLETDIR"	
# 	chown -R bitcoin:bitcoin "$WALLETDIR"
# 	if ! [[ -f "${WALLETFILE}" ]]; then
# 	  echo "The wallet does not exists, creating it at ${WALLETDIR}..."
# 	  gosu bitcoin bitcoin-wallet "-datadir=${WALLETDIR}" "-wallet=" create
# 	fi
# fi

exec gosu bitcoin "$@"

