with builtins;

pkgs: with pkgs;

let mkService = opts: {
        enable   = true;
        wantedBy = [ "default.target"  ];
        after    = [ "local-fs.target" ];
      } // opts // {
        serviceConfig = {
            Type = "simple";
          } // opts.serviceConfig;
        };
in {
  emacs =
    let sudoWrapper = stdenv.mkDerivation {
          name = "sudo-wrapper";
          buildCommand = ''
            mkdir -p "$out/bin"
            ln -s /var/setuid-wrappers/sudo "$out/bin/sudo"
          '';
        };
     in mkService {
          description     = "Emacs daemon";
          path            = [ all sudoWrapper ];
          environment     = { SSH_AUTH_SOCK = "/run/user/1000/ssh-agent"; };
          reloadIfChanged = true;  # As opposed to restarting
          serviceConfig   = {
            User       = "chris";
            Type       = "forking";
            Restart    = "always";
            ExecStart  = ''"${emacs}/bin/emacs" --daemon'';
            ExecStop   = ''"${emacs}/bin/emacsclient" --eval "(kill-emacs)"'';
            ExecReload = ''"${emacs}/bin/emacsclient" --eval "(load-file \"~/.emacs.d/init.el\")"'';
          };
        };

  shell = mkService {
    description     = "Long-running terminal multiplexer";
    path            = [ dvtm dtach ];
    environment     = {
      DISPLAY = ":0";
      TERM    = "xterm";
    };
    reloadIfChanged = true;  # As opposed to restarting
    serviceConfig   = {
      User      = "chris";
      Restart   = "always";
      ExecStart =
        let session = writeScript "session" ''
              #!${bash}/bin/bash
              exec dvtm -M -m ^b
            '';
         in writeScript "shell-start" ''
              #!${bash}/bin/bash
              cd
              exec dtach -A ~/.sesh -r winch "${session}"
            '';
      ExecStop   = ''"${coreutils}/bin/true"'';
      ExecReload = ''"${coreutils}/bin/true"'';
      StandardInput  = "tty";
      StandardOutput = "tty";
      TTYPath        = "/dev/tty6";
    };
  };

  hometime = mkService {
    description = "Count down to the end of the work day";
    path        = with pkgs; [ gksu libnotify iputils networkmanager pmutils ];
    environment = {
      DISPLAY    = ":0";
      XAUTHORITY = "/home/chris/.Xauthority";
    };
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 300;
      ExecStart  =
        let location = writeScript "location" ''
              #!${bash}/bin/bash

              # If we're not online, we can't tell where we are
              /var/setuid-wrappers/ping -c 1 google.com 1>/dev/null 2>/dev/null || {
                echo "unknown"
                exit
              }

              # The WiFi network we're on should tell us where we are
              NET=$(nmcli c | grep -v -- "--" | grep -v "DEVICE" | cut -d ' ' -f1)
              if [[ "x$NET" = "xaa.net.uk" ]]
              then
                echo "home"
              elif [[ "x$NET" = "xUoD_WiFi" ]] || [[ "x$NET" = "xeduroam" ]]
              then
                echo "uni"
              else
                echo "unknown"
              fi
            '';
       in writeScript "hometime" ''
            #!${bash}/bin/bash
            set -e
            set -x

            # Set DBus variables to make notifications work
            MID=$(cat /etc/machine-id)
              D=$(echo "$DISPLAY" | cut -d '.' -f1 | tr -d :)
            source ~/.dbus/session-bus/"$MID"-"$D"
            export DBUS_SESSION_BUS_ADDRESS

            function notify {
              notify-send -t 0 "Home Time" "$1"
            }

            LOC=$(${location})
            if [[ "x$LOC" = "xuni" ]]
            then
              HOUR=$(date "+%H")
              if [[ "$HOUR" -gt "16" ]]
              then
                notify "Past 5pm; half an hour until suspend"
                sleep 600
                notify "20 minutes until suspend"
                sleep 600
                notify "10 minutes until suspend"
                sleep 600
                notify "Suspending"
                sleep 60
                gksudo -S pm-suspend
              fi
            fi
          '';
    };
  };

  inboxen = mkService {
    description   = "Fetch mail inboxes";
    path          = with pkgs; [ bash iputils isync ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 600;
      ExecStart  = writeScript "inboxen-start" ''
        #!${bash}/bin/bash
        /var/setuid-wrappers/ping -c 1 google.com && mbsync gmail dundee
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
    path          = with pkgs; [ bash iputils isync ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 3600;
      ExecStart  = writeScript "mail-backup" ''
        #!${bash}/bin/bash
        /var/setuid-wrappers/ping -c 1 google.com && mbsync gmail-backup
      '';
    };
  };

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
      ExecStop = writeScript "afuse-unmount" ''
        #!${bash}/bin/bash
        pkill -f -9 "sshfs.*${dir}"
        /var/setuid-wrappers/fusermount -u -z "${dir}"
      '';
    };

    pi-mount = mkService {
      inherit path environment;
      description   = "Raspberry pi";
      requires      = [ "home-network.service" ];
      after         = [ "network.target" ];
      wantedBy      = [ "default.target" ];
      serviceConfig = mkCfg "pi@raspberrypi:/opt/shared"
                            "/home/chris/Public"
                            [];
    };

    desktop-mount = mkService {
      inherit path environment;
      description   = "Desktop files";
      requires      = [ "desktop-bind.service" ];
      after         = [ "network.target" ];
      wantedBy      = [ "default.target" ];
      serviceConfig = mkCfg "user@localhost:/"
                            "/home/chris/DesktopFiles"
                            ["-p 22222"];
    };
  })
  pi-mount desktop-mount;

  home-network = mkService {
    description   = "Home LAN";
    path          = [ iputils ];
    requires      = [ "network.target" ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 60;  # Check interval when we're not at home
      ExecStart  = writeScript "inboxen-start" ''
        #!${bash}/bin/bash
        while /var/setuid-wrappers/ping -c 1 raspberrypi
        do
          # We're home; poll to see when we're not
          sleep 60
        done
      '';
    };
  };

  desktop-bind = mkService {
    description   = "Bind desktop SSH";
    path          = [ iputils openssh procps ];
    environment   = { SSH_AUTH_SOCK = "/run/user/1000/ssh-agent"; };
    requires      = [ "ssh-agent.service" "network.target" ];
    serviceConfig = let kill = "pkill -f -9 'ssh.*22222:localhost:22222'"; in {
      User       = "chris";
      Restart    = "always";
      RestartSec = 60;  # Check interval when we're not at home
      ExecStart  = writeScript "desktop-bind" ''
        #!${bash}/bin/bash
        ${kill}
        ssh -N -A -L 22222:localhost:22222 chriswarbo.net
      '';
      ExecStop = writeScript "desktop-unbind" ''
        #!${bash}/bin/bash
        ${kill}
      '';
    };
  };

  hydra-bind = mkService {
    description   = "Bind desktop SSH";
    path          = [ openssh iputils procps ];
    environment   = { SSH_AUTH_SOCK = "/run/user/1000/ssh-agent"; };
    requires      = [ "desktop-bind.service" ];
    wantedBy      = [ "default.target" ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 60;  # Check interval when we're not at home
      ExecStart  = writeScript "desktop-bind" ''
        #!${bash}/bin/bash
        if ssh-add -L | grep "The agent has no identities"
        then
          ssh-add /home/chris/.ssh/id_rsa
        fi
        ssh -N -A -L 3000:localhost:3000 user@localhost -p 22222
      '';
      ExecStop = writeScript "desktop-unbind" ''
        #!${bash}/bin/bash
        pkill -f -9 "ssh .*3000:localhost:3000"
      '';
    };
  };

  ssh-agent = mkService {
    description = "Run ssh-agent";
    path = [ openssh ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 60;  # Check interval when we're not at home
      ExecStart  = writeScript "ssh-agent-start" ''
        #!${bash}/bin/bash
        exec ssh-agent -D -a /run/user/1000/ssh-agent
      '';
      ExecStop   = writeScript "ssh-agent-stop" ''
        #!${bash}/bin/bash
        SSH_AUTH_SOCK=/run/user/1000/ssh-agent ssh-agent -k
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
      RestartSec = 600;
      ExecStart  = writeScript "wifipower" ''
        #!${bash}/bin/bash
        iw dev wlp2s0 set power_save off
      '';
    };
  };
}
