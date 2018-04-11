{ clearlooks-phenix, e17gtk-theme, gtk2-aurora-engine, gtk_engines,
  gtk-engine-murrine, skulpture, vertex-theme, xfce, zuki-theme }:

[
  clearlooks-phenix
  e17gtk-theme
  gtk2-aurora-engine
  gtk_engines
  gtk-engine-murrine
  skulpture  # Qt, but meh
  vertex-theme
  (xfce.gtk_xfce_engine.override { withGtk3 = true; })
  zuki-theme
]
