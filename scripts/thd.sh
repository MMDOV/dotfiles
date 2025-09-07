#!/bin/bash
while true; do
    while [ ! -e /dev/input/event26 ]; do
        sleep 1
    done

    /usr/sbin/thd --triggers ~/.config/triggerhappy/triggers.d/ --deviceglob /dev/input/event*

    sleep 1
done
