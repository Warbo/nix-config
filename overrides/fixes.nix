# Override broken or non-optimal packages from <nixpkgs> and elsewhere
self: super:

with rec {
  inherit (builtins) compareVersions getAttr trace;
  inherit (super.lib) mapAttrs;

  get =
    version: name:
    trace "FIXME: Taking ${name} from nixpkgs${version} as it's broken on 19.09" (
      getAttr name (getAttr "nixpkgs${version}" self)
    );

  from1703 = get "1703";
  from1809 = get "1809";

  # Avoid haskellPackages, since it's a fragile truce between many different
  # packages, and often requires a bunch of manual overrides. In contrast,
  # haskell-nix uses Cabal to solve dependencies automatically per-package.
  # TODO: Check for latest versions
  haskellPkgs =
    with { hn = self.haskell-nix { }; };
    mapAttrs
      (
        _:
        {
          ghc ? hn.buildPackages.pkgs.haskell-nix.compiler.ghc865,
          index-state ? "2020-01-11T00:00:00Z",
          type ? "hackage-package",
          ...
        }@args:
        (getAttr type hn.haskell-nix) (
          removeAttrs args [ "type" ] // { inherit ghc index-state; }
        )
      )
      {
        ghcid = {
          name = "ghcid";
          version = "0.7.5";
        };
        hlint = {
          name = "hlint";
          version = "2.2.2";
        };
        stylish-haskell = {
          name = "stylish-haskell";
          version = "0.9.2.2";
        };
      };
}; {
  overrides = {
    audacious = from1703 "audacious";

    cabal-install =
      (self.haskellPackages.override (old: {
        overrides = helf: huper: {
          aeson = self.haskell.lib.dontCheck huper.aeson;
          lens-aeson = self.haskell.lib.dontCheck huper.lens-aeson;
          SHA = self.haskell.lib.dontCheck huper.SHA;
        };
      })).cabal-install;

    # Newer NixOS systems need fuse3 rather than fuse, but it doesn't exist
    # on older systems. We include it if available, otherwise we just warn.
    fuse3 = super.fuse3 or self.nothing;

    gensgs = from1809 "gensgs";

    ghcid = haskellPkgs.ghcid.components.exes.ghcid;

    hlint = haskellPkgs.hlint.components.exes.hlint;

    libreoffice = from1703 "libreoffice";

    libupnp = super.libupnp.overrideAttrs (old: {
      configureFlags = (old.configureFlags or [ ]) ++ [ "--disable-largefile" ];
    });

    # We only need nix-repl for Nix 1.x, since 2.x has a built-in repl
    nix-repl =
      if compareVersions self.nix.version "2" == -1 then
        super.nix-repl
      else
        self.nothing;

    stylish-haskell = haskellPkgs.stylish-haskell.components.exes.stylish-haskell;

    thermald = from1809 "thermald";

    xorg = super.xorg // {
      # Bump driver to avoid https://bugs.freedesktop.org/show_bug.cgi?id=109689
      xf86videointel = super.xorg.xf86videointel.overrideAttrs (
        old: with { rev = "f66d3954"; }; {
          name = "xf86-video-intel-${rev}";
          src = self.fetchgit {
            inherit rev;
            url = "https://gitlab.freedesktop.org/" + "xorg/driver/xf86-video-intel.git";
            sha256 = "14rwbbn06l8qpx7s5crxghn80vgcx8jmfc7qvivh72d81r0kvywl";
          };
        }
      );
    };

    # xproto was replaced by xorgproto
    xorgproto = super.xorg.xorgproto or super.xorg.xproto;
  };

  tests =
    with super.lib;
    with rec {
      stillBroken = name: pkg: {
        name = "${name}StillNeedsOverride";
        value = self.isBroken pkg;
      };

      stillBrokenPkgs = mapAttrs' stillBroken {
        inherit (super) audacious gensgs thermald;
        inherit (super.xorg) xf86videointel;
        # super.libreoffice is just a wrapper; its libreoffice attribute is the
        # derivation which fails to build.
        inherit (super.libreoffice) libreoffice;
      };

      haskellTests = mapAttrs (_: p: p.components.tests) haskellPkgs;
    };
    stillBrokenPkgs // haskellTests // { libproxyWorks = self.libproxy; };
}
