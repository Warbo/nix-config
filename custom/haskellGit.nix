# Takes the URL of a git repo containing a .cabal file (i.e. a Haskell project).
# Uses cabal2nix on the repo's HEAD.

self: super:

{

haskellGit = args@{ url, ref ? "HEAD", ... }:
  with builtins;

  self.withLatestGit (args // {
    srcToPkg = x: self.nixFromCabal "${x}";
    resultComposes = true;
  });

}
