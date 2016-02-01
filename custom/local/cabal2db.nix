{ latestGit, callPackage }:

callPackage (latestGit {
  url = http://chriswarbo.net/git/cabal2db.git;
  ref = "master";
}) {}
