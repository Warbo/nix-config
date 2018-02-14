{ config, pkgs}:

with builtins;
with pkgs;
with rec {
  # Polls regularly and runs the 'start' script whenever 'shouldRun' is true
  pollingService =
    { name, description, extra ? {}, RestartSec, shouldRun, start }:
      monitoredService {
        inherit name description extra RestartSec shouldRun start;
        stop      = "${coreutils}/bin/true";
        isRunning = "${coreutils}/bin/false";
      };

  # Polls regularly, checking whether 'shouldRun' and 'isRunning' are consistent
  # and running 'start' or 'stop' if they're not
  monitoredService =
    { name, description, extra ? {}, isRunning, RestartSec, shouldRun, start,
      stop, User ? "chris" }:
      with rec {
        extraNoCfg = removeAttrs extra [ "serviceConfig" ];

        generalConfig = {
          inherit description;
        } // extraNoCfg;

        serviceConfig = {
          inherit RestartSec User;
          Restart   = "always";
          ExecStart = wrap {
            name   = name + "-start";
            vars   = { inherit isRunning shouldRun start stop; };
            paths  = [ bash fail ];
            script = ''
              #!/usr/bin/env bash
              set -e

              # If all is well, exit early

              if "$shouldRun" && "$isRunning"
              then
                exit 0
              fi

              if (! "$shouldRun") && (! "$isRunning")
              then
                exit 0
              fi

              # If we're here, we need to take action

              if "$shouldRun"
              then
                echo "Running start script for '$name'" 1>&2
                "$start"
              else
                echo "Running stop script for '$name'" 1>&2
                "$stop"
              fi

              # Check that all is well due to our action

              if "$shouldRun" && (! "$isRunning")
              then
                fail "Didn't manage to start '$name'"
              fi

              if (! "$shouldRun") && "$isRunning"
              then
                fail "Didn't manage to stop '$name'"
              fi

              exit 0
            '';
          };
          ExecStop = wrap {
            name   = name + "-stop";
            vars   = { inherit isRunning stop; };
            paths  = [ bash fail ];
            script = ''
              #!/usr/bin/env bash
              set -e

              "$isRunning" || exit 0

              "$stop"

              if "$isRunning"
              then
                fail "Couldn't stop '$name'"
              fi

              exit 0
            '';
          };
          ExecRestart = wrap {
            name   = name + "-restart";
            paths  = [ bash fail ];
            vars   = { inherit isRunning shouldRun start stop; };
            script = ''
              #!/usr/bin/env bash
              set -e
              if "$isRunning"
              then
                "$stop"
                if "$isRunning"
                then
                  fail "Failed to stop '$name'"
                fi
              fi

              if "$shouldRun"
              then
                "$start"
                "$isRunning" || fail "Failed to start '$name'"
              fi
              exit 0
            '';
          };
        } // (extra.serviceConfig or {});
      };
      mkService (generalConfig // { inherit serviceConfig; });

  findProcess = pat: wrap {
    name   = "find-process";
    paths  = [ bash psutils ];
    vars   = { inherit pat; };
    script = ''
      #!/usr/bin/env bash
      pgrep "$pat"
    '';
  };

  killProcess = pat: wrap {
    name   = "kill-process";
    paths  = [ bash psutils ];
    vars   = { inherit pat; };
    script = ''
      #!/usr/bin/env bash
      pkill "$pat"
    '';
  };

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
        after    = [ "local-fs.target" ];
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

  pingOnce = "${config.security.wrapperDir}/ping -c 1";

  online   = "${pingOnce} google.com 1>/dev/null 2>/dev/null";

  setLocation = wrap {
    name   = "setLocation";
    paths  = [ bash networkmanager ];
    script = ''
      #!/usr/bin/env bash
      set -e

      ${online} || {
        echo "unknown" > /tmp/location
        exit 0
      }

      WIFI=$(nmcli c | grep -v -- "--"  | grep -v "DEVICE" |
                                          cut -d ' ' -f1   )
      if echo "$WIFI" | grep "aa.net.uk" > /dev/null
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

  atHome = wrap {
    name   = "atHome";
    paths  = [ bash ];
    script = ''
      #!/usr/bin/env bash
      set -e

      LOC=$(cat /tmp/location)
      [[ "x$LOC" = "xhome" ]] || exit 1
    '';
  };

  atWork = wrap {
    name   = "atWork";
    paths  = [ bash ];
    script = ''
      #!/usr/bin/env bash
      set -e

      LOC=$(cat /tmp/location)
      [[ "x$LOC" = "xwork" ]] || exit 1
    '';
  };
};
{
  thermald-nocheck = mkService {
    description = "Thermal Daemon Service";
    wantedBy    = [ "multi-user.target" ];
    after       = [];
    script      = wrap {
      name   = "thermald-nocheck";
      paths  = [ bash thermald ];
      script = ''
        #!/usr/bin/env bash
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
          #!/usr/bin/env bash
          coolDown
        '';
      };
    };
  };

  emacs = mkService {
    description     = "Emacs daemon";
    path            = [ all emacs mu sudoWrapper ];
    environment     = {
      inherit SSH_AUTH_SOCK;
      COLUMNS = "80";
    };
    reloadIfChanged = true;  # As opposed to restarting
    serviceConfig   = {
      User       = "chris";
      Type       = "forking";
      Restart    = "always";
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
              #!/usr/bin/env bash
              exec dvtm -M -m ^b
            '';
          };
        };
        script = ''
          #!/usr/bin/env bash
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

  hometime = mkService {
    description = "Count down to the end of the work day";
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 300;
      ExecStart  = wrap {
        name   = "hometime";
        paths  = [ bash gksu libnotify iputils networkmanager pmutils ];
        vars   = {
          DISPLAY    = ":0";
          XAUTHORITY = "/home/chris/.Xauthority";
        };
        script = ''
          #!/usr/bin/env bash
          set -e

          HOUR=$(date "+%H")
          [[ "$HOUR" -gt 16 ]] || exit

          function stillAtWork {
            ${atWork} || exit
          }

          stillAtWork

          # Set DBus variables to make notifications appear on X display
          MID=$(cat /etc/machine-id)
            D=$(echo "$DISPLAY" | cut -d '.' -f1 | tr -d :)
          source ~/.dbus/session-bus/"$MID"-"$D"
          export DBUS_SESSION_BUS_ADDRESS

          function notify {
            notify-send -t 0 "Home Time" "$1"
          }

          notify "Past 5pm; half an hour until suspend"
          sleep 600
          stillAtWork
          notify "20 minutes until suspend"
          sleep 600
          stillAtWork
          notify "10 minutes until suspend"
          sleep 600
          stillAtWork
          notify "Suspending"
          sleep 60
          stillAtWork
          gksudo -S pm-suspend
        '';
      };
    };
  };

  checkLocation = mkService {
    description   = "Use WiFi name to check where we are";
    path          = [ warbo-utilities ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 10;
      ExecStart  = wrap {
        name   = "check-location";
        paths  = [ bash ];
        script = ''
          #!/usr/bin/env bash
          ${setLocation}
          if ${atHome} || ${atWork}
          then
            # Unlikely to change for a while
            sleep 300
          fi
        '';
      };
    };
  };

  joX2X = mkService {
    description   = "Connect to X display when home";
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 10;
      ExecStart  = wrap {
        name   = "jo-x2x";
        paths  = [ bash openssh warbo-utilities ];
        vars   = {
          DISPLAY = ":0";
          TERM    = "xterm";
        };
        script = ''
          #!/usr/bin/env bash
          ${atHome} && jo
        '';
      };
    };
  };

  workX2X = mkService {
    description   = "Connect to X display when at work";
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 10;
      ExecStart  = wrap {
        name   = "work-x2x";
        paths  = [ bash openssh warbo-utilities ];
        vars   = { DISPLAY = ":0"; };
        script = ''
          #!/usr/bin/env bash
          ${atWork} || exit
          ssh -Y user@localhost -p 22222 "x2x -east -to :0"
        '';
      };
    };
  };

  workScreen = mkService {
    description = "Turn on VGA screen";
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 10;
      ExecStart  = wrap {
        name   = "display-on";
        paths  = [ bash nettools psmisc warbo-utilities xorg.xrandr ];
        vars   = { DISPLAY = ":0"; };
        script = ''
          #!/usr/bin/env bash
          # "connected" means plugged in; "(" indicates it's not active
          xrandr | grep "VGA1 connected (" || exit

          # Enable external monitor
          on

          # Force any X2X sessions to restart, since we've messed up X
          pkill -f 'x2x -' || true
        '';
      };
    };
  };

  # FIXME: Add keys service, which checks for xcape

  screenOff = mkService {
    description = "Turn Off VGA screen";
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 10;
      ExecStart  = wrap {
        name   = "display-off";
        paths  = [ bash nettools psmisc warbo-utilities xorg.xrandr ];
        vars   = { DISPLAY = ":0"; };
        script = ''
          #!/usr/bin/env bash
          # "1080" means active; "disconnected" means not plugged in
          xrandr | grep "VGA1 disconnected 1080" || exit

          # Disable external monitor
          off

          # Force any X2X sessions to restart, since we've messed up X
          pkill -f 'x2x -' || true
        '';
      };
    };
  };

  inboxen = mkService {
    description   = "Fetch mail inboxes";
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 600;
      ExecStart  = wrap {
        name   = "inboxen-start";
        paths  = [ bash coreutils iputils isync ];
        script = ''
          #!/usr/bin/env bash
          set -e
          ${online} || exit
          timeout -s 9 3600 mbsync --verbose gmail dundee
          echo "Finished syncing" 1>&2
        '';
      };
    };
  };

  news = mkService {
    description   = "Fetch news";
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
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 3600;
      ExecStart  = wrap {
        name   = "mail-backup";
        paths  = [ bash coreutils iputils isync ];
        script = ''
          #!/usr/bin/env bash
          set -e
          ${online} || exit
          timeout -s 9 3600 mbsync --verbose gmail-backup
          echo "Finished syncing" 1>&2
        '';
      };
    };
  };

  keeptesting = mkService {
    description   = "Run tests";
    enable        = false;
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 300;
      ExecStart  = wrap {
        name  = "keep-testing";
        paths = [ bash basic nix.out warbo-utilities ];
        vars  = {
          LOCATE_PATH = /var/cache/locatedb;
          NIX_PATH    = getEnv "NIX_PATH";
          NIX_REMOTE  = getEnv "NIX_REMOTE";
        };
        script = ''
          #!/usr/bin/env bash
          set -e
          plugged_in || exit
          hot        && exit

          cd "$HOME/System/Tests" || exit 1

          # Choose one successful script at random
          S=$(find results/pass -type f | shuf | head -n1)

          # Choose one test at random
          #T=$(shuf | head -n1)

          # Choose the oldest test
          O=$(ls -1tr results/pass | head -n1)

          # Force chosen tests to be re-run
          for TST in "$S" "$O"
          do
            NAME=$(basename "$TST")
            touch results/pass/"$NAME"
            mv results/pass/"$NAME" results/check/
          done

          # Run chosen tests, along with any existing failures
          ./run
        '';
      };
    };
  };

  inherit (rec {
    opts = extra: concatStringsSep " " (extra ++ [
      "-o follow_symlinks"
      "-o allow_other"
      "-o IdentityFile=/home/chris/.ssh/id_rsa"
      "-o debug"
      "-o sshfs_debug"
      "-o reconnect"
      "-o ServerAliveInterval=15"
    ]);

    path = [ bash fuse fuse3 openssh procps sshfsFuse
             (utillinux.bin or utillinux) ];

    environment = {
      inherit SSH_AUTH_SOCK;
      DISPLAY = ":0"; # For potential ssh passphrase dialogues
    };

    mkCfg = addr: dir: extraOptions: {
      User       = "chris";
      Restart    = "always";
      RestartSec = 60;
      ExecStart  = wrap {
        name   = "sshfs-mount";
        paths  = path;
        script = ''
          #!/usr/bin/env bash
          sshfs -f ${opts extraOptions} ${addr} ${dir}
        '';
      };
      ExecStop = wrap {
        name   = "sshfuse-unmount";
        paths  = path;
        script = ''
          #!/usr/bin/env bash
          pkill -f -9 "sshfs.*${dir}"
          "${config.security.wrapperDir}/fusermount" -u -z "${dir}"
        '';
      };
    };

    pi-mount = mkService {
      inherit path environment;
      description   = "Raspberry pi";
      after         = [ "network.target" ];
      serviceConfig = mkCfg "pi@raspberrypi:/opt/shared"
                            "/home/chris/Public"
                            [];
    };

    desktop-mount = mkService {
      inherit path environment;
      description   = "Desktop files";
      after         = [ "network.target" ];
      serviceConfig = mkCfg "user@localhost:/"
                            "/home/chris/DesktopFiles"
                            ["-p 22222"];
    };
  })
  pi-mount desktop-mount;

  pi-monitor = mkService {
    description = "Unmount raspberrypi when unreachable";
    serviceConfig = {
      User = "root";
      Restart = "always";
      RestartSec = 20;
      ExecStart = wrap {
        name   = "pi-monitor";
        paths  = [ bash fuse fuse3 iputils psmisc utillinux ];
        script = ''
          #!/usr/bin/env bash
          set -e

          # No need to unmount anything if we're home
          ${pingOnce} raspberrypi && exit

          # We're not home; check if raspberrypi is mounted
          if mount | grep raspberrypi
          then
            # Anything trying to access the mount will hang, making KILL the
            # only reliable way to un-hang processes
            pkill -9 -f 'sshfs.*raspberrypi'

            # Try to unmount more cleanly too
            fusermount -u -z /home/chris/Public
          fi
        '';
      };
    };
  };

  desktop-bind = mkService {
    description   = "Bind desktop SSH";
    requires      = [ "network.target" ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 20;
      ExecStart  = wrap {
        name   = "desktop-bind";
        paths  = [ bash iputils openssh procps ];
        vars   = { inherit SSH_AUTH_SOCK; };
        script = ''
          #!/usr/bin/env bash

          echo "Checking for existing bind"
          if pgrep -f 'ssh.*22222:localhost:22222'
          then
            echo "Existing bind found, aborting"
            exit 1
          fi

          echo "No existing binds found, binding port"
          ssh -N -A -L 22222:localhost:22222 chriswarbo.net

          echo "Bind exited"
        '';
      };
    };
  };

  desktop-monitor = mkService {
    description   = "Kill desktop-bind if it's hung";
    serviceConfig = {
      User       = "root";
      Restart    = "always";
      RestartSec = 20;
      ExecStart  = wrap {
        name   = "desktop-monitor";
        paths  = [ bash coreutils iputils openssh procps su.su ];
        vars   = {
          inherit SSH_AUTH_SOCK;
          PAT = "ssh.*22222:localhost:22222";
        };
        script = ''
          #!/usr/bin/env bash
          set -e
          pgrep -f "$PAT" || exit

          # Bind is running, see if it's working
          timeout 10 su -c 'ssh -A user@localhost -p 22222 true' - chris && exit

          echo "Can't access bound port, kill the bind"
          pkill -f -9 "$PAT"
        '';
      };
    };
  };

  hydra-bind = mkService {
    description   = "Bind desktop SSH";
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 20;
      ExecStart  = wrap {
        name   = "hydra-bind";
        paths  = [ bash openssh iputils procps ];
        vars   = { inherit SSH_AUTH_SOCK; };
        script = ''
          #!/usr/bin/env bash
          set -e

          echo "Checking for existing binds"
          pgrep -f 'ssh.*3000:localhost:3000' && exit

          echo "Checking for identity"
          if ssh-add -L | grep "The agent has no identities"
          then
            echo "No identity found, adding"
            ssh-add /home/chris/.ssh/id_rsa
          fi

          echo "Binding port"
          ssh -N -A -L 3000:localhost:3000 user@localhost -p 22222
        '';
      };
    };
  };

  hydra-monitor = mkService {
    description   = "Force hydra-bind to restart when down";
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 20;
      ExecStart  = wrap {
        name   = "hydra-monitor";
        paths  = [ bash coreutils curl procps ];
        script = ''
          #!/usr/bin/env bash
          set -e
          echo "Checking for Hydra server"
          if timeout 10 curl http://localhost:3000
          then
            echo "OK, server is up"
            exit 0
          fi

          echo "Server is down, killing any hydra ssh bindings"
          pkill -f -9 'ssh.*3000:localhost:3000' || true
          exit 0
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
          #!/usr/bin/env bash
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
          #!/usr/bin/env bash
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
          #!/usr/bin/env bash
          killall -9 sshfs || true
        '';
      };
    };
  };

  # Turn off power saving on WiFi to work around
  # https://bugzilla.kernel.org/show_bug.cgi?id=56301 (or something similar)
  wifiPower = mkService {
    wantedBy      = [ "multi-user.target" ];
    after         = [];
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
          #!/usr/bin/env bash
          iw dev wlp2s0 set power_save off
        '';
      };
    };
  };
}
