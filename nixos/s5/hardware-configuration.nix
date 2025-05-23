# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    # extraModulePackages = [ ];
    # initrd = {
    #   availableKernelModules = [
    #     "xhci_pci"
    #     "nvme"
    #     "pci_host_generic"
    #     "virtio_pci"
    #     "9p"
    #     "9pnet_virtio"
    #   ];
    #   kernelModules = [ ];
    # };
    # kernelModules = [ ];
    # kernelPackages = pkgs.linuxPackages_latest;

    # 2024-12-13: These came from hardware scan, defaults, or wherever; but they
    # don't appear in /boot/extlinux/extlinux.conf for the successfully booting
    # system (post self-installation), so removing them for now -- ChrisW
    # kernelParams = [
    #   "console=ttyS0"
    #   "earlycon"
    # ];

    # 2024-12-12: Hit https://lore.kernel.org/lkml/Z0Y_bC42dufBNE4L@ghost/T/ so
    # ChrisW grabbed these patches
    # kernelPatches = with rec {
    #   inherit (rec {
    #     base = "https://git.kernel.org/pub/scm/linux/kernel/git";
    #     fetchPatch = commit: sha256: builtins.fetchurl {
    #       inherit sha256;
    #       url = "${base}/bpf/bpf-next.git/patch/?id=${commit}";
    #     };
    #   }) fetchPatch;

    #   # These patches are included in Linux 6.13, so warn if we're now safe to
    #   # remove these patches.
    #   inherit (builtins) compareVersions toJSON trace;
    #   warn = kernelVersion: if compareVersions kernelVersion "6.13" >= 0
    #             then trace (toJSON {
    #               inherit kernelVersion;
    #               warning = "Kernel patches not needed for Linux >= 6.13";
    #             }) else (x: x);
    # };
    #   warn pkgs.linuxPackages_latest.kernel.version [
    #   {
    #     name = "fix-riscv-libbpf";
    #     patch = fetchPatch "710fbca820c721cdd60fa8c5bbe9deb4c0788aae"
    #       "sha256:0nyj8jnck1hrq5j3b5dni0rk7bqii3x8bfsy2rhwggcwqhbqnms8";
    #   }
    #   {
    #     name = "fix-riscv-bpf";
    #     patch = fetchPatch "19090f0306f1748980596c6c71f1c4b128639cff"
    #       "sha256:1qyh8dx98lh56vg87bv9y65j458kd3gwngyjcsk3hpwm8c099k60";
    #   }
    # ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
    fsType = "ext4";
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  networking.interfaces.end0.useDHCP = lib.mkDefault true;
  networking.interfaces.end1.useDHCP = lib.mkDefault true;
  # networking.interfaces.ip6tnl0.useDHCP = lib.mkDefault true;
  # networking.interfaces.sit0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "riscv64-linux";
}
