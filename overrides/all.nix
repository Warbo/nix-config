# This one package depends on all of the packages we might want in a user
# profile so we don't need to keep track of everything separately. If you're on
# NixOS you can make these available using /etc/nixos/configuration.nix
# If you're using Nix standalone, or want per-user configuration, you can run
# a command like `nix-env -iA all` to install into your profile.
{ /*abiword,*/ acpi, albert, anonymous-pro-font, arandr, aspell, aspellDicts,
  audacious, awf, basic, basket, blueman, buildEnv, cmus, compton, die, dillo,
  droid-fonts, emacsWithPkgs, /*firefox,*/ gcalcli, gensgs, gnome3, hasBinary,
  iotop, kbibtex_full, keepassx, leafpad, lib, lxappearance, /*mplayer,*/ mu,
  mupdf, nixpkgs1709, paprefs, pavucontrol, picard, pidgin-with-plugins,
  stripOverrides, xfce, xorg, trayer, /*vlc,*/ w3m, widgetThemes,
  xsettingsd }@args:

with builtins;
with lib;
with rec {
  nonPackages = [
    "aspellDicts" "buildEnv" "die" "gnome3" "hasBinary" "lib" "nixpkgs1709"
    "stripOverrides" "widgetThemes" "xfce" "xorg"
  ];

  extras = widgetThemes // {
    inherit (gnome3)      gcr;
    inherit (nixpkgs1709) abiword conkeror firefox gnumeric mplayer vlc;
    inherit (xfce)        exo xfce4notifyd;
    inherit (xorg)        xkill;
    aspellDicts = aspellDicts.en;
  };

  packages = stripOverrides (extras // filterAttrs (n: _: !(elem n nonPackages))
                                                   args);
};
assert all isDerivation (attrValues packages) || die {
  error   = "Non-derivation in dependencies of all.nix";
  types   = mapAttrs (_: typeOf) packages;
  nonDrvs = mapAttrs (_: typeOf)
                     (filterAttrs (_: x: !(isDerivation x)) packages);
};
rec {
  pkg   = buildEnv { name = "all"; paths = attrValues packages; };
  tests = hasBinary pkg "firefox";
}
