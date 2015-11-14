# This one package depends on all of the packages we want in our user config
# so we don't need to keep track of everything separately. Use commands like
# `nix-env -i all`, etc. to get the equivalent of a per-user `nixos-rebuild`

with import <nixpkgs> {};

buildEnv {
  name = "all";
  paths = [
    abduco
    kde4.basket
    binutils
    haskellPackages.cabal-install
    cabal2nix
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
    ghostscript
    gimp
    git
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
    arandr
    cifs_utils
    skulpture
    sshfsFuse
    tightvnc
    trayer
    uae
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
}
