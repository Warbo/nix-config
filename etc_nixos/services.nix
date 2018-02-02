with builtins;

{ config, pkgs}: with pkgs;

with rec {
  mkService = opts: {
        enable   = true;
        wantedBy = [ "default.target"  ];
        after    = [ "local-fs.target" ];
      } // opts // {
        serviceConfig = {
            Type = "simple";
          } // opts.serviceConfig;
        };

  sudoWrapper = runCommand "sudo-wrapper" {} ''
    mkdir -p "$out/bin"
    ln -s "${config.security.wrapperDir}/sudo" "$out/bin/sudo"
  '';

  pingOnce = "/var/setuid-wrappers/ping -c 1";

  online   = "${pingOnce} google.com 1>/dev/null 2>/dev/null";

  wifiName = '' ${networkmanager}/bin/nmcli c | grep -v -- "--" | grep -v "DEVICE" | cut -d ' ' -f1'';

  setLocation = writeScript "setLocation" ''
    #!${bash}/bin/bash
    set -e

    ${online} || {
      echo "unknown" > /tmp/location
      exit 0
    }

    WIFI=$(${wifiName})
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

  atHome = writeScript "atHome" ''
    #!${bash}/bin/bash
    set -e

    LOC=$(cat /tmp/location)
    [[ "x$LOC" = "xhome" ]] || exit 1
  '';

  atWork = writeScript "atWork" ''
    #!${bash}/bin/bash
    set -e

    LOC=$(cat /tmp/location)
    [[ "x$LOC" = "xwork" ]] || exit 1
  '';
};
{
  thermald-nocheck = {
    description = "Thermal Daemon Service";
    wantedBy    = [ "multi-user.target" ];
    script      = ''
      exec ${pkgs.thermald}/sbin/thermald --no-daemon   \
                                          --dbus-enable \
                                          --ignore-cpuid-check
    '';
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
      COLUMNS       = "80";
      SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
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
      ExecStart = writeScript "shell-start" ''
        #!${bash}/bin/bash
        cd
        exec dtach -A ~/.sesh -r winch "${writeScript "session" ''
          #!${bash}/bin/bash
          exec dvtm -M -m ^b
        ''}"
      '';

      # Don't stop, since it may kill programs we want to keep using
      ExecStop   = ''"${coreutils}/bin/true"'';
      ExecReload = ''"${coreutils}/bin/true"'';

      # Since we run at startup, X might not be up; pretend we're on a virtual
      # terminal (e.g. ctrl-alt-f6) for the purpose of DVTM's capability queries
      StandardInput  = "tty";
      StandardOutput = "tty";
      TTYPath        = "/dev/tty6";
    };
  };

  hometime = mkService {
    description = "Count down to the end of the work day";
    path        = [ gksu libnotify iputils networkmanager pmutils ];
    environment = {
      DISPLAY    = ":0";
      XAUTHORITY = "/home/chris/.Xauthority";
    };
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 300;
      ExecStart  = writeScript "hometime" ''
        #!${bash}/bin/bash
        set -e

        HOUR=$(date "+%H")
        [[ "$HOUR" -gt 16 ]] || exit

        ${atWork} || exit

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
        notify "20 minutes until suspend"
        sleep 600
        notify "10 minutes until suspend"
        sleep 600
        notify "Suspending"
        sleep 60
        gksudo -S pm-suspend
      '';
    };
  };

  checkLocation = mkService {
    description   = "Use WiFi name to check where we are";
    path          = [ warbo-utilities ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 10;
      ExecStart  = writeScript "check-location" ''
        #!${bash}/bin/bash
        ${setLocation}
        if ${atHome} || ${atWork}
        then
          # Unlikely to change for a while
          sleep 300
        fi
      '';
    };
  };

  joX2X = mkService {
    description   = "Connect to X display when home";
    path          = [ openssh warbo-utilities ];
    environment   = { DISPLAY = ":0"; };
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 10;
      ExecStart  = writeScript "jo-x2x" ''
        #!${bash}/bin/bash
        export TERM=xterm
        ${atHome} && ${warbo-utilities}/bin/jo
      '';
    };
  };

  workX2X = mkService {
    description   = "Connect to X display when at work";
    path          = [ openssh warbo-utilities ];
    environment   = {
      DISPLAY = ":0";
    };
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 10;
      ExecStart  = writeScript "work-x2x" ''
        #!${bash}/bin/bash
        ${atWork} || exit
        ssh -Y user@localhost -p 22222 "x2x -east -to :0"
      '';
    };
  };

  workScreen = mkService {
    description = "Turn on VGA screen";
    path = [ nettools psmisc warbo-utilities xorg.xrandr ];
    environment = {
      DISPLAY = ":0";
    };
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 10;
      ExecStart  = writeScript "display-on" ''
        #!${bash}/bin/bash
        # "connected" means plugged in; "(" indicates it's not active
        if xrandr | grep "VGA1 connected ("
        then
          # Enable external monitor
          on

          # Force any X2X sessions to restart, since we've messed up X
          pkill -f 'x2x -east' || true

          # Our keybindings mess up, so restart them
          sleep 5
          keys
        fi
      '';
    };
  };

  screenOff = mkService {
    description = "Turn Off VGA screen";
    path = [ bash nettools psmisc warbo-utilities xorg.xrandr ];
    environment = {
      DISPLAY = ":0";
    };
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 10;
      ExecStart  = writeScript "display-off" ''
        #!${bash}/bin/bash
        # "1080" means active; "disconnected" means not plugged in
        if xrandr | grep "VGA1 disconnected 1080"
        then
          # Disable external monitor
          off

          # Force any X2X sessions to restart, since we've messed up X
          pkill -f 'x2x -' || true

          # Our keybindings mess up, so restart them
          sleep 5
          keys
        fi
      '';
    };
  };

  inboxen = mkService {
    description   = "Fetch mail inboxes";
    path          = [ bash coreutils iputils isync ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 600;
      ExecStart  = writeScript "inboxen-start" ''
        #!${bash}/bin/bash
        /var/setuid-wrappers/ping -c 1 google.com || exit
        timeout -s 9 3600 mbsync --verbose gmail dundee
      '';
    };
  };

  news = mkService {
    description   = "Fetch news";
    path          = [ findutils.out warbo-utilities ];
    environment   = { LANG = "en_GB.UTF-8"; };
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 60 * 60 * 4;
      ExecStart  = writeScript "get-news-start" ''
        #!${bash}/bin/bash
        exec get_news
      '';
    };
  };

  mailbackup = mkService {
    description   = "Fetch all mail";
    path          = [ bash coreutils iputils isync ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 3600;
      ExecStart  = writeScript "mail-backup" ''
        #!${bash}/bin/bash
        /var/setuid-wrappers/ping -c 1 google.com || exit
        timeout -s 9 3600 mbsync gmail-backup
      '';
    };
  };

  inherit (rec {
    xmobar = description: RestartSec: mkService {
      inherit description;
      serviceConfig = {
        inherit RestartSec;
        User       = "chris";
        Restart    = "always";
        ExecStart  =
          let disk = writeScript "disk" ''
                #!${bash}/bin/bash
                df -h | grep /dev/disk/by-label/nixos |
                        sed -e 's/ [ ]*/ /g'          |
                        cut -d ' ' -f 5
              '';
           in writeScript "xmobar-stats" ''
                #!${bash}/bin/bash
                cd /home/chris/.cache/xmobar
                agenda head         > agenda
              '';
      };
    };

    agenda = xmobar "Agenda " 900;
  })
  agenda;

  keeptesting = mkService {
    description   = "Run tests";
    enable        = false;
    path          = with pkgs; [ basic nix.out ];
    environment   = { LOCATE_PATH = /var/cache/locatedb; } //
                    (listToAttrs
                      (map (name: { inherit name;
                        value = builtins.getEnv name; })
                        [ "NIX_PATH" "NIX_REMOTE" ]));
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 300;
      ExecStart  = writeScript "keep-testing" ''
        #!${bash}/bin/bash
        set -e
        if ! plugged_in
        then
          exit 0
        fi

        if hot
        then
          exit 0
        fi

        cd ~/System/Tests || exit 1

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

    path = [ sshfsFuse (utillinux.bin or utillinux) openssh procps ];

    environment = {
      DISPLAY       = ":0"; # For potential ssh passphrase dialogues
      SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
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
          /var/setuid-wrappers/fusermount -u -z "${dir}"
        '';
      };
    };

    pi-mount = mkService {
      inherit path environment;
      description   = "Raspberry pi";
      after         = [ "network.target" ];
      wantedBy      = [ "default.target" ];
      serviceConfig = mkCfg "pi@raspberrypi:/opt/shared"
                            "/home/chris/Public"
                            [];
    };

    desktop-mount = mkService {
      inherit path environment;
      description   = "Desktop files";
      after         = [ "network.target" ];
      wantedBy      = [ "default.target" ];
      serviceConfig = mkCfg "user@localhost:/"
                            "/home/chris/DesktopFiles"
                            ["-p 22222"];
    };

    /*
    desktop-laptop-mount = mkService {
      inherit path environment;
      description = "Laptop files on desktop";
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        User       = "chris";
        Restart    = "always";
        RestartSec = 60;
        ExecStart  = writeScript "sshfs-mount" ''
          #!${bash}/bin/bash
          ssh -f ${opts} sshfs -f ${opts extraOptions} ${addr} ${dir}
        '';
        ExecStop = writeScript "sshfuse-unmount" ''
          #!${bash}/bin/bash
          pkill -f -9 "sshfs.*${dir}"
          /var/setuid-wrappers/fusermount -u -z "${dir}"
        '';
      };
    };
    */
  })
  pi-mount desktop-mount;

  pi-monitor = mkService {
    description = "Unmount raspberrypi when unreachable";
    path = [ iputils utillinux ];
    serviceConfig = {
      User = "root";
      Restart = "always";
      RestartSec = 20;
      ExecStart = writeScript "pi-monitor" ''
        #!${bash}/bin/bash
        if /var/setuid-wrappers/ping -c 1 raspberrypi
        then
          # We're home, no need to unmount anything
          exit 0
        fi

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

  desktop-bind = mkService {
    description   = "Bind desktop SSH";
    path          = [ iputils openssh procps ];
    environment   = { SSH_AUTH_SOCK = "/run/user/1000/ssh-agent"; };
    requires      = [ "network.target" ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 20;
      ExecStart  = writeScript "desktop-bind" ''
        #!${bash}/bin/bash

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

  desktop-monitor = mkService {
    description   = "Kill desktop-bind if it's hung";
    path          = [ coreutils iputils openssh procps su.su ];
    environment   = { SSH_AUTH_SOCK = "/run/user/1000/ssh-agent"; };
    serviceConfig = {
      User       = "root";
      Restart    = "always";
      RestartSec = 20;
      ExecStart  = writeScript "desktop-monitor" ''
        #!${bash}/bin/bash
        PAT='ssh.*22222:localhost:22222'

        if pgrep -f "$PAT"
        then
          # Bind is running, make sure it's working
          if timeout 10 su -c 'ssh -A user@localhost -p 22222 true' - chris
          then
            # Seems to be working
            true
          else
            echo "Can't access bound port, kill the bind"
            pkill -f -9 "$PAT"
          fi
        fi

        echo "Monitor exiting"
      '';
    };
  };

  hydra-bind = mkService {
    description   = "Bind desktop SSH";
    path          = [ openssh iputils procps ];
    environment   = { SSH_AUTH_SOCK = "/run/user/1000/ssh-agent"; };
    wantedBy      = [ "default.target" ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 20;
      ExecStart  = writeScript "hydra-bind" ''
        #!${bash}/bin/bash
        echo "Checking for existing binds"
        if pgrep -f 'ssh.*3000:localhost:3000'
        then
          echo "Existing bind found, sleeping"
          exit 0
        fi

        echo "Checking for identity"
        if ssh-add -L | grep "The agent has no identities"
        then
          echo "No identity found, adding"
          ssh-add /home/chris/.ssh/id_rsa
        fi

        echo "Binding port"
        ssh -N -A -L 3000:localhost:3000 user@localhost -p 22222

        echo "Bind exited"
      '';
    };
  };

  hydra-monitor = mkService {
    description   = "Force hydra-bind to restart when down";
    path          = [ curl ];
    wantedBy      = [ "default.target" ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 20;
      ExecStart  = writeScript "hydra-monitor" ''
        #!${bash}/bin/bash
        echo "Checking for Hydra server"
        if timeout 10 curl http://localhost:3000
        then
          echo "OK, server is up"
          exit 0
        fi

        echo "Server is down, killing any hydra ssh bindings"
        pkill -f -9 'ssh.*3000:localhost:3000'
        exit 0
      '';
    };
  };

  ipfsRemoteOnLocal = {
    wantedBy      = [ "default.target" ];
    after         = [ "network.target" ];
    environment   = { IPFS_PATH = "/var/lib/ipfs/.ipfs"; };
    path          = with pkgs; [ ipfs openssh ];
    serviceConfig = {
      Type       = "simple";
      User       = "chris";
      Restart    = "always";
      RestartSec = 60;
      ExecStart  = writeScript "ipfs-remote-on-local" ''
        #!${bash}/bin/bash

        echo "Providing chriswarbo.net:4001 (IPFS swarm) as our port 6001" 1>&2
        ssh -N -L "6001:localhost:4001" chriswarbo.net &
        sleep 3

        echo "Adding tunnelled port to IPFS swarm" 1>&2
        ID=Qmf7fikDA5TB5RD3vUT7bF36mAn3NTBcbMbHRNcTo6WqVK
        ipfs swarm connect "/ip4/127.0.0.1/tcp/6001/ipfs/$ID" || true

        wait
      '';
    };
  };

  ipfsLocalOnRemote = {
    wantedBy      = [ "default.target" ];
    after         = [ "network.target" ];
    path          = with pkgs; [ openssh ];
    serviceConfig = {
      Type       = "simple";
      User       = "chris";
      Restart    = "always";
      RestartSec = 60;
      ExecStart  = writeScript "ipfs-local-on-remote" ''
        #!${bash}/bin/bash

        echo "Providing our 4001 (IPFS swarm) as chriswarbo.net:6001" 1>&2
        ssh -N -T -R6001:localhost:4001 chriswarbo.net &
        sleep 3

        echo "Adding tunnelled port to IPFS swarm" 1>&2
        ID=QmVkjeUP5UCZjUJqo6KueCGu5hSi1KqWGWWpbg3NRL6mHZ
        ssh chriswarbo.net ipfs swarm connect "/ip4/127.0.0.1/tcp/6001/ipfs/$ID" || true

        wait
      '';
    };
  };

  ssh-agent = mkService {
    description   = "Run ssh-agent";
    path          = [ openssh ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 20;
      ExecStart  = writeScript "ssh-agent-start" ''
        #!${bash}/bin/bash
        if [[ -e /run/user/1000/ssh-agent ]]
        then
          echo "Socket exists, sleeping"
          exit 0
        fi
        exec ssh-agent -D -a /run/user/1000/ssh-agent
      '';
      ExecStop   = writeScript "ssh-agent-stop" ''
        #!${bash}/bin/bash
        SSH_AUTH_SOCK=/run/user/1000/ssh-agent ssh-agent -k
      '';
    };
  };

  kill-network-mounts = mkService {
    description   = "Force kill network mounts after suspend/resume";
    path          = [ psmisc];

    # suspend.target causes this to be invoked, but only after (i.e. on resume)
    after         = [ "suspend.target" ];
    wantedBy      = [ "suspend.target" ];
    serviceConfig = {
      User      = "root";
      Type      = "oneshot";
      ExecStart = writeScript "kill-network-filesystems" ''
        #!${bash}/bin/bash
        killall -9 sshfs || true
      '';
    };
  };

  # Turn off power saving on WiFi to work around
  # https://bugzilla.kernel.org/show_bug.cgi?id=56301 (or something similar)
  wifiPower = {
    wantedBy      = [ "multi-user.target" ];
    before        = [ "network.target" ];
    path          = with pkgs; [ iw ];
    serviceConfig = {
      Type       = "simple";
      User       = "root";
      Restart    = "always";
      RestartSec = 60;
      ExecStart  = writeScript "wifipower" ''
        #!${bash}/bin/bash
        iw dev wlp2s0 set power_save off
      '';
    };
  };
}
