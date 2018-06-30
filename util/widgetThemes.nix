{ clearlooks-phenix, e17gtk-theme, gtk2-aurora-engine, gtk_engines,
  gtk-engine-murrine, skulpture, vertex-theme, xfce, zuki-theme }:

{
  inherit clearlooks-phenix e17gtk-theme gtk2-aurora-engine gtk_engines
    gtk-engine-murrine skulpture vertex-theme zuki-theme;
  gtk_xfce_engine = ((xfce.gtk_xfce_engine or xfce.gtk-xfce-engine).override {
    withGtk3 = true;
  });
}
