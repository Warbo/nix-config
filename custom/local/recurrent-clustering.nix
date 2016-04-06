{ latestGit, callPackage }:

callPackage (latestGit {
  url = if (import <nixpkgs> {}).localOnly
           then /home/chris/Progamming/repos/recurrent-clustering.git
           else http://chriswarbo.net/git/recurrent-clustering.git;
  ref = "master";
}) {}
