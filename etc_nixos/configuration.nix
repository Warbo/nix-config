# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
rec {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config = {
    packageOverrides = super: let self = super.pkgs; in {
      # Workaround for https://github.com/NixOS/nixpkgs/issues/11467
      # Build mesa_drivers with llvm_36.
      # The r600 driver doesn't work with llvm_37.
      #mesa_drivers = self.mesaDarwinOr (
      #  let mo = self.mesa_noglu.override {
      #    llvmPackages = self.llvmPackages_36;
      #  };
      #   in mo.drivers
      #);
    };
  };

  # Use the GRUB 2 boot loader.
  # FIXME: Can we update LibreBoot instead?
  boot = {
    loader.grub = {
      enable  = true;
      version = 2;
      device  = "/dev/sda";
    };

    # FIXME: Are these needed? They might be artefacts of using QEMU to install.
    kernelModules = [ "kvm-intel" "tun" "virtio" ];
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
    extraHosts = builtins.readFile "/home/chris/.dotfiles/hosts";

    # NetworkManager
    networkmanager.enable = true;
    enableIPv6            = false;
  };

  # FIXME: This would be better when disconnecting the network
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

  # Works around some SSH errors
  # FIXME: is this still necessary?
  environment.etc."ssh/ssh_config".source = /home/chris/ssh_config;

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
  #services.locate = {
  #  enable    = true;
  #  localuser = "chris";
  #  extraFlags = ["--prunepaths='/home/chris/Public /home/chris/Uni'"];
  #};
  # FIXME: Once https://github.com/NixOS/nixpkgs/pull/14686/files has reached
  # the channels, we can stop forcing this override and go back to the above
  systemd.services.fixedLocate = {
    description = "Update Locate Database";
    path   = [ pkgs.su ];
    script = ''
      mkdir -m 0755 -p $(dirname "/var/cache/locatedb")
      exec updatedb \
           --localuser=chris \
           --output="/var/cache/locatedb" \
           --prunepaths='/home/chris/Public /home/chris/Uni'
    '';
    serviceConfig.Nice = 19;
    serviceConfig.IOSchedulingClass = "idle";
    serviceConfig.PrivateTmp = "yes";
    serviceConfig.PrivateNetwork = "yes";
    serviceConfig.NoNewPrivileges = "yes";
    serviceConfig.ReadOnlyDirectories = "/";
    serviceConfig.ReadWriteDirectories = "/var/cache";
  };

  services.printing = {
    enable  = true;
    drivers = [ pkgs.gutenprint ];
  };

  # Turn off power saving on WiFi to work around
  # https://bugzilla.kernel.org/show_bug.cgi?id=56301 (or something similar)
  systemd.services.wifiPower = {
    wantedBy      = [ "multi-user.target" ];
    before        = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = ''${pkgs.iw}/bin/iw dev wlp2s0 set power_save off'';
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
    extraGroups = [ "wheel" "voice" "networkmanager" "fuse" "dialout" "atd" "audio" ];
    uid         = 1000;
    createHome  = true;
    home        = "/home/chris";
    shell       = "/run/current-system/sw/bin/bash";
  };

  services.cron.systemCronJobs = [
    "*/30 * * * * chris /home/chris/warbo-utilities/web/imm -u"
    "*/5  * * * * chris ${pkgs.isync}/bin/mbsync gmail dundee"
    "2    * * * * chris ${pkgs.isync}/bin/mbsync gmail-backup"
  ];
}
