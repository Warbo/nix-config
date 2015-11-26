# Takes the URL of a git repo containing a .cabal file (i.e. a Haskell project).
# Uses cabal2nix on the repo's HEAD.
let nixpkgs = import <nixpkgs> {};
 in url: nixpkgs.nixFromCabal (nixpkgs.latestGit { inherit url; })
