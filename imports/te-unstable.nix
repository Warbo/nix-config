with import <nixpkgs> {};
callPackage /home/chris/System/Packages/haskell-te {
  HS2AST           = /home/chris/Programming/Haskell/HS2AST;
  treefeatures     = /home/chris/Programming/Haskell/TreeFeatures;
  ArbitraryHaskell = /home/chris/Programming/Haskell/ArbitraryHaskell;
  ml4hs            = /home/chris/Programming/ML4HS;
  AstPlugin        = /home/chris/Programming/Haskell/AstPlugin;
  nix-eval         = /home/chris/Programming/Haskell/nix-eval;
  mlspec           = /home/chris/Programming/Haskell/MLSpec;
  order-deps       = /home/chris/Programming/Haskell/order-deps;
  getDeps          = /home/chris/Programming/Haskell/getDeps;
}
