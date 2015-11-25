# Override Haskell packages using haskellOverrides
with import <nixpkgs> {};

pkgs:

# Add everything from ./imports/haskell to haskellPackages
let overrideHaskellPkgs = hsPkgs:
      hsPkgs.override {
        overrides = self: super: haskellOverrides pkgs self;
      };
in {
  # Latest
  haskellPackages = overrideHaskellPkgs pkgs.haskellPackages;

  # GHC 7.8.4
  haskell = pkgs.haskell // {
    packages = pkgs.haskell.packages // {
      ghc784 = overrideHaskellPkgs pkgs.haskell.packages.ghc784;
    };
  };
}
