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
  cfg = config.warbo-wsl;
};
{
  imports = [ (./warbo.nix) ];

  options.warbo-wsl = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Turn on customisations for running in Windows Subsystem for Linux.
      '';
    };

  };

  config = mkIf cfg.enable (mkMerge [
    {
      warbo.enable = true;
      warbo.packages = (builtins.attrValues rec {
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
          text = builtins.readFile ../wsl-ubuntu/selenium.sh;
        };
        # Fix up LAN dodginess caused by WSL and VPN
        lan = pkgs.writeShellApplication {
          name = "lan";
          text = builtins.readFile ../wsl-ubuntu/lan.sh;
          runtimeInputs = [
            pkgs.parallel
            pkgs.nmap
          ];
        };
        # Simple command to get WSL up and running
        go = pkgs.writeShellApplication {
          name = "go";
          text = builtins.readFile ../wsl-ubuntu/go.sh;
          runtimeEnv.LAN = lan;
        };
        pyselenium = pkgs.callPackage ../wsl-ubuntu/pyselenium.nix {};
      });
    }
  ]);
}
