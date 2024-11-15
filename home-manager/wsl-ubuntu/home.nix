{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ (../modules/warbo.nix) (../modules/warbo-wsl.nix) ];

  warbo-wsl.enable = true;
  warbo.professional = true;
  warbo.home-manager.stateVersion = "24.05";
  warbo.packages = [
    (pkgs.hiPrio pkgs.moreutils) # prefer timestamping 'ts' on WSL
    pkgs.devCli
    pkgs.devGui
    pkgs.sysCliNoFuse
    pkgs.google-chrome
    pkgs.haskellPackages.fourmolu
    pkgs.haskellPackages.implicit-hie
    pkgs.haskellPackages.stylish-haskell
    pkgs.nix
    pkgs.rxvt-unicode # Used to auto-spawn emacsclient
    pkgs.uw-ttyp0 # Fonts
  ];
  home.username = "chrisw";
  home.homeDirectory = "/home/chrisw";

  home.file = {
    ".screenrc" = {
      text = ''
        msgwait 0
        startup_message off
        screen -t emacs-daemon 1 emacs --fg-daemon
        screen -t journald-user 2 journalctl --user --follow
        screen -t journald-sys 3 sudo journalctl --follow
        screen -t htop 0 htop
      '';
    };
  };

  fonts.fontconfig.enable = true;

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/chrisw/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
    FONT_EXISTS_CMD = builtins.toString ./font_exists.sh;
  };

  # Let Home Manager install and manage itself.
  programs = {
    # Need mkBefore, since warbo.nix has an early-return when non-interactive
    # TODO: It would be better to make the latter mkAfter!
    bash.bashrcExtra = lib.mkBefore (
      with {
        npiperelay = pkgs.callPackage ../../nixos/nixos-wsl/npiperelay.nix { };
      };
      ''
        . ${pkgs.nix}/etc/profile.d/nix.sh

        export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
        (
          export PATH="${pkgs.socat}/bin:${npiperelay}/bin:$PATH"
          . ${../../nixos/nixos-wsl/1password.sh}
        )

        for D in '.local/bin' 'bin'
        do
          echo "$PATH" | grep -q "$HOME/$D" || export PATH="$HOME/$D:$PATH"
        done

        export NVM_DIR="$HOME/.nvm"
        for F in "$HOME/.ghcup/env" \
                 "$NVM_DIR/nvm.sh" \
                 "$NVM_DIR/bash_completion" \
                 "$HOME/SETUP.SH" \
                 /usr/share/doc/nix-bin/examples/nix-profile-daemon.sh \
                 ~/.nix-profile/etc/profile.d/*
        do
          [ -e "$F" ] && . "$F"
        done
      ''
    );

    git.extraConfig.safe.directory = "*";
    git.includes =
      # Look for existing .gitconfig files on WSL. If exactly 1 WSL user has
      # a .gitconfig file, include it.
      with builtins;
      with rec {
        inherit
          (
            (rec { inherit (import ../../overrides/repos.nix overrides { }) overrides; })
            .overrides.nix-helpers
          )
          sanitiseName
          ;
        # Look for any Windows users
        wslDir = /mnt/c/Users;
        userDirs = if pathExists wslDir then readDir wslDir else { };
        # See if any has a .gitconfig file
        userCfg = name: wslDir + "/${name}/.gitconfig";
        users = filter (
          name: userDirs."${name}" == "directory" && pathExists (userCfg name)
        ) (attrNames userDirs);
      };
      assert
        length users < 2
        || abort "Ambiguous .gitconfig, found multiple: ${toJSON users}";
      lib.lists.optional (length users == 1) {
        # Nix store paths can't begin with ".", so use contents = readFile
        path = path {
          path = userCfg (head users);
          name = sanitiseName "gitconfig-${head users}";
        };
      };

    # TODO: Put me in warbo.nix HM module (when not is-nixos?)
    home-manager = {
      path = import ../nixos-import.nix;
    };
  };
}
