# Combine the contents of `local` (from imports/local.nix) with the rest of the
# overrides
with import <nixpkgs> {};

pkgs: local pkgs
