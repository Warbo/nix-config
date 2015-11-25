{haskellPackages, latestGit}:

haskellPackages.callPackage (latestGit {
  url = http://chriswarbo.net/git/panhandle.git;
}) {}
