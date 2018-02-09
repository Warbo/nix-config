# Used for testing and building via continuous integration (e.g. Hydra)
with builtins;
with import <nixpkgs> { config = import ./config.nix; };
with lib;
with rec {
  # Select our custom packages/overrides, except for those which are buried
  # in larger sets
  topLevel = pkgs:
    with rec {
      tooBig = name:
                 # Ignore copies of nixpkgs
                 hasPrefix "nixpkgs" name ||
                 elem name [
                   "unstable"
                   "customised"

                   # Most Haskell packages aren't ours
                   "haskell"
                   "haskellPackages"
                   "profiledHaskellPackages"
                   "unprofiledHaskellPackages"
                   "unstableHaskellPackages"

                   # These are designed to break on unstable, so avoid them
                   "latestNixCfg"
                   "latestCfgPkgs"
                   "withLatestCfg"
                 ];

      nonDerivation = name: elem name [];

      keepers = name: !(tooBig name) && !(nonDerivation name);
    };
    genAttrs (filter keepers customPkgNames)
             (name: getAttr name pkgs);

  select = pkgs:
    with rec {
      # Select our custom Haskell packages from the various sets of Haskell
      # packages provided by nixpkgs (e.g. for different compiler versions)
      haskell =
        with rec {
          # GHC version ranges
          ghc784  = [ [ "haskell" "packages" "ghc784"  ] ];
          ghc7102 = [ [ "haskell" "packages" "ghc7102" ] ];
          ghc7103 = [ [ "haskell" "packages" "ghc7103" ] ];
          ghc710  = ghc7102 ++ ghc7103;
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
                lazysmallcheck2012        = ghc784;
                ML4HSFE                   = ghc710;
                mlspec                    = ghc710;
                mlspec-helper             = ghc710;
                nix-eval                  = ghc710;
                runtime-arbitrary         = ghc710;
                runtime-arbitrary-tests   = ghc710;
                structural-induction      = ghc7103;
                tasty                     = ghc710;
                tasty-ant-xml             = ghc710;
                tip-haskell-frontend      = ghc710;
                tip-haskell-frontend-main = ghc710;
                tip-lib                   = ghc710;
                tip-types                 = ghc710;
              };

              errorMessage = "pkgGhcVersions name not found";
              debugInfo    = toJSON {
                               inherit errorMessage haskellNames name;
                             };
              check        = name: elem name haskellNames || abort debugInfo;
            };
            assert all check (attrNames versions); versions;

          # Either they're not on Hackage, or nixpkgs version doesn't match
          extraDeps = mapAttrs (_: map (n: unpack
                                             (getAttr n pkgs.haskellPackages).src)) {
            AstPlugin            = [ "HS2AST"             ];
            lazy-lambda-calculus = [ "lazysmallcheck2012" ];
            ML4HSFE              = [ "HS2AST"             ];
            mlspec               = [ "mlspec-helper"      ];
          };

          # Create attrset with all working versions of the named Haskell pkg
          getDrvs = name:
            with {
              versions = getAttr name pkgGhcVersions;
              addDrv   = path: set: setIn {
                inherit set;
                path  = path ++ [ name ];

                # Ensure each package gets compatible dependencies
                value =
                  with rec {
                    fail   = abort (toJSON {
                               inherit name path;
                               message = "Couldn't find Haskell package";
                             });
                    hP     = attrByPath path fail pkgs;
                    pkg    = getAttr name hP;
                    extras = if hasAttr name extraDeps
                                then { extra-sources = getAttr name extraDeps; }
                                else {};
                  };
                  haskellPkgWithDeps
                    ({
                      delay-failure = true;
                      dir           = unpack pkg.src;
                      hsPkgs        = hP;
                     } // extras);
              };
            };
            fold addDrv {} (getAttr name pkgGhcVersions);
        };
        fold (name: recursiveUpdate (getDrvs name)) {} haskellNames;

      tests = import ./test.nix { inherit pkgs; };
    };
    topLevel pkgs // haskell // { tests = tests.testDrvs; };
};

lib.mapAttrs (_: select) customised
