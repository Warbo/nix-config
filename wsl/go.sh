#!/usr/bin/env bash

[[ "$PWD" = "$HOME" ]] || {
    echo "Going $HOME" 1>&2
    cd
}
if [[ -e SWAP ]]
then
    grep -q SWAP < /proc/swaps || {
        echo "Activating $PWD/SWAP" 1>&2
        sudo swapon SWAP
    }
fi

"${LAN:?No LAN script}/bin/lan" || true
ping -w5 -c1 192.168.0.1 || {
    echo "Couldn't ping local network. Fix routing table, and update $0!"
    exit 1
} 1>&2
ping -w5 -c1 google.com || {
    echo "Couldn't ping Google. Fix routing table, and update $0!"
    exit 1
}

exec screen -DR
