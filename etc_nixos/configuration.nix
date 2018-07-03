# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
with builtins;
with rec {
  mypkgs  = import <nixpkgs> {
    config = import /home/chris/.nixpkgs/config.nix;
  };

  warbo-utilities = mypkgs.warbo-utilities.override { forceLatest = true; };

  myOverrides =
    with mypkgs; lib.genAttrs customPkgNames (n: getAttr n mypkgs) // {
      inherit warbo-utilities;
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

    extraModulePackages = [ config.boot.kernelPackages.tp_smapi ];

    kernelParams = [
      "acpi_osi="
      "clocksource=acpi_pm pci=use_crs"
      "consoleblank=0"
    ];
  };

  hardware.bluetooth.enable = false;

  hardware.cpu.intel.updateMicrocode = true;

  hardware.pulseaudio = {
    systemWide = true;
    enable     = true;
    package    = mypkgs.pulseaudioFull;
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

    # NetworkManager
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
      DISPLAY=:0 "${warbo-utilities}"/bin/keys || true
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
    systemPackages = [ mypkgs.all warbo-utilities ];
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
    packageOverrides = pkgs: mypkgs // {
      mesa_drivers =
        with rec {
          mo = pkgs.mesa_noglu.override {
            grsecEnabled        = config.grsecurity or false;
            enableTextureFloats = true;
            galliumDrivers      = if pkgs.stdenv.isArm || pkgs.stdenv.isAarch64
                                     then null
                                     else ["r300" "r600" "radeonsi" "nouveau"];
          };

          patch = toFile "i915-gl2.patch" ''
            diff --git a/src/mesa/drivers/dri/i915/intel_extensions.c b/src/mesa/drivers/dri/i915/intel_extensions.c
            index 4f2c6fa34e..ab7820f123 100644
            --- a/src/mesa/drivers/dri/i915/intel_extensions.c
            +++ b/src/mesa/drivers/dri/i915/intel_extensions.c
            @@ -92,12 +92,8 @@ intelInitExtensions(struct gl_context *ctx)
                   ctx->Extensions.ATI_separate_stencil = true;
                   ctx->Extensions.ATI_texture_env_combine3 = true;
                   ctx->Extensions.NV_texture_env_combine4 = true;
            -
            -      if (driQueryOptionb(&intel->optionCache, "fragment_shader"))
            -         ctx->Extensions.ARB_fragment_shader = true;
            -
            -      if (driQueryOptionb(&intel->optionCache, "stub_occlusion_query"))
            -         ctx->Extensions.ARB_occlusion_query = true;
            +      ctx->Extensions.ARB_fragment_shader = true;
            +      ctx->Extensions.ARB_occlusion_query = true;
                }
            ${" "}
                if (intel->ctx.Mesa_DXTn
            diff --git a/src/mesa/drivers/dri/i915/intel_screen.c b/src/mesa/drivers/dri/i915/intel_screen.c
            index 863f6ef7ec..ac61d4ffcd 100644
            --- a/src/mesa/drivers/dri/i915/intel_screen.c
            +++ b/src/mesa/drivers/dri/i915/intel_screen.c
            @@ -61,10 +61,6 @@ DRI_CONF_BEGIN
             	 DRI_CONF_DESC(en, "Enable early Z in classic mode (unstable, 945-only).")
                   DRI_CONF_OPT_END
            ${" "}
            -      DRI_CONF_OPT_BEGIN_B(fragment_shader, "true")
            -	 DRI_CONF_DESC(en, "Enable limited ARB_fragment_shader support on 915/945.")
            -      DRI_CONF_OPT_END
            -
                DRI_CONF_SECTION_END
                DRI_CONF_SECTION_QUALITY
                   DRI_CONF_FORCE_S3TC_ENABLE("false")
            @@ -78,10 +74,6 @@ DRI_CONF_BEGIN
                   DRI_CONF_DISABLE_GLSL_LINE_CONTINUATIONS("false")
                   DRI_CONF_DISABLE_BLEND_FUNC_EXTENDED("false")
            ${" "}
            -      DRI_CONF_OPT_BEGIN_B(stub_occlusion_query, "false")
            -	 DRI_CONF_DESC(en, "Enable stub ARB_occlusion_query support on 915/945.")
            -      DRI_CONF_OPT_END
            -
                   DRI_CONF_OPT_BEGIN_B(shader_precompile, "true")
             	 DRI_CONF_DESC(en, "Perform code generation at shader link time.")
                   DRI_CONF_OPT_END
            @@ -1135,21 +1127,12 @@ set_max_gl_versions(struct intel_screen *screen)
                __DRIscreen *psp = screen->driScrnPriv;
            ${" "}
                switch (screen->gen) {
            -   case 3: {
            -      bool has_fragment_shader = driQueryOptionb(&screen->optionCache, "fragment_shader");
            -      bool has_occlusion_query = driQueryOptionb(&screen->optionCache, "stub_occlusion_query");
            -
            +   case 3:
                   psp->max_gl_core_version = 0;
                   psp->max_gl_es1_version = 11;
            +      psp->max_gl_compat_version = 21;
                   psp->max_gl_es2_version = 20;
            -
            -      if (has_fragment_shader && has_occlusion_query) {
            -         psp->max_gl_compat_version = 21;
            -      } else {
            -         psp->max_gl_compat_version = 14;
            -      }
                   break;
            -   }
                case 2:
                   psp->max_gl_core_version = 0;
                   psp->max_gl_compat_version = 13;
          '';

          patched = mo.overrideAttrs (old: {
            patches = old.patches ++ [ patch ];
          });
        };
        trace ''FIXME: The Gallium version of the i915 driver seems to segfault.
                       This affects things like Firefox, which is annoying.
                       Until this is fixed upstream, we're using the workaround
                       from https://github.com/NixOS/nixpkgs/issues/30758 which
                       removes i915 from the list of Gallium drivers, causing a
                       fallback to the non-Gallium version. It also patches the
                       i915 driver's source to ensure OpenGL2 works.
                NOTE: We can test this by seeing if glxgears segfaults:
                        nix-shell -p glxinfo --run glxgears''
              patched.drivers;
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
    };
  };

  services.bitlbee.enable = true;

  services.ipfs = {
    enable         = true;
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

  services.openssh = {
    enable     = true;
    forwardX11 = true;
  };

  # Because Tories
  services.tor = { client = { enable = true; }; };

  services.udev =
    with mypkgs;
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
      '';
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

  systemd.services = import ./services.nix {
    inherit config warbo-utilities;
    pkgs = mypkgs;
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
    extraGroups = [ "wheel" "voice" "networkmanager" "fuse" "dialout" "atd" "audio" "docker" "pulse" ];
    uid         = 1000;
    createHome  = true;
    home        = "/home/chris";
    shell       = "/run/current-system/sw/bin/bash";
  };
}
