#!/usr/bin/env bash
set -e
# VPN may add an extraneous route which hides our LAN. Remove it if found.
{
    ip route |
        grep '192\.168\.0\.' |
        grep 'via' |
        grep -v '^default' |
        cut -d' ' -f1-3 || true;
} | while read -r ROUTE
do
    echo "Removing route $ROUTE so we can access LAN" 1>&2
    # shellcheck disable=SC2086
    sudo ip route del $ROUTE
done
