FOUND=()
for XML in "${PROCESSED:?PROCESSED dir not specified}"/*
do
    FOUND+=("$XML")
done

toMaildir() {
    DEST="${MAILDIR:?MAILDIR not specified}/$1"
    mkdir -p "$DEST"
    feed2maildir -n "$1" -m "$DEST"
}

for XML in "${FOUND[@]}"
do
    NAME=$(basename "$XML" .rss)
    if toMaildir "$NAME" < "$XML"
    then
        rm -f "$XML"
    else
        echo "Error converting '$NAME'" 1>&2
    fi
done
sleep 10
