#!/usr/bin/env bash
set -e

# Simple, quick sanity check. Useful as a git pre-commit hook.
find . -name "*.nix" | while read -r F
do
    echo "Checking '$F'" 1>&2
    nix-instantiate --parse "$F" > /dev/null
done

# Fail if checks don't pass
EXPR='(import ./nix).nix-config-check || abort "Checks failed"'
nix-instantiate --read-write-mode --eval -E "$EXPR" > /dev/null

for P in firefoxBinary
do
    echo "Checking if $P warns about being out of date" 1>&2
    echo "with import <nixpkgs> { overlays = import ./overlays.nix; }; $P" |
        nix repl
done
