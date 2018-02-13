# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
with builtins;
with rec {
  mypkgs  = import <nixpkgs> {
    config = import /home/chris/.nixpkgs/config.nix;
  };
};

{ config, pkgs, ... }:
rec {

  # Low level/hardware stuff

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix ];

  # Use the GRUB 2 boot loader.
  boot = trace "FIXME: Use system.activationScripts to make /boot/grub/libreboot_grub.cfg" {
    loader.grub = {
      enable  = true;
      version = 2;
      device  = "/dev/sda";
    };

    kernelModules = trace "FIXME: Which modules are artefacts of using QEMU to install?" [
      "kvm-intel" "tun" "virtio"

      "coretemp"

      # VPN-related, see https://github.com/NixOS/nixpkgs/issues/22947
      "nf_conntrack_pptp"

      # Needed for virtual consoles to work
      "fbcon" "i915"
    ];

    kernel.sysctl."net.ipv4.tcp_sack" = 0;

    #extraModprobeConfig = ''
    #  # thinkpad acpi
    #  options thinkpad_acpi
    #  # experimental=1 fan_control=1 brightness_enable=1 hotkey=enable,0xffffff
    #'';

    extraModulePackages = [ config.boot.kernelPackages.tp_smapi ];

    kernelParams = [
      "acpi_osi="
      #"video.use_native_backlight=1"
      "clocksource=acpi_pm pci=use_crs"
      "consoleblank=0"
    ];
  };

  hardware.bluetooth.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  hardware.pulseaudio = {
    systemWide = false;
    enable     = true;
    package    = mypkgs.pulseaudioFull;
    configFile = mypkgs.writeText "default.pa" ''
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
    zeroconf.discovery.enable = true;
  };

  sound.mediaKeys.enable = true;

  networking = {
    hostName                          = "nixos";
    firewall.enable                   = false;
    firewall.autoLoadConntrackHelpers = true;

    # Block surveillance, malicious actors, time wasters, etc.
    extraHosts =
      with pkgs.lib;
      with rec {
        format = lst: concatStringsSep "\n" (map (d: "127.0.0.1 ${d}") lst);

        blockList = url: mypkgs.runCommand "blocklist.nix"
          {
            inherit url;
            buildInputs   = with mypkgs; [ jq wget ];
            SSL_CERT_FILE = /etc/ssl/certs/ca-bundle.crt;
          }
          ''
            echo "Fetching block list '$url'" 1>&2

            wget -O- "$url" | grep '^.' > tmp

            grep -v '^\s*#' < tmp > tmp2
            mv tmp2 tmp

            sed -e 's/\s\s*/ /g' < tmp > tmp2
            mv tmp2 tmp

            cut -d ' ' -f2 < tmp > tmp2
            mv tmp2 tmp

            echo '['           > "$out"
              jq -R '.' < tmp >> "$out"
            echo ']'          >> "$out"
          '';

        general = blockList "http://someonewhocares.org/hosts/hosts";

        facebook = blockList "https://www.remembertheusers.com/files/hosts-fb";

        timewasters = [
          "facebook.com"
          "www.facebook.com"
          "twitter.com"
          "www.twitter.com"
          "reddit.com"
          "www.reddit.com"
          "ycombinator.com"
          "news.ycombinator.com"
          "lobste.rs"
          "www.lobste.rs"
          "slashdot.org"
          "www.slashdot.org"
          "slashdot.com"
          "www.slashdot.com"
          "lesswrong.com"
          "www.lesswrong.com"
        ];
      };
      ''
        127.0.0.1 nixos
        ${trace ''
          FIXME: Faking texLive mirror source. See
          https://github.com/NixOS/nixpkgs/issues/24683#issuecomment-314631069
        '' "146.185.144.154	lipa.ms.mff.cuni.cz"}
        ${format (import general)}
        ${format (import facebook)}
        ${format timewasters}
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

  programs = {
    #light.enable = true;
    #mosh.enable  = true;
  };

  time = {
    timeZone = "Europe/London";
  };

  environment = {
    # For SSHFS
    etc."fuse.conf".text = ''
      user_allow_other
    '';

    # Apparently needed for GTK themes.
    pathsToLink = [ "/share" ];

    # Make system themes available to user sessions
    variables = {
      GTK_DATA_PREFIX = [ "${config.system.path}" ];

      # find theme engines
      GTK_PATH = concatStringsSep ":" [
        "${config.system.path}/lib/gtk-3.0"
        "${config.system.path}/lib/gtk-2.0"
      ];

      # Find the mouse
      XCURSOR_PATH = [
        "~/.icons"
        "~/.nix-profile/share/icons"
        "/var/run/current-system/sw/share/icons"
      ];
    };

    # Packages to install in system profile.
    # NOTE: You *could* install these individually via `nix-env -i` as root, but
    # those won't be updated by `nixos-rebuild` and aren't version controlled.
    # To see if there are any such packages, do `nix-env -q` as root.
    systemPackages = [ mypkgs.all ];
  };

  fonts = {
    enableDefaultFonts      = true;
    fontconfig.defaultFonts = {
      monospace = [ "Droid Sans Mono" ];
      sansSerif = [ "Droid Sans"      ];
      serif     = [ "Droid Sans"      ];
    };
    fonts = [
      mypkgs.anonymous-pro-font
      mypkgs.droid-fonts
    ];
  };

  nixpkgs.config = {
    packageOverrides = pkgs: {
      # Required for PulseAudio headsets
      bluez = pkgs.bluez5;
    };
  };

  nix.trustedBinaryCaches = [ "http://hydra.nixos.org/" ];

  # Programs which need to be setuid, etc. should be put in here. These will get
  # wrappers made and put into a system-wide directory when the config is
  # activated, and will be removed when switched away.
  security.wrappers = {
    fusermount.source  = "${mypkgs.fuse}/bin/fusermount";
    fusermount3.source = "${mypkgs.fuse3}/bin/fusermount3";
  };

  # List services that you want to enable:

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

  services.ipfs = {
    enable      = true;
    autoMount   = true;
    enableGC    = true; # Laptop, limited storage
    dataDir     = "/var/lib/ipfs/.ipfs";
    #autoMigrate = true; # If the storage format changes
  };

  # Limit the size of our logs, to prevent ridiculous space usage and slowdown
  services.journald = {
    extraConfig = ''
      SystemMaxUse=100M
      RuntimeMaxUse=100M
    '';
  };

  services.openssh = {
    enable     = true;
    forwardX11 = true;
  };

  # Because Tories
  services.tor = {
    client = {
      enable = true;
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
      sessionCommands = readFile /home/chris/.dotfiles/xsession;
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
    enable  = true;  # Switch this to enable CUPS
    drivers = [ mypkgs.hplip mypkgs.gutenprint ];
  };

  services.avahi = {
    enable   = true;
    nssmdns  = true;
    hostName = "nixos";
    publish.enable      = true;
    publish.addresses   = true;
    publish.workstation = true;
  };

  # Not sure which is better. Ubuntu uses thermald by default.
  #services.thinkfan.enable = true;
  #services.thermald.enable = true;  # Requires CPU check disabling on X60s

  systemd.services = import ./services.nix { inherit config; pkgs = mypkgs; };

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
