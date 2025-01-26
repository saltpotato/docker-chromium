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

/usr/bin/chromium-browser --version

# # Wait for all PIDs to terminate.
# set +e
# for PID in $PIDS $node_pid $db_pid; do
#    wait $PID
# done
# set -e

# rm SingleTonLock
rm -f /config/profile/SingletonLock

exec /usr/bin/chromium-browser \
 --no-sandbox \
 --user-data-dir=/config/profile \
 --incognito \
 --start-maximized \
 "$@" >> /config/log/chromium/output.log 2>> /config/log/chromium/error.log