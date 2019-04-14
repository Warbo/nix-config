# Used for testing and building via continuous integration (e.g. Hydra)
with { pkgs = import <nixpkgs> { overlays = import ./overlays.nix; }; };
{
  inherit (pkgs) all basic nix-config-tests;
}
