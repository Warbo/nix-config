# This one package depends on all of the packages we want in our user config
# so we don't need to keep track of everything separately. If you're on NixOS
# you can make these available system-wide using /etc/nixos/configuration.nix
# If you're using Nix standalone, or want per-user configuration, you can run
# a command like `nix-env -iA all` to install into your profile.

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
    basic # Anything useful for scripts should go in here
    stable.kde4.basket
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
    gtk_engines
    iotop
    kbibtex_full
    keepassx
    leafpad
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
