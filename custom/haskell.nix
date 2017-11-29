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

  # Some versions of nixpkgs support benchmarkHaskellDepends, others don't
  callWith = self:
    with rec {
      f = { mkDerivation }: { inherit mkDerivation; };

      inherit (self.callPackage f {}) mkDerivation;

      polyfill = def: self.callPackage def {
        mkDerivation = { benchmarkHaskellDepends ? null }@args:
          mkDerivation (removeAttrs args [ "benchmarkHaskellDepends" ] // {
                          libraryHaskellDepends = args.libraryHaskellDepends ++
                                                  args.benchmarkHaskellDepends;
                       });
      };
    };
    if functionArgs mkDerivation ? benchmarkHaskellDepends
       then self.callPackage
       else polyfill;

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

  haskell =
    with rec {
      # We need GHC 8.0.2 for tinc
      backport = if super.haskell.packages ? ghc802
                    then {}
                    else {
                      inherit (self.nixpkgs1703.haskell.packages) ghc802;
                    };

      packages = mapAttrs (_: hsPkgs: hsPkgs.override {
                            overrides = haskellOverrides;
                          })
                          (super.haskell.packages // backport);
    };
    super.haskell // { inherit packages; };
}
