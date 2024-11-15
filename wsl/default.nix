{
  lib,
  pkgs
}:
{
  # Programs to put in PATH, either system-wide (NixOS-only) or via Home Manager
  packages = [
    pkgs.google-chrome
    pkgs.rxvt-unicode # Used to auto-spawn emacsclient
    pkgs.uw-ttyp0 # Fonts
  ] ++ (builtins.attrValues rec {
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
    };
    pyselenium = pkgs.callPackage ./pyselenium.nix {};
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

  bashrcExtra =
    with { npiperelay = pkgs.callPackage ../nixos/nixos-wsl/npiperelay.nix { }; }; ''
      export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
      (
        export PATH="${pkgs.socat}/bin:${npiperelay}/bin:$PATH"
        . ${../nixos/nixos-wsl/1password.sh}
      )
    '';

  # Things which should work as-is, without any merging
  config = {
    fonts.fontconfig.enable = true;
  };
}
