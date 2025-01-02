{
  config,
  lib,
  pkgs,
  ...
}:
with { inherit (builtins) toString trace; };
{
  boot =
    with {
      mods = trace "FIXME: Which modules are artefacts of using QEMU to install?" [
        "kvm-intel"
        "tun"
        "virtio"
        "coretemp"
        "ext4"
        "usb_storage"
        "ehci_pci"
        "ahci"
        "xhci_hcd"
        "dm_mod"

        # VPN-related, see https://github.com/NixOS/nixpkgs/issues/22947
        "nf_conntrack_pptp"

        # Needed for virtual consoles to work, and for early KMS
        "fbcon"
        "drm_kms_helper"
        "intel_agp"
        "i915"
      ];
    }; {
      # Use the GRUB 2 boot loader.
      loader.grub = {
        enable = true;
        version = 2;
        device = "/dev/sda";
        copyKernels = true;
      };

      initrd = {
        # Always loaded
        kernelModules = mods;
        # Loaded on-demand (if/when the matching hardware is spotted)
        availableKernelModules = mods;
      };

      # We want at least Linux 4.17, since it contains commit 073cd78 which
      # seems to prevent some regular "kernel oops" I was hitting with the
      # i915 driver in Linux 4.9.
      kernelPackages =
        with rec {
          # Some modules, like prl-tools, make assertions about the kernel
          # version, which started failing when we upgraded to NixOS 19.09.
          # Overriding these doesn't seem to work, so we take the nuclear
          # option and patch them out of all-packages.nix.
          unasserted = pkgs.run {
            name = "nixpkgs-unasserted";
            vars = {
              broken = builtins.concatStringsSep " " [
                "blcr"
                "e1000e"
                "jool"
                "prl-tools"
              ];
              repo = pkgs.repo1809;
            };
            script = ''
              cp -r "$repo" "$out"
              chmod +w -R "$out"
              for NAME in $broken
              do
                sed -e "s@\($NAME *= *\).*;@\1null;@g" \
                    -i "$out/pkgs/top-level/all-packages.nix"
              done
            '';
          };

          patched = import unasserted { };
        };
        trace ''
          FIXME: We would like the latest kernel but kernel mode setting
          doesn't work for i915.
        '' patched.linuxPackages_latest;

      kernelModules = mods;
      blacklistedKernelModules = [
        "snd_pcsp"
        "pcspkr"
      ];

      kernel.sysctl = {
        "net.ipv4.tcp_sack" = 0;
        "vm.swappiness" = 10;
      };

      extraModulePackages = [ config.boot.kernelPackages.tp_smapi ];

      kernelParams = [
        "acpi_osi="
        "clocksource=acpi_pm"
        "pci=use_crs"
        "consoleblank=0"

        # The "cstate" determines speed vs power usage. State c3 and above
        # produce a high-pitched whining sound on my X60s, so this disables them
        "processor.max_cstate=2"

        # Turning this on prevents warnings about "Nobody cared", but causes a
        # bunch of "hpet1: lost 5900 rtc interrupts" messages and instability.
        # Keep it off for now. See https://lists.gt.net/linux/kernel/2575040
        #"irqpoll"

        # FIXME: Every kernel option below here is an attempt to make 5.x work
        # without i915 KMS crashing the system at boot. Remove them once we've
        # got that working.
        #"acpi_backlight=native"

        # Avoid spurious display connectors throwing off KMS
        # "video=TV-1:d"
        # "video=S-VIDEO-1:d"

        # "i915.fastboot=0"
        # "xforcevesa"
        # "i915.modeset=0"
        # "video=efifb"
        # "i915.enable_execlists=0"
        # "acpi=off"
        # "intel_iommu=off"
        # "intel_iommu=off,igfx_off"
        # "iommu=off"
        # "i915.enable_rc6=0"
        # "i915.enable_psr=0"
        # "drm.edid_firmware=edid/1024x768.bin"
        # "video=LVDS-1:1024x768"
        # "nomodeset"
      ];
    };

  hardware.bluetooth.enable = false;

  hardware.cpu.intel.updateMicrocode = true;

  hardware.pulseaudio = {
    systemWide = true;
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  sound.mediaKeys.enable = true;

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    enableIPv6 = false; # TODO: Why?
  };

  powerManagement = {
    enable = true;
    powerDownCommands = ''
      umount -at cifs
      killall sshfs || true
    '';
    resumeCommands = ''
      DISPLAY=:0 "${pkgs.warbo-utilities}"/bin/keys || true
    '';
  };

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
    enable = true;
    bindings = [
      {
        # Mute key
        keys = [ 113 ];
        events = [ "key" ];
        command = toString (
          pkgs.wrap {
            name = "muteToggle";
            paths = with pkgs; [
              bash
              alsa-utils
            ];
            script = ''
              #!${pkgs.bash}/bin/bash
              # Toggle mute state of 'Master'
              amixer -q -c 0 sset Master toggle

              # To get audio we need 'Master' and 'Speaker' to be unmuted. Muting
              # 'Master' also causes 'Speaker' to mute, but unmuting it doesn't.
              # To work around this asymmetry we always finish by unmuting
              # 'Speaker'. The audio state thus only depends on 'Master'.
              amixer -q -c 0 sset Speaker unmute
            '';
          }
        );
      }

      {
        # Volume down
        keys = [ 114 ];
        events = [
          "key"
          "rep"
        ];
        command = "${pkgs.alsa-utils}/bin/amixer -c 0 sset Master 1-";
      }

      {
        # Volume up
        keys = [ 115 ];
        events = [
          "key"
          "rep"
        ];
        command = "${pkgs.alsa-utils}/bin/amixer -c 0 sset Master 1+";
      }
    ];
  };

  services.laminar = {
    enable = true;
    bindHttp = "localhost:8008"; # Default 8080 clashes with IPFS
    cfg =
      with { dir = /home/chris/System/Laminar; };
      assert pathExists dir;
      toString dir;
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

  services.udev =
    with pkgs;
    with {
      fixKeyboard = wrap {
        name = "usb-keyboard.sh";
        paths = [
          bash
          coreutils
        ];
        script = ''
          #!${bash}/bin/bash
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
        ${builtins.concatStringsSep ", " [
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
    enable = true;
    videoDrivers = [
      "intel"
      "i915"
      "vesa"
      "vga"
      "fbdev"
    ];
    windowManager = {
      default = "xmonad";
      xmonad = {
        # 18.09 seems to have a broken 'hint' package
        inherit (pkgs.nixpkgs1803) haskellPackages;
        enable = true;
        enableContribAndExtras = true;
      };
    };

    desktopManager.default = "none";

    # Log in automatically as "chris"
    displayManager = {
      autoLogin = {
        enable = true;
        user = "chris";
      };
      sessionCommands = "/home/chris/.xsession";
    };
  };

  system.stateVersion = "19.03";
}
