{
  pkgs ? (import <nixpkgs> { overlays = [ (import ./overlay.nix) ]; }),
}:
pkgs.nix-config-tests
