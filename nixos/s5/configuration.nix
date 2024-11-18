# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

with { nixpkgs-path = import ./nixpkgs.nix; };
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix.nixPath = [
    "nixos-config=/etc/nixos/configuration.nix"
    "nixpkgs=${nixpkgs-path}"
  ];
  nixpkgs.flake.source = nixpkgs-path;

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  fileSystems =
    with {
      options = [
        "noatime"
        "nodiratime"
        "discard"
      ];
    };
    {
      "/".options = options;
    }
    // builtins.listToAttrs (
      builtins.map
        (uuid: {
          name = "/mnt/${uuid}";
          value = {
            inherit options;
            device = "/dev/disk/by-uuid/${uuid}";
          };
        })
        [
          "05d217f7-1c0d-4503-8d46-70673d9486d3"
          "16a08904-689b-47ff-a4b4-c3476a0be1c9"
          "39ebff8b-a773-4efe-a1d4-37c42ccf1527"
          "cb745460-34de-429d-bf01-2b5470cb41e1"
          "dec31a7f-4774-4c79-a3df-01c6382a60b8"
        ]
    );

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     tree
  #   ];
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "24.11";
}
