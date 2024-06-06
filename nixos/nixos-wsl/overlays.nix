{ nix-helpers-src ? sources.nix-helpers
, warbo-packages-src ? sources.warbo-packages
, sources ? import ../../nix/sources.nix
}:
# TODO: Make the nix-config overlays a bit more direct to use
[
  (self: super: {
    # Repo of helper functions
    nix-helpers = import nix-helpers-src { nixpkgs = super; };

    # Repo of useful packages
    warbo-packages = import warbo-packages-src {
      inherit (self) nix-helpers;
      nixpkgs = super;
    };
  })
  (self: super:
    # Use some of this repo's overrides. TODO: Update them to use options or
    # something, so we can opt-in to what we want more directly.
    with rec {
      slf = sup // extra.overrides;
      sup = super // super.nix-helpers // super.warbo-packages;
      extra = import ../../overrides/metaPackages.nix slf sup;
    };
    { inherit (extra.overrides) devCli; })
]

