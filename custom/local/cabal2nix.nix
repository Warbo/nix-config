{ haskellPackages, nixpkgs1603, stable }:

if stable
   then nixpkgs1603.haskellPackages.cabal2nix
   else haskellPackages.cabal2nix
