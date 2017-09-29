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
                                     (import (./haskell + "/${name}")
                                             self super))
                                   hsFiles;

  # Packages loaded from elsewhere, e.g. hackage, github, ...
  hsExternal = mapAttrs (_: self.runCabal2nix) {};

  # Packages to include only if they're not already present
  hsFallbacks =
    with {
      unoverridden = (import <nixpkgs> { config = {}; }).haskellPackages;
    };
    filterAttrs (n: _: !(hasAttr n unoverridden)) {

      # Isn't in older nixpkgs
      weigh = self.runCabal2nix { url = "cabal://weigh"; };
    };

  # Adds haskell/ contents to a Haskell package set
  haskellOverrides = self: super: mapAttrs (_: def: self.callPackage def {})
                                           (hsFallbacks // hsFileDefs
                                                        // hsExternal);

  # Overrides a Haskell package set
  overrideHaskellPkgs = hsPkgs:
    hsPkgs.override {
      overrides = haskellOverrides;
    };
};

rec {
  inherit haskellOverrides;

  # Lets us know which packages we've overridden
  haskellNames = attrNames hsFileDefs;

  #callHackage  = { inherit (super.haskell.packages.ghc7103) callHackage; };

  # Too many breakages on unstable and 8.x
  unprofiledHaskellPackages = haskell.packages.ghc7103;

  # Turn profiling on/off via environment variable, to make life easier
  haskellPackages = if getEnv "HASKELL_PROFILE" == "1"
                       then profiledHaskellPackages
                       else unprofiledHaskellPackages;

  #haskellPackages.callHackage = super.haskell.packages.ghc7103.callHackage;

  # Profiling
  profiledHaskellPackages = unprofiledHaskellPackages.override {
    overrides = self: super: haskellOverrides self super // {
      mkDerivation = args: super.mkDerivation (args // {
        enableLibraryProfiling    = true;
        enableExecutableProfiling = true;
        doHaddock                 = false;  # Because it can fail
        configureFlags = [
          "--ghc-option=-fprof-auto-exported"
          "--ghc-option=-rtsopts"
        ];
      });
    };
  };

  haskell =
    with rec {
      config = import (if self.stable then ../stable.nix else ../unstable.nix);
      polyfill = if super.haskell.packages ? ghc802
                    then {}
                    else {
                      inherit ((import self.repo1703 {
                        inherit config;
                      }).haskell.packages) ghc802;
                    };
    };
    super.haskell // {
      packages = mapAttrs (n: overrideHaskellPkgs)
                          (super.haskell.packages // polyfill);
    };
}
