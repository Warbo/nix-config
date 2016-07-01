# Override Haskell packages using haskell/*.nix
self: super:

with super;
with super.lib;
with builtins;

# Add everything from haskell/ to haskellPackages
let haskellOverrides = hsPkgs:
      let mkPkg = x: old:
            old // listToAttrs [{
                     name  = removeSuffix ".nix" x;
                     value = hsPkgs.callPackage (./haskell + "/${x}") {};
                   }];
          files = filter (hasSuffix ".nix")
                         (attrNames (readDir ./haskell));
       in fold mkPkg {} files;

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
  stableHaskellPackages = overrideHaskellPkgs self.stable.haskellPackages;
}
