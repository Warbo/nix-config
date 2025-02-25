# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

# NOTE: If DNS doesn't work in WSL (e.g. can ping 8.8.8.8 but not google.com)
# then try creating a .wslconfig file as per https://askubuntu.com/a/1512056
{
  config,
  lib,
  pkgs,
  ...
}:
with {
  inherit
    (
      (rec { inherit (import ../../overrides/repos.nix overrides { }) overrides; })
      .overrides.nix-helpers
    )
    sanitiseName
    ;
  osPkgs = pkgs;
  warbo-wsl = import ../../wsl { inherit lib pkgs; };
};
{
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules> # TODO: Pin this, delete the channel
    (import ../modules/warbo.nix)
  ];

  warbo.enable = true;
  warbo.professional = true;
  warbo.wsl = true;
  warbo.home-manager = {
    username = "nixos";
    extras = {
      inherit (warbo-wsl) home programs;
    };
  };
  warbo.packages = warbo-wsl.packages ++ [
    pkgs.devCli
    pkgs.devGui
    pkgs.sysCliNoFuse
  ];

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11";

  nix.nixPath = [
    # Tells nixos-rebuild to use this file as configuration, rather than
    # /etc/nixos/configuration.nix. Two things to note:
    #  - We make it relative to ../.., to try and avoid broken symlinks when
    #    making copies (at least, we'll get better errors!)
    #  - There is a "bootstrap" problem, where we initially need to run
    #    'NIX_PATH=nixos-config=... nixos-rebuild switch' to ensure this file
    #    will be used the first time, so this option can take effect thereafter!
    "nixos-config=${builtins.toString ../..}/nixos/nixos-wsl/configuration.nix"
    "nixos-wsl=/nix/var/nix/profiles/per-user/root/channels/nixos-wsl"
  ];

  # Required to run dodgy Linux executables provided by Windows applications
  # (e.g. 1Password's op-ssh-sign-wsl)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [ ];
  };

  # Put some fonts in the place WSL's X server expects to find them
  # See https://github.com/microsoft/wslg/issues/310#issuecomment-1528839137
  system.activationScripts.wslFontsDir = ''
    set -x
    mkdir -p /usr/share/fonts/X11
    ${pkgs.rsync}/bin/rsync -r '${pkgs.warbo-packages.jmk-x11-fonts}/share/X11/fonts/' /usr/share/fonts/X11/
    ${pkgs.xorg.mkfontdir}/bin/mkfontdir /usr/share/fonts/X11
  '';
}
