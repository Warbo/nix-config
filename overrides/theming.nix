self: super:

{
  overrides = {
    widgetThemes = self.skulpture // {
      inherit (self) clearlooks-phenix e17gtk-theme gtk2-aurora-engine
        gtk_engines gtk-engine-murrine vertex-theme zuki-theme;
    };
  };
  tests = {};
}
