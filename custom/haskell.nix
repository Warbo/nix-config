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

{
  tests = {};
  pkgs  = rec {
    inherit haskellNames haskellOverrides;

    unprofiledHaskellPackages = super.haskellPackages.override {
      overrides = haskellOverrides;
    };

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

    haskell = super.haskell // {
      packages = mapAttrs (_: hsPkgs: hsPkgs.override {
                            overrides = haskellOverrides;
                          })
                          super.haskell.packages;
    };
  };
}
