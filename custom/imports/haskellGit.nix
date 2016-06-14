# Takes the URL of a git repo containing a .cabal file (i.e. a Haskell project).
# Uses cabal2nix on the repo's HEAD.
args@{ url, ref ? "HEAD", ... }:

with builtins;
let nixpkgs = import <nixpkgs> {};
in

nixpkgs.withLatestGit (args // {
  srcToPkg = x: nixpkgs.nixFromCabal "${x}";
  resultComposes = true;
})
