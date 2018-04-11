# Force firefox 59, since Nixpkgs 17.09 FF seems crashy
{ bash, fetchurl, gtk3, lib, mkBin, runCommand, self, super, steam, unpack,
  wrap }:

with builtins;
with rec {
  ff      = super.firefox;
  version = ff.version or elemAt (lib.splitString "-" ff.name) 1;
  check   = if compareVersions "59" version == 1
               then (x: x)
               else trace "FIXME: Don't override, have Firefox 59 (${version})";

  styles = p: with p; widgetThemes ++ [
    anonymous-pro-font
    droid-fonts
  ];

  firefoxDeps = p: with p; with gnome2; [ gtk3 gtk2 perl zip libIDL libjpeg
    zlib bzip2 dbus dbus_glib pango freetype fontconfig xorg.libXi
    xorg.libX11 xorg.libXrender xorg.libXft xorg.libXt file
    nspr libnotify xorg.pixman yasm mesa
    xorg.libXScrnSaver xorg.scrnsaverproto
    xorg.libXext xorg.xextproto sqlite unzip makeWrapper
    hunspell libevent libstartup_notification libvpx /* cairo */
    icu libpng jemalloc gcc ] ++ styles p;

  firefoxDir = unpack (fetchurl {
    url    = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/59.0.1/linux-i686/en-US/firefox-59.0.1.tar.bz2";
    sha256 = "0xacmxdbibdfgrrs8nmikjh37n6s7m1cj2f1ws04ixzack16733z";
  });

  fhsEnv = steam.override {
    nativeOnly = true;
    extraPkgs  = firefoxDeps;
  };
};
check mkBin {
  name   = "firefox";
  paths  = [ fhsEnv.run ];
  vars   = {
    ff = wrap {
      name   = "run-ff";
      paths  = [ bash ];
      vars   = {
        inherit firefoxDir;
        GTK_DATA_PREFIX = "/run/current-system/sw";
        GTK_PATH = concatStringsSep ":" [
          "/run/current-system/sw/lib/gtk-3.0"
          "/run/current-system/sw/lib/gtk-2.0"
        ];
        PULSE_SERVER = "/run/user/1000/pulse/native";
        XCURSOR_PATH = concatStringsSep " " [
          "~/.icons"
          "~/.nix-profile/share/icons"
          "/var/run/current-system/sw/share/icons"
        ];
        XDG_DATA_DIRS = "${gtk3}/share/gsettings-schemas/${gtk3.name}/";
      };
      script = ''
        #!/usr/bin/env bash
        export LD_LIBRARY_PATH="$firefoxDir:$LD_LIBRARY_PATH"
        exec "$firefoxDir/firefox" "$@"
      '';
    };
  };
  script = ''
    #!/usr/bin/env bash
    exec steam-run "$ff" "$@"
  '';
}
