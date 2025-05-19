#!/usr/bin/env bash
# Update nixos-basic container using this configuration.nix

# Figure out NixOS path
NIXOS_PATH=$(nix-instantiate --eval --expr '<nixpkgs/nixos>')

# Pass $PATH through to sudo, since root doesn't have our Nix profile
# Also pass SSH_AUTH_SOCK, since root's SSH access is different to our user's
sudo env PATH="$PATH" SSH_AUTH_SOCK="$SSH_AUTH_SOCK" NIX_PATH="$NIX_PATH" \
     nixos-container update nixos-basic \
     --config-file configuration.nix \
     --nixos-path "$NIXOS_PATH"
