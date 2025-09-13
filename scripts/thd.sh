#!/bin/bash
CMD="/usr/sbin/thd --triggers $HOME/.config/triggerhappy/triggers.d/ --deviceglob /dev/input/event*"

COUNT=0
while true; do
    NEWCOUNT=$(ls /dev/input/event* 2>/dev/null | wc -l)
    if [[ $NEWCOUNT -ne $COUNT ]]; then
        echo "Device count changed, restarting thd..."
        pkill -x thd
        $CMD &
        COUNT=$NEWCOUNT
    fi
    sleep 1
done
