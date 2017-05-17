{ haskell, haskellPackages, runCabal2nix, tincify }:

with rec {
  # We use 1.17.2 for compatibility with panpipe 0.2 and panhandle 0.2
  def = runCabal2nix { url = "cabal://pandoc-1.17.2"; };

  # Turn definition into a package with haskellPackages
  pkg = haskellPackages.callPackage def {};

  # Use tinc for dependencies rather than those hardcoded in haskellPackages
  withDeps = tincify pkg;

  # Writer tests fail since they can't access the disk, so we disable them all
  result = haskell.lib.dontCheck withDeps;
};
result
