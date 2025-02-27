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

if [[ -e "$CONTAINERS_UNIT" ]] && [[ "$(lsb_release -is)" = "Ubuntu" ]]
then
    # If we're on Ubuntu, tell SystemD how to run a nixos-container
    sudo ln -sfn "$CONTAINERS_UNIT" '/etc/systemd/system/container@.service'
    sudo systemctl daemon-reload

    # Then start our NixOS containers
    (
        shopt -s nullglob
        for MACHINE in /etc/nixos-containers/*
        do
            MACHINE_NAME=$(basename "$MACHINE")
            MACHINE_NAME="${MACHINE_NAME/.conf/}"
            sudo env PATH="$PATH" nixos-container start "$MACHINE_NAME"
        done
    )
fi

F_DIR=/mnt/wslg/distro/usr/share/fonts/X11/jmk
if [[ -e "$F_DIR" ]]
then
    xset fp+ "$F_DIR" || true
    xset fp rehash || true
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
