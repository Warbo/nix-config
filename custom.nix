pkgs: local: with pkgs; local // rec {

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

  ml4pg  = import (fetchgit {
                     name   = "ml4pg";
                     url    = /home/chris/Programming/repos/ml4pg.git;
                     sha256 = "03v6vxb6dnrx5fvw8x7x4xkmhvzhq71qpkzv54pmvnb775m933rv";
                   });

  # Default version of Theory Exploration tools
  inherit (import (fetchgit {
             name   = "haskell-te";
             url    = /home/chris/Programming/repos/haskell-te.git;
             rev    = import ./local/haskell-te.rev;
             sha256 = import ./local/haskell-te.sha256;
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

  # Manage chriswarbo.net #
  #-----------------------#

  git2html-real = callPackage ./local/git2html.nix {};
  git2html      = stdenv.lib.overrideDerivation git2html-real (old: {
                    src = /home/chris/Programming/git2html;
                  });

  # Other #
  #-------#

  pdf-extract     = callPackage ./local/pdf-extract        {};

  warbo-utilities = import /home/chris/warbo-utilities;

  # Default Haskell modules
  hsEnv = haskellPackages.ghcWithPackages (pkgs : [
            pkgs.xmonad
            pkgs.xmonad-extras
            pkgs.xmonad-contrib
          ]);

  ghcTurtle = haskellPackages.ghcWithPackages (pkgs: [ pkgs.turtle ]);

  #haskellPackages = pkgs.haskellPackages.override {
  #  overrides = self: super: {
  #    nix-eval         = self.callPackage (import /home/chris/Programming/Haskell/nix-eval) {};
  #    every-bit-counts = self.callPackage (import /home/chris/System/Packages/Haskell/ebc/new) {};
  #  };
  #};

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
}
