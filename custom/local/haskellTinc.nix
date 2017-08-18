{ haskell }:

with rec {
  p   = haskell.packages;
  set = p.ghc802 or p.ghc801 or p.ghc7103;
};
set.tinc
