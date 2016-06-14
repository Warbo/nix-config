{ haskellPackages }:

with import <nixpkgs> {};

haskell.lib.doJailbreak haskellPackages.tip-haskell-frontend-main
