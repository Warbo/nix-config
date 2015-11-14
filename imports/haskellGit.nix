# Takes the URL of a git repo containing a .cabal file (i.e. a Haskell project).
# Uses cabal2nix on the repo's HEAD.
with import <nixpkgs> {};

url: { haskellPackages }:

haskellPackages.callPackage (nixFromCabal (latestGit { inherit url; })) {}
