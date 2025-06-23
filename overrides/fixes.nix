# Override broken or non-optimal packages from <nixpkgs> and elsewhere
self: super:

with rec {
  inherit (builtins)
    compareVersions
    getAttr
    hasAttr
    trace
    ;
  inherit (super.lib) mapAttrs;

  get =
    version:
    with rec {
      attr = "nixpkgs${version}";
      set = getAttr attr (if hasAttr attr self then self else nix-helpers);
    };
    name:
    trace "FIXME: Taking ${name} from nixpkgs${version} as it's broken on 19.09" (
      getAttr name set
    );

  nix-helpers =
    self.nix-helpers
      or (rec { inherit (import ../overrides/repos.nix overrides { }) overrides; })
      .overrides.nix-helpers;

  isBroken = self.isBroken or nix-helpers.isBroken;
}; {
  overrides = {
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

    warbo-packages = super.warbo-packages // {
      awf = self.empty;
    };
  };

  tests =
    with super.lib;
    with rec {
      stillBroken = name: pkg: {
        name = "${name}StillNeedsOverride";
        value = isBroken pkg;
      };

      stillBrokenPkgs = mapAttrs' stillBroken {
        inherit (super.xorg) xf86videointel;
      };
    };
    stillBrokenPkgs
    // {
      inherit (self.python312Packages) dbus-next;
      libproxyWorks = self.libproxy;
    };
}
