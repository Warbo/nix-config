#!/usr/bin/env bash
set -e

# Sets up Nix gcroots for repos of Nixlang code our configs may want to read.
# Since that Nixlang code doesn't appear as a dependency of its outputs, the
# garbage collector can remove it; which causes a lot of unnecessary fetching,
# which is avoided by making a root.

X=$(nix-instantiate --eval --read-write-mode \
                    -E 'import home-manager/nixos-import.nix')
X="${X%\"}" X="${X#\"}"  # Strip surrounding "
nix-store --add-root hm-gcroot -r "$X"
