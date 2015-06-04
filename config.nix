{
  packageOverrides = pkgs: with pkgs; rec {

    # Shorthand synonyms #
    #====================#

    # Gives us dontCheck, dontHaddock, etc.
    hsTools = import "${<nixpkgs>}/pkgs/development/haskell-modules/lib.nix" {
      inherit pkgs;
    };

    callHaskell = haskellPackages.callPackage;

    haskell-agda = haskell.packages.ghc784.Agda;

    # Custom packages #
    #=================#

    # Projects and dependencies #
    #---------------------------#

    #mcaixictw = callPackage ./local/mcaixictw.nix {};

    #pidetop = callPackage ./local/pidetop.nix {};

    ml4pg = import /home/chris/Programming/ML4PG;
    #ml4pg = callPackage ./local/ml4pg.nix {};

    # FIXME: These should come from git; remove overrides once repos are canonical
    hsPath        = /home/chris/Programming/Haskell/HS2AST;
    hs2ast        = callHaskell hsPath {};
    hs2ast2       = stdenv.lib.overrideDerivation hs2ast (old: {
                      name = "hs2ast2";
                      src  = fetchgit {
                        name   = "hs2ast";
                        url    = hsPath;
                        sha256 = "1lg8p0p30dp6pvbi007hlpxk1bnyxhfazzvgyqrx837da43ymm7f";
                      };
                    });

    tfSrc = fetchgit {
              name   = "tfSrc";
              url    = /home/chris/Programming/Haskell/TreeFeatures;
              sha256 = "1w71h7b1i91fdbxv62m3cbq045n1fdfp54h6bra2ccdj2snibx3y";
            };
    tfPath        = /home/chris/Programming/Haskell/TreeFeatures;
    treefeats     = callHaskell "${tfSrc}/default.nix" {};
    treefeatures  = callPackage ./local/treefeatures.nix {};
    treefeatures2 = stdenv.lib.overrideDerivation treefeats (old: {
                      src = tfSrc;
                    });

    weka = pkgs.weka.override { jre = openjre; };

    coalp = let raw = callHaskell ./local/coalp.nix {};
            in  hsTools.dontCheck (hsTools.dontHaddock raw);

    quickspec = callHaskell /home/chris/Programming/Haskell/quickspec {};
    #quickspec = ./local/quickspec.nix {
    #              cabal = cabal;
    #              QuickCheck = QuickCheck;
    #              random = random;
    #              spoon = spoon;
    #              transformers = transformers;
    #            };

    # QuickSpec v2 and its dependencies (currently taken from v2 GitHub branch)
    # Hopefully these will get added to Hackage eventually...
    #quickspec2     = callHaskell ./local/quickspec2.nix {};

    #jukebox        = callHaskell ./local/jukebox.nix {
    #                   minisat = hsMinisat;
    #                 };

    #hsMinisat      = callHaskell ./local/haskell-minisat.nix {};

    #termRewriting  = callHaskell ./local/term-rewriting.nix {};

    #uglymemo       = callHaskell ./local/uglymemo.nix {};

    #unionFindArray = callHaskell ./local/union-find-array.nix {};

    #z3hs           = with (import <nixpkgs/pkgs/development/haskell-modules/lib.nix> { inherit pkgs; });
    #                 overrideCabal haskellngPackages.z3 (drv: {
    #                   configureFlags = "--extra-include-dirs=${pkgs.z3}/include/ --extra-lib-dirs=${pkgs.z3}/lib/";
    #                 });

    # TIP tools (both from https://github.com/tip-org/tools) and dependencies
    # Hopefully these will get added to Hackage eventually...
    #tipLib             = callPackage ./local/tip-lib.nix              {
    #                       cabal = haskellPackages.cabal.override {
    #                         extension = self : super : {
    #                           noHaddock = true;
    #                         };
    #                       };
    #                     };
    #tipHaskellFrontend = callPackage ./local/tip-haskell-frontend.nix {
    #                       cabal = haskellPackages.cabal;
    #                       geniplate = geniplate;
    #                     };
    #geniplate          = callHaskell ./local/geniplate.nix            {};

    # Writing infrastructure #
    #------------------------#

    md2pdf    = callPackage ./local/md2pdf.nix {};
    panpipe   = callHaskell /home/chris/Programming/Haskell/PanPipe {};
    panhandle = callHaskell /home/chris/Programming/Haskell/pan-handler {};
    #panpipe   = import ./local/panpipe.nix;
    #panhandle = callPackage ./local/panhandle.nix {};
    #ditaaeps  = callPackage ./local/ditaaeps.nix {};

    # Manage chriswarbo.net #
    #-----------------------#

    git2html  = callPackage ./local/git2html.nix {};
    git2html2 = import /home/chris/Programming/git2html;

    # Generates a static HTML interface for git repos
    gitHtml = callPackage ./local/git-html.nix {
                repos = /home/chris/Programming/repos;
              };

    # Other #
    #-------#

    #pngquant       = callPackage ./local/pngquant.nix       {};
    #dupeguru       = callPackage ./local/dupeguru.nix       { pythonPackages = };
    #whitey         = callPackage ./local/whitey.nix         {};
    #bugseverywhere = callPackage ./local/bugseverywhere.nix {};

    # Default Haskell modules
    hsEnv = haskellPackages.ghcWithPackages (pkgs : [
              pkgs.Agda
              pkgs.xmonad
              pkgs.xmonad-extras
              pkgs.xmonad-contrib
            ]);

    # Overrides #
    #===========#

    # Use OpenJDK rather than IcedTea, since it has far fewer dependencies
    jre = openjre;

    # Updated get_iplayer
    #get_iplayer = stdenv.lib.overrideDerivation pkgs.get_iplayer (oldAttrs : {
    #  name = "get_iplayer-2.92";
    #  src  = fetchurl {
    #    url    = ftp://ftp.infradead.org/pub/get_iplayer/get_iplayer-2.92.tar.gz;
    #    sha256 = "1pg4ay32ykxbnvk9dglwpbfjwhcc4ijfl8va89jzyxicbf7s6077";
    #  };
    #});

    # Coq with Mtac support
    #coq_mtac = stdenv.lib.overrideDerivation coq (oldAttrs : {
    #  name = "coq-mtac";
    #  src  = fetchgit {
    #    url    = https://github.com/beta-ziliani/coq.git;
    #    rev    = "2651fd3";
    #    sha256 = "1949z7pjb51w89954narwcd1ykb9wxi7prldic1a1slxrr5b6lq7";
    #  };
    #});

    # Haskell Fix #
    #-------------#

    # Bug https://github.com/NixOS/nixpkgs/issues/7810 causes ghc742Binary to
    # look for libncurses.so.5 which the default ncurses doesn't provide. We use
    # ncursesFix to work around this. The ./local/ncurses directory is just a
    # copy of nixpkgs 41b53577a8f2:pkgs/development/libraries/ncurses

    ncursesFix = callPackage ./local/ncurses {};

    # We *could* override ncurses with ncursesFix at the top level, ie.

    #ncurses = ncursesFix;

    # But we'd rather not, since that would cause most of the OS to be rebuilt.
    # Instead, we only override the ncurses used by ghc742Binary.

    # Since GHC is written in Haskell, it needs to be bootstrapped. As of
    # 2015-05-27 the default haskellPackages is built with ghc7101, ghc7101 is
    # built with ghc784 and ghc784 is built with the pre-built binary
    # ghc742Binary.
    # These packages are defined relative to each other in haskell-packages.nix,
    # rather than going through the top level where we can override them. Hence
    # we must override:
    #
    #  - haskell.compiler.ghc742Binary (to fix the ncurses issue)
    #  - haskell.compiler.ghc784       (to be built by *our* ghc742Binary)
    #  - haskell.compiler.ghc7101      (to be built by *our* ghc784)
    #  - haskell.packages.ghc7101      (to be built by *our* ghc7101)
    #  - haskellPackages               (to be *our* haskell.packages.ghc7101)

    # Define the compilers and packages
    ghc742BinaryC = pkgs.haskell.compiler.ghc742Binary.override {
                      ncurses = ncursesFix;
                    };
    ghc784C  = pkgs.haskell.compiler.ghc784.override  { ghc = ghc742BinaryC; };
    ghc7101C = pkgs.haskell.compiler.ghc7101.override { ghc = ghc784C;       };
    ghc784P  = pkgs.haskell.packages.ghc784.override  { ghc = ghc784C;       };
    ghc7101P = pkgs.haskell.packages.ghc7101.override { ghc = ghc7101C;      };

    # Replace the regular Haskell setup with our modification
    haskell = pkgs.haskell // {
      compiler = pkgs.haskell.compiler // {
        ghc742Binary = ghc742BinaryC;
        ghc784       = ghc784C;
        ghc7101      = ghc7101C;
      };
      packages = {
        ghc784  = ghc784P;
        ghc7101 = ghc7101P;
      };
    };

    # Point the default synonym to our setup
    haskellPackages = haskell.packages.ghc7101;
  };
}
