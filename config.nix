{
  packageOverrides = pkgs: with pkgs; rec {

    # Lets us turn off tests,haddock, etc.
    hsTools = import "${<nixpkgs>}/pkgs/development/haskell-modules/lib.nix" {
      inherit pkgs;
    };

    # Use OpenJDK rather than IcedTea, since it has far fewer dependencies
    jre = openjre;

    # Custom packages
    #panpipe        = import ./local/panpipe.nix;
    panpipe        = haskellPackages.callPackage /home/chris/Programming/Haskell/PanPipe {};
    #panhandle      = callPackage ./local/panhandle.nix      {};
    panhandle      = haskellPackages.callPackage /home/chris/Programming/Haskell/pan-handler {};
    pandocLib      = hsTools.dontCheck
                       (haskellPackages.callPackage ./local/pandoc.nix {});
    #pngquant       = callPackage ./local/pngquant.nix       {};
    #dupeguru       = callPackage ./local/dupeguru.nix       { pythonPackages = };
    #mcaixictw      = callPackage ./local/mcaixictw.nix      {};
    #whitey         = callPackage ./local/whitey.nix         {};
    #ml4pg          = callPackage ./local/ml4pg.nix          {};
    ml4pg          = import /home/chris/Programming/ML4PG;
    #bugseverywhere = callPackage ./local/bugseverywhere.nix {};
    #pidetop        = callPackage ./local/pidetop.nix        {};

    # TIP tools     https://github.com/tip-org/tools
    #geniplate          = with haskellPackages;
    #                     callPackage ./local/geniplate.nix            {};

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

    #treefeatures   = callPackage ./local/treefeatures.nix   {};
    #ditaaeps       = callPackage ./local/ditaaeps.nix       {};

    quickspec      = haskellPackages.callPackage /home/chris/Programming/Haskell/quickspec {};
    #./local/quickspec.nix {
                       #cabal = cabal;
                       #QuickCheck = QuickCheck;
                       #random = random;
                       #spoon = spoon;
                       #transformers = transformers;
    #                 };

    # QuickSpec v2 and dependencies (currently taken from v2 GitHub branch)
    #quickspec2     = with haskellPackages;
    #                 callPackage ./local/quickspec2.nix {};

    #jukebox        = with haskellPackages;
    #                 callPackage ./local/jukebox.nix {
    #                   minisat = hsMinisat;
    #                 };

    #hsMinisat      = with haskellPackages;
    #                 callPackage ./local/haskell-minisat.nix {};

    #termRewriting  = with haskellPackages;
    #                 callPackage ./local/term-rewriting.nix {
    #                 };

    #uglymemo       = with haskellPackages;
    #                 callPackage ./local/uglymemo.nix {};

    #unionFindArray = with haskellPackages;
    #                 callPackage ./local/union-find-array.nix {};

    #z3hs           = with (import <nixpkgs/pkgs/development/haskell-modules/lib.nix> { inherit pkgs; });
    #                 overrideCabal haskellngPackages.z3 (drv: {
    #                   configureFlags = "--extra-include-dirs=${pkgs.z3}/include/ --extra-lib-dirs=${pkgs.z3}/lib/";
    #                 });

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

    md2pdf   = callPackage ./local/md2pdf.nix   {};
    git2html = callPackage ./local/git2html.nix {};
    git2html2 = import /home/chris/Programming/git2html;

    hs2ast = haskellPackages.callPackage /home/chris/Programming/Haskell/HS2AST/default.nix {};

    treefeats = haskellPackages.callPackage /home/chris/Programming/Haskell/TreeFeatures/default.nix {};

    weka = pkgs.weka.override {
      jre = openjre;
    };

    # CoALP, via cabal2nix; make sure doCheck and doHaddock are false
    coalp = let raw = haskellPackages.callPackage ./local/coalp.nix {};
            in  hsTools.dontCheck (hsTools.dontHaddock raw);

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

    # Default Haskell modules
    hsEnv = haskellPackages.ghcWithPackages (pkgs : [
       pkgs.Agda
       pkgs.xmonad
       pkgs.xmonad-extras
       pkgs.xmonad-contrib
    ]);

    haskell-agda = haskell.packages.ghc784.Agda;

    # Manage chriswarbo.net

    # Bare clones of all git repos, with post-update hooks in place
    gitRepos = /home/chris/Programming/repos;

    # Generates a static HTML interface for git repos
    gitHtml = callPackage ./local/git-html.nix { repos = gitRepos; };


  };
}
