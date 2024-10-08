#!/usr/bin/env bash
set -e

# Simple, quick sanity check. Useful as a git pre-commit hook.
CODE=0
while read -r F
do
    [[ -n "$DEBUG" ]] && echo "Checking '$F'" 1>&2
    nix-instantiate --parse "$F" > /dev/null || CODE=1
    if command -v nixfmt > /dev/null
    then
        if ! nixfmt -w 80 -c "$F"
        then
            CODE=1
            if [[ -n "$REFORMAT" ]]
            then
                nixfmt -w 80 "$F"
            else
                echo "(Set REFORMAT=1 to auto-format)" 1>&2
            fi
        fi
    fi
done < <(find . -name "*.nix")

# Fail if checks don't pass
EXPR='(import ./nix).nix-config-check || abort "Checks failed"'
nix-instantiate --show-trace --read-write-mode --eval -E "$EXPR" > /dev/null ||
    CODE=1

exit "$CODE"
