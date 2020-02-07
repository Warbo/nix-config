{ config, pkgs }:

with builtins;
with pkgs;
with rec {
  # Polls regularly and runs the 'start' script whenever 'shouldRun' is true
  pollingService =
    {
      name,         # Used for naming scripts, etc.
      description,  # Shows up in systemd output
      extra ? {},   # Any extra systemd options we don't have by default
      RestartSec,   # Number of seconds to sleep between polls
      shouldRun,    # Script: exit status is whether or not to run 'start'
      start         # Script: do the required task then exit (not long-lived)
    }:
      monitoredService {
        inherit name description extra RestartSec shouldRun start;
        stop      = "${coreutils}/bin/true";
        isRunning = "${coreutils}/bin/false";
        allGood   = "${coreutils}/bin/true";  # We're stateless, so always good
      };

  # Polls regularly, checking whether 'shouldRun' and 'isRunning' are consistent
  # and running 'start' or 'stop' if they're not
  monitoredService =
    {
      name,           # Used to name scripts, etc.
      description,    # Shows up in systemd output
      extra ? {},     # Extra options to pass through to systemd
      isRunning,      # Script: whether the functionality is currently running
      RestartSec,     # How long to wait between checks
      shouldRun,      # Script: whether to be started or stopped, e.g. if online
      start,          # Script to start the functionality. Not long-lived.
      stop,           # Idempotent script to stop (e.g. kill) the functionality
      allGood ? "",   # Script: whether we're started/stopped correctly
      User ? "chris"  # User to run scripts as
    }:
      with rec {
        extraNoCfg = removeAttrs extra [ "serviceConfig" ];

        generalConfig = {
          inherit description;
          script  = wrap {
            name   = name + "-script";
            vars   = {
              inherit allGood isRunning name shouldRun start stop;
              secs = toString RestartSec;
            };
            paths  = [ bash fail ];
            script = ''
              #!${bash}/bin/bash
              set -e

              # Stopping on exit puts us in a known state
              trap "$stop" EXIT

              function allIsWell {
                # If allGood script is provided, use that to check that we're in
                # a sensible state
                if [[ -n "$allGood" ]]
                then
                  "$allGood"
                  return "$?"
                fi

                # If not, check that we're running iff we should be
                consistent || return 1
                return 0
              }

              function consistent {
                # Whether we're running iff we should be
                "$shouldRun" && "$isRunning" && return 0
                "$shouldRun" || "$isRunning" || return 0
                return 1
              }

              function startOrStop {
                # Take an action (start or stop) as appropriate
                if "$shouldRun"
                then
                  echo "Running start script for '$name'" 1>&2
                  "$start"
                else
                  echo "Running stop script for '$name'" 1>&2
                  "$stop"
                fi

                # Bail out if we're not in a sensible state
                allIsWell || echo "Inconsistent state for '$name'" 1>&2
              }

              # Make a long-running process, since 'start' exits immediately
              while true
              do
                # Iff we've become inconsistent, trigger an action
                consistent || startOrStop
                sleep "$secs"
              done
            '';
          };
        } // extraNoCfg;

        serviceConfig = {
          inherit RestartSec User;
          Restart = "always";

        } // (extra.serviceConfig or {});
      };
      mkService (generalConfig // { inherit serviceConfig; });

  SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";

  mkService = opts:
    with rec {
      service       = srvDefaults // opts;
      serviceConfig = if opts ? serviceConfig
                         then { serviceConfig = cfgDefaults //
                                                opts.serviceConfig; }
                         else {};
      cfgDefaults   = { Type = "simple"; };
      srvDefaults   = {
        enable   = true;
        wantedBy = [ "default.target"  ];
      };

      combined  = service // serviceConfig;

      # Some attributes must be strings of commands, rather than externally
      # defined scripts. We replace such scripts with strings that call them.
      stringify = x: if x ? script && lib.isDerivation x.script
                        then stringify (x // { script = toString x.script; })
                        else x;
    };
    stringify combined;

  sudoWrapper = runCommand "sudo-wrapper" {} ''
    mkdir -p "$out/bin"
    ln -s "${config.security.wrapperDir}/sudo" "$out/bin/sudo"
  '';

  pingOnce  = "${config.security.wrapperDir}/ping -c 1";

  online    = "${pingOnce} google.com 1>/dev/null 2>/dev/null";
};
{
  thermald-nocheck = mkService {
    description = "Thermal Daemon Service";
    wantedBy    = [ "multi-user.target" ];
    script      = wrap {
      name   = "thermald-nocheck";
      paths  = [ bash thermald ];
      script = ''
        #!${bash}/bin/bash
        exec thermald --no-daemon --dbus-enable --ignore-cpuid-check
      '';
    };
  };

  coolDown = mkService {
    description   = "Suspend common resource hogs when temperature's too hot";
    path          = [ procps warbo-utilities ];
    serviceConfig = {
      User       = "root";
      Restart    = "always";
      RestartSec = 30;
      ExecStart  = wrap {
        name  = "cool-now";
        paths = [ bash warbo-utilities ];
        script = ''
          #!${bash}/bin/bash
          coolDown 2> /dev/null
        '';
      };
    };
  };

  emacs = mkService {
    description     = "Emacs daemon";
    path            = [ pkgs.allPkgs sudoWrapper ];
    environment     = {
      inherit SSH_AUTH_SOCK;
      COLUMNS = "80";
    };
    reloadIfChanged = true;  # As opposed to restarting
    serviceConfig   = {
      User       = "chris";
      Type       = "forking";
      Restart    = "always";
      Timeout    = 300;
      ExecStart  = writeScript "emacs-start" ''
        #!${bash}/bin/bash
        cd "$HOME"
        exec emacs --daemon
      '';
      ExecStop = writeScript "emacs-stop" ''
        #!${bash}/bin/bash
        exec emacsclient --eval "(kill-emacs)"
      '';
      ExecReload = writeScript "emacs-reload" ''
        #!${bash}/bin/bash
        emacsclient --eval "(load-file \"~/.emacs.d/init.el\")"
      '';
    };
  };

  shell = mkService {
    description     = "Long-running terminal multiplexer";
    path            = [ dvtm dtach ];
    environment     = {
      DISPLAY = ":0";
      TERM    = "xterm"; # Useful when remote servers don't have dvtm
    };
    reloadIfChanged = true;  # As opposed to restarting
    serviceConfig   = {
      User      = "chris";
      Restart   = "always";
      ExecStart = wrap {
        name   = "shell-start";
        paths  = [ bash dtach ];
        vars   = {
          session = wrap {
            name   = "session";
            paths  = [ bash dvtm ];
            script = ''
              #!${bash}/bin/bash
              exec dvtm -M -m ^b
            '';
          };
        };
        script = ''
          #!${bash}/bin/bash
          cd "$HOME"
          exec dtach -A "$HOME/.sesh" -r winch "$session"
        '';
      };

      # Don't stop, since it may kill programs we want to keep using
      ExecStop   = "${coreutils}/bin/true";
      ExecReload = "${coreutils}/bin/true";

      # Since we run at startup, X might not be up; pretend we're on a virtual
      # terminal (e.g. ctrl-alt-f6) for the purpose of DVTM's capability queries
      StandardInput  = "tty";
      StandardOutput = "tty";
      TTYPath        = "/dev/tty6";
    };
  };

  checkLocation = pollingService {
    name        = "check-location";
    description = "Use WiFi name to check where we are";
    extra       = { requires = [ "network.target" ]; };
    RestartSec  = 10;
    shouldRun   = "${coreutils}/bin/true";
    start       = wrap {
      name   = "setLocation";
      paths  = [ bash networkmanager ];
      script = ''
        #!${bash}/bin/bash
        set -e

        ${online} || {
          echo "unknown" > /tmp/location
          exit 0
        }

        WIFI=$(nmcli c | grep -v -- "--"  | grep -v "DEVICE" |
                         cut -d ' ' -f1   )
        if echo "$WIFI" | grep "VM4163004" > /dev/null
        then
          echo "home" > /tmp/location
          exit 0
        fi
        if echo "$WIFI" | grep "UoD_WiFi" > /dev/null
        then
          echo "work" > /tmp/location
          exit 0
        fi
        if echo "$WIFI" | grep "eduroam" > /dev/null
        then
          echo "work" > /tmp/location
          exit 0
        fi
        echo "unknown" > /tmp/location
      '';
    };
  };

  inboxen = mkService {
    description   = "Fetch mail inboxes";
    requires      = [ "network.target" ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 600;
      ExecStart  = wrap {
        name   = "inboxen-start";
        paths  = [ bash coreutils iputils isync mu procps psutils gnused ];
        script = ''
          #!${bash}/bin/bash
          set -e
          ${online} || exit
          CODE=0

          echo "Fetching mail" 1>&2
          if timeout -s 9 3600 mbsync --verbose gmail dundee
          then
            echo "Finished syncing" 1>&2
          else
            echo "Error syncing" 1>&2
            CODE=1
          fi

          # Try waiting for existing mu processes to die
          for RETRY in $(seq 1 20)
          do
            # Find running mu processes. Try to exclude mupdf, etc.
            if P=$(ps auxww | grep '[ /]mu\( \|$\)')
            then
              echo "Stopping running mu instances" 1>&2
              echo "$P" | sed -e 's/  */ /g' | cut -d ' ' -f2 | while read -r I
              do
                kill -INT "$I"
              done
              sleep 1
            else
              # Stop early if nothing's running
              break
            fi
          done

          echo "Indexing maildirs for Mu" 1>&2
          if mu index --maildir=~/Mail --lazy-check
          then
            echo "Finished indexing" 1>&2
          else
            echo "Error indexing" 1>&2
            CODE=2
          fi
          exit "$CODE"
        '';
      };
    };
  };

  news = mkService {
    description   = "Fetch news";
    requires      = [ "network.target" ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 60 * 60 * 4;
      ExecStart  = wrap {
        name  = "get-news-start";
        paths = [ findutils.out warbo-utilities ];
        vars  = { LANG = "en_GB.UTF-8"; };
        file  = "${warbo-utilities}/bin/get_news";
      };
    };
  };

  mailbackup = mkService {
    description   = "Fetch all mail";
    requires      = [ "network.target" ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 3600;
      ExecStart  = wrap {
        name   = "mail-backup";
        paths  = [ bash coreutils iputils isync ];
        script = ''
          #!${bash}/bin/bash
          set -e
          ${online} || exit
          timeout -s 9 3600 mbsync --verbose gmail-backup
          echo "Finished syncing" 1>&2
        '';
      };
    };
  };

  ssh-agent = mkService {
    description   = "Run ssh-agent";
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 20;
      ExecStart  = wrap {
        name   = "ssh-agent-start";
        paths  = [ bash openssh ];
        script = ''
          #!${bash}/bin/bash
          set -e
          [[ -e /run/user/1000/ssh-agent ]] && exit

          exec ssh-agent -D -a /run/user/1000/ssh-agent
        '';
      };
      ExecStop   = wrap {
        name   = "ssh-agent-stop";
        paths  = [ bash openssh ];
        vars   = { inherit SSH_AUTH_SOCK; };
        script = ''
          #!${bash}/bin/bash
          ssh-agent -k
        '';
      };
    };
  };

  kill-network-mounts = mkService {
    description   = "Force kill network mounts after suspend/resume";

    # suspend.target causes this to be invoked, but only after (i.e. on resume)
    after         = [ "suspend.target" ];
    wantedBy      = [ "suspend.target" ];
    serviceConfig = {
      User      = "root";
      Type      = "oneshot";
      ExecStart = wrap {
        name   = "kill-network-filesystems";
        paths  = [ bash psmisc];
        script = ''
          #!${bash}/bin/bash
          killall -9 sshfs || true
        '';
      };
    };
  };

  # Turn off power saving on WiFi to work around
  # https://bugzilla.kernel.org/show_bug.cgi?id=56301 (or something similar)
  wifiPower = mkService {
    wantedBy      = [ "multi-user.target" ];
    before        = [ "network.target" ];
    serviceConfig = {
      Type       = "simple";
      User       = "root";
      Restart    = "always";
      RestartSec = 60;
      ExecStart  = wrap {
        name   = "wifipower";
        paths  = [ bash iw ];
        script = ''
          #!${bash}/bin/bash
          iw dev wlp2s0 set power_save off
        '';
      };
    };
  };
}
