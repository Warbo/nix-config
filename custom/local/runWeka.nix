{ callPackage, latestGit, repoSource }:

callPackage (latestGit {
  url = "${repoSource}/run-weka.git";
}) {}
