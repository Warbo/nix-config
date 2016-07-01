# Override Haskell packages using haskell/*.nix
self: super:

with self;

# Add everything from haskell/ to haskellPackages
let haskellOverrides = hsPkgs:
    let mkPkg = x: old:
        let n = super.lib.removeSuffix ".nix" x;
         in old // builtins.listToAttrs [{
                     name  = n;
                     value = hsPkgs.callPackage (./haskell + "/${n}.nix") {};
                   }];
     in super.lib.fold mkPkg
                      {}
                      (builtins.filter (super.lib.hasSuffix ".nix")
                                       (builtins.attrNames (builtins.readDir ./haskell)));

  overrideHaskellPkgs = hsPkgs:
      hsPkgs.override {
        overrides = self: super: haskellOverrides self;
      };
in {
  # Latest
  haskellPackages = overrideHaskellPkgs super.haskellPackages;

  # GHC 7.8.4
  haskell = super.haskell // {
    packages = super.haskell.packages // {
      ghc784 = overrideHaskellPkgs super.haskell.packages.ghc784;
    };
  };

  # The haskellPackages from stable, but augmented with our overrides. Useful if
  # the unstable haskellPackages are broken through no fault of ours.
  stableHaskellPackages = overrideHaskellPkgs stable.haskellPackages;
}
