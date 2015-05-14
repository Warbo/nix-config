{
  packageOverrides = pkgs: with pkgs; rec {

    # Custom packages
    panpipe        = callPackage ./local/panpipe.nix        {};
    panhandle      = callPackage ./local/panhandle.nix      {};
    pngquant       = callPackage ./local/pngquant.nix       {};
    #dupeguru       = callPackage ./local/dupeguru.nix       { pythonPackages = };
    mcaixictw      = callPackage ./local/mcaixictw.nix      {};
    #whitey         = callPackage ./local/whitey.nix         {};
    #ml4pg          = callPackage ./local/ml4pg.nix          {};
    #bugseverywhere = callPackage ./local/bugseverywhere.nix {};
    #pidetop        = callPackage ./local/pidetop.nix        {};

    # TIP tools     https://github.com/tip-org/tools
    geniplate          = with haskellPackages;
                         callPackage ./local/geniplate.nix            {};

    tipLib             = callPackage ./local/tip-lib.nix              {
                           cabal = haskellPackages.cabal.override {
                             extension = self : super : {
                               noHaddock = true;
                             };
                           };
                         };
    tipHaskellFrontend = callPackage ./local/tip-haskell-frontend.nix {
                           cabal = haskellPackages.cabal;
                           geniplate = geniplate;
                         };

    treefeatures   = callPackage ./local/treefeatures.nix   {};
    ditaaeps       = callPackage ./local/ditaaeps.nix       {};
    md2pdf         = callPackage ./local/md2pdf.nix         {};
    quickspec      = with haskellPackages;
                     callPackage ./local/quickspec.nix      {
                       #cabal = cabal;
                       #QuickCheck = QuickCheck;
                       #random = random;
                       #spoon = spoon;
                       #transformers = transformers;
                     };

    # QuickSpec v2 and dependencies (currently taken from v2 GitHub branch)
    quickspec2     = with haskellPackages;
                     callPackage ./local/quickspec2.nix {};

    jukebox        = with haskellPackages;
                     callPackage ./local/jukebox.nix {
                       minisat = hsMinisat;
                     };

    hsMinisat      = with haskellPackages;
                     callPackage ./local/haskell-minisat.nix {};

    termRewriting  = with haskellPackages;
                     callPackage ./local/term-rewriting.nix {
                     };

    uglymemo       = with haskellPackages;
                     callPackage ./local/uglymemo.nix {};

    unionFindArray = with haskellPackages;
                     callPackage ./local/union-find-array.nix {};

    z3hs           = with (import <nixpkgs/pkgs/development/haskell-modules/lib.nix> { inherit pkgs; });
                     overrideCabal haskellngPackages.z3 (drv: {
                       configureFlags = "--extra-include-dirs=${pkgs.z3}/include/ --extra-lib-dirs=${pkgs.z3}/lib/";
                     });

    # Updated get_iplayer
    get_iplayer = stdenv.lib.overrideDerivation pkgs.get_iplayer (oldAttrs : {
      name = "get_iplayer-2.92";
      src  = fetchurl {
        url    = ftp://ftp.infradead.org/pub/get_iplayer/get_iplayer-2.92.tar.gz;
        sha256 = "1pg4ay32ykxbnvk9dglwpbfjwhcc4ijfl8va89jzyxicbf7s6077";
      };
    });

    # GVFS with Samba support
    #gvfs = gvfs.override { gnome = gnome3;
    #                       gnomeSupport = true; };

    # Coq with Mtac support
    coq_mtac = stdenv.lib.overrideDerivation coq (oldAttrs : {
      name = "coq-mtac";
      src  = fetchgit {
        url    = https://github.com/beta-ziliani/coq.git;
        rev    = "2651fd3";
        sha256 = "1949z7pjb51w89954narwcd1ykb9wxi7prldic1a1slxrr5b6lq7";
      };
    });

    git2html = callPackage ./local/git2html.nix {};

    hs2ast = with haskellPackages;
             callPackage /home/chris/Programming/Haskell/HS2AST/default.nix {};

    treefeats = with haskellPackages;
                callPackage /home/chris/Programming/Haskell/TreeFeatures/default.nix {};

    # Default Haskell modules
    #hsEnv = haskellPackages.ghcWithPackagesOld (pkgs : [
    #   pkgs.xmonad
    #   pkgs.xmonadExtras
    #   pkgs.xmonadContrib
    #]);
  };
}
