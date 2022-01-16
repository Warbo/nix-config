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
  machine = {
    i686-linux    = "thinkpad";
    aarch64-linux = "pinephone";
    x86_64-darwin = "macbook";
  }."${builtins.currentSystem}" or null;

  imports =
    # Custom NixOS modules
    map (f: ./modules + "/${f}") (attrNames (readDir ./modules)) ++

    # Include the results of the hardware scan.
    [ ./hardware-configuration.nix ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = if nix-config == null
                        then trace "WARNING: No overlays found" []
                        else import (nix-config + "/overlays.nix");


  # 4 is reasonable, 7 is everything
  boot.consoleLogLevel = 4;

  hardware.enableAllFirmware = true;

  networking = {
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
            __noChroot    = true;
            buildInputs   = with pkgs; [ curl ];
            SSL_CERT_FILE = /etc/ssl/certs/ca-bundle.crt;
          }
          ''
            echo "Fetching block list '$url'" 1>&2
            curl "$url" > tmp

            # Keep only non-empty lines
            grep '^.' < tmp > tmp2
            mv tmp2 tmp

            # Remove comments
            grep -v '^\s*#' < tmp > tmp2
            mv tmp2 tmp

            # Collapse spaces
            sed -e 's/\s\s*/ /g' < tmp > tmp2
            mv tmp2 tmp

            # Extract second field
            cut -d ' ' -f2 < tmp > tmp2
            mv tmp2 tmp

            echo '['                            > "$out"
              sed -e 's/^\(.*\)$/"\1"/g' < tmp >> "$out"
            echo ']'                           >> "$out"
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
        127.0.0.1     ${config.networking.hostName}
        192.168.1.202 phone
        ${trace ''
          FIXME: Faking texLive mirror source. See
          https://github.com/NixOS/nixpkgs/issues/24683#issuecomment-314631069
        '' "146.185.144.154	lipa.ms.mff.cuni.cz"}
        ${format (import general)}
        ${format (import facebook)}
        ${format timewasters}
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
      # XCURSOR_PATH = [
      #   "~/.icons"
      #   "~/.nix-profile/share/icons"
      #   "/var/run/current-system/sw/share/icons"
      # ];
    };

    # Packages to install in system profile.
    # NOTE: You *could* install these individually via `nix-env -i` as root, but
    # those won't be updated by `nixos-rebuild` and aren't version controlled.
    # To see if there are any such packages, do `nix-env -q` as root.
    systemPackages = [ pkgs.allPkgs ];
  };

  fonts = {
    enableDefaultFonts      = true;
    fontconfig.defaultFonts = {
      monospace = [ "Droid Sans Mono" ];
      sansSerif = [ "Droid Sans"      ];
      serif     = [ "Droid Sans"      ];
    };
    fonts = [
      pkgs.anonymousPro
      pkgs.droid-fonts
      pkgs.liberation_ttf
      pkgs.terminus_font
      pkgs.ttf_bitstream_vera
    ];
  };

  nix = {
    # Defaults to 'true' in 19.03, which disallows network access in builders.
    # We prefer "relaxed", which allows derivations to opt-out by having a
    # '__noChroot = true' attribute.
    useSandbox          = "relaxed";
    trustedBinaryCaches = [ "http://hydra.nixos.org/" ];

    # Non-sandboxed builds, including the __noChroot opt-out, can only be built
    # by these users and root (if the useSandbox option isn't false).
    trustedUsers = [ "chris" "laminar" ];
  };

  programs = {
    gnupg.agent.enable = true;
    iotop.enable = true;
    mosh.enable  = true;
    qt5ct.enable = true;  # Non-DE Qt config GUI
  };

  # Programs which need to be setuid, etc. should be put in here. These will get
  # wrappers made and put into a system-wide directory when the config is
  # activated, and will be removed when switched away.
  security.wrappers = {
    fusermount.source  = "${pkgs.fuse}/bin/fusermount";
    fusermount3.source = "${pkgs.fuse3}/bin/fusermount3";
  };

  # List services that you want to enable:

  services.avahi = {
    inherit (config.networking) hostName;
    enable              = true;
    nssmdns             = true;
    publish.enable      = true;
    publish.addresses   = true;
    publish.workstation = true;
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

  services.printing = {
    enable  = true;
    drivers = [ pkgs.nixpkgs1709.hplip pkgs.nixpkgs1709.gutenprint ];
  };

  # Because Tories
  services.tor = { client = { enable = true; }; };

  services.xserver = {
    layout     = "gb";
    xkbOptions = "ctrl:nocaps";
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

  console.keyMap     = "uk";
  i18n.defaultLocale = "en_GB.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    extraUsers = {
      chris = {
        name         = "chris";
        group        = "users";
        uid          = 1000;
        createHome   = true;
        home         = "/home/chris";
        shell        = "/run/current-system/sw/bin/bash";
        isNormalUser = true;
        extraGroups  = [
          "atd" "audio" "dialout" "docker" "fuse" "netdev" "networkmanager"
          "pulse" "voice" "wheel"
        ];
      };
    };
  };
}
