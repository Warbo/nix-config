#!/usr/bin/env bash
# Update nixos-basic container using this configuration.nix
set -e

NIXOS_PATH=$(nix-instantiate --eval --expr '<nixpkgs/nixos>')

# Relies on our nixos-container wrapper, which calls sudo and propagates a
# bunch of env vars!
nixos-container update nixos-basic \
                --config-file configuration.nix \
                --nixos-path "$NIXOS_PATH"
