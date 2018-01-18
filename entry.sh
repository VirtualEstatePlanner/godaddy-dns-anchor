#!/bin/sh

# start cron
/DNS-Anchor.sh
/usr/sbin/crond -f -l 8
