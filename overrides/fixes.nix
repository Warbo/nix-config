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

  # Avoid haskellPackages, since it's a fragile truce between many different
  # packages, and often requires a bunch of manual overrides. In contrast,
  # haskell-nix uses Cabal to solve dependencies automatically per-package.
  # TODO: Check for latest versions
  haskellPkgs =
    with { hn = self.haskell-nix {}; };
    mapAttrs
      (_: { ghc         ? hn.buildPackages.pkgs.haskell-nix.compiler.ghc865
          , index-state ? "2020-01-11T00:00:00Z"
          , type        ? "hackage-package"
          , ...
          }@args: (getAttr type hn.haskell-nix)
                        (removeAttrs args [ "type" ] // {
                          inherit ghc index-state;
                        })) {
      ghcid           = { name = "ghcid";           version = "0.7.5";   };
      hlint           = { name = "hlint";           version = "2.2.2";   };
      stylish-haskell = { name = "stylish-haskell"; version = "0.9.2.2"; };
    };
};
{
  overrides = {
    audacious = cached "audacious";

    # Newer NixOS systems need fuse3 rather than fuse, but it doesn't exist
    # on older systems. We include it if available, otherwise we just warn.
    fuse3 = super.fuse3 or self.nothing;

    gensgs = broken1903 "gensgs";

    ghcid = haskellPkgs.ghcid.components.exes.ghcid;

    gimp = cached "gimp";

    hlint = haskellPkgs.hlint.components.exes.hlint;

    keepassx-community =
      with rec {
        version = "2.5.3";
        src     = fetchTarball {
          url    = "https://github.com/keepassxreboot/keepassxc/releases/" +
                   "download/${version}/keepassxc-${version}-src.tar.xz";
          sha256 = "06ixlm8r596k92l5jfy1x9js0rwhjxjgcgxql5am65xjwja56lag";
        };

        latest = import (self.runCommand "latest-keepassxc"
          {
            buildInputs = [ self.utillinux self.xidel ];
            pat  = "//a[contains(text(),'Latest release')]/../..//a/@href";
            page = fetchurl
              https://github.com/keepassxreboot/keepassxc/releases/latest;
          }
          ''
            mkdir "$out"
            xidel - -q -e "$pat" < "$page"  |
              grep tag                      |
              rev                           |
              cut -d / -f1                  |
              rev                           |
              sed -e 's/^/"/g' -e 's/$/"/g' > "$out/default.nix"
          '');

        updated = check: super.keepassx-community.overrideAttrs (old: rec {
          inherit src version;
          name        = "keepassxc-${version}";
          buildInputs = old.buildInputs ++ [
            self.nixpkgs1709.pkgconfig                # Needed to find qrencode
            self.qt5.qtsvg self.nixpkgs1709.qrencode  # New dependencies
          ];
          checkPhase =
            if check
               then ''
                 export LC_ALL="en_US.UTF-8"
                 export QT_QPA_PLATFORM=offscreen
                 export QT_PLUGIN_PATH="${with self.qt5.qtbase;
                                          "${bin}/${qtPluginPrefix}"}"
                 make test ARGS+="-E testgui --output-on-failure"
               ''
               else trace ''
                 FIXME: keepassxc tests disabled due to:
                     === Received signal at function time: 300000ms, total time: 301016ms, dumping stack ===
                     === End of stack trace ===
                     QFATAL : TestCli::testAdd() Test function timed out
                     FAIL!  : TestCli::testAdd() Received a fatal error.
                     Loc: [Unknown file(0)]
                 '' ''echo "FIXME: Tests disabled" 1>&2'';
          patches = [];  # One patch is Mac-only, other has been included in src
        });
      };
      (if self.onlineCheck && (compareVersions version latest != 0)
          then trace (toJSON {
                 inherit latest version;
                 warning = "KeePassXC version doesn't match latest";
               })
          else (x: x))
      # Provide the untested version, but also ensure that the tested
      # version is indeed still failing
      self.withDeps' "keepassxc-unchecked"
                     [ (self.isBroken (updated true)) ]
                     (updated false);

    libreoffice = cached "libreoffice";

    libupnp = super.libupnp.overrideAttrs (old: {
      configureFlags = (old.configureFlags or []) ++ [ "--disable-largefile" ];
    });

    mplayer = cached "mplayer";

    # We only need nix-repl for Nix 1.x, since 2.x has a built-in repl
    nix-repl = if compareVersions self.nix.version "2" == -1
                  then super.nix-repl
                  else self.nothing;

    # We need to override the happy-path 'racket' package, taking it from super
    # to avoid infinite loops.
    racket = self.checkedRacket.override {
      racket = trace (concatStringsSep " " [
                       "WARNING: checkedRacket didn't use its fallback package."
                       "This might indicate that checkedRacket is not needed"
                       "any more."])
                     super.racket;
    };

    stylish-haskell =
      haskellPkgs.stylish-haskell.components.exes.stylish-haskell;

    thermald = broken1903 "thermald";

    xorg = super.xorg // {
      # Bump driver to avoid https://bugs.freedesktop.org/show_bug.cgi?id=109689
      xf86videointel = super.xorg.xf86videointel.overrideAttrs (old:
        with { rev = "f66d3954"; };
        {
          name = "xf86-video-intel-${rev}";
          src  = self.fetchgit {
            inherit rev;
            url    = "https://gitlab.freedesktop.org/" +
                     "xorg/driver/xf86-video-intel.git";
            sha256 = "14rwbbn06l8qpx7s5crxghn80vgcx8jmfc7qvivh72d81r0kvywl";
          };
        });
    };

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
          audacious
          gensgs
          libreoffice
          thermald
          ;
        inherit (super.xorg)
          xf86videointel
          ;
      };

      haskellTests = mapAttrs (_: p: p.components.tests) haskellPkgs;
    };
    stillBrokenPkgs // self.checkRacket.checkWhetherBroken // haskellTests // {
      libproxyWorks = self.libproxy;
    };
}
