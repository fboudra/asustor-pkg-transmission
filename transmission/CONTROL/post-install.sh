#!/bin/sh
# post-install script for transmission

set -e

APKG_PKG_DIR=/usr/local/AppCentral/transmission

rpc_whitelist() {
    # Attempt to get IP address from eth0 then from bond0 and fallback to localhost
    export AS_NAS_INET4_ADDR_BOND0=$(ip -4 addr show bond0 | awk '/inet / {gsub(/\/.*/,"",$2); print $2}')

    if [ "${AS_NAS_INET4_ADDR_0}" != "" ]; then
        sed -i "s|@AS_NAS_INET4_ADDR@|${AS_NAS_INET4_ADDR_0%.*}.*|" ${APKG_PKG_DIR}/etc/settings.json
    elif [ "${AS_NAS_INET4_ADDR_BOND0}" != "" ]; then
        sed -i "s|@AS_NAS_INET4_ADDR@|${AS_NAS_INET4_ADDR_BOND0%.*}.*|" ${APKG_PKG_DIR}/etc/settings.json
    else
        sed -i "s|\,@AS_NAS_INET4_ADDR@||" ${APKG_PKG_DIR}/etc/settings.json
    fi
}

case "$APKG_PKG_STATUS" in
    install)
        rpc_whitelist
    ;;

    upgrade)
    ;;

    *)
        echo "post-install called with unknown argument \`$1'" >&2
        exit 1
    ;;
esac

exit 0
