# Force firefox 59, since Nixpkgs 17.09 FF seems crashy
{ bash, fetchurl, lib, mkBin, super, steam, unpack, wrap }:

with builtins;
with rec {
  ff      = super.firefox;
  version = ff.version or elemAt (lib.splitString "-" ff.name) 1;
  check   = if compareVersions "59" version == 1
               then (x: x)
               else trace "FIXME: Don't override, have Firefox 59 (${version})";

  firefoxDeps = p: with p; with gnome2; [ gtk3 gtk2 perl zip libIDL libjpeg
    zlib bzip2 dbus dbus_glib pango freetype fontconfig xorg.libXi
    xorg.libX11 xorg.libXrender xorg.libXft xorg.libXt file
    nspr libnotify xorg.pixman yasm mesa
    xorg.libXScrnSaver xorg.scrnsaverproto
    xorg.libXext xorg.xextproto sqlite unzip makeWrapper
    hunspell libevent libstartup_notification libvpx /* cairo */
    icu libpng jemalloc ];

  firefoxBin = fetchurl {
    url    = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/59.0.1/linux-i686/en-US/firefox-59.0.1.tar.bz2";
    sha256 = "0xacmxdbibdfgrrs8nmikjh37n6s7m1cj2f1ws04ixzack16733z";
  };

  fhsEnv = steam.override {
    nativeOnly = true;
    extraPkgs  = firefoxDeps;
  };
};
check mkBin {
  name   = "firefox";
  paths  = [ fhsEnv.run ];
  vars   = { firefox = unpack firefoxBin; };
  script = ''
    #!/usr/bin/env bash
    exec steam-run "$firefox/firefox" "$@"
  '';
}
