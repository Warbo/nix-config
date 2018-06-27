# This one package depends on all of the packages we might want in a user
# profile so we don't need to keep track of everything separately. If you're on
# NixOS you can make these available using /etc/nixos/configuration.nix
# If you're using Nix standalone, or want per-user configuration, you can run
# a command like `nix-env -iA all` to install into your profile.
{ abiword, acpi, albert, anonymous-pro-font, arandr, aspell, aspellDicts,
  audacious, awf, basic, basket, blueman, buildEnv, cmus, compton, dillo,
  droid-fonts, emacs, firefox, gcalcli, gensgs, gnome3, iotop, kbibtex_full,
  keepassx, leafpad, lib, lxappearance, mplayer, mu, mupdf,
  networkmanagerapplet, nixpkgs1709, paprefs, pavucontrol, picard,
  pidgin-with-plugins, xfce, xorg, trayer, vlc, w3m, widgetThemes, withDeps,
  xsettingsd }@args:

with builtins;
with lib;
with rec {
  nonPackages = [
    "aspellDicts" "buildEnv" "gnome3" "lib" "widgetThemes" "withDeps" "xfce"
    "xorg"
  ];

  extras = concatLists [
    [ aspellDicts.en ]
    [ gnome3.gcr ]
    (with nixpkgs1709; [ conkeror ])
    widgetThemes
    (with xfce; [ exo xfce4notifyd ])
    (with xorg; [ xkill ])
  ];

  packages = extras ++ map (name: getAttr name args)
                           (filter (name: !(elem name nonPackages))
                                   (attrNames args));
  pkg = buildEnv {
    name  = "all";
    paths = packages;
  };

  tested = withDeps [ (hasBinary pkg "firefox") ] pkg;
};
{
  pkg   = tested;
  tests = tested;
}
