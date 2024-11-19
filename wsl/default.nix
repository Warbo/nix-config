{ lib, pkgs }:
{
  # Programs to put in PATH, either system-wide (NixOS-only) or via Home Manager
  packages =
    [
      pkgs.google-chrome
      pkgs.rxvt-unicode # Used to auto-spawn emacsclient
      pkgs.uw-ttyp0 # Fonts
    ]
    ++ (builtins.attrValues rec {
      podman-wrapper = pkgs.writeShellApplication {
        # Podman has issues running "rootless", so we just wrap it in
        # sudo. That needs a little massaging, so (a) it uses our usual $HOME
        # and (b) it has the required commands on $PATH.
        name = "podman";
        runtimeInputs = [
          pkgs.crun
          pkgs.podman
          pkgs.shadow # for newuidmap
        ];
        text = ''
          # We print this message to remind ourselves that we're using this
          # hacky shell script, when we inevitably encounter un-google-able
          # problems!
          echo "Running ChrisW's podman sudo wrapper..." 1>&2
          sudo "HOME=$HOME" "PATH=$PATH" "$(command -v podman)" "$@"
        '';
      };
      selenium-runner = pkgs.writeShellApplication {
        name = "selenium";
        runtimeEnv = {
          # Set up some env vars that we don't want Nix to manage. The UNUSED
          # ones avoid problems with scripts that get sourced.
          SETUP = builtins.toString ~/SETUP.SH;
          VM_IP = "VM_IP IS UNUSED";
          STATIC_ROOT = "STATIC_ROOT IS UNUSED";
        };
        runtimeInputs = [
          pkgs.gnugrep
          pkgs.nix
          podman-wrapper
        ];
        text = builtins.readFile ./selenium.sh;
      };
      # Fix up LAN dodginess caused by WSL and VPN
      lan = pkgs.writeShellApplication {
        name = "lan";
        text = builtins.readFile ./lan.sh;
        runtimeInputs = [
          pkgs.parallel
          pkgs.nmap
        ];
      };
      # Simple command to get WSL up and running
      go = pkgs.writeShellApplication {
        name = "go";
        text = builtins.readFile ./go.sh;
        runtimeEnv.LAN = lan;
        runtimeInputs = [ pkgs.xorg.xset pkgs.xorg.xfontsel pkgs.xorg.mkfontdir ];
      };
      pyselenium = pkgs.callPackage ./pyselenium.nix { };
    });

  # Settings specific to Home Manager, whether on NixOS or standalone
  home = {
    sessionVariables = {
      FONT_EXISTS_CMD = builtins.toString ./font_exists.sh;
    };
    file = {
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
  };

  programs = {
    bash = {
      bashrcExtra =
        with { npiperelay = pkgs.callPackage ./npiperelay.nix { }; };
        # Need mkBefore, since warbo.nix has an early-return when non-interactive
        # TODO: It would be better to make the latter mkAfter!
        lib.mkBefore ''
          # Put Nix in PATH, if it's not already
          . ${pkgs.nix}/etc/profile.d/nix.sh

          # Set up 1password socket, if not already running
          export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
          (
            export PATH="${pkgs.socat}/bin:${npiperelay}/bin:$PATH"
            . ${./1password.sh}
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
        '';
    };

    git = {
      extraConfig.safe.directory = "*";
      includes =
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
        };
        assert length users < 2 || abort "Ambiguous .gitconfig, found multiple: ${toJSON users}";
        lib.lists.optional (length users == 1) {
          # Nix store paths can't begin with ".", so use contents = readFile
          path = path {
            path = userCfg (head users);
            name = "gitconfig-wsl";
          };
        };
    };
  };

  # Things which should work as-is, without any merging
  config = {
    fonts.fontconfig.enable = true;
  };
}
