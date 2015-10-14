# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
rec {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot = {
    loader.grub = {
      enable  = true;
      version = 2;
      device  = "/dev/sda";
    };

    kernelModules = [ "kvm-intel" "tun" "virtio" ];
    kernel.sysctl."net.ipv4.tcp_sack" = 0;
  };

  networking = {
    hostName                = "nixos";
    interfaceMonitor.enable = false; # Watch for plugged cable.
    firewall.enable         = false;

    # Block time wasters
    extraHosts = builtins.readFile "/home/chris/.dotfiles/hosts";

    # NetworkManager
    networkmanager.enable = true;
    enableIPv6            = false;
  };

  powerManagement = {
    enable = true;
    powerDownCommands = ''
      umount -at cifs
      killall sshfs || true
    '';
  };

  time = {
    timeZone = "Europe/London";
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    trayer networkmanagerapplet pmutils shared_mime_info
    # KDE
    kde4.kdemultimedia kde4.kdegraphics kde4.kdeutils kde4.applications
    kde4.kdegames kde4.kdeedu kde4.kdebindings kde4.kdeaccessibility
    kde4.kde_baseapps kde4.kactivities kde4.kdeadmin kde4.kdeartwork
    kde4.kde_base_artwork kde4.kdenetwork kde4.kdepim kde4.kdepimlibs
    kde4.kdeplasma_addons kde4.kdesdk kde4.kdetoys kde4.kde_wallpapers
    kde4.kdewebdev kde4.oxygen_icons kde4.kdebase_workspace kde4.kdelibs
    kde4.kdevelop kde4.kdevplatform kde4.kbibtex
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  environment.etc."ssh/ssh_config".source = /home/chris/ssh_config;

  #environment.etc."mime.types".source = /home/chris/.dotfiles/mime.types;

  # Enable the X11 windowing system.
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

    desktopManager = {
      default = "none";
      kde4 = {
        enable = true;
      };
    };

    displayManager = {
      auto = {
        enable = true;
        user   = "chris"; # login as "chris"
      };
    };
  };

  # Enable updatedb for the locate command. Run as chris to access /home/chris
  services.locate = {
    enable    = true;
    localuser = "chris";
    extraFlags = ["--prunepaths='/home/chris/Public /home/chris/Uni'"];
  };

  services.printing = {
    enable  = true;
    drivers = [ pkgs.gutenprint ];
  };

  services.atd = {
    enable = true;
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
    extraGroups = [ "wheel" "voice" "networkmanager" "fuse" "dialout" "atd" ];
    uid         = 1000;
    createHome  = true;
    home        = "/home/chris";
    shell       = "/run/current-system/sw/bin/bash";
  };

  users.extraUsers.kde = {
    name        = "kde";
    group       = "users";
    extraGroups = [ "wheel" "voice" "networkmanager" "fuse" "dialout" "atd" ];
    uid         = 1001;
    createHome  = true;
    home        = "/home/kde";
    shell       = "/run/current-system/sw/bin/bash";
  };
}
