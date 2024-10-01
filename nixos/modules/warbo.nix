# Warbo's preferred setup, used across a bunch of systems. This part is specific
# to NixOS; there is an equivalent module for Home Manager (which this module
# can load for us too!)
{
  config,
  lib,
  pkgs,
  ...
}:
with {
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.warbo;
};
{
  imports = [ (import "${import ../../home-manager/nixos-import.nix}/nixos") ];

  options.warbo =
    with { common = import ../../warbo-options.nix { inherit lib; }; };
    common
    // {
      home-manager = (common.home-manager or { }) // {
        username = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            The username to enable Home Manager for (leave null to disable HM).
          '';
        };
      };
    };

  config = mkIf cfg.enable (mkMerge [
    {
      # Unconditional; override if desired
      nix.settings.show-trace = true;
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
        loadInNixShell = true; # This option doesn't exist in Home Manager
        nix-direnv.enable = true;
      };
    })
    (mkIf (cfg.home-manager.username != null) {
      home-manager.users."${cfg.home-manager.username}" =
        { ... }:
        {
          # Load our Home Manager equivalent
          imports = [ (../../home-manager/modules/warbo.nix) ];

          # Pass along relevant config to our Home Manager module
          warbo = {
            inherit (cfg)
              direnv
              enable
              nixpkgs
              packages
              professional
              ;
            is-nixos = true;
            # Passing along username will cause an error, since our Home Manager
            # module doesn't define that option
            home-manager = builtins.removeAttrs cfg.home-manager [ "username" ];
          };
        };
    })
    (mkIf (cfg.home-manager.username == null) {
      # We prefer to put cfg.packages in the user's home.packages, but if HM
      # isn't being used then we put them in the system environment.
      environment.systemPackages = cfg.packages;
    })
  ]);
}
