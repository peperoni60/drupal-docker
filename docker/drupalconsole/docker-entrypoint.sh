#!/usr/bin/env bash
# set umask for root to make the files created by drupal console be editable by all
# and then call the drupal console
umask 000
drupal "${@}"