#!/usr/bin/env bash
set -e

# Sets up Nix gcroots for repos of Nixlang code our configs may want to read.
# Since that Nixlang code doesn't appear as a dependency of its outputs, the
# garbage collector can remove it; which causes a lot of unnecessary fetching,
# which is avoided by making a root.

mkRoot() {
    X=$(nix-instantiate --eval --read-write-mode -E "$1")
    X="${X%\"}" X="${X#\"}"  # Strip surrounding "
    nix-store --add-root "$2" -r "$X"
}
mkRoot 'import home-manager/nixos-import.nix' 'hm-gcroot'
mkRoot '(import ./nix).path' 'nixpkgs-gcroot'
