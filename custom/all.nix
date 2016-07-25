# This one package depends on all of the packages we want in our user config
# so we don't need to keep track of everything separately. Use commands like
# `nix-env -i all`, etc. to get the equivalent of a per-user `nixos-rebuild`

self: super:

with self;

let haskellPackages = haskell.packages.ghc7103;
 in {

all = buildEnv {
  name = "all";
  paths = [
    acpi
    anonymous-pro-font
    aspell
    aspellDicts.en
    autossh
    kde4.basket
    binutils
    haskellPackages.cabal-install
    haskellPackages.cabal2nix
    cmus
    compton
    conkeror
    dillo
    dmenu
    droid-fonts
    dtach
    dvtm
    emacs
    file
    firefox
    gcalcli
    gensgs
    get_iplayer
      # FIXME: These two should be dependencies of get_iplayer
      perlPackages.XMLSimple
      ffmpeg
    ghc
    ghostscript
    git
    gnumake
    gtk_engines
    kbibtex_full
    md2pdf
    mplayer
    msmtp
    mupdf

    # Networking GUI, requires keyring
    networkmanagerapplet
    gnome3.gcr

    nix-repl
    openssh
    pamixer
    panhandle
    panpipe
    paprefs
    pavucontrol
    pidgin
    poppler_utils
    xorg.xkill
    pmutils
    psmisc
    arandr
    cifs_utils
    silver-searcher
    skulpture
    sshfsFuse
    sshuttle
    smbnetfs
    sox
    st
    imagemagick
    tightvnc
    trayer
    ts
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
    xorg.xproto
    youtube-dl
    zip
  ];
};

}
