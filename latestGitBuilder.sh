source $stdenv/setup

printf "%s" $(git ls-remote "$url" | grep HEAD | sed -e 's/\s.*//g') > "$out"
