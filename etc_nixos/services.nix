with builtins;

pkgs: with pkgs;

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

  sudoWrapper = stdenv.mkDerivation {
    name = "sudo-wrapper";
    buildCommand = ''
      mkdir -p "$out/bin"
      ln -s /var/setuid-wrappers/sudo "$out/bin/sudo"
    '';
  };

  pingOnce = "/var/setuid-wrappers/ping -c 1";
};
{
  emacs = mkService {
    description     = "Emacs daemon";
    path            = [ all emacs mu sudoWrapper ];
    environment     = {
      COLUMNS       = 80;
      SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
    };
    reloadIfChanged = true;  # As opposed to restarting
    serviceConfig   = {
      User       = "chris";
      Type       = "forking";
      Restart    = "always";
      ExecStart  = ''emacs --daemon'';
      ExecStop   = ''emacsclient --eval "(kill-emacs)"'';
      ExecReload = ''emacsclient --eval "(load-file \"~/.emacs.d/init.el\")"'';
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
        if [[ "$HOUR" -lt 17 ]]
        then
          echo "Too early to notify"
          exit
        fi

        if ${pingOnce} google.com 1>/dev/null 2>/dev/null
        then
          echo "We're online, getting location from WiFi network name"
        else
          echo "Can't get location from WiFi network (we're offline)"
          exit
        fi

        NET=$(nmcli c | grep -v -- "--" | grep -v "DEVICE" | cut -d ' ' -f1)
        if [[ "x$NET" = "xUoD_WiFi" ]] || [[ "x$NET" = "xeduroam" ]]
        then
          echo "We're at uni"
        else
          echo "Not at uni, so not notifying"
          exit 1
        fi

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
        timeout -s 9 3600 mbsync gmail dundee
      '';
    };
  };

  news = mkService {
    description   = "Fetch news";
    path          = [ findutils.out ];
    environment   = { LANG = "en_GB.UTF-8"; };
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 3600;
      ExecStart  = writeScript "get-news-start" ''
        #!${bash}/bin/bash
        "${warbo-utilities}/bin/get_news"

        # Extra delay if there's a bunch of stuff unread
        UNREAD=$(find Mail/feeds -path "*/new/*" -type f | wc -l)
        if [[ "$UNREAD" -gt 100 ]]
        then
          sleep $(( 60 * UNREAD ))
        fi
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

    path = [ sshfsFuse utillinux.bin openssh procps ];

    environment = {
      DISPLAY       = ":0"; # For potential ssh passphrase dialogues
      SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
    };

    mkCfg = addr: dir: extraOptions: {
      User       = "chris";
      Restart    = "always";
      RestartSec = 60;
      ExecStart  = writeScript "sshfs-mount" ''
        #!${bash}/bin/bash
        sshfs -f ${opts extraOptions} ${addr} ${dir}
      '';
      ExecStop = writeScript "sshfuse-unmount" ''
        #!${bash}/bin/bash
        pkill -f -9 "sshfs.*${dir}"
        /var/setuid-wrappers/fusermount -u -z "${dir}"
      '';
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
    path          = [ iputils openssh procps su.su ];
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
          if su -c 'ssh -A user@localhost -p 22222 true' - chris
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
        if curl http://localhost:3000
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
