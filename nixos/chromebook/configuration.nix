# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import ../modules/warbo.nix)
    ];

  warbo.enable = true;
  warbo.home-manager.username = "jo";
  warbo.packages = with pkgs; [
    curl
    git
    google-chrome
    htop
    mpv
    p7zip
    pavucontrol
    rclone
    screen
    sshfs
    transmission-gtk
    unzip
    vlc
    wget
    xfce.xfce4-pulseaudio-plugin

    # Fixes Patreon downloading as of Jan 2024
    /*(yt-dlp.overrideAttrs (old: {
      src = fetchFromGitHub {
        owner = "yt-dlp";
        repo  = "yt-dlp";
        rev   = "f0e8bc7c60b61fe18b63116c975609d76b904771";
        hash  = "sha256-WgagSVwgC+LB1Mev44UkJsCkI53ca2PTLDrseK63jzA=";
      };
    }))*/

    # Replaces google chrome binary with a wrapper that disables update nags
    (pkgs.hiPrio (pkgs.writeScriptBin "google-chrome-stable" ''
      #!${pkgs.bash}/bin/bash
      exec ${pkgs.google-chrome}/bin/google-chrome-stable --simulate-outdated-no-au='Tue, 31 Dec 2099' "$@"
    ''))

    openmw
    openra
    retroarchFull
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [
    # Attempt to work around screen going black occasionally
    "intel_iommu=on"
    "igfx_off"
  ];

  networking.hostName = "chromebook"; # Define your hostname.
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
    keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  };

  # Set wireless keyboard-with-trackpad to US layout. Also, its Alt
  # key sends a right-alt code (AltGr), which doesn't work for things
  # like Alt-Tab, so use an xkb option to make right-alt act as left.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="input", KERNEL=="event*", ENV{ID_INPUT_KEY}=="?*", DRIVERS=="usb", ATTRS{idVendor}=="0406", ATTRS{idProduct}=="2814", ENV{XKBMODEL}="pc104", ENV{XKBLAYOUT}="us", ENV{XKBOPTIONS}="lv3:ralt_alt"
  '';

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.desktopManager = {
    xfce.enable = true;
  };
  services.displayManager = {
    defaultSession = "xfce";
    autoLogin.user = "jo";
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "gb";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  services.fwupd.enable = true;

  services.autorandr = {
    enable = true;
    profiles = {
      lgtv = {
        fingerprint = {
          HDMI-2 = "00ffffffffffff001e6d0100010101010117010380a05a780aee91a3544c99260f5054a1080031404540614081800101010101010101023a801871382d40582c450040846300001e662150b051001b304070360040846300001e000000fd003a3e1e5310000a202020202020000000fc004c472054560a202020202020200197020321f14d109f04130514030212202215012615075009570767030c001000b82d023a801871382d40582c450040846300001e011d8018711c1620582c250040846300009e011d007251d01e206e28550040846300001e0e1f008051001e304080370040846300001c0000000000000000000000000000000000000000000066";
          eDP-1 = "00ffffffffffff0006af5c230000000001180104951a0e78026bf5915554912722505400000001010101010101010101010101010101ce1d56e250001e30261636000090100000180000000f0000000000000000000000000020000000fe0041554f0a202020202020202020000000fe004231313658544e30322e33200a006f";
        };
        config = {
          eDP-1.enable = false;
          HDMI-2 = {
            enable = true;
            #crtc = 0;
            primary = true;
            #position = "0x0";
            #mode = "3840x2160";
            #gamma = "1.0:0.909:0.833";
            #rate = "60.00";
            #rotate = "left";
          };
        };
        #hooks.postswitch = readFile ./work-postswitch.sh;
      };
    };
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  #sound.enable = true;  # This is just for ALSA?
  #hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;
  security.rtkit.enable = true;  # Let PipeWire ask for realtime priority
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    # The following only exists on NixOS 24.05+
    #wireplumber.configPackages = [
    #  (pkgs.writeTextDir "share/wireplumber/")
    #];
  };
  # Avoid stuttering/under-runs. PipeWire assumes that (a) our system is
  # reasonably fast (it's not), and (b) that we really care about low
  # latency (we don't). Increasing ALSA's "headroom" allows more audio
  # data to be buffered, so applications don't need to run as often to
  # refill it. The downside is that this increases latency: data written
  # into the buffer will only get played once everything before it has
  # finished, and a bigger buffer means more milliseconds worth of audio
  # to get through. That's fine for media players, etc. although high
  # latency might be more noticable in games or phone calls.
  environment.etc."wireplumber/wireplumber.conf.d/91-increase-headroom.conf".text = ''
    api.alsa.headroom = 2048
  '';

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jo = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     tree
  #   ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  nix = {
    package = pkgs.nixVersions.nix_2_19; # default of 2.18.1 was corrupt?
    nixPath = with builtins; [
      "nixos-config=${toString ../..}/nixos/chromebook/configuration.nix"
    ];
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.avahi = {
    inherit (config.networking) hostName;
    enable = true;
    nssmdns4 = true;
    ipv4 = true;
    publish.enable = true;
    publish.addresses = true;
    publish.workstation = true;
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


