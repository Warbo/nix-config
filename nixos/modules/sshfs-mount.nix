{
  config,
  lib,
  pkgs,
  ...
}:

with builtins // lib;
with rec {
  args = with types; {
    canary = mkOption {
      description = "A known path to check exists inside the mount";
      example = "backups/foo.tar.gz";
      type = str;
    };
    privateKey = mkOption {
      description = "Path of the SSH private key to use";
      example = "/home/bob/.ssh/id_rsa";
      type = path;
    };
    localPath = mkOption {
      description = "Mount point for this share";
      example = "/home/bob/mounts/alice";
      type = path;
    };
    localUser = mkOption {
      description = "User we should run as on this machine (e.g. for keys)";
      example = "bob";
      type = str;
    };
    name = mkOption {
      description = "Name for this mount, for use in scripts/logs/etc.";
      example = "work";
      type = str;
    };
    remoteHost = mkOption {
      description = "Host name/IP to connect to";
      example = "192.168.1.2";
      type = str;
    };
    remotePath = mkOption {
      description = "Path on remote host we should mount";
      example = "/home/alice/shared";
      type = path;
    };
    remotePort = mkOption {
      default = 22;
      description = "Port to use for SSH; null defaults to 22";
      example = "8888";
      type = port;
    };
    remoteUser = mkOption {
      description = "User we should log in as on the remote machine";
      example = "alice";
      type = str;
    };
  };

  cfg = config.services.sshfsMounts;

  # Generate the Bash boilerplate to get the $1th element of the named array.
  # Note that we automatically pluralise and quote.
  get = name: ''"''${${name}s[$1]}"'';

  RestartSec = 30;

  toVar = var: ''
    ${var}s=(${concatStringsSep " " (map (x: toString (getAttr var x)) cfg.mounts)})
  '';
};
assert get "foo" == ''"''${foos[$1]}"'';
{
  options.services.sshfsMounts = {
    mounts = mkOption {
      default = [ ];
      description = "SSHFS mounts to create and monitor";
      type =
        with types;
        listOf (submodule {
          options = args;
        });
    };
  };

  config = mkIf (cfg.mounts != [ ]) {
    systemd.services.sshfsMounts = {
      enable = true;
      wantedBy = [ "default.target" ];
      description = "Mount and monitor sshfs mounts";
      requires = [ "network.target" ];
      serviceConfig = {
        inherit RestartSec;
        Restart = "always";
        User = "chris";
        Type = "simple";
      };
      script = "${pkgs.wrap {
        name = "sshfsMount-runner";
        vars = {
          DISPLAY = ":0"; # For potential ssh passphrase dialogues
          secs = toString RestartSec;
          SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
        };
        paths = with pkgs; [
          bash
          coreutils
          fuse
          fuse3
          iputils
          openssh
          procps
          sshfsFuse
          (utillinux.bin or utillinux)
        ];
        script = ''
          #!${pkgs.bash}/bin/bash
          set -e

          # Turn service options into bash variables
          ${concatStringsSep "\n" (map toVar (attrNames args))}

          # Largest index for the above arrays
          n=${toString (length cfg.mounts - 1)}

          function stop {
            LP=${get "localPath"}
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
            RH=${get "remoteHost"}
            pingOnce "$RH" || return 1
            return 0
          }

          function isRunning {
            dir=${get "localPath"}
            canary=${get "canary"}

            # If we can't list what's in the directory then we don't count as
            # running, even if the processes exist, etc.
            ls "$dir" 1> /dev/null 2> /dev/null || return 1

            # If we don't see our canary, assume that we're not mounted
            [[ -e "$dir/$canary" ]] || return 1

            # Look for an sshfs command involving this directory
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
            name=${get "name"}
            if shouldRun "$1"
            then
              echo "Starting '$name'" 1>&2
              start "$1"
            else
              echo "Stopping '$name'" 1>&2
              stop "$1"
            fi

            # Bail out if we're not in a sensible state
            consistent "$1" || echo "Inconsistent state for '$name'" 1>&2
          }

          function start {
            stop "$1" || true

            privateKey=${get "privateKey"}
             localPath=${get "localPath"}
            remoteUser=${get "remoteUser"}
            remoteHost=${get "remoteHost"}
            remotePath=${get "remotePath"}
            remotePort=${get "remotePort"}

            sshfs -o ${
              concatStringsSep "," [
                # Since we're not interactive, we need to avoid some
                # common annoyances (e.g. when DHCP leases change)

                # Don't complain about unseen hosts
                "UserKnownHostsFile=/dev/null"

                # Don't complain about changed keys
                "StrictHostKeyChecking=no"

                # Give the keyfile explicitly, rather than looking in ~
                "IdentityFile=\"$privateKey\""

                # Reliability
                "reconnect"
                "ServerAliveInterval=15"

                # Make mounted filesystem more useful
                "follow_symlinks"
                "allow_other"

                # Speed
                "cache=yes"
                "kernel_cache"
                "compression=no"
                "cache_timeout=115200"
                "attr_timeout=115200"
                "no_readahead"
                "Cipher=chacha20-poly1305@openssh.com"
              ]
            } \
                  "$remoteUser@$remoteHost:$remotePath" "$localPath"
            sleep 1
          }

          function pingOnce {
            "${config.security.wrapperDir}/ping" -c 1 "$@"
          }

          # Make a long-running process, since 'start' exits immediately
          while true
          do
            # Check online state once, rather than per mount
            ONLINE=0
            pingOnce google.com 1>/dev/null 2>/dev/null && ONLINE=1

            ATHOME=0
            if [[ "$ONLINE" -eq 1 ]]
            then
              if [[ -e /tmp/location ]]
              then
                LOC=$(cat /tmp/location)
                [[ "x$LOC" = "xhome" ]] && ATHOME=1
              fi
            fi

            # Iff we've become inconsistent, trigger an action
            for i in $(seq 0 "$n")
            do
              consistent "$i" || startOrStop "$i"
            done
            sleep "$secs"
          done
        '';
      }}";
    };
  };
}
