# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

# NOTE: If DNS doesn't work in WSL (e.g. can ping 8.8.8.8 but not google.com)
# then try creating a .wslconfig file as per https://askubuntu.com/a/1512056
{ config, lib, pkgs, ... }: {
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules> # TODO: Pin this, delete the channel
  ];

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11";

  # Go up then down to ensure we work for symlinks too
  nixpkgs.overlays = import ../nixos-wsl/overlays.nix;

  # Use a pinned Nixpkgs, rather than relying on env vars like <nixpkgs>.
  # The documentation for this option says it can be used for this purpose
  # on systems which don't use flakes.
  /*nixpkgs.flake.source =
    with rec {
      #inherit (import ../../nix/sources.nix) nix-helpers;
      nix-helpers = /home/nixos/nix-helpers;
      pinnedNixpkgs = import "${nix-helpers}/helpers/pinnedNixpkgs" {};
    };
    pinnedNixpkgs.repoLatest;*/

  environment.systemPackages = [ pkgs.devCli ];
}
