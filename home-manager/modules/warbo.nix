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
  options.warbo = import ../../warbo-options.nix { inherit lib pkgs; };

  config = mkIf cfg.enable (mkMerge [
    {
      # Unconditional; override if desired
      home.stateVersion = cfg.home-manager.stateVersion;
      home.file.".config/git/ignore".text = ''
        # Per-directory Emacs config can by put into a .dir-locals.el file (a
        # bit like direnv's .envrc files). They shouldn't be globally ignored by
        # git, since some repos may include them, and that would cause problems.

        # However, Emacs will ALSO read files called .dir-locals-2.el, which are
        # intended for personal settings that shouldn't be distributed. That way
        # we can (a) ignore them globally to ensure they don't get committed, or
        # show up as unstaged changes, etc. whilst (b) not having to worry about
        # repos which include such files, since they're not for distribution!
        .dir-locals-2.el

        # Aider creates these
        .aider*
      '';
      home.file.".config/pinentry/preexec".source = ./pinentry-preexec.sh;
      home.packages = cfg.packages;
      nixpkgs.config.allowUnfree = true;
      programs = {
        bash = {
          enable = true;
          profileExtra = ''
            if [[ -n "$BASH_VERSION" ]] && [[ -e "$HOME/.bashrc" ]]
            then
              . "$HOME/.bashrc"
            fi
            true
          '';
        };
        git = {
          enable = true;
          extraConfig.diff.algorithm = "histogram";
        };
        home-manager.enable = true;
        home-manager.path = import ../nixos-import.nix;
        htop.enable = true;
        jq.enable = true;
        jujutsu.enable = true;
        password-store = {
          enable = true;
          package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
          settings.PASSWORD_STORE_DIR =
            builtins.toString config.home.homeDirectory + "/.password-store";
        };
        ssh = {
          enable = true;
          matchBlocks = {
            chromebook = {
              hostname = "chromebook.local";
              user = "jo";
            };
            phone = {
              hostname = "manjaro-arm.local";
              user = "manjaro";
            };
            pi = {
              hostname = "dietpi.local";
              user = "pi";
            };
            laptop = {
              hostname = "nixos-amd64.local";
              user = "chris";
            };
            s5 = {
              hostname = "s5.local";
              user = "nixos";
            };
          };
        };
        /*
          TODO: Add these?
          https://github.com/nix-community/home-manager/blob/master/modules/programs/mbsync.nix
          https://github.com/nix-community/home-manager/blob/master/modules/programs/msmtp.nix
          https://github.com/nix-community/home-manager/blob/master/modules/programs/mu.nix
        */
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
      programs.git = {
        userEmail = "chriswarbo@gmail.com";
        userName = "Chris Warburton";
      };
      programs.yt-dlp.enable = true;
      #rtorrent.enable = true;
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
        assert
          (typeOf cfg.dotfiles == "path" && pathExists cfg.dotfiles)
          || (cfg.dotfiles ? outPath);
        ''
          # Always make Nix binaries available. If they're not defined in /etc,
          # then splice pkgs.nix as a fallback.
          [[ -e /etc/profile.d/nix.sh ]] || . ${pkgs.nix}/etc/profile.d/nix.sh
          ${readFile "${cfg.dotfiles}/bashrc"}
        '';
    })
  ]);
}
