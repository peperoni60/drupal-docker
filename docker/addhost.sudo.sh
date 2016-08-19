#!/usr/bin/env bash
# Script to add/remove the project's hosts to/from /etc/hosts
# If a host's IP is empty, it's entry is removed from /etc/hosts
# *************************************
# * This script must be run as sudo!  *
# *************************************

. environment > /dev/null

echo "SUBDOMAINS=$SUBDOMAINS"
hostsnew=..hosts
hosts=/etc/hosts
cat $hosts > ${hostsnew}
rm ${hostsnew}.tmp 2> /dev/null
typeset -u prefix
for prefix in $SUBDOMAINS
do
    domain=${prefix}_DOMAIN
    ip=${prefix}_IP
    if [ ! -z "${!domain}" ]
        then
        grep -v "${!domain}" ${hostsnew} > ${hostsnew}.tmp
        mv ${hostsnew}.tmp ${hostsnew}
        if [ ! -z "${!ip}" ]
            then
            echo "${!ip}" "${!domain}" >> ${hostsnew}
        fi
    fi
done

cat $hosts > ${hosts}.backup
cat $hostsnew > $hosts
rm $hostsnew

echo "New $hosts file:"
cat $hosts


