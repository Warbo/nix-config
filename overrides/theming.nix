self: super:

{
  overrides = {
    iconThemes = {
      inherit (self       ) hicolor-icon-theme;
      inherit (self.gnome2)   gnome_icon_theme;
      inherit (self.gnome3) adwaita-icon-theme;
    };
    widgetThemes = self.skulpture // {
      inherit (self) blueshell-theme clearlooks-phenix e17gtk-theme
        gtk2-aurora-engine gtk_engines gtk-engine-murrine vertex-theme
        zuki-theme;
    };
  };
  tests = {};
}
