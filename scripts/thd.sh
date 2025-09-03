#!/bin/bash
/usr/bin/steam -silent "$@" &
/usr/sbin/thd --triggers ~/.config/triggerhappy/triggers.d/ --deviceglob /dev/input/event*
