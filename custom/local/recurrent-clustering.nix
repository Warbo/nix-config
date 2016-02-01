{ latestGit, callPackage }:

callPackage (latestGit {
  url = http://chriswarbo.net/git/recurrent-clustering.git;
  ref = "master";
}) {}
