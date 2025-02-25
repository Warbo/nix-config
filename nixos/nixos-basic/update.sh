#!/usr/bin/env bash
# Update nixos-basic container using this configuration.nix

# Figure out NixOS path
NIXOS_PATH=$(nix-instantiate --eval --expr '<nixpkgs/nixos>')

# Pass $PATH through to sudo, since root doesn't have our Nix profile
sudo env PATH="$PATH" \
     nixos-container update nixos-basic \
     --config-file configuration.nix \
     --nixos-path "$NIXOS_PATH"
