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
    inherit hackagePackageNamesDrv nix-config-tests;

    haskell     = withDeps (attrValues haskellTests)
                           (runCommand "haskell-tests" {} ''
                             echo pass > "$out"
                           '');
  };

  all = withDeps (attrValues tests)
                 (runCommand "all-tests" {} ''echo pass > "$out"'');
}
