{ hasBinary, nixpkgs1603, stable, super, withDeps }:

with rec {
  # We use cabal2nix in our Haskell overrides, so we need to use super instead
  # of self, to prevent infinite recursion
  pkg = if stable
           then nixpkgs1603.haskellPackages.cabal2nix
           else super.haskellPackages.cabal2nix;

  tested = withDeps [ (hasBinary pkg "cabal2nix") ] pkg;
};
{
  pkg   = tested;
  tests = tested;
}
