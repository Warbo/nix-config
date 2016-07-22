# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
with builtins;

{ config, pkgs, ... }:
rec {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot = trace "FIXME: Can we update LibreBoot?" {
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

  time = {
    timeZone = "Europe/London";
  };

  # Packages to install in system profile.
  # NOTE: You *could* install these individually via `nix-env -i` as root, but
  # those won't be updated by `nixos-rebuild` and aren't version controlled.
  # To see if there are any such packages, do `nix-env -q` as root.
  environment.systemPackages = with pkgs; [
    trayer networkmanagerapplet pmutils shared_mime_info cryptsetup lsof
    samba st wpa_supplicant xfsprogs cifs_utils
  ];

  # List services that you want to enable:

  services.openssh.enable = true;

  environment.etc = trace "FIXME: Add dispatcher.d scripts" [

    #{ source = ipUpScript;
    #  target = "NetworkManager/dispatcher.d/01nixos-ip-up"; }

  ];

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
      configFile = "/home/chris/.synergy.conf";
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

  services.cron.systemCronJobs = [
    "*/30 * * * * chris /home/chris/warbo-utilities/web/imm -u"
    "*/5  * * * * chris ${pkgs.coreutils}/bin/timeout 240 ${pkgs.isync}/bin/mbsync gmail dundee"
    "2    * * * * chris ${pkgs.coreutils}/bin/timeout 240 ${pkgs.isync}/bin/mbsync gmail-backup"
  ];
}
