{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ (../modules/warbo.nix) ];

  warbo.enable = true;
  warbo.professional = true;
  warbo.home-manager.stateVersion = "24.05";
  warbo.packages = with pkgs; [
    devCli
    devGui
    sysCli
    pkgs.haskellPackages.implicit-hie
    pkgs.haskellPackages.stylish-haskell
    pkgs.haskellPackages.fourmolu
  ];
  home.username = "chrisw";
  home.homeDirectory = "/home/chrisw";
  #home.stateVersion = "24.05"; # Please read the comment before changing.

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
  };

  # Let Home Manager install and manage itself.
  programs = {
    # Need mkBefore, since warbo.nix has an early-return when non-interactive
    # TODO: It would be better to make the latter mkAfter!
    bash.bashrcExtra = lib.mkBefore (
      with { npiperelay = pkgs.callPackage ../../nixos/nixos-wsl/npiperelay.nix { }; };
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

    git.includes =
      # Look for existing .gitconfig files on WSL. If exactly 1 WSL user has
      # a .gitconfig file, include it.
      with builtins;
      with rec {
        # Look for any Windows users
        wslDir = /mnt/c/Users;
        userDirs = if pathExists wslDir then readDir wslDir else { };
        # See if any has a .gitconfig file
        userCfg = name: wslDir + "/${name}/.gitconfig";
        users = filter (name: userDirs."${name}" == "directory" && pathExists (userCfg name)) (
          attrNames userDirs
        );
        sanitiseName = import "${nix-helpers-src}/helpers/sanitiseName" { inherit lib; };
        nix-helpers-src = sources.nix-helpers;
        sources = import ../../nix/sources.nix;
      };
      assert length users < 2 || abort "Ambiguous .gitconfig, found multiple: ${toJSON users}";
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
