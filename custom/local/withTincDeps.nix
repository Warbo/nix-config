# Calls a Haskell package with dependencies solved by Cabal and converted to
# Nix by tinc/cabal2nix
{ withTincPackages }:

{ extras ? [], haskellPackages, nixpkgs, tincified }:
with rec {
  resolver = withTincPackages {
    inherit extras haskellPackages nixpkgs tincified;
  };
};
resolver.callPackage "${tincified}/package.nix" {}
