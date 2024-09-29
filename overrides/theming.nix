self: super:

{
  overrides = {
    iconThemes = {
      inherit (self) hicolor-icon-theme;
      inherit (self.gnome2) gnome_icon_theme;
      inherit (self.gnome3) adwaita-icon-theme;
    };

    widgetThemes =
      with rec {
        warbo-packages = self.warbo-packages or (import ./repos.nix self super).overrides.warbo-packages;
        skulpture = self.skulpture or warbo-packages.skulpture;
      }; {
        # These come from upstream, so should always be available
        inherit (self)
          clearlooks-phenix
          e17gtk
          gtk_engines
          gtk-engine-murrine
          theme-vertex
          zuki-themes
          ;

        # These come from warbo-packages, which may not be included in overlays.
        # Look them up in self, to allow overrides; but fall back to loading
        # them directly from warbo-packages.
        blueshell-theme = self.blueshell-theme or warbo-packages.blueshell-theme;

        # TODO: This is broken due to Nixpkgs renaming pkgconfig
        #gtk2-aurora-engine = self.gtk2-aurora-engine or warbo-packages.gtk2-aurora-engine

        skulpture-qt5 = self.skulpture-qt5 or skulpture.qt5;
        skulpture-qt6 = self.skulpture-qt6 or skulpture.qt6;
      };
  };
}
