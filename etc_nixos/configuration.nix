# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
with builtins;
with {
  mypkgs = import <nixpkgs> {
             config = import /home/chris/.nixpkgs/config.nix;
           };
};

{ config, pkgs, ... }:
rec {

  # Low level/hardware stuff

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot = trace "FIXME: Use system.activationScripts to make /boot/grub/libreboot_grub.cfg" {
    loader.grub = {
      enable  = true;
      version = 2;
      device  = "/dev/sda";
    };

    kernelModules = trace "FIXME: Which modules are artefacts of using QEMU to install?"
                          [ "kvm-intel" "tun" "virtio" "coretemp" ];

    kernel.sysctl."net.ipv4.tcp_sack" = 0;

    #extraModprobeConfig = ''
    #  # thinkpad acpi
    #  options thinkpad_acpi
    #  # experimental=1 fan_control=1 brightness_enable=1 hotkey=enable,0xffffff
    #'';

    extraModulePackages = [ config.boot.kernelPackages.tp_smapi ];

    kernelParams = [
      "acpi_osi="
      "video.use_native_backlight=1"
      "clocksource=acpi_pm pci=use_crs"
      "consoleblank=0"
    ];
  };

  hardware.bluetooth.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  hardware.pulseaudio = {
    systemWide = false;
    enable     = true;
    package    = pkgs.pulseaudioFull;
    configFile = pkgs.writeText "default.pa" ''
      load-module module-udev-detect
      load-module module-jackdbus-detect channels=2
      load-module module-bluetooth-policy
      load-module module-bluetooth-discover
      load-module module-esound-protocol-unix
      load-module module-native-protocol-unix
      load-module module-always-sink
      load-module module-console-kit
      load-module module-systemd-login
      load-module module-intended-roles
      load-module module-position-event-sounds
      load-module module-filter-heuristics
      load-module module-filter-apply
    '';
  };

  sound.enableMediaKeys = true;

  networking = {
    hostName                = "nixos";
    firewall.enable         = false;

    # Block time wasters
    extraHosts = readFile "/home/chris/.dotfiles/hosts";

    # NetworkManager
    networkmanager.enable = true;
    enableIPv6            = false;
  };

  powerManagement = {
    enable = true;
    powerDownCommands = trace "FIXME: Better unmounting when disconnecting" ''
      umount -at cifs
      killall sshfs || true
    '';
  };

  programs = {
    light.enable = true;
    mosh.enable  = true;
  };

  time = {
    timeZone = "Europe/London";
  };

  # Packages to install in system profile.
  # NOTE: You *could* install these individually via `nix-env -i` as root, but
  # those won't be updated by `nixos-rebuild` and aren't version controlled.
  # To see if there are any such packages, do `nix-env -q` as root.
  environment.systemPackages = [ mypkgs.all pkgs.sshfsFuse ];

  nixpkgs.config = {
    packageOverrides = pkgs: {
      # Required for PulseAudio headsets
      bluez = pkgs.bluez5;
    };
  };

  nix.trustedBinaryCaches = [ "http://hydra.nixos.org/" ];

  # For SSHFS
  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  # List services that you want to enable:

  services.openssh.enable = true;

  services.acpid = {
    enable = true;
    handlers = {
      mute = {
        event = "button/mute.*";
        action = "amixer set Master toggle";
      };
      /*brighten = {
        event  = "video/brightnessup";
        action = "";
      }
      darken = {
        event  = "video/brightnessdown";
        action = "";
      };*/
    };
  };

  # Limit the size of our logs, to prevent ridiculous space usage and slowdown
  services.journald = {
    extraConfig = ''
      SystemMaxUse=10M
      RuntimeMaxUse=10M
    '';
  };

  services.xserver = {
    enable         = true;
    layout         = "gb";
    xkbOptions     = "ctrl:nocaps";
    windowManager  = {
      default      = "xmonad";
      xmonad       = {
        enable                 = true;
        enableContribAndExtras = true;
        extraPackages          = self: [ self.xmonad-contrib ];
      };
    };

    desktopManager.default = "none";

    # Log in automatically as "chris"
    displayManager = {
      auto = {
        enable = true;
        user   = "chris";
      };
    };
  };

  # Enable updatedb for the locate command. Run as chris to access /home/chris
  services.locate = {
    enable     = true;
    localuser  = "chris";
    extraFlags = [
      "--prunefs='fuse.sshfs'"
      "--prunepaths='/home/chris/Public /home/chris/Uni /nix/store'"
      "--localpaths='/home/chris'"
    ];
  };

  services.printing = {
    enable  = true;
    drivers = [ pkgs.hplip pkgs.gutenprint ];
  };

  services.avahi = {
    enable   = true;
    nssmdns  = true;
    hostName = "nixos";
  };

  systemd = {
    services = import ./services.nix (pkgs // mypkgs);
  };

  # Locale, etc.
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    consoleKeyMap = "uk";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.chris = {
    name        = "chris";
    group       = "users";
    extraGroups = [ "wheel" "voice" "networkmanager" "fuse" "dialout" "atd" "audio" "docker" "pulse" ];
    uid         = 1000;
    createHome  = true;
    home        = "/home/chris";
    shell       = "/run/current-system/sw/bin/bash";
  };
}
