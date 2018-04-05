{ nixpkgs1709, stable, super }:

# We use cabal2nix in our Haskell overrides, so we need to use super instead of
# self, to prevent infinite recursion
if stable
   then nixpkgs1709.haskellPackages.cabal2nix
   else super.haskellPackages.cabal2nix
