# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

# NOTE: If DNS doesn't work in WSL (e.g. can ping 8.8.8.8 but not google.com)
# then try creating a .wslconfig file as per https://askubuntu.com/a/1512056
{ config, lib, pkgs, ... }:
with {
  osPkgs = pkgs;
};
{
  imports =
    with rec {
      # Use builtins.fetchTarball, since pkgs.fetchFromGitHub would cause an
      # infinite loop. This helper function makes update-nix-fetchgit work.
      fetchFromGitHub = { owner, repo, rev, sha256 }:
        builtins.fetchTarball {
          inherit sha256;
          url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
        };

      home-manager = fetchFromGitHub {
        owner = "nix-community";
        repo = "home-manager";
        rev = "845a5c4c073f74105022533907703441e0464bc3"; # release-24.05
        sha256 = "0l3pcd38p4iq46ipc5h3cw7wmr9h8rbn34h8a5a4v8hcl21s8r5x";
      };
    };
    [
      # include NixOS-WSL modules
      <nixos-wsl/modules> # TODO: Pin this, delete the channel
      (import "${home-manager}/nixos")
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

  # Go up then down to ensure we work for symlinks too
  nixpkgs.overlays = import ../nixos-wsl/overlays.nix;
  nix.nixPath = [
    # Tells nixos-rebuild to use this file as configuration, rather than
    # /etc/nixos/configuration.nix. Two things to note:
    #  - We make it relative to ../.., to try and avoid broken symlinks when
    #    making copies (at least, we'll get better errors!)
    #  - There is a "bootstrap" problem, where we initially need to run
    #    'NIX_PATH=nixos-config=... nixos-rebuild switch' to ensure this file
    #    will be used the first time, so this option can take effect thereafter!
    "nixos-config=${builtins.toString ../..}/nixos/nixos-wsl/configuration.nix"
    "nixpkgs=${pkgs.path}"
    "nixos-wsl=/nix/var/nix/profiles/per-user/root/channels/nixos-wsl"
  ];

  # Use a pinned Nixpkgs, rather than relying on env vars like <nixpkgs>.
  # The documentation for this option says it can be used for this purpose
  # on systems which don't use flakes.
  /*nixpkgs.flake.source =
    with rec {
      #inherit (import ../../nix/sources.nix) nix-helpers;
      nix-helpers = /home/nixos/nix-helpers;
      pinnedNixpkgs = import "${nix-helpers}/helpers/pinnedNixpkgs" {};
    };
    pinnedNixpkgs.repoLatest;*/

  environment.systemPackages = [ pkgs.devCli ];
}
