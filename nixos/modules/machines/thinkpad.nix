{ config, lib, pkgs, ... }:
with {
  inherit (builtins) trace;
};
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
    };
    {
      # Use the GRUB 2 boot loader.
      loader.grub = {
        enable      = true;
        version     = 2;
        device      = "/dev/sda";
        copyKernels = true;
      };

      initrd = {
        # Always loaded
        kernelModules          = mods;
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
            name   = "nixpkgs-unasserted";
            vars   = {
              broken = concatStringsSep " " [
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

          patched = import unasserted {};
        };
        trace ''
          FIXME: We would like the latest kernel but kernel mode setting
          doesn't work for i915.
        '' patched.linuxPackages_latest;

      kernelModules            = mods;
      blacklistedKernelModules = [ "snd_pcsp" "pcspkr" ];

      kernel.sysctl = {
        "net.ipv4.tcp_sack" = 0;
        "vm.swappiness"     = 10;
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
    enable     = true;
    package    = pkgs.pulseaudioFull;
  };

  sound.mediaKeys.enable = true;
}
