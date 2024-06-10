# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

with rec {
  inherit (pinnedNixpkgs) repoLatest;
  nix-helpers-src = (import ../../nix/sources.nix).nix-helpers;
  pinnedNixpkgs = import "${nix-helpers-src}/helpers/pinnedNixpkgs" {};
};
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import ../modules/warbo.nix)
    ];

  warbo.enable = true;
  warbo.home-manager.username = "chris";

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sdb"; # or "nodev" for efi only

  networking.hostName = "nixos-amd64"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
  #   font = "Lat2-Terminus16";
    keyMap = "uk";
  #   useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "gb";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.chris = {
    isNormalUser = true;
    initialPassword = "123";
    extraGroups = [
      "networkmanager"            # Allows managing NetworkManager, e.g. for WiFi
      "wheel"                     # Enable ‘sudo’ for the user.
      "kvm"                       # Faster virtualisation
      config.services.kubo.group  # Required to run IPFS CLI commands
    ];
    packages = with pkgs; [
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    devCli
    mediaGui
    netCli
    netGui
    sysCli
    leafpad
  ];

  fonts = {
    enableDefaultPackages   = true;
    fontconfig.defaultFonts = {
     monospace = [ "Droid Sans Mono" ];
     sansSerif = [ "Droid Sans"      ];
     serif     = [ "Droid Sans"      ];
    };
    packages = [
      pkgs.anonymousPro
      #pkgs.droid-fonts
      pkgs.liberation_ttf
      pkgs.nerdfonts
      pkgs.terminus_font
      pkgs.ttf_bitstream_vera
    ];
  };

  nix = {
    extraOptions = ''experimental-features = nix-command flakes'';
    nixPath = with builtins; [
      "nixos-config=${toString ../..}/nixos/nixos-amd64/configuration.nix"
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  services.emacs = {
    enable = true;
    package = pkgs.emacs29-pgtk; # replace with emacs-gtk, or a version provided by the community overlay if desired.
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.X11Forwarding = true;
  };

  services.gnunet.enable = true;

  services.avahi.hostName = config.networking.hostName;

  services.kubo = {
    enable = true;
    autoMount = true;
    settings.Addresses.API = [ "/ip4/127.0.0.1/tcp/5001" ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
