# Warbo's preferred setup, used across a bunch of systems. This part is specific
# to NixOS; there is an equivalent module for Home Manager (which this module
# can load for us too!)
{ config, lib, pkgs, ... }:
with {
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.warbo;
};
{
  imports = [ (import "${import ../../home-manager/nixos-import.nix}/nixos") ];

  options.warbo = import ../../warbo-options.nix { inherit lib; } // {
    home-manager.username = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The username to enable Home Manager for (leave null to disable HM).
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # Unconditional; override if desired
      nixpkgs.config.allowUnfree = true;
      programs.iotop.enable = true;
      programs.screen.enable = true;
    }
    (mkIf (cfg.nixpkgs.path != null) {
      nix.nixPath = [ "nixpkgs=${cfg.nixpkgs.path}" ];
      nixpkgs.flake.source = cfg.nixpkgs.path;
    })
    (mkIf (cfg.nixpkgs.overlays != null) {
      nixpkgs.overlays = cfg.nixpkgs.overlays (import ../../overlays.nix);
    })
    (mkIf (!cfg.professional) {
      # Disable by setting 'warbo.professional'
      programs.gnupg.agent.enable = true;
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        publish.enable = true;
        publish.addresses = true;
        publish.workstation = true;
      };
    })
    (mkIf cfg.direnv {
      programs.direnv = {
        enable = true;
        loadInNixShell = true;  # This option doesn't exist in Home Manager
        nix-direnv.enable = true;
      };
    })
    (mkIf (cfg.home-manager.username != null) {
      home-manager.users."${cfg.home-manager.username}" = {...}: {
        # Load our Home Manager equivalent
        imports = [(../../home-manager/modules/warbo.nix)];

        # Pass along relevant config to our Home Manager module
        warbo = {
          inherit (cfg) enable professional direnv nixpkgs home-manager;
          is-nixos = true;
        };
      };
    })
  ]);
}
