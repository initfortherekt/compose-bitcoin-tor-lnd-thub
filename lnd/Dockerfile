FROM debian:buster-slim as builder

RUN set -e \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates wget gnupg2

ENV LND_PLATFORM=linux-amd64
ENV LND_VERSION=v0.13.0-beta

ENV LND_DOWNLOAD_PREFIX_URL=https://github.com/lightningnetwork/lnd/releases/download/$LND_VERSION

ENV LND_TARBALL_PREFIX=lnd-$LND_PLATFORM-$LND_VERSION
ENV LND_URL=$LND_DOWNLOAD_PREFIX_URL/$LND_TARBALL_PREFIX.tar.gz
ENV LND_MANIFEST_URL=$LND_DOWNLOAD_PREFIX_URL/manifest-$LND_VERSION.txt
ENV LND_MANIFEST_SIG_URL=$LND_DOWNLOAD_PREFIX_URL/manifest-\$pgp_key-$LND_VERSION.sig

ENV PGP_ROASBEEF=roasbeef
ENV PGP_CARLAKIRKCOHEN=carlakirkcohen
ENV PGP_GUGGERO=guggero
ENV PGP_EUGENE=eugene_
ENV PGP_HALSETH=halseth

RUN set -e \
        && wget "$LND_URL" \
        && wget -O lnd-manifest.txt "$LND_MANIFEST_URL" \
        && found=''; \
		for pgp_key in $PGP_ROASBEEF $PGP_CARLAKIRKCOHEN $PGP_GUGGERO $PGP_EUGENE $PGP_HALSETH \
		; do \
                        echo "Verifying manifest signature against $pgp_key's key" \  
			&& manifest_sig_url=$(eval "echo wget -qO lnd-manifest.txt.sig $LND_MANIFEST_SIG_URL") \
			&& echo $manifest_sig_url \
			&& eval "$manifest_sig_url" \
                        && wget -O $pgp_key.pub.asc https://keybase.io/$pgp_key/pgp_keys.asc \
                        && gpg --import $pgp_key.pub.asc \
                        && gpg --verify lnd-manifest.txt.sig 2> /dev/null \
                        && found=yes \
                        && break; \
                done; \
                rm lnd-manifest.txt.sig && rm *.pub.asc \
		&& test -z "$found" && echo exit 1; \

	echo "Successfully completed validation of signatures" \
        && grep lnd-$LND_PLATFORM-$LND_VERSION.tar.gz lnd-manifest.txt | sha256sum -c - \
        && tar -xvzf $LND_TARBALL_PREFIX.tar.gz \
        && grep "$LND_TARBALL_PREFIX/lncli" lnd-manifest.txt | sha256sum -c - \
        && grep "$LND_TARBALL_PREFIX/lnd" lnd-manifest.txt | sha256sum -c - 

# ENTRYPOINT ["bash"]
