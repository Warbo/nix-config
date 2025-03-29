cd "${TEMP:?No TEMP}"

# Build up our output format for xmlstarlet
TEMPLATE=()

# Select all <outline> elements which have an xmlUrl attribute. These form the
# basis of our output (one per line)
TEMPLATE+=('-m' '//outline[@xmlUrl]')

# For each outline-with-an-xmlUrl, find all of its <outline> ancestors
TEMPLATE+=('-m' 'ancestor::outline')

# Output the title attribute of each ancestor, separated by _
TEMPLATE+=('-v' '@title' '-o' '_')

# "Break nesting"; i.e. we're done looping over ancestors
TEMPLATE+=('-b')

# Output details of the outline-with-an-xmlUrl (appearing after its ancestors)
TEMPLATE+=(-v "concat(@title,'.rss+',@xmlUrl)")

# Newline, ready for the next outline-with-an-xmlUrl
TEMPLATE+=('-n')

# Turns OPML data into name+URL lines. We use '+' to separate the name from URL,
# since it survives translation to/from XML (unlike whitespace), and doesn't
# appear in any names.
opmlToLines() {
    xmlstarlet sel --text -t "${TEMPLATE[@]}"
}

# Fix annoyances in OPML data, like spaces and repetition in titles.
clean() {
    tr -d ' ' | sed -e 's/\(_[^_]*\)\1\+/\1/g'
}

fetch() {
    # Some servers block raw 'curl' requests, so say we're Thunderbird
    curl --user-agent 'Mozilla Thunderbird' "$@"
}

mkdir -p "${FETCHED:?No FETCHED}"

< "${OPML:?No OPML}" opmlToLines | clean | shuf | while read -r FEED
do
    NAME=$(basename "$(echo "$FEED" | cut -d+ -f1)")
    URL=$(echo "$FEED" | cut -d+ -f2-)
    if fetch "$URL" > "raw-$NAME"
    then
        mv "raw-$NAME" "${FETCHED:?No FETCHED}/$NAME"
    else
        echo "Skipping '$NAME' due to error" 1>&2
    fi
done
