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
                     value = let pkg = import (./haskell + "/${x}") self super;
                              in hsPkgs.callPackage pkg {};
                   }];

       in fold mkPkg {} hsFiles;

    overrideHaskellPkgs = hsPkgs:
      hsPkgs.override {
        overrides = self: super: haskellOverrides self;
      };

    hsFiles = filter (hasSuffix ".nix")
                     (attrNames (readDir ./haskell));
in rec {
  # Lets us know which packages we've overridden
  haskellNames = map (removeSuffix ".nix") hsFiles;

  # Too many breakages on 8.x
  haskellPackages = overrideHaskellPkgs haskell.packages.ghc7103;

  # Profiling
  profiledHaskellPackages = haskellPackages.override {
    overrides = self: super: haskellOverrides self // {
      mkDerivation = args: super.mkDerivation (args // {
        enableLibraryProfiling = true;
      });
    };
  };

  # GHC 7.8.4
  haskell = super.haskell // {
    packages = super.haskell.packages //
                 mapAttrs (n: v: overrideHaskellPkgs v)
                          super.haskell.packages;
    #{
    #  ghc783  = overrideHaskellPkgs self.stable.haskell.packages.ghc783;
    #  ghc784  = overrideHaskellPkgs self.stable.haskell.packages.ghc784;
    #  ghc7102 = overrideHaskellPkgs self.stable.haskell.packages.ghc7102;
    #  ghc7103 = overrideHaskellPkgs self.stable.haskell.packages.ghc7103;
    #  ghc801  = overrideHaskellPkgs self.stable.haskell.packages.ghc801;
    #};
  };
}
