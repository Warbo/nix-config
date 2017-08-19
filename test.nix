# Tests for our definitions. These should mostly exercise the actual definition,
# e.g. ensuring there are no type errors, maybe checking that something builds,
# etc. to ensure we've packaged them properly. They shouldn't test the real
# functionality of the actual programs/libraries/etc. since that should be done
# by the package's build script with the usual 'checkPhase' stuff.

with builtins;
with import <nixpkgs> { config = import ./config.nix; };
with lib;
with rec {
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
    "emacs"
    "fail"
    "gcalcli"
    "get_iplayer"
    "git2html"
    "ipfs"
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
    bugseverywhere  = "be";
    coq_mtac        = "coqc";
    ML4HSFE         = "ml4hsfe-outer-loop";
    stableHackage   = "makeCabalConfig";
    timeout         = "withTimeout";
    warbo-utilities = "jo";
  };

  # Makes a derivation with the given value in its environment; checks whether
  # this causes the build to fail or not.
  tryInEnv = name: x: runCommand "try-${name}-in-env" { inherit x; }
                        ''echo pass > "$out"'';

  TODO = genAttrs [
    "anonymous-pro-font"
    "beautifulsoup-custom"
    "citationstyles"
    "dirsToAttrs"
    "ditaaeps"
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
    "git2html-real"
    "goat"
    "google-api-python-client"
    "gscholar"
    "hackageDb"
    "hackageUpdate"
    "haskell"
    "haskellGit"
    "haskellNames"
    "haskellOverrides"
    "haskellPackages"
    "haskellTinc"
    "helpers"
    "hfeed2atom"
    "inNixedDir"
    "isBroken"
    "isPath"
    "jsbeautifier"
    "kbibtex_full"
    "latestCabal"
    "latestCfgPkgs"
    "latestGit"
    "latestNixCfg"
    "lhasa"
    "linkchecker"
    "md2pdf"
    "mergeDirs"
    "mf2py"
    "mhonarc"
    "miller"
    "mk-python-lhafile"
    "ml4pg"
    "mlspec"
    "newNixpkgsEnv"
    "nix-eval-test"
    "nixFromCabal"
    "nixpkgs1603"
    "nixpkgs1609"
    "nixpkgs1703"
    "nothing"
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
    "tidy-html5"
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

    attrsToDirs     = tryInEnv "attrsToDirs" (attrsToDirs {
                                               foo = { bar = ./test.nix; };
                                             });

    callPackage     = tryInEnv "callPackage-val" (callPackage ({ bash }: "x")
                                                              {});

    composeWithArgs = tryInEnv "composeWithArgs"
                        (callPackage (composeWithArgs (x: x)
                                                      ({ hello }: hello)) {});

    customPkgNames  = tryInEnv "customPkgNames" customPkgNames;

    dirContaining   = tryInEnv "dirContaining"  (dirContaining ./custom [
                                                  ./custom/local.nix
                                                  ./custom/haskell.nix
                                                ]);

    gx              = tryInEnv "gx" gx;

    isCallable      = if isCallable
                           (callPackage ({}: (x: abort "shouldn't force")) {})
                         then nothing
                         else runCommand "isCallable-fail" "exit 1";

    nixListToBashArray =
      with nixListToBashArray { name = "check"; args = [ "foo" ]; };
      runCommand "check-NLTBA" env ''
        ${code}
        echo pass > "$out"
      '';


    repo1603        = tryInEnv "repo1603" repo1603;
    repo1609        = tryInEnv "repo1609" repo1609;
    repo1703        = tryInEnv "repo1703" repo1703;
    stable          = tryInEnv "stable" stable.hello;
    stableHackageDb = tryInEnv "stableHackageDb" stableHackageDb;
    stableRepo      = tryInEnv "stableRepo" stableRepo;

    wrap = tryInEnv "wrap" (wrap {
      name   = "wrap-test";
      paths  = [ bash ];
      vars   = {
        MY_VAR = "MY VAL";
      };
      script = ./test.nix;
    });
  };

  testDrvs = tests // {
    haveAllTests = runCommand "have-all-tests"
      {
        missing = filter (n: !(elem n (attrNames tests))) customPkgNames;
      }
      ''
        for M in $missing
        do
          echo "Missing tests for $missing" 1>&2
          exit 1
        done
        echo pass > "$out"
      '';
  };
};
withDeps (attrValues testDrvs)
         (runCommand "all-tests" {} ''echo pass > "$out"'')
