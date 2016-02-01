{ latestGit, callPackage }:

callPackage (latestGit {
  url = http://chriswarbo.net/git/annotatedb.git;
  ref = "master";
}) {}
