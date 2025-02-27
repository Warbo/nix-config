#!/usr/bin/env bash
set -e

[[ -d "$DEST" ]] || {
    cat /proc/mounts
    echo "Destination '$DEST' not found"
} 1>&2

ls -1 "$FETCHED" | shuf | while read -r D
do
    DIR="$FETCHED/$D"
    rm -f "$DIR"/stderr "$DIR"/stdout "$DIR"/success
    for INNER in "$DIR"/*
    do
        [[ -d "$INNER" ]] || continue
        "$RSYNC" -r --remove-source-files --progress "$INNER" "$DEST"/
        rmdir "$INNER" || true
    done
    rmdir "$DIR" || true
done
