{ nix-helpers-src ? sources.nix-helpers
, warbo-packages-src ? sources.warbo-packages
, sources ? import ../../nix/sources.nix
}:
[
  # Repo of helper functions
  (self: super: { nix-helpers = import nix-helpers-src { nixpkgs = super; }; })

  # Repo of useful packages
  (self: super: {
    warbo-packages = import warbo-packages-src {
      inherit (super) nix-helpers;
      nixpkgs = super;
    };
  })
  
  # metaPackages provides sets of common functionality.
  (self: super:
    with rec {
      slf = super // extra.overrides;
      extra = import ../../overrides/metaPackages.nix slf super;
    };
    extra.overrides)
]

