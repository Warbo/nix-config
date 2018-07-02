self: super:

{
  overrides = {
    widgetThemes = {
      inherit (self) clearlooks-phenix e17gtk-theme gtk2-aurora-engine
        gtk_engines gtk-engine-murrine vertex-theme zuki-theme;
      inherit (self.customised.nixpkgs1709) skulpture;
    };
  };
  tests = {};
}
