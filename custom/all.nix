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
    arandr
    aspell
    aspellDicts.en
    basic
    kde4.basket
    cmus
    compton
    conkeror
    dillo
    dmenu
    droid-fonts
    emacs
    firefox
    gcalcli
    gensgs
    ghc
    gtk_engines
    haskellPackages.cabal-install
    haskellPackages.cabal2nix
    haskellPackages.stack
    kbibtex_full
    mplayer
    mu
    mupdf

    # Networking GUI, requires keyring
    networkmanagerapplet
    gnome3.gcr
    paprefs
    pavucontrol
    pidgin
    xorg.xkill
    skulpture
    trayer
    vlc
    w3m
    xfce.exo
    xfce.gtk_xfce_engine
    xfce.xfce4notifyd
    haskellPackages.xmobar
  ];
};

}
