#!/usr/bin/env bash
set -e
mkdir -p "$TEMP"

# Read all feeds up-front to reduce chance of catching it mid-edit
# We'll fetch them in a random order, in case one causes breakage.
ALL_FEEDS=$(shuf < "$FEEDS")

while read -r LINE
do
  FORMAT=$(echo "$LINE" | cut -f1)

  # Only handle 'youtube' for now; allows new types to be added.
  [[ "$FORMAT" = "youtube" ]] || continue

  NAME=$(echo "$LINE" | cut -f2)
  URL=$(echo "$LINE" | cut -f3)
  echo "Processing $LINE" 1>&2

  # Video IDs will go in here
  mkdir -p "$TODO"
  mkdir -p "$DONE"

  # Extract URLs immediately; no point storing feed itself
  while read -u 3 -r VURL
  do
    VID=$(echo "$VURL" | cut -d= -f2)
    [[ -e "$DONE/$VID" ]] || {
      # Write atomically to TODO
      T="$TEMP/$VID"
      mkdir -p "$T"
      echo "$VURL" > "$T/$NAME"
      mv -v "$T" "$TODO/"
    }
  done 3< <(curl "$URL" |
    grep -o 'https://www.youtube.com/watch?v=[^<>" &]*')
done < <(echo "$ALL_FEEDS")
true
