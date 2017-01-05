# Override Haskell packages using haskell/*.nix
self: super:

with super;
with super.lib;
with builtins;
with rec {
  # All .nix files in haskell/
  hsFiles = filterAttrs (n: _: hasSuffix ".nix" n)
                        (readDir ./haskell);

  # Package definitions loaded from hsFiles
  hsFileDefs = mapAttrs' (name: _: nameValuePair
                           (removeSuffix ".nix" name)
                           (import (./haskell + "/${name}") self super))
                         hsFiles;

  # Packages loaded from elsewhere
  hsExternal = mapAttrs (_: self.runCabal2nix) {

  };

  # Adds haskell/ contents to a Haskell package set
  haskellOverrides = hsPkgs: mapAttrs (_: def: hsPkgs.callPackage def {})
                                      (hsFileDefs // hsExternal);

  # Overrides a Haskell package set
  overrideHaskellPkgs = hsPkgs:
    hsPkgs.override {
      overrides = self: super: haskellOverrides self;
    };
};

rec {
  # Lets us know which packages we've overridden
  haskellNames = attrNames hsFileDefs;

  #callHackage  = { inherit (super.haskell.packages.ghc7103) callHackage; };

  # Too many breakages on unstable and 8.x
  haskellPackages = haskell.packages.stable.ghc7103 // {
    inherit (super.haskell.packages.ghc7103) callHackage;
  };

  # Default unstable version
  unstableHaskellPackages = super.haskellPackages;

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
                in unstable // stable // {
                     # Direct access to old/new if needed
                     inherit unstable stable;

                     # Use unstable GHC 8.0.1 rather than 'stable' prerelease
                     inherit (unstable) ghc801;
                   };
  };
}
