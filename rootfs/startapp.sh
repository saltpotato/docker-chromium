#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

export HOME=/config

PIDS=

notify() {
    for N in $(ls /etc/logmonitor/targets.d/*/send)
    do
       "$N" "$1" "$2" "$3" &
       PIDS="$PIDS $!"
    done
}

# Verify support for membarrier.
if ! /usr/bin/membarrier_check 2>/dev/null; then
   notify "$APP_NAME requires the membarrier system call." "$APP_NAME is likely to crash because it requires the membarrier system call.  See the documentation of this Docker container to find out how this system call can be allowed." "WARNING"
fi

# Wait for all PIDs to terminate.
set +e
for PID in "$PIDS"; do
   wait $PID
done
set -e

/usr/bin/chromium-browser --version

# remove lock file (chromium locks the profile dir occasionally
# after an unclean shutdown)
# otherwise it will refuse to start
rm -f /config/profile/SingletonLock

#to get rid of net::ERR_INSUFFICIENT_RESOURCES errors
# --> --disable-dev-shm-usage

exec /usr/bin/chromium-browser \
 --user-data-dir=/config/profile \
 --start-maximized \
 --disable-dev-shm-usage \
 "$CHROMIUM_CUSTOM_ARGS" \
 "$@" >> /config/log/chromium/output.log 2>> /config/log/chromium/error.log