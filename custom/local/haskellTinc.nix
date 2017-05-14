{ haskell, latestGit, runCabal2nix }:

haskell.packages.ghc802.callPackage (runCabal2nix {
  url = latestGit {
    url = "http://chriswarbo.net/git/tinc.git";
  };
}) {}
