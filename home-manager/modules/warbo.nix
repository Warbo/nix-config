{ config, lib, pkgs, ... }:
with {
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.warbo;
};
{
  options.warbo = import ../../warbo-options.nix { inherit lib; };

  config = mkIf cfg.enable (mkMerge [
    {
      # Unconditional; override if desired
      home.stateVersion = cfg.home-manager.stateVersion;
      programs = {
        bash = {
          enable = true;
        };
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
    }
    (mkIf (!cfg.professional) {
      # Disable by setting 'warbo.professional'
      programs.yt-dlp.enable = true;
    })
    (mkIf (cfg.direnv && (!cfg.is-nixos)) {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    })
