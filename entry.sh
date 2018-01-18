#!/bin/sh

# start cron

/usr/sbin/crond -f -l 8

# check and change IP once
/DNS-Anchor.sh
