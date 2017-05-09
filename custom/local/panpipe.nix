{ haskell, tincify }:

with {
  haskellPackages = haskell.ghc7103.packages;  # For base 4.8.*
};
tincify {
  inherit haskellPackages;
  inherit (haskellPackages.panpipe) name src;
}
