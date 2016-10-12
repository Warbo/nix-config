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
  };

  hardware.pulseaudio = {
    systemWide = true;
    enable = true;
    package = pkgs.pulseaudioFull;
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
  environment.systemPackages = with pkgs; [
    mypkgs.all trayer networkmanagerapplet pmutils shared_mime_info cryptsetup lsof
    s6 samba st wpa_supplicant xfsprogs cifs_utils xlibs.xbacklight
  ];

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
      "--prunepaths='/home/chris/Public /home/chris/Uni /nix/store'"
      "--localpaths='/home/chris'"
    ];
  };

  services.printing = {
    enable  = true;
    drivers = [ pkgs.hplip pkgs.gutenprint ];
  };

  services.avahi = {
    enable  = true;
    nssmdns = true;
  };

  services.synergy = {
    server = {
      enable     = true;
      autoStart  = true;
      configFile = "/home/chris/.synergy.conf";
    };
  };

  # S6 daemon supervisor; far simpler than systemd
  systemd.services.s6 =
    let dir = "/home/chris/.service";
     in {
      enable      = true;
      description = "s6 daemon supervisor";
      wantedBy    = [ "default.target" ];
      after       = [ "local-fs.target"   ];
      path        = [ pkgs.s6 pkgs.bash pkgs.nix.out mypkgs.basic ];
      environment = listToAttrs
                      (map (name: { inherit name;
                                    value = builtins.getEnv name; })
                           [ "NIX_PATH" "NIX_REMOTE" ]);
      serviceConfig = {
        Type      = "simple";
        User      = "root";
        ExecStart = pkgs.writeScript "s6-start" ''
          #!/usr/bin/env bash
          s6-svscan "${dir}"
        '';
        ExecStop  = pkgs.writeScript "s6-stop"  ''
          #!/usr/bin/env bash
          s6-svscanctl -q "${dir}"
        '';
      };
    };

  # Turn off power saving on WiFi to work around
  # https://bugzilla.kernel.org/show_bug.cgi?id=56301 (or something similar)
  systemd.services.wifiPower = {
    wantedBy      = [ "multi-user.target" ];
    before        = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "${pkgs.iw}/bin/iw dev wlp2s0 set power_save off";
    };
  };

  services.cron.systemCronJobs = [
    "*/5  * * * * chris ${pkgs.coreutils}/bin/timeout 240 ${pkgs.isync}/bin/mbsync gmail dundee"
    "2    * * * * chris ${pkgs.coreutils}/bin/timeout 240 ${pkgs.isync}/bin/mbsync gmail-backup"
  ];

  # Locale, etc.
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    consoleKeyMap = "uk";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.chris = {
    name        = "chris";
    group       = "users";
    extraGroups = [ "wheel" "voice" "networkmanager" "fuse" "dialout" "atd" "audio" "docker" ];
    uid         = 1000;
    createHome  = true;
    home        = "/home/chris";
    shell       = "/run/current-system/sw/bin/bash";
  };
}
