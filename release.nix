# Used for testing and building via continuous integration (e.g. Hydra)
{
  inherit (import <nixpkgs> { overlays = import ./overlays.nix; })
    nix-config-tests
    ;

  inherit (import <nixpkgs/nixos> { configuration = ./nixos/configuration.nix; })
    system
    ;
}
