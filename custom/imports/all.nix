# This one package depends on all of the packages we want in our user config
# so we don't need to keep track of everything separately. Use commands like
# `nix-env -i all`, etc. to get the equivalent of a per-user `nixos-rebuild`

with import <nixpkgs> {};

buildEnv {
  name = "all";
  paths = [
    abduco
    aspell
    aspellDicts.en
    kde4.basket
    binutils
    haskellPackages.cabal-install
    cabal2nix
    cmus
    compton
    conkeror
    coq
    dash
    dillo
    dmenu
    droid-fonts
    dvtm
    emacs
    file
    firefox
    gensgs
    get_iplayer
      # FIXME: These two should be dependencies of get_iplayer
      perlPackages.XMLSimple
      ffmpeg
    ghc
    ghostscript
    gimp
    git
    gnumake
    gtk_engines
    inkscape
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
    psmisc
    arandr
    cifs_utils
    skulpture
    sshfsFuse
    smbnetfs
    sox
    st
    imagemagick
    tightvnc
    tomahawk
    trayer
    uae
    unzip
    vlc
    w3m
    warbo-utilities
    wget
    wmname
    xbindkeys
    xcalib
    xcape
    xfce.exo
    xfce.gtk_xfce_engine
    xfce.xfce4notifyd
    xorg.xmodmap
    haskellPackages.xmobar
    xmp
    xorg.xproto
    xsane
    youtube-dl
    zip
    zotero
  ];
}
