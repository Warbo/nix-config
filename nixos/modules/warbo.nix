{ config, lib, pkgs, ... }:
with {
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.warbo;
};
{
  imports = [(import ../../home-manager/nixos-import.nix)];

  options.warbo = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Turn on custom "warbo" configuration.
      '';
    };

    professional = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Stick to utilities (avoiding music players, torrent clients, etc.).
      '';
    };

    direnv.enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable direnv and nix-shell integration.
      '';
    };

    home-manager.username = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The username to enable Home Manager for (leave null to disable HM).
      '';
    };
    home-manager.stateVersion = mkOption {
      type = types.str;
      default = "24.05";  # Override as needed
      description = ''
        Passed along to user's Home Manager. Records the version of Home
        Manager that was originally installed, so future upgrades can apply
        any necessary fixes/workarounds to maintain compatibility.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (with rec {
      inherit (import "${nix-helpers}/helpers/pinnedNixpkgs" {}) repoLatest;
      inherit (import ../../nix/sources.nix) nix-helpers;
    };
      {
        # Unconditional; override if desired
        nixpkgs = {
          config.allowUnfree = true;
          flake.source = repoLatest;
          overlays = with import ../../overlays.nix; [
            sources
            repos
            metaPackages
          ];
        };
        nix.nixPath = ["nixpkgs=${repoLatest}"];
        programs.iotop.enable = true;
        programs.screen.enable = true;
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
    (mkIf cfg.direnv.enable {
      programs.direnv = {
        enable = true;
        loadInNixShell = true;
        nix-direnv.enable = true;
      };
    })
    (mkIf (cfg.home-manager.username != null) {
      home-manager.users."${cfg.home-manager.username}" = {...}: {
        home.stateVersion = cfg.home-manager.stateVersion;
        programs = {
          bash.enable = true;
          git.enable = true;
          home-manager.enable = true;
          htop.enable = true;
          jq.enable = true;
          jujutsu.enable = true;
          password-store = {
            enable = true;
            package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
            settings.PASSWORD_STORE_DIR = "$HOME/.password-store";
          };
        };
        services.emacs.defaultEditor = true;
      };
    })
    (mkIf ((cfg.home-manager.username != null) && (!cfg.professional)) {
      home-manager.users."${cfg.home-manager.username}" = {...}: {
        programs.yt-dlp.enable = true;
      };
    })
  ]);
}
