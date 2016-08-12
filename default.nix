{ pkgFunc ? import <nixpkgs> }:

pkgFunc { config = import ./config.nix; }
