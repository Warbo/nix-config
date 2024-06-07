self: super:

{
  overrides = {
    iconThemes = {
      inherit (self) hicolor-icon-theme;
      inherit (self.gnome2) gnome_icon_theme;
      inherit (self.gnome3) adwaita-icon-theme;
    };

    widgetThemes = {
      inherit (self)
        blueshell-theme
        clearlooks-phenix
        e17gtk-theme
        gtk2-aurora-engine
        gtk_engines
        gtk-engine-murrine
        vertex-theme
        zuki-theme
        ;

      inherit (self.skulpture) skulpture-qt4;

      skulpture-qt5 = self.libsForQt5.skulpture;
    };

    mkLibsForQt5 =
      qelf:
      super.mkLibsForQt5 qelf
      // {
        skulpture = qelf.callPackage self.skulpture.mkSkulptureQt5 { };
      };
  };
}
