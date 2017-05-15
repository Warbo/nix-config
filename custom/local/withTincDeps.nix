# Calls a Haskell package with dependencies solved by Cabal and converted to
# Nix by tinc/cabal2nix
{ withTincPackages }:

{ extras ? [], haskellPackages, includeExtras, nixpkgs, tincified }:
with rec {
  resolver = withTincPackages {
    inherit extras haskellPackages nixpkgs tincified;
  };

  pkg = resolver.callPackage "${tincified}/package.nix" {};
};

if includeExtras
   then resolver.ghcWithPackages (h: [ pkg ] ++ map (n: h."${n}") extras)
   else pkg
