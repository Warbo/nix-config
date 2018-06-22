{ hasBinary, haskellPackages, latestGit, withDeps }:

with rec {
  src = latestGit {
    url    = https://github.com/awakesecurity/nix-delegate.git;
    stable = {
      rev    = "aeb6c4a";
      sha256 = "0qb83jkb495vgh912sdiqcph7zrppm4rch9j25m5988d9y1ykgja";
    };
  };

  pkg = haskellPackages.callPackage src {};
};
withDeps [ (hasBinary pkg "nix-delegate") ] pkg
