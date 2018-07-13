{ config, lib, pkgs, ... }:

with builtins;
with lib;
with { cfg = config.services.nix-daemon-tunnel; };
{
  options.services.nix-daemon-tunnel = {
    enable = mkOption {
      type        = types.bool;
      default     = false;
      description = ''
        Let anyone communicate with nix-daemon as if they were a certain user.
      '';
    };

    socketDir = mkOption {
      type        = types.path;
      default     = "/var/lib/nix-daemon-tunnel";
      description = ''
        The directory to contain the 'socket' file.
      '';
    };

    nixDaemonSocket = mkOption {
      type    = types.path;
      default = "/nix/var/nix/daemon-socket/socket";
      description = ''
        The location of nix-daemon's socket.
      '';
    };

    user = mkOption {
      default     = "nixbuildtrampoline";
      type        = types.str;
      description = "User the new socket should connect as.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.nix-daemon-tunnel = {
      description = "Provides a socket tunnelled to nix-daemon as a user.";
      wantedBy    = [ "multi-user.target" ];
      path        = [ pkgs.bash pkgs.openssh ];
      preStart    = ''
        [[ -e "${cfg.socketDir}" ]] || mkdir -p "${cfg.socketDir}"
        chmod a+r "${cfg.socketDir}"
        chmod a+x "${cfg.socketDir}"
        rm -f "${cfg.socketDir}/socket"
      '';
      serviceConfig = {
        User                 = cfg.user;
        PermissionsStartOnly = true;  # Allow preStart to run as root
        ExecStart            = pkgs.writeScript "nix-daemon-tunnel" ''
          #!/usr/bin/env bash
          set -e

          if [[ "x$USER" = "xnixbuildtrampoline" ]]
          then
            [[ -e "$HOME/.ssh/id_rsa.pub" ]] || {
              echo "No SSH key found for '$USER', generating one" 1>&2
              ssh-keygen -q -N "" < /dev/zero
            }
          fi
          [[ -e "$HOME/.ssh/id_rsa.pub" ]] || {
            echo "Couldn't find '$HOME/.ssh/id_rsa.pub', aborting" 1>&2
            exit 1
          }
          if [[ "x$USER" = "xnixbuildtrampoline" ]]
          then
            [[ -e "$HOME/.ssh/authorized_keys" ]] || {
              echo "Adding '$USER' SSH key to '$HOME/.ssh/authorized_keys'" 1>&2
              cat "$HOME/.ssh/id_rsa.pub" >> "$HOME/.ssh/authorized_keys"
            }
          fi

          function cleanUp {
            rm -r "${cfg.socketDir}/socket"
          }
          trap cleanUp EXIT

          echo "Tunnelling '${cfg.socketDir}/socket' to '${cfg.nixDaemonSocket}'" 1>&2
          ssh -o "StrictHostKeyChecking no" -o UserKnownHostsFile=/dev/null \
              -o "ExitOnForwardFailure yes" -o "ConnectTimeout 10"          \
              -nNT -L "${cfg.socketDir}/socket":"${cfg.nixDaemonSocket}"    \
              "$USER"@localhost &
          sleep 1
          chmod a+r "${cfg.socketDir}/socket"
          chmod a+w "${cfg.socketDir}/socket"
          wait
        '';
      };
    };

    users.extraUsers = optional (cfg.user == "nixbuildtrampoline") {
      name            = cfg.user;
      description     = "User to tunnel nix-daemon connections through.";
      isNormalUser    = true;
      createHome      = true;
      home            = cfg.socketDir;
      group           = "users";
      useDefaultShell = true;
    };
  };
}
