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
  options.warbo = import ../../warbo-options.nix { inherit lib; };

  config = mkIf cfg.enable (mkMerge [
    {
      # Unconditional; override if desired
      home.stateVersion = cfg.home-manager.stateVersion;
      nixpkgs.config.allowUnfree = true;
      programs = {
        bash = {
          enable = true;
          profileExtra = ''
            # Inherited from pre-Home-Manager config; not sure if needed
            [[ -f ~/.bashrc ]] && . ~/.bashrc
          '';
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
    (mkIf (cfg.nixpkgs.path != null) {
      home.sessionVariables.NIX_PATH = "nixpkgs=${cfg.nixpkgs.path}";
    })
    (mkIf (cfg.nixpkgs.overlays != null) {
      nixpkgs.overlays = cfg.nixpkgs.overlays (import ../../overlays.nix);
    })
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
    (mkIf (cfg.dotfiles != null) {
      programs.bash.bashrcExtra =
        with builtins;
        assert (typeOf cfg.dotfiles == "path" && pathExists cfg.dotfiles) ||
               (cfg.dotfiles ? outPath);
        readFile "${cfg.dotfiles}/bashrc";
    })
  ]);
}
