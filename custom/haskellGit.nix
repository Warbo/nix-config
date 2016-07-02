# Takes the URL of a git repo containing a .cabal file (i.e. a Haskell project).
# Uses cabal2nix on the repo's HEAD.
args@{ url, ref ? "HEAD", ... }:

with builtins;

import ./withLatestGit.nix (args // {
  srcToPkg = x: import ./nixFromCabal.nix "${x}";
  resultComposes = true;
})
