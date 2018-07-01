# This one package depends on all of the packages we might want in a user
# profile so we don't need to keep track of everything separately. If you're on
# NixOS you can make these available using /etc/nixos/configuration.nix
# If you're using Nix standalone, or want per-user configuration, you can run
# a command like `nix-env -iA all` to install into your profile.
self: super:

with builtins;
with super.lib;
with {
  packages = self.stripOverrides (widgetThemes // {
    inherit (gnome3)      gcr;
    inherit (nixpkgs1709) abiword conkeror firefox gnumeric mplayer vlc;
    inherit (self)        acpi albert anonymous-pro-font arandr aspell audacious
      awf basic basket blueman cmus compton dillo droid-fonts emacsWithPkgs
      gcalcli gensgs iotop kbibtex_full keepassx leafpad lxappearance mu mupdf
      paprefs pavucontrol picard pidgin-with-plugins trayer w3m xsettingsd;
    inherit (xfce)        exo xfce4notifyd;
    inherit (xorg)        xkill;
    aspellDicts = aspellDicts.en;
  });
};

assert all self.isDerivation (attrValues packages) || self.die {
  error   = "Non-derivation in dependencies of all.nix";
  types   = mapAttrs (_: typeOf) packages;
  nonDrvs = mapAttrs (_: typeOf)
    (filterAttrs (_: x: !(self.isDerivation x)) packages);
};

{
  overrides = {
    all = self.buildEnv { name  = "all"; paths = attrValues packages; };
  };

  tests = self.hasBinary self.all "firefox";
}
