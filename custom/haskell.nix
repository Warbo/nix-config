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

  #callHackage  = { inherit (super.haskell.packages.ghc7103) callHackage; };

  # Too many breakages on unstable and 8.x
  haskellPackages = haskell.packages.stable.ghc7103 // { inherit (super.haskell.packages.ghc7103) callHackage; };

  #haskellPackages.callHackage = super.haskell.packages.ghc7103.callHackage;

  # Profiling
  profiledHaskellPackages = haskellPackages.override {
    overrides = self: super: haskellOverrides self // {
      mkDerivation = args: super.mkDerivation (args // {
        enableLibraryProfiling = true;
      });
    };
  };

  haskell = super.haskell // {
    packages = let override = mapAttrs (n: v: overrideHaskellPkgs v);
                   unstable = override       super.haskell.packages;
                     stable = override self.stable.haskell.packages;
                in unstable // stable // { inherit unstable stable; };
  };
}
