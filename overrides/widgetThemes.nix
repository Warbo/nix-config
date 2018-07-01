self: super:

{
  overrides = {
    widgetThemes = {
      inherit (self) clearlooks-phenix e17gtk-theme gtk2-aurora-engine
        gtk_engines gtk-engine-murrine skulpture vertex-theme zuki-theme;
    };
  };
  tests = {};
}
