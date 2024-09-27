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
        e17gtk
        gtk2-aurora-engine
        gtk_engines
        gtk-engine-murrine
        theme-vertex
        zuki-themes
        ;
      skulpture-qt5 = self.skulpture.qt5;
      skulpture-qt6 = self.skulpture.qt6;
    };

    mkLibsForQt5 =
      qelf:
      super.mkLibsForQt5 qelf // { skulpture = qelf.callPackage self.skulpture.mkSkulptureQt5 { }; };
  };
}
