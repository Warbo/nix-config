{ haskell, isoTincify }:

with {
  haskellPackages = haskell.packages.ghc7103;  # For base 4.8.*
};
isoTincify (haskellPackages.panpipe // { inherit haskellPackages; })
