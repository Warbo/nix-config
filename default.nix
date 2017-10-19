{ pkgFunc ? import <nixpkgs> }:

builtins.trace "FIXME: Make nix-config's default.nix take nixpkgs and output a set of our custom pkgs"
  (pkgFunc { config = import ./config.nix; })
