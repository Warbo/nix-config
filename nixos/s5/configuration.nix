# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:
with {
  nixpkgs-path = import ./nixpkgs.nix;
};
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Include VisionFive2 support from nixos-hardware
    "${import ./nixos-hardware.nix}/starfive/visionfive/v2"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.binfmt = {
    # See https://discourse.nixos.org/t/chroot-into-arm-container-with-systemd-nspawn/34735/9
    emulatedSystems =
      with builtins;
      filter (s: s != currentSystem) [
        "aarch64-linux" # Pinephone
        "armv6l-linux" # RaspberryPi
        "i686-linux" # Thinkpad
        "riscv64-linux" # VisionFive
        "x86_64-linux" # Laptops
      ];
    # https://github.com/felixonmars/archriscv-packages/blob/7c270ecef6a84edd6031b357b7bd1f6be2d6d838/devtools-riscv64/z-archriscv-qemu-riscv64.conf#L1
    registrations."x86_64-linux" = {
      preserveArgvZero = true;
      matchCredentials = true;
      fixBinary = true;
    };
  };

  system.tools.nixos-option.enable = false;  # This drags in an old Nix 2.18

  nix = {
    extraOptions = ''experimental-features = nix-command flakes'';
    nixPath = [
      "nixos-config=${../..}/nixos/s5/configuration.nix"
      "nixpkgs=${nixpkgs-path}"
    ];
    settings = {
      trusted-users = [ "root" "@wheel" ];
    };
  };
  nixpkgs = {
    flake.source = nixpkgs-path;
    hostPlatform.system = "riscv64-linux";
    buildPlatform.system = "x86_64-linux";
    overlays = builtins.attrValues rec {
      disableShellcheck = self: super: {
        # GHC isn't bootstrapped for RiscV in Nixpkgs, but seems to claim it is.
        # Override that, so that trivial-builders don't try to shellcheck their
        # scripts.
        shellcheck-minimal.compiler.meta.platforms = [];
      };

      mergerFsDependency = self: super: {
        mergerfs = super.mergerfs.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
            self.binutils
          ];
        });
      };
    };
  };
  #systemd.services.nix-daemon.environment.TMPDIR =
  #  "/mnt/internal/nix-daemon-tmp";

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

      # Shared drive
      "/mnt/shared" = {
        fsType = "fuse.mergerfs";
        device = "/mnt/uuid/*/Shared";
        options = [
          "cache.files=partial"
          "dropcacheonclose=true"
          "category.create=mfs"
        ];
      };
    };

  swapDevices = [
    {
      device = "/mnt/internal/SWAP";
      size = 16 * 1024;
    }
  ];

  networking.hostName = "s5";
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nixos = {
    isNormalUser = true;
    initialPassword = "123";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxAT8WR2oMGuFTQiOnShMlp+XjtP16WZNfDCo1sMsZ0I7kflcvmJtn0mxMHiNoMhP39slVkZf6Idd3T9d05reWx0X8SNFyQlCiDZFS5/t1Vc5c4CGVAFGoKGUzAa7dN9n3tX6uhSx8HSWvdzqiJGolh1u9iawJ+oM15ijXvfBJShL+nG7tTszdSpSeFJ6Pbfy3c3VEm9xw4DE3AkOxHNtACgZQx1OXM6MFBgIsBl/BvZ/4x6OcD2tIQTXZsOKePGvSkFvXNlsFfySELoNpLerWoAnDGUX1bbYCrUkdQ9BuOTt9WJa1JztEUtLyhEJ5o+61IBsY7OBsXV2tXqluL2Hl warbo@github.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuJIYFjGTZyEdIIilGLRkDy1M/AYBmsjML8tQJG48Rn chris@nixos-amd64"
    ];
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      curl
      git
      nix
      #tree
    ];
  };

  environment.systemPackages = with pkgs; [ curl git mergerfs nix ];

  security.sudo.wheelNeedsPassword = false;

  services = {
    avahi = {
      enable = true;
      publish.enable = true;
      publish.userServices = true;  # Let samba register mDNS records
      #nssmdns4 = true;
    };
    openssh.enable = true;
    samba = {
      enable = true;
      #package = pkgs.samba4Full;  # Has avahi, etc
      shares.shared = {
        path = "/mnt/shared";
        writable = "false";
        comment = "Merged hard drive pool";
      };
    };
  };
  system.stateVersion = "25.05"; #"24.11";
}
