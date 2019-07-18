{ config, lib, pkgs, ... }:

with builtins // lib;
with rec {
  args = with types; {
    key = mkOption {
      description = "Path of the SSH private key to use";
      example     = "/home/bob/.ssh/id_rsa";
      type        = str;
    };
    localPath = mkOption {
      description = "Mount point for this share";
      example     = "/home/bob/mounts/alice";
      type        = str;
    };
    localUser = mkOption {
      description = "User we should run as on this machine (e.g. for keys)";
      example     = "bob";
      type        = str;
    };
    name = mkOption {
      description = "Name for this mount, for use in scripts/logs/etc.";
      example     = "work";
      type        = str;
    };
    remoteHost = mkOption {
      description = "Host name/IP to connect to";
      example     = "192.168.1.2";
      type        = str;
    };
    remotePath = mkOption {
      description = "Path on remote host we should mount";
      example     = "/home/alice/shared";
      type        = str;
    };
    remotePort = mkOption {
      default     = null;
      description = "Port to use for SSH; null defaults to 22";
      example     = "8888";
      type        = nullOr port;
    };
    remoteUser = mkOption {
      description = "User we should log in as on the remote machine";
      example     = "alice";
      type        = str;
    };
  };

  cfg        = config.services.sshfsMounts;

  RestartSec = 30;

  toVar      = var: ''
    ${var}s=(${concatStringsSep " " (map (getAttr var) cfg.mounts)}
  '';
};
{
  options.services.sshfsMounts = {
    mounts = mkOption {
      default     = [];
      description = "SSHFS mounts to create and monitor";
      type        = with types; listOf (submodule args);
    };
  };

  config = mkIf (cfg.mounts != []) {
    systemd.services.sshfsMounts = {
      enable        = true;
      wantedBy      = [ "default.target" ];
      description   = "Mount and monitor sshfs mounts";
      requires      = [ "network.target" ];
      serviceConfig = {
        inherit RestartSec;
        Restart = "always";
        User    = "chris";
        Type    = "simple";
      };
      script = toString (wrap {
        name = "sshfsMount-runner";
        vars = {
          DISPLAY       = ":0";  # For potential ssh passphrase dialogues
          secs          = toString RestartSec;
          SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
        };
        paths = [
          bash coreutils fuse fuse3 iputils openssh procps sshfsFuse
          (utillinux.bin or utillinux)
        ];
        script = ''
          #!/usr/bin/env bash
          set -e

          # Turn service options into bash variables
          ${concatStringsSep "\n" (map toVar (attrNames args))}

          # Largest index for the above arrays
          n=${toString (length cfg.mounts - 1)}

          function stop {
            LP="''${localPaths[$1]}"
            pkill -f -9 "sshfs.*$LP"
            "${config.security.wrapperDir}/fusermount" -u -z "$LP"
          }

          function stopAll {
            for i in $(seq 0 "$n")
            do
              stop "$i"
            done
          }

          # Stopping on exit puts us in a known state
          trap stopAll EXIT

          ONLINE=0
          ATHOME=0
          function shouldRun {
            # We must be online
            [[ "$ONLINE" -eq 1 ]] || return 1

            # We must be home
            [[ "$ATHOME" -eq 1 ]] || return 1

            # Try to contact this host
            "${config.security.wrapperDir}/ping" -c 1 "''${remoteHosts[$1]}" ||
              return 1
            return 0
          }

          function isRunning {
            dir="''${localPaths[$1]}"

            # If we can't list what's in the directory then we don't count as
            # running, even if the processes exist, etc.
            ls "$dir" 1> /dev/null 2> /dev/null || return 1

            pgrep -f "sshfs.*$dir" || return 1
            return 0
          }

          function consistent {
            # Whether we're running iff we should be
            shouldRun "$1" && isRunning "$1" && return 0
            shouldRun "$1" || isRunning "$1" || return 0
            return 1
          }

          function startOrStop {
            # Take an action (start or stop) as appropriate
            name="''${names[$1]}"
            if shouldRun "$1"
            then
              echo "Starting '$name'" 1>&2
              "$start" "$i"
            else
              echo "Stopping '$name'" 1>&2
              "$stop"
            fi

            # Bail out if we're not in a sensible state
            consistent "$1" || echo "Inconsistent state for '$name'" 1>&2
          }

          function start {
            stop "$1" || true

                   key="''${key[$1]}"
             localPath="''${localPaths[$1]}"
            remoteUser="''${remoteUsers[$1]}"
            remoteHost="''${remoteHosts[$1]}"
            remotePath="''${remotePaths[$1]}"

            sshfs -o follow_symlinks              \
                  -o allow_other                  \
                  -o IdentityFile="$key"          \
                  -o UserKnownHostsFile=/dev/null \
                  -o StrictHostKeyChecking=no     \
                  -o debug                        \
                  -o sshfs_debug                  \
                  -o reconnect                    \
                  -o ServerAliveInterval=15       \
                  "$remoteUser@$remoteHost:$remotePath" "localPath"
            sleep 1
          }

          # Make a long-running process, since 'start' exits immediately
          while true
          do
            # Check online state once, rather than per mount
            ONLINE=0
            ${online} && ONLINE=1

            ATHOME=0
            [[ "$ONLINE" -eq 1 ]] && "$atHome" && ATHOME=1

            # Iff we've become inconsistent, trigger an action
            for i in $(seq 0 "$n")
            do
              consistent "$i" || startOrStop "$i"
            done
            sleep "$secs"
          done
        '';
      });
    };
  };
}
