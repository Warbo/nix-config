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

    gimp = cached "gimp";

    keepassx-community =
      with rec {
        version = "2.5.0";
        src     = self.unpack (self.fetchurl {
          url    = "https://github.com/keepassxreboot/keepassxc/releases/" +
                   "download/${version}/keepassxc-${version}-src.tar.xz";
          sha256 = "10bq2934xqpjpr99wbjg2vwmi73fcq0419cb3v78n2kj5fbwwnb3";
        });

        latest = import (self.runCommand "latest-keepassxc"
          {
            __noChroot  = true;
            buildInputs = [ self.utillinux self.wget self.xidel ];
            nix         = self.writeScript "read-version.nix" ''
              with builtins;
              readFile ./version.txt
            '';
            pat = "//a[contains(text(),'Latest release')]/../..//a/@href";
            url = https://github.com/keepassxreboot/keepassxc/releases/latest;
          }
          ''
            mkdir "$out"
            #cp "$nix" "$out/default.nix"
            wget -q --no-check-certificate -O- "$url" |
              xidel - -q -e "$pat"                    |
              grep tag                                |
              rev                                     |
              cut -d / -f1                            |
              rev                                     |
              sed -e 's/^/"/g' -e 's/$/"/g' > "$out/default.nix"
          '');

        # Use known-good dependencies, to avoid broken Qt, etc.
        fixedDeps = super.keepassx-community.override (old: {
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

        updated = fixedDeps.overrideAttrs (old: rec {
          inherit src version;
          name        = "keepassxc-${version}";
          buildInputs = old.buildInputs ++ [
            self.nixpkgs1709.pkgconfig                # Needed to find qrencode
            self.qt5.qtsvg self.nixpkgs1709.qrencode  # New dependencies
          ];
          checkPhase = ''
            export LC_ALL="en_US.UTF-8"
            export QT_QPA_PLATFORM=offscreen
            export QT_PLUGIN_PATH="${with self.nixpkgs1709.qt5.qtbase;
                                     "${bin}/${qtPluginPrefix}"}"
            make test ARGS+="-E testgui --output-on-failure"
          '';
          patches = [];  # One patch is Mac-only, other has been included in src
        });
      };
      trace "FIXME: Overriding deps of keepassx-community to avoid broken Qt"
            (if self.onlineCheck && (compareVersions version latest != 0)
                then trace (toJSON {
                       inherit latest version;
                       warning = "KeePassXC version doesn't match latest";
                     })
                else (x: x))
            updated;

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

    # We need to override the happy-path 'racket' package, taking it from super
    # to avoid infinite loops.
    racket = self.checkedRacket.override {
      racket = trace (concatStringsSep " " [
                       "WARNING: checkedRacket didn't use its fallback package."
                       "This might indicate that checkedRacket is not needed"
                       "any more."])
                     super.racket;
    };

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
