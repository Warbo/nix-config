# Override Haskell packages using haskell/*.nix
self: super:

with super;
with super.lib;
with builtins;
with rec {
  # All .nix files in haskell/
  haskellNames = map (removeSuffix ".nix")
                     (attrNames (filterAttrs (n: _: hasSuffix ".nix" n)
                                             (readDir ./haskell)));
  haskellDefs  = genAttrs haskellNames
                          (f: import (./haskell + "/${f}.nix") self super);

  haskellOverrides = self: super: mapAttrs (_: def: self.callPackage def {})
                                           haskellDefs;
};

rec {
  inherit haskellNames haskellOverrides;

  # Too many breakages on unstable and 8.x
  unprofiledHaskellPackages = haskell.packages.ghc7103;

  # Turn profiling on/off via environment variable, to make life easier
  haskellPackages = if getEnv "HASKELL_PROFILE" == "1"
                       then profiledHaskellPackages
                       else unprofiledHaskellPackages;

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

  haskell.packages =
    # We need GHC 8.0.2 for tinc
    with rec {
      config   = import (if self.stable
                            then ../stable.nix
                            else ../unstable.nix);
      polyfill = if super.haskell.packages ? ghc802
                    then {}
                    else {
                      inherit ((import self.repo1703 {
                        inherit config;
                      }).haskell.packages) ghc802;
                    };
    };
    mapAttrs (_: hsPkgs: hsPkgs.override { overrides = haskellOverrides; })
             (super.haskell.packages // polyfill);
}
