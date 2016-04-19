#!/bin/sh

. /etc/script/lib/command.sh

. /lib/lsb/init-functions

APKG_PKG_DIR=/usr/local/AppCentral/transmission

PATH=${APKG_PKG_DIR}/bin/:${PATH}
DAEMON=transmission-daemon

TRANSMISSION_HOME=${APKG_PKG_DIR}/etc
TRANSMISSION_WEB_HOME=${APKG_PKG_DIR}/www

# Avoid the error messages;
#  UDP Failed to set receive buffer
#  UDP Failed to set sent buffer
# Set bigger sent and receive buffer
${AS_SYSCTL} -w net.core.rmem_max=16777216
${AS_SYSCTL} -w net.core.wmem_max=4194304

case "$1" in
    start)
    ;;

    stop)
    ;;

    *)
        echo "start-stop called with unknown argument \`$1'" >&2
        exit 1
    ;;
esac

exit 0
