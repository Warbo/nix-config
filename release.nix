# Used for testing and building via Hydra or "nix-build"
with builtins;
with rec {
  # The stable packages should always work; unstable shows us potential bit rot.
  unstable = import <nixpkgs>         { config = import ./unstable.nix; };
    stable = import unstable.repo1609 { config = import   ./stable.nix; };

  mkSet = pkgs:
    with pkgs;
    with lib;
    with rec {
      # Select our custom packages/overrides, except for those which are buried
      # in larger sets
      tooBig = name: hasPrefix "nixpkgs" name ||
                     hasPrefix "repo"    name ||
                     elem name [
                       "stableNixpkgs"             # Copy of nixpkgs
                       "stableRepo"                # Ditto
                       "haskell"                   # Mostly not ours
                       "haskellPackages"           # Ditto
                       "profiledHaskellPackages"   # Ditto
                       "unprofiledHaskellPackages" # Ditto
                       "unstableHaskellPackages"   # Ditto
                     ];
      drvName  = name: isDerivation (getAttr name pkgs);
      keepers  = name: !(tooBig name) && isDerivation (getAttr name pkgs);
      topLevel = genAttrs (filter keepers customPkgNames)
                          (name: getAttr name pkgs);

      # Select our custom Haskell packages from the various sets of Haskell
      # packages provided by nixpkgs (e.g. for different compiler versions)
      haskell = with rec {
        # GHC version ranges
        ghc710  = [ [ "haskell" "packages" "ghc7102" ]
                    [ "haskell" "packages" "ghc7103" ] ];
        ghc802  = [ [ "haskell" "packages" "ghc802"  ] ];
        ghc80   = [ [ "haskell" "packages" "ghc801"  ]
                    [ "haskellPackages"              ]
                    [ "profiledHaskellPackages"      ] ] ++ ghc802;

        post710 = ghc710 ++ post80;
        post80  = ghc80;

        # GHC versions with a particular feature set
        base48 = ghc710;

        # Which GHC versions a package should work under
        pkgGhcVersions =
          with rec {
            versions = {
              ArbitraryHaskell          = ghc710;
              AstPlugin                 = ghc710;
              genifunctors              = ghc710;
              geniplate                 = ghc710;
              getDeps                   = ghc710;
              ghc-dup                   = base48;
              ghc-simple                = ghc710;
              haskell-example           = base48;
              HS2AST                    = ghc710;
              ifcxt                     = base48;
              lazy-lambda-calculus      = ghc710;
              lazysmallcheck2012        = ghc710;
              ML4HSFE                   = ghc710;
              mlspec                    = ghc710;
              mlspec-helper             = ghc710;
              nix-eval                  = ghc710;
              runtime-arbitrary         = ghc710;
              runtime-arbitrary-tests   = ghc710;
              structural-induction      = ghc710;
              tasty                     = ghc710;
              tasty-ant-xml             = ghc710;
              tinc                      = ghc802;
              tip-haskell-frontend      = ghc710;
              tip-haskell-frontend-main = ghc710;
              tip-lib                   = ghc710;
              tip-types                 = ghc710;
            };

            errorMessage = "pkgGhcVersions name not found";
            debugInfo    = toJSON { inherit errorMessage haskellNames name; };
            check        = name: elem name haskellNames || abort debugInfo;
          };
          assert all check (attrNames versions); versions;

        # Either they're not on Hackage, or nixpkgs version doesn't match
        extraDeps = {
          AstPlugin            = [ "HS2AST"             ];
          ML4HSFE              = [ "HS2AST"             ];
          lazy-lambda-calculus = [ "lazysmallcheck2012" ];
        };

        # Create attrset containing all working versions of the named Haskell pkg
        getDrvs = name:
          with {
            versions = getAttr name pkgGhcVersions;
            addDrv   = path: set: setIn {
              inherit set;
              path  = path ++ [ name ];

              # Tincify each package, to ensure it gets the right dependencies
              value = with rec {
                fail            = abort (toJSON {
                                    inherit name path;
                                    message = "Couldn't find Haskell package";
                                  });
                haskellPackages = attrByPath path fail pkgs;
                pkg             = getAttr name haskellPackages;
                extras          = if hasAttr name extraDeps
                                     then { extras = getAttr name extraDeps; }
                                     else {};
              };
              tincify (pkg // extras // { inherit haskellPackages; }) {};
            };
          };
          fold addDrv {} (getAttr name pkgGhcVersions);
      };
      fold (name: recursiveUpdate (getDrvs name)) {} haskellNames;

      tests = import ./test.nix { inherit pkgs; };
    };
    topLevel // haskell // { tests = tests.testDrvs; };
};
stable.lib.mapAttrs (_: mkSet) {
  inherit stable unstable;
}
