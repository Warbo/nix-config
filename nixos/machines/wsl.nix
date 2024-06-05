{ config, lib, pkgs, ... }: {
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules> # TODO: Pin this, delete the channel
  ];
  wsl.enable = true;
  wsl.defaultUser = "nixos";
  system.stateVersion = "23.11";
}
