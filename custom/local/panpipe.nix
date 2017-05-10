{ haskell, tincify }:

with {
  haskellPackages = haskell.packages.ghc7103;  # For base 4.8.*
};
tincify (haskellPackages.panpipe // { inherit haskellPackages; })
