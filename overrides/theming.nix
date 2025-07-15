self: super:

with {
  warbo-packages =
    self.warbo-packages or (
      (rec { inherit (import ./repos.nix overrides super) overrides; })
      .overrides.warbo-packages
    );
};
with { skulpture = self.skulpture or warbo-packages.skulpture; };
{
  overrides = {
    iconThemes = {
      inherit (self) adwaita-icon-theme gnome-icon-theme hicolor-icon-theme;
    };

    widgetThemes = {
      # These come from upstream, so should always be available
      inherit (self)
        clearlooks-phenix
        e17gtk
        gtk_engines
        gtk-engine-murrine
        theme-vertex
        zuki-themes
        ;

      qt5styleplugin-kvantum = self.libsForQt5.qtstyleplugin-kvantum;
      qt6styleplugin-kvantum = self.qt6Packages.qtstyleplugin-kvantum;

      # These come from warbo-packages, which may not be included in overlays.
      # Look them up in self, to allow overrides; but fall back to loading
      # them directly from warbo-packages.
      blueshell-theme = self.blueshell-theme or warbo-packages.blueshell-theme;

      # TODO: This is broken due to Nixpkgs renaming pkgconfig
      #gtk2-aurora-engine = self.gtk2-aurora-engine or
      #  warbo-packages.gtk2-aurora-engine

      skulpture-qt5 = self.skulpture-qt5 or skulpture.qt5;
      skulpture-qt6 = self.skulpture-qt6 or skulpture.qt6;
    };
  };
}
