{ nix-helpers-src ? sources.nix-helpers
, sources ? import ../../nix/sources.nix
}:
# TODO: Make the nix-config overlays a bit more direct to use
[
  (self: super: {
    # GitHub don't support 'v3' in their API anymore; this fork uses an
    # appropriate replacement.
    update-nix-fetchgit = super.update-nix-fetchgit.overrideAttrs (old: {
      src = builtins.fetchTarball {
        url = "https://github.com/ja0nz/update-nix-fetchgit/archive/7460aede467fbaf4f3db363102d299232f9684e2.tar.gz";
      };
    });
    # Repo of helper functions
    nix-helpers = import nix-helpers-src { nixpkgs = super; };
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

