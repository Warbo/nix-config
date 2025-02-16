#!/usr/bin/env bash
set -e
shopt -s nullglob

[[ -d "$DEST" ]] || {
    cat /proc/mounts
    echo "Destination '$DEST' not found"
} 1>&2

# As long as doneFile exists, we'll be re-run by SystemD over and over; until it
# kills us for restarting too often. Avoid that by looping ourselves.
# The outer loop emulates a do-while, since the body lives in the condition, it
# will always execute at least once.
while
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
        [[ -e "$doneFile" ]] && rmdir "$DIR"
    done
    sleep 5
    ! [[ -e "$doneFile" ]]  # The "real" condition, to see if we'll loop or not
do :
done
