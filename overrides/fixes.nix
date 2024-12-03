# Override broken or non-optimal packages from <nixpkgs> and elsewhere
self: super:

with rec {
  inherit (builtins) compareVersions getAttr hasAttr trace;
  inherit (super.lib) mapAttrs;

  get = version:
    with rec {
      attr = "nixpkgs${version}";
      set = getAttr attr (if hasAttr attr self then self else nix-helpers);
    };
    name: trace
      "FIXME: Taking ${name} from nixpkgs${version} as it's broken on 19.09"
      (getAttr name set);

  from1703 = get "1703";
  from1809 = get "1809";

  nix-helpers = self.nix-helpers or (rec {
    inherit (import ../overrides/repos.nix overrides { }) overrides;
  }).overrides.nix-helpers;

  isBroken = self.isBroken or nix-helpers.isBroken;
}; {
  overrides = {
    # Newer NixOS systems need fuse3 rather than fuse, but it doesn't exist
    # on older systems. We include it if available, otherwise we just warn.
    fuse3 = super.fuse3 or self.nothing;

    # We only need nix-repl for Nix 1.x, since 2.x has a built-in repl
    nix-repl =
      if compareVersions self.nix.version "2" == -1 then
        super.nix-repl
      else
        self.nothing;

    python312 = super.python312.override (old: {
      packageOverrides = pelf: puper:
        (old.packageOverrides or (_: _: {})) pelf puper // {
          dbus-next = nix-helpers.withDeps' "dbus-next" [(isBroken puper.dbus-next)]
            (puper.dbus-next.overridePythonAttrs (_: {
              doCheck = false;
            }));
        };
    });

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
        value = isBroken pkg;
      };

      stillBrokenPkgs = mapAttrs' stillBroken {
        inherit (super) thermald;
        inherit (super.xorg) xf86videointel;
      };
    };
    stillBrokenPkgs // {
      inherit (self.python312Packages) dbus-next;
      libproxyWorks = self.libproxy;
    };
}
