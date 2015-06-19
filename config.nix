{
  allowUnfree = true;
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

    ml4pg  = import (fetchgit {
                       name   = "ml4pg";
                       url    = /home/chris/Programming/repos/ml4pg.git;
                       sha256 = "03v6vxb6dnrx5fvw8x7x4xkmhvzhq71qpkzv54pmvnb775m933rv";
                     });

    # Default version of Theory Exploration tools
    inherit (import (fetchgit {
               name   = "haskell-te";
               url    = /home/chris/Programming/repos/haskell-te.git;
               rev    = "3d43f79";
               sha256 = "0i2xlp101ffd8r1zn6hcqvg41qn8d7xvf2pj2igka26hk4b1ndxa";
             }) {})
      quickspec hipspec hipspecifyer hs2ast treefeatures ml4hs mlspec
      ArbitraryHaskell;

    # Work-in-progress version of Theory Exploration tools (useful for
    # integration testing before committing/pushing)
    te-unstable = (import /home/chris/System/Packages/haskell-te) {
      hs2ast           = /home/chris/Programming/Haskell/HS2AST;
      treefeatures     = /home/chris/Programming/Haskell/TreeFeatures;
      ArbitraryHaskell = /home/chris/Programming/Haskell/ArbitraryHaskell;
      ml4hs            = /home/chris/Programming/Haskell/ML4HS;
    };

    coalp = let raw = callHaskell ./local/coalp.nix {};
            in  hsTools.dontCheck (hsTools.dontHaddock raw);

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

    panpipe   = callHaskell (fetchgit {
                               name   = "panpipe";
                               url    = http://chriswarbo.net/git/panpipe.git;
                               sha256 = "0sajlq926yr4684vbzmjh2209fnmrx1p1lqfbhxj5j0h166424ak";
                             }) {};
    panhandle = callHaskell (fetchgit {
                               name   = "panhandle";
                               url    = http://chriswarbo.net/git/panhandle.git;
                               rev    = "f49f798";
                               sha256 = "0gdaw7q9ciszh750nd7ps5wvk2bb265iaxs315lfl4rsnbvggwkd";
                             }) {};

    #ditaaeps  = callPackage ./local/ditaaeps.nix {};

    # Manage chriswarbo.net #
    #-----------------------#

    git2html-real = callPackage ./local/git2html.nix {};
    git2html      = stdenv.lib.overrideDerivation git2html-real (old: {
                      src = /home/chris/Programming/git2html;
                    });
    cwNet         = import /home/chris/blog;

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

    # Updated get_iplayer
    get_iplayer = stdenv.lib.overrideDerivation pkgs.get_iplayer (oldAttrs : {
      name = "get_iplayer";
      src  = fetchurl {
        url    = ftp://ftp.infradead.org/pub/get_iplayer/get_iplayer-2.94.tar.gz;
        sha256 = "16p0bw879fl8cs6rp37g1hgrcai771z6rcqk2nvm49kk39dx1zi4";
      };
    });

    # Coq with Mtac support
    #coq_mtac = stdenv.lib.overrideDerivation coq (oldAttrs : {
    #  name = "coq-mtac";
    #  src  = fetchgit {
    #    url    = https://github.com/beta-ziliani/coq.git;
    #    rev    = "2651fd3";
    #    sha256 = "1949z7pjb51w89954narwcd1ykb9wxi7prldic1a1slxrr5b6lq7";
    #  };
    #});
  };
}
