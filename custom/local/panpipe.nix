{haskellPackages, latestGit}:

haskellPackages.callPackage (latestGit {
  url    = http://chriswarbo.net/git/panpipe.git;
}) {}
