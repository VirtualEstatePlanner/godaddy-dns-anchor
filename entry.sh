#!/bin/sh

#check current IP and correct if necessary

/godaddy-dns-anchor.sh


# start cron

/usr/sbin/crond -f -l 8
