{
  allowUnfree = true;
  packageOverrides = pkgs: with pkgs;

    # Turn files of the form "./local/foo.nix" into packages "foo"
    (with lib;
    let mkPkg = x: old:
      let n = removeSuffix ".nix" x;
       in old // builtins.listToAttrs [{
                   name = n;
                   value = callPackage "${./local}/${n}.nix" {};
                 }];
     in fold mkPkg
              {}
              (filter (hasSuffix ".nix")
                      (builtins.attrNames (builtins.readDir ./local))))
     // rec {

    # Shorthand synonyms #
    #====================#

    # This one package depends on all of the packages we want in our user config
    # so we don't need to keep track of everything separately. Use commands like
    # `nix-env -i all`, etc. to get the equivalent of a per-user `nixos-rebuild`
    all = buildEnv {
      name = "all";
      paths = [
        #bash
        abduco
        kde4.basket
        binutils
        haskellPackages.cabal-install
        cabal2nix
        #cacert
        conkeror
        coq
        dash
        dillo
        dmenu
        dvtm
        emacs
        file
        firefox
        #gcc
        gensgs
        get_iplayer
          # FIXME: These two should be dependencies of get_iplayer
          perlPackages.XMLSimple
          ffmpeg
        #haskellPackages.ghc
        ghostscript
        gimp
        git
        #git2html
        #graphviz
        #imagemagick
        inkscape
        #inotifyTools
        mplayer
        msmtp
        mupdf

        # Networking GUI
        networkmanagerapplet
        gnome3.gcr

        nix-repl
        openssh
        pidgin
        poppler_utils
        xorg.xkill
        pioneers
        pmutils
        #psmisc
        arandr
        #pythonPackages.whitey
        #smbnetfs
        cifs_utils
        sshfsFuse
        tightvnc
        trayer
        uae
        #unison
        unzip
        vlc
        wget
        wmname
        xbindkeys
        xcape
        xfce.exo
        xfce.xfce4notifyd
        xorg.xmodmap
        haskellPackages.xmobar
        xmp
        xorg.xproto
        xsane
        youtube-dl
        zip
        warbo-utilities
        zotero
      ];
    };

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
               rev    = import ./local/haskell-te.rev.nix;
               sha256 = import ./local/haskell-te.sha256.nix;
             }) {})
      quickspec HS2AST treefeatures ml4hs mlspec getDeps
      ArbitraryHaskell AstPlugin ML4HSFE nix-eval order-deps;

    # Work-in-progress version of Theory Exploration tools (useful for
    # integration testing before committing/pushing)
    te-unstable = (import /home/chris/System/Packages/haskell-te) {
      HS2AST           = /home/chris/Programming/Haskell/HS2AST;
      treefeatures     = /home/chris/Programming/Haskell/TreeFeatures;
      ArbitraryHaskell = /home/chris/Programming/Haskell/ArbitraryHaskell;
      ml4hs            = /home/chris/Programming/ML4HS;
      AstPlugin        = /home/chris/Programming/Haskell/AstPlugin;
      nix-eval         = /home/chris/Programming/Haskell/nix-eval;
      mlspec           = /home/chris/Programming/Haskell/MLSpec;
      order-deps       = /home/chris/Programming/Haskell/order-deps;
      getDeps          = /home/chris/Programming/Haskell/getDeps;
    };

    QuickSpecMeasure = haskellPackages.callPackage
                         /home/chris/Programming/Haskell/QuickSpecMeasure {};

    coalp = let raw = haskellPackages.callPackage ./local/coalp.nix {};
            in  haskell.lib.dontCheck (haskell.lib.dontHaddock raw);

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

    # Writing infrastructure #
    #------------------------#

    switchSrc = p: s: stdenv.lib.overrideDerivation p { src = s; };

    panpipe-unstable = switchSrc pkgs.panpipe
                                 /home/chris/Programming/Haskell/PanPipe;

    panhandle-unstable = switchSrc pkgs.panhandle
                                   /home/chris/Programming/Haskell/pan-handler;

    #ditaaeps  = callPackage ./local/ditaaeps.nix {};

    # Manage chriswarbo.net #
    #-----------------------#

    git2html-real = callPackage ./local/git2html.nix {};
    git2html      = stdenv.lib.overrideDerivation git2html-real (old: {
                      src = /home/chris/Programming/git2html;
                    });

    # Other #
    #-------#

    #dupeguru       = callPackage ./local/dupeguru.nix       { pythonPackages = };
    #whitey         = callPackage ./local/whitey.nix         {};
    #bugseverywhere = callPackage ./local/bugseverywhere.nix {};
    linkchecker     = callPackage ./local/linkchecker.nix    {};

    pdfssa4met = callPackage ./local/pdfssa4met.nix {};

    scholar = callPackage ./local/scholar.nix {};

    searchtobibtex = callPackage ./local/searchtobibtex.nix {};

    translitcodec   = callPackage ./local/translitcodec.nix  {};

    pdfmeat         = callPackage ./local/pdfmeat.nix        {};

    x2vnc           = callPackage ./local/x2vnc.nix          {};

    x2x = callPackage ./local/x2x.nix {};

    subdist = callPackage ./local/subdist.nix {};

    docear = callPackage ./local/docear.nix {};

    jsbeautifier    = callPackage ./local/jsbeautifier.nix   {};

    bibclean        = callPackage ./local/bibclean.nix       {};

    pdf-extract     = callPackage ./local/pdf-extract        {};

    warbo-utilities = import /home/chris/warbo-utilities;

    # Default Haskell modules
    hsEnv = haskellPackages.ghcWithPackages (pkgs : [
              pkgs.xmonad
              pkgs.xmonad-extras
              pkgs.xmonad-contrib
            ]);

    ghcTurtle = haskellPackages.ghcWithPackages (pkgs: [ pkgs.turtle ]);

    haskellPackages = pkgs.haskellPackages.override {
      overrides = self: super: {
        nix-eval         = self.callPackage (import /home/chris/Programming/Haskell/nix-eval) {};
        mlspec-helper    = te-unstable.mlspec-helper;
        every-bit-counts = self.callPackage (import /home/chris/S
        ystem/Packages/Haskell/ebc/new) {};
      };
    };

    # To use profiled libraries, use: nix-shell --arg compiler '"profiled"'
    #haskell.packages.profiled = haskellPackages.override {
    #  overrides = self: super: {
    #    mkDerivation = args: super.mkDerivation (args // {
    #      enableLibraryProfiling = true;
    #    });
    #  };
    #};

    # Overrides #
    #===========#

    # Updated get_iplayer
    get_iplayer = stdenv.lib.overrideDerivation pkgs.get_iplayer (oldAttrs : {
      name = "get_iplayer";
      src  = fetchurl {
        url    = ftp://ftp.infradead.org/pub/get_iplayer/get_iplayer-2.94.tar.gz;
        sha256 = "16p0bw879fl8cs6rp37g1hgrcai771z6rcqk2nvm49kk39dx1zi4";
      };
      propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
        perlPackages.XMLSimple
        ffmpeg
      ];
    });

    # Coq with Mtac support
    coq_mtac = stdenv.lib.overrideDerivation coq (oldAttrs : {
      name = "coq-mtac";
      src  = fetchgit {
        url    = https://github.com/beta-ziliani/coq.git;
        rev    = "2651fd3";
        sha256 = "1949z7pjb51w89954narwcd1ykb9wxi7prldic1a1slxrr5b6lq7";
      };
    });
  };
}
