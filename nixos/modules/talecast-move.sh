#!/usr/bin/env bash
set -e

[[ -d "$DEST" ]] || {
    cat /proc/mounts
    echo "Destination '$DEST' not found"
} 1>&2

ls -1 "$FETCHED" | shuf | while read -r D
do
    DIR="$FETCHED/$D"
    for F in "$DIR"/*
    do
        [[ -f "$F" ]] || continue
        mkdir -p "$DEST/$D"
        rsync -r --remove-source-files --progress "$F" "$DEST/$D/"
        sleep 1
    done
    rmdir "$DIR" || true
    sleep 1
done
sleep 5
