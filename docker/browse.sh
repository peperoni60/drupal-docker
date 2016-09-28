#!/usr/bin/env bash

. functions

# open specified url in the preferred browser
if [ "${1}" ] ; then
    url="${1}"
else
    url="http://$WWW_DOMAIN/"
fi
[[ -x $BROWSER ]] && exec "$BROWSER" "${url}"
path=$(which xdg-open || which kde-open || which gnome-open) &&  $path "${url}" && exit
echo "Can't find browser"
