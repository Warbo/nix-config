# Use morss to "unsummarise" RSS/ATOM feeds. This may perform lots of HTTP
# requests, so we deliberately slow it down to avoid hammering servers.

cd "${TEMP:?No TEMP dir specified}"

unsummarise() {
    python3 "${UNSUMMARISE?UNSUMMARISE script not specified}"
}

FOUND=()
for RAW in "${FETCHED:?No FETCHED dir specified}"/*
do
    FOUND+=("$RAW")
done

for RAW in "${FOUND[@]}"
do
    # This may do a HTTP request for every item in a feed
    mkdir -p "${PROCESSED:?No PROCESSED dir specified}"
    NAME=$(basename "$RAW")
    if unsummarise < "$RAW" > processed-"$NAME"
    then
        mv "processed-$NAME" "$PROCESSED/$NAME" && rm -f "$RAW"
    else
        echo "Skipping '$NAME' due to error" 1>&2
    fi
    sleep 60  # Wait between feeds, in case the next one is on the same server
done
sleep 3600  # Wait after fetching all feeds, in case any got stuck
