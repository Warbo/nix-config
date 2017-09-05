# Tests for our definitions. These should mostly exercise the actual definition,
# e.g. ensuring there are no type errors, maybe checking that something builds,
# etc. to ensure we've packaged them properly. They shouldn't test the real
# functionality of the actual programs/libraries/etc. since that should be done
# by the package's build script with the usual 'checkPhase' stuff.

with builtins;
with import <nixpkgs> { config = import ./config.nix; };
with lib;
rec {
  # Check whether the given package provides the given binary
  hasBinary = pkg: bin: runCommand "have-binary-${bin}"
    {
      inherit bin;
      buildInputs = [ pkg ];
    }
    ''
      command -v "$bin" || exit 1
      echo pass > "$out"
    '';

  # Packages which should provide a binary of the same name
  selfNamedBinaries = genAttrs [
    "asv"
    "bibcheck"
    "bibclean"
    "bibtool"
    "cabal2nix"
    "cmus"
    "conkeror"
    "ditaaeps"
    "emacs"
    "fail"
    "gcalcli"
    "get_iplayer"
    "git2html"
    "goat"
    "ipfs"
    "linkchecker"
    "mhonarc"
    "pandoc"
    "panhandle"
    "panpipe"
    "pipeToNix"
    "sshuttle"
    "x2x"
    "xdms"
    "youtube-dl"
    "yq"
  ] (n: hasBinary (getAttr n pkgs) n);

  # Packages which should provide some binary
  binaryProviders = mapAttrs (n: hasBinary (getAttr n pkgs)) {
    all             = "firefox";
    artemis         = "git-artemis";
    asv-nix         = "asv";
    basic           = "ssh";
    coq_mtac        = "coqc";
    git2html-real   = "git2html";
    hydra           = "hydra-eval-jobs";
    kbibtex_full    = "kbibtex";
    miller          = "mlr";
    ML4HSFE         = "ml4hsfe-outer-loop";
    stableHackage   = "makeCabalConfig";
    tidy-html5      = "tidy";
    timeout         = "withTimeout";
    warbo-utilities = "jo";
  };

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
      notMine = (genAttrs [
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
      ] tryHaskellPackage) // {
        tinc = haskell.packages.ghc802.tinc;
      };

      mine = (genAttrs [
        "ArbitraryHaskell"
        "AstPlugin"
        "HS2AST"
        "getDeps"
        "haskell-example"
        "lazy-lambda-calculus"
        "mlspec-helper"
        "nix-eval"
        "panhandle"
        "panpipe"
        "runtime-arbitrary"
        "runtime-arbitrary-tests"
      ] tryHaskellPackage) // {
        ML4HSFE = withDeps
          [ (isBroken haskellPackages.weigh) ]

          (tincify (haskellPackages.ML4HSFE // { extras = [ "HS2AST" ]; }) {});

        mlspec = withDeps
          [ (isBroken haskellPackages.weigh) ]

          (tincify haskellPackages.mlspec {});
      };

      pkgTests = mine // notMine // {
        haveAllHaskellTests = testWeHave {
          label  = "haskell";
          wanted = haskellNames;
          have   = attrNames pkgTests;
        };
      };
    };
    pkgTests;

  TODO = genAttrs [
    "anonymous-pro-font"
    "beautifulsoup-custom"
    "citationstyles"
    "droid-fonts"
    "elcid"
    "feed2maildirsimple"
    "fetchGitHashless"
    "fetchgx"
    "font-spacemono"
    "forceBuilds"
    "fsuae-launcher"
    "getDeps"
    "getNixpkgs"
    "ghcPackageEnv"
    "ghcTurtle"
    "ghcast"
    "google-api-python-client"
    "gscholar"
    "hackageDb"
    "hackageUpdate"
    "haskellGit"
    "haskellNames"
    "haskellOverrides"
    "haskellPackages"
    "haskellTinc"
    "helpers"
    "hfeed2atom"
    "inNixedDir"
    "isBroken"
    "jsbeautifier"
    "latestCabal"
    "latestCfgPkgs"
    "latestGit"
    "latestNixCfg"
    "lhasa"
    "md2pdf"
    "mergeDirs"
    "mf2py"
    "mk-python-lhafile"
    "ml4pg"
    "mlspec"
    "newNixpkgsEnv"
    "nix-eval-test"
    "nixFromCabal"
    "nixpkgs1603"
    "nixpkgs1609"
    "nixpkgs1703"
    "profiledHaskellPackages"
    "pypdf2"
    "python-lhafile"
    "repo2npm"
    "repoSource"
    "reverse"
    "runCabal2nix"
    "runScript"
    "sanitiseName"
    "scholar"
    "searchtobibtex"
    "skulpture"
    "stripOverrides"
    "suffMatch"
    "tincify"
    "tipSrc"
    "translitcodec"
    "unpack"
    "unprofiledHaskellPackages"
    "unstableHaskellPackages"
    "unstableTipSrc"
    "uritemplate"
    "w3c-validator"
    "withArgs"
    "withArgsOf"
    "withDeps"
    "withLatestCfg"
    "withLatestGit"
    "withNix"
    "withTincDeps"
    "withTincPackages"
  ] (n: assert hasAttr n pkgs;
        trace "TODO: no test for ${n} yet" nothing);

  tests = TODO // selfNamedBinaries // binaryProviders // {

    attrsToDirs     = attrsToDirs { foo = { bar = ./test.nix; }; };

    backtrace       = runCommand "backtrace-test"
                        { buildInputs = [ backtrace fail ]; }
                        ''
                          X=$(NOTRACE=1 backtrace)
                          [[ -z "$X" ]] || fail "NOTRACE should suppress trace"

                          Y=$(backtrace)
                          for Z in "Backtrace" "End Backtrace" "bash"
                          do
                            echo "$Y" | grep -F "$Z" || fail "Didn't find '$Z'"
                          done

                          echo pass > "$out"
                        '';

    callPackage     = tryInEnv "callPackage" (callPackage ({ bash }: "x") {});

    composeWithArgs = tryInEnv "composeWithArgs"
                               (callPackage (composeWithArgs
                                               (x: x)
                                               ({ hello }: hello)) {});

    customPkgNames  = tryInEnv "customPkgNames" customPkgNames;

    dirContaining   = dirContaining ./custom [
                        ./custom/local.nix
                        ./custom/haskell.nix
                      ];

    dirsToAttrs     = runCommand "dirsToAttrs-test"
                        (dirsToAttrs (attrsToDirs {
                          x = ./custom/local/dirsToAttrs.nix; }))
                        ''
                          [[ -n "$x" ]]                      || exit 1
                          [[ -f "$x" ]]                      || exit 2
                          grep 'builtins' < "$x" > /dev/null || exit 3

                          echo "pass" > "$out"
                        '';

    gx              = gx;

    hackagePackageNames = tryInEnv "hackagePackageNames"
                                   (typeOf hackagePackageNames);

    hackagePackageNamesDrv = hackagePackageNamesDrv;

    haskell         = withDeps (attrValues haskellTests)
                               (runCommand "haskell-tests" {} ''
                                 echo pass > "$out"
                               '');

    isCallable      = ifDrv "isCallable-test"
                            (isCallable (callPackage
                                          ({}: (x: abort "shouldn't force"))
                                          {}));

    isPath          = withDeps [
                        (ifDrv "relativePathIsPath" (isPath ./test.nix))
                        (ifDrv "absolutePathIsPath" (isPath /tmp      ))
                        (ifDrv "pathStringIsPath"   (isPath "/tmp"    ))
                        (ifDrv "stringIsNotPath"  (!(isPath "foo"    )))
                        (ifDrv "otherIsNotPath"   (!(isPath 42       )))
                      ] nothing;

    mkBin = runCommand "mkBin-test"
              {
                buildInputs = [ fail (mkBin {
                  name   = "ping";
                  script = ''
                    #!/usr/bin/env bash
                    echo "pong"
                  '';
                }) ];
              }
              ''
                X=$(ping)
                [[ "x$X" = "xpong" ]] || fail "Output was '$X'"
                echo pass > "$out"
              '';

    nixListToBashArray =
      with nixListToBashArray { name = "check"; args = [ "foo" ]; };
      runCommand "check-NLTBA" env ''
        ${code}
        echo pass > "$out"
      '';

    nothing = runCommand "nothing-test"
      {
        inherit nothing;
        buildInputs = [ fail ];
      }
      ''
        [[ -e "$nothing" ]] || fail "Couldn't find '$nothing'"
        if [[ -f "$nothing" ]]
        then
          fail "'$nothing' shouldn't be a file"
        fi

        COUNT=$(find "$nothing/" | wc -l)
        [[ "$COUNT" -eq 1 ]] || fail "Found '$COUNT' things in '$nothing'"

        echo pass > "$out"
      '';

    repo1603        = repo1603;
    repo1609        = repo1609;
    repo1703        = repo1703;
    stable          = stable.hello;
    stableHackageDb = stableHackageDb;
    stableRepo      = stableRepo;

    wrap = wrap {
      name   = "wrap-test";
      paths  = [ bash ];
      vars   = {
        MY_VAR = "MY VAL";
      };
      script = ./custom/local/wrap.nix;
    };
  };

  testDrvs = tests // {
    haveAllTests = testWeHave {
      label  = "all";
      wanted = customPkgNames;
      have   = attrNames tests;
    };
  };

  all = withDeps (attrValues testDrvs)
                 (runCommand "all-tests" {} ''echo pass > "$out"'');
}
