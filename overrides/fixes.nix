# Override broken or non-optimal packages from <nixpkgs> and elsewhere
self: super:

with builtins;
with super.lib;
with rec {
  get = reason: name: version:
    trace "FIXME: Taking ${name} from nixpkgs${version} because ${reason}"
          (getAttr name (getAttr "nixpkgs${version}" self));

  cached = name: get "it's cached" name "1703";

  broken1903 = name: get "it's broken on 19.03" name "1809";
};
{
  overrides = {
    audacious = cached "audacious";

    conkeror = get "it's broken on 18.03+" "conkeror" "1703";

    # Newer NixOS systems need fuse3 rather than fuse, but it doesn't exist
    # on older systems. We include it if available, otherwise we just warn.
    fuse3 = super.fuse3 or self.nothing;

    gensgs = broken1903 "gensgs";

    get_iplayer = trace "FIXME: Overriding get_iplayer to avoid 19.03 breakages"
                        super.get_iplayer.override {
                          inherit (self.nixpkgs1809) get_iplayer;
                        };

    gimp = cached "gimp";

    keepassx-community = trace
      "FIXME: Overriding dependencies of keepassx-community to avoid broken Qt"
      super.keepassx-community.override (old: {
        inherit (self.nixpkgs1709)
          cmake
          curl
          glibcLocales
          libargon2
          libgcrypt
          libgpgerror
          libmicrohttpd
          libsodium
          libyubikey
          stdenv
          yubikey-personalization
          zlib;
        inherit (self.nixpkgs1709.qt5)
          qtbase
          qttools
          qtx11extras;
        inherit (self.nixpkgs1709.xorg)
          libXi
          libXtst;
      });

    libproxy = trace
      "FIXME: Removing flaky, heavyweight SpiderMonkey dependency from libproxy"
      super.libproxy.overrideDerivation (old: {
        buildInputs  = filter (x: !(hasPrefix "spidermonkey" x.name))
                              old.buildInputs;
        preConfigure = replaceStrings [ ''"-DWITH_MOZJS=ON"'' ]
                                      [ ""                    ]
                                      old.preConfigure;
      });

    libreoffice = cached "libreoffice";

    mplayer = cached "mplayer";

    # We only need nix-repl for Nix 1.x, since 2.x has a built-in repl
    nix-repl = if compareVersions self.nix.version "2" == -1
                  then super.nix-repl
                  else self.nothing;

    # This depends on pyqt5, which in turn depends on qt5 that is broken on
    # 19.03. Plumbing our qt5 override through these ends up with
    # "ImportError: libQt5Core.so.5" in picard's test suite.
    picard = broken1903 "picard";

    qt5 = get (concatStringsSep " " [
      "build is broken (bootstrap related?) on 18.03+"
      "(see https://groups.google.com/forum/#!topic/nix-devel/fAMADzFhcFo)"
    ]) "qt5" "1709";

    racket = trace ''FIXME: Taking racket from nixpkgs 16.09, since it's
                     broken on i686 for newer versions''
                   self.nixpkgs1609.racket;

    thermald = broken1903 "thermald";

    v4l_utils = trace
      (concatStringsSep " " [
        "FIXME: Redefining v4l_utils to avoid problems evaluating with"
        "pinned qt5 fix. This should be removed once qt5 is working."
      ])
      self.newScope
      self.qt5
      "${<nixpkgs/pkgs/os-specific/linux/v4l-utils>}"
      {};

    vlc = cached "vlc";

    # xproto was replaced by xorgproto
    xorgproto = super.xorg.xorgproto or super.xorg.xproto;
  };

  tests =
    with super.lib;
    with rec {
      stillBroken = name: pkg: {
        name  = "${name}StillNeedsOverride";
        value = self.isBroken pkg;
      };

      stillBrokenPkgs = mapAttrs' stillBroken {
        inherit (super)
          gensgs
          thermald
          ;
        inherit (super.qt5) qtbase;

        picard = super.picard.override (old: {
          python3Packages = super.python3Packages.override
            (oldAttrs: {
              overrides = (           super.lib.composeExtensions or
                           self.nixpkgs1803.lib.composeExtensions)
                (oldAttrs.overrides or (self: super: {}))
                (pelf: puper: {
                  pyqt5 = puper.pyqt5.override {
                    inherit (self.qt5)
                      qmake
                      qtbase
                      qtconnectivity
                      qtsvg
                      qtwebengine
                      qtwebsockets
                      ;
                  };
                });
            });
        });
      };
    };
    stillBrokenPkgs // self.checkRacket.checkWhetherBroken // {
      libproxyWorks = self.libproxy;
    };
}
