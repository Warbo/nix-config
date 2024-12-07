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
    "${import ./nixos-hardware.nix}/starfive/visionfive/v2"
  ];

  documentation.nixos.enable = false;  # This also uses Rust
  system.tools.nixos-option.enable = false;  # This drags in an old Nix 2.18
  services.nscd.enableNsncd = false; # This also uses Rust
  systemd.shutdownRamfs.enable = false; # Uses make-initrd-ng which uses Rust

  nix.nixPath = [
    "nixos-config=${../..}/nixos/s5/configuration.nix"
    "nixpkgs=${nixpkgs-path}"
  ];
  nixpkgs.flake.source = nixpkgs-path;
  nixpkgs.overlays =
    with {
      fetchFromGitHub = import ../../nix/fetchFromGitHub.nix;

      warn = name: bound: got:
        if builtins.compareVersions got bound == -1
        then (x: x)
        else builtins.trace ''
          WARNING: Avoiding breakage with ${name} < ${bound} but it's now ${got}
        '';
    }; builtins.attrValues rec {
      disableShellcheck = self: super: {
        # GHC isn't bootstrapped for RiscV in Nixpkgs, but seems to claim it is.
        # Override that, so that trivial-builders don't try to shellcheck their
        # scripts.
        shellcheck-minimal.compiler.meta.platforms = [];
      };

      avoidRustBreakage = self: super:
        with {
          # Parent of the commit that bumps Rust to 1.82, which hits a compile
          # error on RiscV
          rustNixpkgs =
            warn "Rust" "1.83" super.rustPackages.rustc.version import (fetchFromGitHub {
              owner = "NixOS";
              repo = "nixpkgs";
              rev = "9c47bda6cc20cf976e5174c149997149e8a518ec";
              sha256 = "sha256-hX/ZAWWf6zE7WLN2LRZRrF27TOFu5TgM8jOL2+H+Aac=";
            }) { config = {}; };
        }; { inherit (rustNixpkgs) rustPackages; };

      nixWithoutDocumentation = self: super:
        with {
          # Disabling Nix documentation breaks the test suite of Nix 2.24, so
          # update to 2.25.2 to include https://github.com/NixOS/nix/pull/11729
          nixNixpkgs = warn "Nix" "2.25" super.nix.version import (fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "10a35620c9a348a87af60316f17ede79fa55a84a";
            sha256 = "sha256:15k1xxnipv3mxwphg7vaprizq11ncphawc13ns6v1shm180ck9i1";
          }) { config = { overlays = [ avoidRustBreakage ]; }; };
        };
        {
          # 2024-11-20 ChrisW: Disable documentation to avoid depending on Rust,
          # since we hit https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=282853
          nix = nixNixpkgs.nixVersions.nix_2_25.override (_: {
            enableDocumentation = false;
          });
        };
    };
  systemd.services.nix-daemon.environment.TMPDIR =
    "/mnt/internal/nix-daemon-tmp";

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  fileSystems =
    with rec {
      internal = "dec31a7f-4774-4c79-a3df-01c6382a60b8";
      uuids = [
        "05d217f7-1c0d-4503-8d46-70673d9486d3"
        "16a08904-689b-47ff-a4b4-c3476a0be1c9"
        "39ebff8b-a773-4efe-a1d4-37c42ccf1527"
        "cb745460-34de-429d-bf01-2b5470cb41e1"
        internal
      ];
      byUuid = uuid: {
        name = "/mnt/uuid/${uuid}";
        value = {
          inherit options;
          device = "/dev/disk/by-uuid/${uuid}";
          neededForBoot = uuid == internal;
        };
      };
      options = [
        "noatime"
        "nodiratime"
      ];
    };
    builtins.listToAttrs (builtins.map byUuid uuids)
    // {
      "/".options = options;

      # Bind mounts
      "/mnt/internal" = rec {
        device = "/mnt/uuid/${internal}";
        depends = [ device ];
        fsType = "none";
        options = [ "bind" ];
        neededForBoot = true;
      };
      "/nix" = rec {
        device = "/mnt/internal/nix";
        depends = [ device ];
        fsType = "none";
        options = [ "bind" ];
        neededForBoot = true;
      };
    };

  swapDevices = [
    {
      device = "/mnt/internal/SWAP";
      size = 16 * 1024;
    }
  ];

  networking.hostName = "s5";
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "Europe/London";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.nixos = {
     isNormalUser = true;
     initialPassword = "123";
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
       curl
       git
       nix
       #firefox
       #tree
     ];
   };

  services.openssh.enable = true;

  system.stateVersion = "24.11";
}
