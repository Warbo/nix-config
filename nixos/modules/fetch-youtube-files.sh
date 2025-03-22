#!/usr/bin/env bash
set -e
mkdir -p "$FETCHED"

while true
do
  # Run find to completion before changing anything in todo
  FILES=$(find "$TODO" -type f | shuf)

  # Stop if nothing more was found
  echo "$FILES" | grep -q '^.' || break

  while read -r F
  do
    # Extract details
    URL=$(cat "$F")
    VID=$(basename "$(dirname "$F")")
    NAME=$(basename "$F")
    DONE="$DONE_BASE/$NAME"

    # Set up a temp dir to work in. The name is based on the VID; so
    # we can tell if this entry has been attempted before.
    T="$TEMP/fetch-$VID"
    if [[ -e "$T" ]]
    then
      echo "Skipping $VID as $T already exists (prev. failure?)" >&2
      continue
    fi

    # If this hasn't been attempted yet, make a working dir inside
    # the temp dir, named after the destination directory (making it
    # easier to move atomically without overlaps). Metadata is kept
    # in the temp dir, so we can tell what happened.
    mkdir -p "$T/$NAME"
    pushd "$T/$NAME"
      if "$CMD" "$URL" 1> >(tee ../stdout) 2> >(tee ../stderr 1>&2)
      then
        touch ../success
      else
        if [[ -e ../stderr ]] &&
           grep -q 'nsig extraction failed' < ../stderr
        then
            echo 'Found nsig extraction failure (API breakage?)' 1>&2
        else
          if [[ -e ../stderr ]] &&
             grep -q 'Requested format is not available' < ../stderr
          then
            echo 'Desired format not available (youtube short?); skipping' 1>&2
            touch ../unavailable
          fi
        fi
      fi
    popd

    # If the fetch succeeded, move the result atomically to fetched
    # and move the VID from todo to done
    if [[ -e "$T/success" ]]
    then
      mv "$T" "$FETCHED/"
      mkdir -p "$DONE"
      mv "$F" "$DONE/$VID"
      rmdir "$(dirname "$F")"
    fi

    # If the video isn't available, move the VID from todo to done
    if [[ -e "$T/unavailable" ]]
    then
        mv "$F" "$DONE/$VID"
        rmdir "$(dirname "$F")"
      # Clean up expected files. Use rmdir rather than 'rm -r' to avoid deleting
      # unexpected data, like partial downloads that could maybe be resumed.
      rm -f "$T/stdout" "$T/stderr" "$T/unavailable"
      rmdir "$T/$NAME"
      rmdir "$T"
    fi
    sleep 10 # Slight delay to cut down on spam
  done < <(echo "$FILES")

  sleep 10  # Slight delay to cut down on spam
done
true
