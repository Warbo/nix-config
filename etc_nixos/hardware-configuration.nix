# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot = {
    initrd.availableKernelModules = [ "uhci_hcd" "ehci_hcd" "ata_piix" "ahci" "firewire_ohci" ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    extraModprobeConfig = ''
      options thinkpad-acpi brightness_mode=1
      options ath9k nohwcrypt=1
    '';
  };

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  swapDevices = [
    { device = "/var/swapfile";
      size = 1954; # MB
    }
  ];

  nix.maxJobs = 2;
}
