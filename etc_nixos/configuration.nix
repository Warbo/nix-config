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
    extraHosts = ''
      127.0.0.1 news.ycombinator.com
      127.0.0.1 slashdot.org
      127.0.0.1 reddit.com
      127.0.0.1 tumblr.com
      127.0.0.1 4chan.org
      127.0.0.1 news.bbc.co.uk
    '';

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
    trayer networkmanagerapplet pmutils
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  environment.etc."ssh/ssh_config".source = /home/chris/ssh_config;

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

    desktopManager.default = "none";
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

  # Locale, etc.
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    consoleKeyMap = "gb";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.chris = {
    name        = "chris";
    group       = "users";
    extraGroups = [ "wheel" "voice" "networkmanager" "fuse" "dialout" ];
    uid         = 1000;
    createHome  = true;
    home        = "/home/chris";
    shell       = "/run/current-system/sw/bin/bash";
  };
}
