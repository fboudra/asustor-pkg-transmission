#!/bin/sh

. /etc/script/lib/command.sh

. /lib/lsb/init-functions

APKG_PKG_DIR=/usr/local/AppCentral/transmission

USERNAME=admin

TRANSMISSION_HOME=${APKG_PKG_DIR}/etc
TRANSMISSION_WEB_HOME=${APKG_PKG_DIR}/www
TRANSMISSION_ARGS=""

PATH=${APKG_PKG_DIR}/bin/:${PATH}
DESC="bittorrent client"
NAME=transmission-daemon
DAEMON=$(which $NAME)
PIDFILE=/var/run/$NAME.pid

[ -x "$DAEMON" ] || exit 0

# Avoid the error messages;
#  UDP Failed to set receive buffer
#  UDP Failed to set sent buffer
# Set bigger sent and receive buffer
sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=4194304

do_start() {
    # Export the configuration/web directory, if set
    if [ -n "$TRANSMISSION_HOME" ]; then
          export TRANSMISSION_HOME
    fi
    if [ -n "$TRANSMISSION_WEB_HOME" ]; then
          export TRANSMISSION_WEB_HOME
    fi

    # Return
    #   0 if daemon has been started
    #   1 if daemon was already running
    #   2 if daemon could not be started
    start-stop-daemon --chuid $USERNAME --start --pidfile $PIDFILE --make-pidfile \
            --exec $DAEMON --background --test -- -f $TRANSMISSION_ARGS > /dev/null \
            || return 1
    start-stop-daemon --chuid $USERNAME --start --pidfile $PIDFILE --make-pidfile \
            --exec $DAEMON --background -- -f $TRANSMISSION_ARGS \
            || return 2
}

do_stop() {
        # Return
        #   0 if daemon has been stopped
        #   1 if daemon was already stopped
        #   2 if daemon could not be stopped
        #   other if a failure occurred
        start-stop-daemon --stop --quiet --retry=TERM/10/KILL/5 --pidfile $PIDFILE --exec $DAEMON
        RETVAL="$?"
        [ "$RETVAL" = 2 ] && return 2

        # Wait for children to finish too if this is a daemon that forks
        # and if the daemon is only ever run from this initscript.
        # If the above conditions are not satisfied then add some other code
        # that waits for the process to drop all resources that could be
        # needed by services started subsequently.  A last resort is to
        # sleep for some time.

        start-stop-daemon --stop --quiet --oknodo --retry=0/30/KILL/5 --exec $DAEMON
        [ "$?" = 2 ] && return 2

        # Many daemons don't delete their pidfiles when they exit.
        rm -f $PIDFILE

        return "$RETVAL"
}

case "$1" in
    start)
        echo "Starting $DESC" "$NAME..."
        do_start
        case "$?" in
                0|1) echo "   Starting $DESC $NAME succeeded" ;;
                *)   echo "   Starting $DESC $NAME failed" ;;
        esac
    ;;

    stop)
        echo "Stopping $DESC $NAME..."
        do_stop
        case "$?" in
                0|1) echo "   Stopping $DESC $NAME succeeded" ;;
                *)   echo "   Stopping $DESC $NAME failed" ;;
        esac
    ;;

    *)
        echo "start-stop called with unknown argument \`$1'" >&2
        exit 3
    ;;
esac

exit 0
