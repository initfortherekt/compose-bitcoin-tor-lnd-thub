FROM debian:buster-slim as builder

RUN set -e \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates wget gnupg2 \
	&& rm /bin/sh && ln -s /bin/bash /bin/sh

ENV LND_PLATFORM=linux-amd64
ENV LND_VERSION=v0.13.0-beta

ENV LND_DOWNLOAD_PREFIX_URL=https://github.com/lightningnetwork/lnd/releases/download/$LND_VERSION

ENV LND_TARBALL_PREFIX=lnd-$LND_PLATFORM-$LND_VERSION
ENV LND_URL=$LND_DOWNLOAD_PREFIX_URL/$LND_TARBALL_PREFIX.tar.gz
ENV LND_MANIFEST_URL=$LND_DOWNLOAD_PREFIX_URL/manifest-$LND_VERSION.txt
ENV LND_MANIFEST_SIG_URL=$LND_DOWNLOAD_PREFIX_URL/manifest-\$pgp_key-$LND_VERSION.sig

RUN set -e \
	&& declare -a SIGNERS \
	&& SIGNERS=( "roasbeef" "carlakirkcohen" "guggero" "eugene_" "halseth" ) \
        && wget -q "$LND_URL" \
        && wget -qO lnd-manifest.txt "$LND_MANIFEST_URL" \
        && verified=''; \
		for pgp_key in "${SIGNERS[@]}" \
		; do \
                        echo "Verifying manifest signature against $pgp_key's key" \  
			&& manifest_sig_url=$(eval "echo wget -qO lnd-manifest.txt.sig $LND_MANIFEST_SIG_URL") \
			&& eval "$manifest_sig_url" \
                        && wget -qO $pgp_key.pub.asc https://keybase.io/$pgp_key/pgp_keys.asc \
                        && gpg --import $pgp_key.pub.asc 2> /dev/null \
                        && gpg --verify lnd-manifest.txt.sig 2> /dev/null \
                        && verified=yes \
                        && break; \
                done; \
                rm lnd-manifest.txt.sig && rm *.pub.asc \
		&& test -z "$verified" && echo exit 1; \

	echo "Successfully completed validation of signatures" \
        && grep lnd-$LND_PLATFORM-$LND_VERSION.tar.gz lnd-manifest.txt | sha256sum -c - \
        && tar -xvzf $LND_TARBALL_PREFIX.tar.gz \
        && grep "$LND_TARBALL_PREFIX/lncli" lnd-manifest.txt | sha256sum -c - \
        && grep "$LND_TARBALL_PREFIX/lnd" lnd-manifest.txt | sha256sum -c - 

# ENTRYPOINT ["bash"]
