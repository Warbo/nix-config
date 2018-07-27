self: super:

{
  overrides = {
    widgetThemes = self.skulpture // {
      inherit (self) clearlooks-phenix e17gtk-theme gtk2-aurora-engine
        gtk_engines gtk-engine-murrine vertex-theme zuki-theme;
    };

    # Force screen dimming so we can tell it's running
    dmenu2 = self.attrsToDirs' "dmenu2" {
      bin = {
        dmenu     = "${super.dmenu2}/bin/dmenu";
        dmenu_run = self.wrap {
          name   = "dmenu_run-patched";
          paths  = [ self.bash ];
          script = ''
            #!/usr/bin/env bash
            exec "${super.dmenu2}/bin/dmenu_run" -dim 0.5 "$@"
          '';
        };
      };
    };
  };
  tests = {};
}
