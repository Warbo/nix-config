#!/usr/bin/env bash
set -e

# Simple, quick sanity check. Useful as a git pre-commit hook.
find . -name "*.nix" | while read -r F
do
    echo "Checking '$F'" 1>&2
    nix-instantiate --parse "$F" > /dev/null
done

REPO="warbo-utilities"
echo "Checking $REPO version" 1>&2

# Allow failure to get HEAD (e.g. in case we're offline)
if REV=$(git ls-remote "http://chriswarbo.net/git/$REPO.git" |
             grep HEAD | cut -d ' ' -f1 | cut -c1-7)
then
    grep "$REV" < helpers.nix || {
        echo "Didn't find $REPO rev '$REV' in helpers.nix" 1>&2
        exit 1
    }
    echo "Checking $REPO in helpers.nix builds (e.g. for SHA256)" 1>&2
    nix-build --no-out-link -A "$REPO" helpers.nix || exit 1
fi
