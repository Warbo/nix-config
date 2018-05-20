# Tests for our definitions. These should mostly exercise the actual definition,
# e.g. ensuring there are no type errors, maybe checking that something builds,
# etc. to ensure we've packaged them properly. They shouldn't test the real
# functionality of the actual programs/libraries/etc. since that should be done
# by the package's build script with the usual 'checkPhase' stuff.

with builtins;

{ pkgs ? (import <nixpkgs> { config = import ./config.nix; }) }:
with pkgs;
with lib;
rec {
  failDrv = name: runCommand name "exit 1";

  # Makes a derivation with the given value in its environment; checks whether
  # this causes the build to fail or not.
  tryInEnv = name: x: runCommand "try-${name}-in-env" { inherit x; }
                                 ''echo pass > "$out"'';

  ifDrv   = name: bool: runCommand name {} ''
    mkdir "$out"
    exit ${if bool then "0" else "1"}
  '';

  testWeHave = { label, wanted, have}: runCommand "have-${label}-tests"
    {
      inherit label;
      missing = filter (n: !(elem n have)) wanted;
    }
    ''
      for M in $missing
      do
        echo "Missing '$label' tests for $missing" 1>&2
        exit 1
      done
      echo pass > "$out"
    '';

  tryHaskellPackage = n: getAttr n haskellPackages;

  haskellTests =
    with rec {
      notMine = genAttrs [
        "genifunctors"
        "structural-induction"
        "lazysmallcheck2012"
        "ifcxt"
        "ghc-simple"
        "ghc-dup"
        "tip-lib"
        "tip-haskell-frontend-main"
        "tip-haskell-frontend"
        "tasty-ant-xml"
        "tasty"
        "tip-types"
        "geniplate"
      ] tryHaskellPackage;

      mine = (genAttrs [
        "ArbitraryHaskell"
        "AstPlugin"
        "HS2AST"
        "getDeps"
        "haskell-example"
        "lazy-lambda-calculus"
        "mlspec-helper"
        "nix-eval"
        "runtime-arbitrary"
        "runtime-arbitrary-tests"
      ] tryHaskellPackage);

      pkgTests = mine // notMine // {
        haveAllHaskellTests = testWeHave {
          label  = "haskell";
          wanted = haskellNames;
          have   = attrNames pkgTests;
        };
      };
    };
    pkgTests;

  tests = {
    inherit nothing pidgin-privacy-please repo1603 repo1609 repo1703 repo1709
            stableHackageDb;

    callPackage     = tryInEnv "callPackage" (callPackage ({ bash }: "x") {});

    hackagePackageNamesDrv = hackagePackageNamesDrv;

    haskell         = withDeps (attrValues haskellTests)
                               (runCommand "haskell-tests" {} ''
                                 echo pass > "$out"
                               '');
  };

  testDrvs = tests // {
    customTests  = withDeps customTests nothing;
  };

  all = withDeps (attrValues testDrvs)
                 (runCommand "all-tests" {} ''echo pass > "$out"'');
}
