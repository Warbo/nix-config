# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:

with builtins;
with rec {
  nix-config =
    with { fallback = /home/chris/Programming/Nix/nix-config; };
    if pathExists ../overlays.nix
       then ../.
       else if pathExists fallback
               then fallback
               else null;
};
rec {
  # Low level/hardware stuff

  imports =
    # Custom NixOS modules
    map (f: ./modules + "/${f}") (attrNames (readDir ./modules)) ++

    # Include the results of the hardware scan.
    [ ./hardware-configuration.nix ];

  nixpkgs.overlays = if nix-config == null
                        then trace "WARNING: No overlays found" []
                        else import (nix-config + "/overlays.nix");

  # Use the GRUB 2 boot loader.
  boot = trace "FIXME: Use system.activationScripts to make /boot/grub/libreboot_grub.cfg" {
    loader.grub = {
      enable  = true;
      version = 2;
      device  = "/dev/sda";

      # Put kernels in /boot, which should help with getting LibreBoot to work
      copyKernels = true;
    };

    # Use kernel from 17.09 to avoid system freezes which started with 18.03
    kernelPackages = pkgs.nixpkgs1709.linuxPackages;

    kernelModules = trace "FIXME: Which modules are artefacts of using QEMU to install?" [
      "kvm-intel" "tun" "virtio"

      "coretemp"

      # VPN-related, see https://github.com/NixOS/nixpkgs/issues/22947
      "nf_conntrack_pptp"

      # Needed for virtual consoles to work
      "fbcon" "i915"
    ];

    kernel.sysctl = {
      "net.ipv4.tcp_sack" = 0;
      "vm.swappiness"     = 10;
    };

    extraModulePackages = [ config.boot.kernelPackages.tp_smapi ];

    kernelParams = [
      "acpi_osi="
      "clocksource=acpi_pm pci=use_crs"
      "consoleblank=0"

      # The "cstate" determines speed vs power usage. State c3 and above produce
      # a high-pitched whining sound on my X60s, so this disables them.
      "processor.max_cstate=2"
    ];
  };

  hardware.bluetooth.enable = false;

  hardware.cpu.intel.updateMicrocode = true;

  hardware.pulseaudio = {
    systemWide = true;
    enable     = true;
    package    = pkgs.pulseaudioFull;
  };

  sound.mediaKeys.enable = true;

  networking = {
    hostName                          = "nixos";
    firewall.enable                   = false;
    firewall.autoLoadConntrackHelpers = true;

    # Don't rely on those from DHCP, since the ISP might MITM
    nameservers = [ "208.67.222.222" "208.67.220.220" "8.8.8.8" ];

    # Block surveillance, malicious actors, time wasters, etc.
    extraHosts =
      with pkgs.lib;
      with rec {
        format = lst: concatStringsSep "\n" (map (d: "127.0.0.1 ${d}") lst);

        blockList = url: pkgs.runCommand "blocklist.nix"
          {
            inherit url;
            buildInputs   = with pkgs; [ jq wget ];
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

        general  = blockList "http://someonewhocares.org/hosts/hosts";
        facebook = blockList "https://www.remembertheusers.com/files/hosts-fb";

        timewasters = [
          "facebook.com"
          "www.facebook.com"
          "twitter.com"
          "www.twitter.com"
          #"ycombinator.com"
          #"news.ycombinator.com"
          #"lobste.rs"
          #"www.lobste.rs"
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

    networkmanager.enable = true;
    enableIPv6            = false;
  };

  powerManagement = {
    enable            = true;
    powerDownCommands = ''
      umount -at cifs
      killall sshfs || true
    '';
    resumeCommands = ''
      DISPLAY=:0 "${pkgs.warbo-utilities}"/bin/keys || true
    '';
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
    systemPackages = [ pkgs.all pkgs.warbo-utilities ];
  };

  fonts = {
    enableDefaultFonts      = true;
    fontconfig.defaultFonts = {
      monospace = [ "Droid Sans Mono" ];
      sansSerif = [ "Droid Sans"      ];
      serif     = [ "Droid Sans"      ];
    };
    fonts = [
      pkgs.anonymous-pro-font
      pkgs.droid-fonts
    ];
  };

  nix.trustedBinaryCaches = [ "http://hydra.nixos.org/" ];

  # Programs which need to be setuid, etc. should be put in here. These will get
  # wrappers made and put into a system-wide directory when the config is
  # activated, and will be removed when switched away.
  security.wrappers = {
    fusermount.source  = "${pkgs.fuse}/bin/fusermount";
    fusermount3.source = "${pkgs.fuse3}/bin/fusermount3";
  };

  # List services that you want to enable:

  services.acpid = {
    enable = true;
    handlers = {
      mute = {
        event = "button/mute.*";
        action = "amixer set Master toggle";
      };
    };
  };

  # Provides keybindings by intercepting the output of each keyboard device.
  # Unlike e.g. xbindkeys, these bindings will even work in text consoles.
  # Note that NixOS has an audio.mediaKeys option which does a similar thing,
  # but its 'amixer' invocations don't seem to work on my X60s laptop.
  services.actkbd = {
    enable   = true;
    bindings = [
      {
        # Mute key
        keys    = [ 113 ];
        events  = [ "key" ];
        command = toString (pkgs.wrap {
          name   = "muteToggle";
          paths  = with pkgs; [ bash alsaUtils ];
          script = ''
            #!/usr/bin/env bash
            # Toggle mute state of 'Master'
            amixer -q -c 0 sset Master toggle

            # To get audio we need 'Master' and 'Speaker' to be unmuted. Muting
            # 'Master' also causes 'Speaker' to mute, but unmuting it doesn't.
            # To work around this asymmetry we always finish by unmuting
            # 'Speaker'. The audio state thus only depends on 'Master'.
            amixer -q -c 0 sset Speaker unmute
          '';
        });
      }

      {
        # Volume down
        keys    = [ 114 ];
        events  = [ "key" "rep" ];
        command = "${pkgs.alsaUtils}/bin/amixer -c 0 sset Master 1-";
      }

      {
        # Volume up
        keys    = [ 115 ];
        events  = [ "key" "rep" ];
        command = "${pkgs.alsaUtils}/bin/amixer -c 0 sset Master 1+";
      }
    ];
  };

  services.bitlbee = {
    enable = true;
    authMode = "Registered";
  };

  services.ipfs = {
    enable         = false;  # Quite resource-hungry
    autoMount      = false;  # Mounting can cause FUSE errors
    enableGC       = true;   # Laptop, limited storage
    dataDir        = "/var/lib/ipfs/.ipfs";
    serviceFdlimit = 64 * 1024;  # Bump up, since it keeps running out
    extraConfig    = {
      # Reduce memory usage (from https://github.com/ipfs/go-ipfs/issues/4145 )
      Swarm = {
        AddrFilters = null;
        ConnMgr     = {
          GracePeriod = "20s";
          HighWater   = 100;
          LowWater    = 50;
          Type        = "basic";
        };
      };
    };
    extraFlags = [
      # Reduce CPU usage (from https://github.com/ipfs/go-ipfs/issues/4145 )
      "--routing=dhtclient"
    ];
  };

  # Limit the size of our logs, to prevent ridiculous space usage and slowdown
  services.journald = {
    extraConfig = ''
      SystemMaxUse=100M
      RuntimeMaxUse=100M
    '';
  };

  services.nix-daemon-tunnel.enable = true;

  services.openssh = {
    enable     = true;
    forwardX11 = true;
  };

  # Laptop power management
  services.tlp = {
    enable = true;
    extraConfig = ''
      # See https://linrunner.de/en/tlp/docs/tlp-configuration.html

      # Force battery mode rather than AC
      TLP_DEFAULT_MODE=BAT
      TLP_PERSISTENT_DEFAULT=1

      # Powersave keeps CPU underclocked to avoid overheating, see 'tlp-stat -p'
      CPU_SCALING_GOVERNOR_ON_AC=powersave
      CPU_SCALING_GOVERNOR_ON_BAT=powersave

      # Underclock to avoid overheating
      CPU_SCALING_MIN_FREQ_ON_AC=0         # Default (1000000)
      CPU_SCALING_MAX_FREQ_ON_AC=1333000   # Rather than 1666000
      CPU_SCALING_MIN_FREQ_ON_BAT=0        # Default (1000000)
      CPU_SCALING_MAX_FREQ_ON_BAT=1333000  # Rather than 1666000

      # Try using one CPU when near idle
      SCHED_POWERSAVE_ON_AC=1
      SCHED_POWERSAVE_ON_BAT=1

      # Prefer powersaving
      ENERGY_PERF_POLICY_ON_AC=powersave
      ENERGY_PERF_POLICY_ON_BAT=powersave
    '';
  };

  # Because Tories
  services.tor = { client = { enable = true; }; };

  services.udev =
    with pkgs;
    with {
      fixKeyboard = wrap {
        name   = "usb-keyboard.sh";
        paths  = [ bash coreutils ];
        script = ''
          #!/usr/bin/env bash
          # Requests that the keyboard be fixed. Running 'keys' from here seems
          # to fail (even with DISPLAY, etc. set) so we instead just log a
          # request in /tmp and rely on 'key_poller' to spot it.
          date '+%s' > /tmp/keys-last-ask
        '';
      };
    };
    {
      extraRules = ''
        SUBSYSTEM=="usb", ACTION=="add|remove", RUN+="${fixKeyboard}"

        # USB networking for OpenMoko
        ${concatStringsSep ", " [
          ''SUBSYSTEM=="net"''
          ''ACTION=="add"''
          ''DRIVERS=="?*"''
          ''ATTRS{idProduct}=="a4a2"''
          ''ATTRS{idVendor}=="0525"''
          ''KERNEL=="usb*"''
          ''NAME="openmoko0"''
        ]}
      '';
    };

  services.xserver = {
    enable         = true;
    layout         = "gb";
    xkbOptions     = "ctrl:nocaps";
    windowManager  = {
      default      = "xmonad";
      xmonad       = {
        # 18.09 seems to have a broken 'hint' package
        inherit (pkgs.nixpkgs1803) haskellPackages;
        enable                 = true;
        enableContribAndExtras = true;
      };
    };

    desktopManager.default = "none";

    # Log in automatically as "chris"
    displayManager = {
      auto = {
        enable = true;
        user   = "chris";
      };
      sessionCommands = "/home/chris/.xsession";
    };
  };

  services.printing = {
    enable  = true;
    drivers = [ pkgs.nixpkgs1709.hplip pkgs.nixpkgs1709.gutenprint ];
  };

  services.avahi = {
    enable   = true;
    nssmdns  = true;
    hostName = "nixos";
    publish.enable      = true;
    publish.addresses   = true;
    publish.workstation = true;
  };

  services.laminar = {
    enable   = true;
    bindHttp = "localhost:8008";  # Default 8080 clashes with IPFS
    cfg      = toString /home/chris/System/Laminar;
  };

  system.activationScripts = {
    dotfiles = ''
      cd /home/chris/.dotfiles || exit 1
      for X in *
      do
        [[ "x$X" = "x.issues"   ]] && continue
        [[ "x$X" = "xetc_nixos" ]] && continue
        [[ "x$X" = "xREADME"    ]] && continue
        [[ "x$X" = "xcheck.sh"  ]] && continue
        [[ -h "/home/chris/.$X" ]] && continue
        [[ -e "/home/chris/.$X" ]] && {
          echo "WARNING: Found ~/.$X but it's not a symlink" 1>&2
          continue
        }
        (cd /home/chris && ln -s .dotfiles/"$X" ."$X")
      done
    '';
    dotEmacs = with pkgs; ''
      # ~/.emacs.d is currently stand alone, but we still want to hook some Nix
      # things into it, e.g. paths to executables
      X='(setq explicit-shell-file-name "${warbo-utilities}/bin/wrappedShell")'
      echo "$X" > /home/chris/.emacs.d/personal/preload/wrapped-shell.el
    '';
  };

  systemd.services = import ./services.nix { inherit config pkgs; };

  # Locale, etc.
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    consoleKeyMap = "uk";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.chris = {
    name        = "chris";
    group       = "users";
    extraGroups = [ "wheel" "voice" "networkmanager" "fuse" "dialout" "atd"
                    "audio" "docker" "pulse" ];
    uid         = 1000;
    createHome  = true;
    home        = "/home/chris";
    shell       = "/run/current-system/sw/bin/bash";
  };
}
