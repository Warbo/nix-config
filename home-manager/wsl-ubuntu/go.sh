#!/usr/bin/env bash

[[ "$PWD" = "$HOME" ]] || {
    echo "Going $HOME" 1>&2
    cd
}
grep -q SWAP < /proc/swaps || {
    echo "Activating $PWD/SWAP" 1>&2
    sudo swapon SWAP
}

# VPN may add an extraneous route which hides our LAN. Remove it if found.
{
  ip route |
    grep '192\.168\.0\.' |
    grep 'via' |
    grep -v '^default' |
    cut -d' ' -f1-3 || true
} | while read -r ROUTE
    do
        echo "Removing route $ROUTE so we can access LAN" 1>&2
        # shellcheck disable=SC2086
        sudo ip route del $ROUTE
    done
ping -w5 -c1 192.168.0.1 || {
    echo "Couldn't ping local network. Fix routing table, and update $0!"
    exit 1
} 1>&2
ping -w5 -c1 google.com || {
    echo "Couldn't ping Google. Fix routing table, and update $0!"
    exit 1
}

exec screen -DR
