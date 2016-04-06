{ latestGit, callPackage }:

callPackage (latestGit {
  url = if (import <nixpkgs> {}).localOnly
           then /home/chris/Programming/repos/annotatedb.git
           else http://chriswarbo.net/git/annotatedb.git;
  ref = "master";
}) {}
