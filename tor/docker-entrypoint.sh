#!/bin/sh
set -e

mkdir -p "$(dirname $TOR_CONFIG)"

mkdir -p "$TOR_DATA"
chown -R tor "$TOR_DATA"
chmod 700 "$TOR_DATA"

mkdir -p "/var/lib/tor/hidden_services"
chown -R tor /var/lib/tor/hidden_services
chmod 700 /var/lib/tor/hidden_services

chown -R tor "$(dirname $TOR_CONFIG)"

if ! [ -z "${TOR_PASSWORD}" ]; then
    TOR_PASSWORD_HASH="$(gosu tor tor --hash-password "$TOR_PASSWORD")"
    echo "HashedControlPassword $TOR_PASSWORD_HASH" >> "$TOR_CONFIG"
    echo "'HashedControlPassword $TOR_PASSWORD_HASH' added to tor config"
fi

exec gosu tor "$@"
