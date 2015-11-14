with import <nixpkgs> {};

{ haskellPackages }:

haskellPackages.callPackage
  (nixFromCabal (latestGit {
                   url = http://chriswarbo.net/git/lazy-smallcheck-2012.git;
                 }))
  {}
