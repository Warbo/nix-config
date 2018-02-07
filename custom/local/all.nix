# This one package depends on all of the packages we want in our user config
# so we don't need to keep track of everything separately. If you're on NixOS
# you can make these available system-wide using /etc/nixos/configuration.nix
# If you're using Nix standalone, or want per-user configuration, you can run
# a command like `nix-env -iA all` to install into your profile.

{ customised, self, stable }:

with self;
buildEnv {
  name  = "all";
  paths = [
    acpi
    anonymous-pro-font
    arandr
    aspell
    aspellDicts.en
    asublim
    audacious
    basic # Anything useful for scripts should go in here
    (if stable then nixpkgs1709 else self).blueman
    basket
    clearlooks-phenix
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
    picard
    customised.nixpkgs1609.pidgin-with-plugins
    xorg.xkill
    skulpture
    trayer
    vlc
    w3m
    xfce.exo
    (xfce.gtk_xfce_engine.override { withGtk3 = true; })
    xfce.xfce4notifyd
    xsettingsd
  ];
}
