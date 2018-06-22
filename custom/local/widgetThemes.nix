{ clearlooks-phenix, customised, e17gtk-theme, gtk2-aurora-engine, gtk_engines,
  gtk-engine-murrine, skulpture, vertex-theme, xfce, zuki-theme }:

with builtins;
[
  clearlooks-phenix
  e17gtk-theme
  gtk2-aurora-engine
  gtk_engines
  gtk-engine-murrine
  skulpture
  vertex-theme

  ((if customised ? nixpkgs1709
       then (x: x)
       else trace ''Warning: No need to check for gtk_xfce_engines now that
                    nixpkgs < 18.03 doesn't seem to be supported anymore.'')
   ((xfce.gtk_xfce_engine or xfce.gtk-xfce-engine).override {
      withGtk3 = true;
    }))

  zuki-theme
]
