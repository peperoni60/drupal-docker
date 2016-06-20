#!/usr/bin/env bash
# set umask for root to make the files created by node/npm be editable by all
# and then call node
umask 000
"${@}"