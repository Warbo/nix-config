# Takes the URL of a git repo containing a .cabal file (i.e. a Haskell project).
# Uses cabal2nix on the repo's HEAD.
let pkgs = import <nixpkgs> {};
 in url: pkgs.nixFromCabal (pkgs.latestGit { inherit url; })
