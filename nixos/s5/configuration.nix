# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:
with rec {
  nixpkgs-path = import ./nixpkgs.nix;
  nixpkgs-x86_64 = import nixpkgs-path {
    config = {};
    overlays = [];
    system = "x86_64-linux";
  };
  nixpkgs-built-on-x86_64 = import nixpkgs-path {
    config = {};
    overlays = [];
    hostSystem = "riscv64-linux";
    buildSystem = "x86_64-linux";
  };
  initial = import /home/nixos/deleteme/reproduce-initial-setup;
  rm = builtins.removeAttrs;
  fiddle = c: rm c [
    "debug" "fonts" "installer" "krb5" "nesting" "qt5" "sdImage" "sound"
    "stubby" "zramSwap"
  ] // {
    warnings = [];
    boot = rm c.boot [
      "bootMount" "crashDump" "extraTTYs" "plymouth" "uvesafb" "zfs"
    ] // {
      initrd = rm c.boot.initrd [ "luks" "secrets" "network" ];
      loader = rm c.boot.loader [ "grub" "raspberryPi" ];
    };
    console = rm c.console [ "extraTTYs" ];
    documentation = c.documentation // {
      nixos = c.documentation.nixos // {
        options = rm c.documentation.nixos.options [ "allowDocBook" ];
      };
    };
    environment = rm c.environment [ "blcr" "noXlibs" ] // {
      etc = rm c.environment.etc [ "os-release" ];
    };
    #fonts = rm c.fonts [ "enableCoreFonts" ] // {
    #  fontconfig = rm c.fonts.fontconfig [ "penultimate" "ultimate" ];
    #};
    hardware.display = rm c.hardware.display [ "edid" ];
    programs = rm c.programs [
      "_1password"
      "_1password-gui"
      "adb"
      "alvr"
      "appgate-sdp"
      "appimage"
      "arp-scan"
      "atop"
      "ausweisapp"
      "autojump"
      "bandwhich"
      "bash"
      "bash-my-aws"
      "bcc"
      "benchexec"
      "browserpass"
      "calls"
      "captive-browser"
      "cardboard"
      "ccache"
      "cdemu"
      "cfs-zen-tweaks"
      "chromium"
      "clash-verge"
      "cnping"
      "coolercontrol"
      "corectl"
      "corefreq"
      "cpu-energy-meter"
      "criu"
      "darling"
      "dconf"
      "digitalbitbox"
      "direnv"
      "dmrconfig"
      "droidcam"
      "dublin-traceroute"
      "ecryptfs"
      "envision"
      "evince"
      "evolution"
      "extra-container"
      "fcast-receiver"
      "feedbackd"
      "file-roller"
      "firefox"
      "firejail"
      "fish"
      "flashrom"
      "flexoptix-app"
      "foot"
      "fuse"
      "fzf"
      "gamemode"
      "gamescope"
      "gdk-pixbuf"
      "geary"
      "git"
      "gnome-disks"
      "gnome-documents"
      "nautilus-open-any-terminal"
      "nbd"
      "neovim"
      "nethoscope"
      "nexttrace"
      "nh"
      "niri"
      "nix-index"
      "nix-ld"
      "nix-required-mounts"
      "nm-applet"
      "nncp"
      "noisetorch"
      "npm"
      "ns-usbloader"
      "mdevctl"
      "mepo"
      "mininet"
      "minipro"
      "miriway"
      "mosh"
      "mouse-actions"
      "msmtp"
      "mtr"
      "liboping"
      "light"
      "localsend"
      "ladybird"
      "lazygit"
      "kdeconnect"
      "kubeswitch"
      "labwc"
      "kbdlight"
      "kclock"
      "kde-pim"
      "joycond-cemuhook"
      "k3b"
      "k40-whisperer"
      "iotop"
      "java"
      "immersed-vr"
      "gnome-terminal"
      "gnupg"
      "goldwarden"
      "gpaste"
      "gphoto2"
      "gpu-screen-recorder"
      "haguichi"
      "hamster"
      "htop"
      "hyprland"
      "hyprlock"
      "i3lock"
      "iay"
      "ibus"
      "iftop"
      "iio-hyprland"
      "immersed"
      "pantheon-tweaks"
      "obs-studio"
      "oddjobd"
      "oblogout"
      "openvpn3"
      "qt5ct"
      "partition-manager"
      "pay-respects"
      "plotinus"
      "pqos-wrapper"
      "projecteur"
      "proxychains"
      "pulseview"
      "qdmr"
      "qgroundcontrol"
      "rog-control-center"
      "quark-goldleaf"
      "regreet"
      "river"
      "sedutil"
      "rust-motd"
      "ryzen-monitor-ng"
      "screen"
      "seahorse"
      "sharing"
      "singularity"
      "skim"
      "slock"
      "sniffnet"
      "soundmodem"
      "spacefm"
      "ssh"
      "starship"
      "steam"
      "streamcontroller"
      "streamdeck-ui"
      "sway"
      "sysdig"
      "system-config-printer"
      "systemtap"
      "tcpdump"
      "thefuck"
      "thunar"
      "thunderbird"
      "tilp2"
      "tmux"
      "traceroute"
      "trippy"
      "tsmClient"
      "tuxclocker"
      "udevil"
      "unity3d"
      "usbtop"
      "uwsm"
      "vim"
      "virt-manager"
      "wavemon"
      "way-cooler"
      "waybar"
      "wayfire"
      "weylus"
      "winbox"
      "wireshark"
      "wshowkeys"
      "xastir"
      "xfconf"
      "xonsh"
      "xss-lock"
      "xwayland"
      "yabar"
      "yazi"
      "ydotool"
      "yubikey-touch-detector"
      "zmap"
      "zsh"
      "unity3d" "zsh"
      "x2goserver"
    ];
    security = rm c.security [
      "acme" "apparmor" "hideProcessInformation" "initialRootPassword" "klogd"
      "rngd" "setuidOwners" "setuidPrograms" "wrappers"
    ] // {
      duosec = rm c.security.duosec [ "host" "ikey" "integrationKey" "skey" ];
      #wrappers = rm c.security.wrappers [
      #  "dbus-daemon-launch-helper" "fusermount" "fusermount3"
      #];
    };
    systemd = rm c.systemd
      [ "enableUnifiedCgroupHierarchy" "generator-packages" "shutdownRamfs" "timers"] // {
        services = rm c.systemd.services ["logrotate"];
      };
    services = rm c.services [ "logging" "logrotate" ];
    users = (c.users or {}) // {
      root = (c.users.root or {}) // {
        initialHashedPassword = c.users.root.initialHashedPassword or
          c.security.initialRootPassword;
      };
    };
    virtualisation = rm c.virtualisation [ "growPartition"
                                           "anbox"
                                           "appvm"
                                           "containerd"
                                           "containers"
                                           "cri-o"
                                           "docker"
                                           "hypervGuest"
                                           "incus"
                                           "kvmgt"
                                           "libvirtd"
                                           "lxc"
                                           "lxd"
                                           "multipass"
                                           "podman"
                                           "rkt"
                                           "rosetta"
                                           "spiceUSBRedirection"
                                           "vswitch"
                                           "waydroid"
                                           "xen"
                                         ];
    xdg = c.xdg // {
      portal = rm c.xdg.portal [ "gtkUsePortal" ];
    };
  };
};
/*{ inherit (fiddle initial.config) boot hardware; } //*/ {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Include VisionFive2 support from nixos-hardware
    "${import ./nixos-hardware.nix}/starfive/visionfive/v2"
    #(import "/nix/store/1sgcsmyckgds3pqsvzkci84xhz4bjfq7-source/starfive/visionfive/v2")
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  #documentation.nixos.enable = false;  # This also uses Rust
  system.tools.nixos-option.enable = false;  # This drags in an old Nix 2.18
  #services.nscd.enableNsncd = false; # This also uses Rust
  #systemd.shutdownRamfs.enable = false; # Uses make-initrd-ng which uses Rust

  nix.nixPath = [
    "nixos-config=${../..}/nixos/s5/configuration.nix"
    "nixpkgs=${nixpkgs-path}"
  ];
  nixpkgs = {
    flake.source = nixpkgs-path;
    hostPlatform.system = "riscv64-linux";
    buildPlatform.system = "x86_64-linux";
    overlays =
    with {
      fetchFromGitHub = import ../../nix/fetchFromGitHub.nix;

      warn = name: bound: got:
        if builtins.compareVersions got bound == -1
        then (x: x)
        else builtins.trace ''
          WARNING: Avoiding breakage with ${name} < ${bound} but it's now ${got}
        '';
    }; builtins.attrValues rec {
      # x86-GHC = self: super: {
      #   inherit (nixpkgs-built-on-x86_64) ghc haskell haskellPackages shellcheck-minimal;
      # };
      # Avoids modprobe: FATAL: Module dw_mmc_starfive not found in directory
      # when cross-compiling kernel
      #avoidInitrdError = self: super: {
      #  makeModulesClosure = x:
      #    super.makeModulesClosure (x // { allowMissing = true; });
      #};

      disableShellcheck = self: super: {
        # GHC isn't bootstrapped for RiscV in Nixpkgs, but seems to claim it is.
        # Override that, so that trivial-builders don't try to shellcheck their
        # scripts.
        shellcheck-minimal.compiler.meta.platforms = [];
      };

      avoidRustBreakage = self: super:
        with {
          # Parent of the commit that bumps Rust to 1.82, which hits a compile
          # error on RiscV
          rustNixpkgs =
            warn "Rust" "1.83" super.rustPackages.rustc.version import (fetchFromGitHub {
              owner = "NixOS";
              repo = "nixpkgs";
              rev = "9c47bda6cc20cf976e5174c149997149e8a518ec";
              sha256 = "sha256-hX/ZAWWf6zE7WLN2LRZRrF27TOFu5TgM8jOL2+H+Aac=";
            }) { config = {}; };
        }; { inherit (rustNixpkgs) rustPackages; };

      nixWithoutDocumentation = self: super:
        with {
          # Disabling Nix documentation breaks the test suite of Nix 2.24, so
          # update to 2.25.2 to include https://github.com/NixOS/nix/pull/11729
          nixNixpkgs = warn "Nix" "2.25" super.nix.version import (fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "10a35620c9a348a87af60316f17ede79fa55a84a";
            sha256 = "sha256:15k1xxnipv3mxwphg7vaprizq11ncphawc13ns6v1shm180ck9i1";
          }) { config = { overlays = [ avoidRustBreakage ]; }; };
        };
        {
          # 2024-11-20 ChrisW: Disable documentation to avoid depending on Rust,
          # since we hit https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=282853
          nix = nixNixpkgs.nixVersions.nix_2_25.override (_: {
            enableDocumentation = false;
          });
        };
    };
  };
  #systemd.services.nix-daemon.environment.TMPDIR =
  #  "/mnt/internal/nix-daemon-tmp";

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  #boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  #boot.loader.generic-extlinux-compatible.enable = true;

  fileSystems =
    with rec {
      internal = "dec31a7f-4774-4c79-a3df-01c6382a60b8";
      uuids = [
        "05d217f7-1c0d-4503-8d46-70673d9486d3"
        "16a08904-689b-47ff-a4b4-c3476a0be1c9"
        "39ebff8b-a773-4efe-a1d4-37c42ccf1527"
        "cb745460-34de-429d-bf01-2b5470cb41e1"
        internal
      ];
      byUuid = uuid: {
        name = "/mnt/uuid/${uuid}";
        value = {
          inherit options;
          device = "/dev/disk/by-uuid/${uuid}";
          neededForBoot = uuid == internal;
        };
      };
      options = [
        "noatime"
        "nodiratime"
      ];
    };
    builtins.listToAttrs (builtins.map byUuid uuids)
    // {
      "/".options = options;

      # Bind mounts
      "/mnt/internal" = rec {
        device = "/mnt/uuid/${internal}";
        depends = [ device ];
        fsType = "none";
        options = [ "bind" ];
        neededForBoot = true;
      };
      "/nix" = rec {
        device = "/mnt/internal/nix";
        depends = [ device ];
        fsType = "none";
        options = [ "bind" ];
        neededForBoot = true;
      };
    };

  swapDevices = [
    {
      device = "/mnt/internal/SWAP";
      size = 16 * 1024;
    }
  ];

  networking.hostName = "s5";
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "Europe/London";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.nixos = {
     isNormalUser = true;
     initialPassword = "123";
     openssh.authorizedKeys.keys = [
       "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxAT8WR2oMGuFTQiOnShMlp+XjtP16WZNfDCo1sMsZ0I7kflcvmJtn0mxMHiNoMhP39slVkZf6Idd3T9d05reWx0X8SNFyQlCiDZFS5/t1Vc5c4CGVAFGoKGUzAa7dN9n3tX6uhSx8HSWvdzqiJGolh1u9iawJ+oM15ijXvfBJShL+nG7tTszdSpSeFJ6Pbfy3c3VEm9xw4DE3AkOxHNtACgZQx1OXM6MFBgIsBl/BvZ/4x6OcD2tIQTXZsOKePGvSkFvXNlsFfySELoNpLerWoAnDGUX1bbYCrUkdQ9BuOTt9WJa1JztEUtLyhEJ5o+61IBsY7OBsXV2tXqluL2Hl warbo@github.com"
       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuJIYFjGTZyEdIIilGLRkDy1M/AYBmsjML8tQJG48Rn chris@nixos-amd64"
     ];
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
       curl
       git
       nix
       #firefox
       #tree
     ];
   };

  services.openssh.enable = true;

  system.stateVersion = "25.05"; #"24.11";
}
