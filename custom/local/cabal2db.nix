{ latestGit, callPackage }:

callPackage (latestGit {
  url = if (import <nixpkgs> {}).localOnly
           then /home/chris/Programming/repos/cabal2db.git
           else http://chriswarbo.net/git/cabal2db.git;
  ref = "master";
}) {}
