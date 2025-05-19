# Backport of Nix with (working) git-hashing feature. See also the overlay at
# overrides/nix-backport.nix, which doesn't require a NixOS config; but may need
# manual tweaking to handle cross-compilation.
{ pkgs, config, ... }:
with rec {
  backport-from-repo = (import pkgs.path {
    config = {};
    overlays = [ (import ../../overlays.nix).nix-backport ];
  }).nix-backport.nixpkgs-src;

  backport-from = import backport-from-repo {
    config = {};
    overlays = [];
    localSystem = config.nixpkgs.buildPlatform.system;
    crossSystem = config.nixpkgs.hostPlatform.system;
  };
  nix-backport = backport-from.nixVersions.nix_2_28;
};
{
  nix.package = nix-backport;
}
