{ config, pkgs, lib, ... }:

with rec {
  inherit (warbo-utilities) warbo-packages;
  inherit (warbo-packages) nix-helpers;
  inherit (nix-helpers) nixpkgs-lib;

  buuf = pkgs.newScope (nix-helpers // warbo-packages) ./buuf { };

  warbo-utilities = import ./warbo-utilities.nix;

  commands = import ./commands.nix { };
}; {

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "manjaro";
  home.homeDirectory = "/home/manjaro";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = builtins.attrValues commands ++ [
    (pkgs.hiPrio warbo-utilities)

    pkgs.libsForQt5.qtstyleplugin-kvantum
    pkgs.qt6Packages.qtstyleplugin-kvantum

    pkgs.audacious
    pkgs.awscli
    pkgs.cantata
    pkgs.dnsutils
    pkgs.entr
    pkgs.leafpad
    pkgs.lxqt.qterminal # KGX is slow, Foot mangles lines, Konsole needs KDElibs
    pkgs.mpv
    pkgs.nixfmt
    pkgs.p7zip
    pkgs.rclone
    pkgs.rsync
    pkgs.screen
    pkgs.strace
    pkgs.taskspooler
    pkgs.thunderbird
    pkgs.unzip
    pkgs.update-nix-fetchgit
    pkgs.usbutils
    pkgs.vlc
    pkgs.w3m
    pkgs.wget
    pkgs.wlr-randr
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = with rec {
    mkDesktop = name: args:
      "${
        pkgs.makeDesktopItem ({ inherit name; } // args)
      }/share/applications/${name}.desktop";

    autostarts = lib.mapAttrs' (pname: value: {
      inherit value;
      name = ".config/autostart/${pname}.desktop";
    }) {
      thunderbird.text = pkgs.thunderbird.desktopItem.text;
      firefox.text = pkgs.firefox.desktopItem.text;
      screen-local.source = mkDesktop "screen-local" {
        desktopName = "screen-local";
        exec = ''${pkgs.lxqt.qterminal}/bin/qterminal -e "screen -DR"'';
      };
      screen-pi.source = mkDesktop "screen-pi" {
        desktopName = "screen-pi";
        exec =
          ''${pkgs.lxqt.qterminal}/bin/qterminal -e "ssh -t pi screen -DR"'';
      };
    };
  };
    {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    } // autostarts;

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/manjaro/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    NIX_PATH =
      pkgs.lib.concatStringsSep ":" [ "nixpkgs=${nix-helpers.nixpkgs.path}" ];
    QT_STYLE_OVERRIDE = "kvantum";
  };

  # These three ensure our Nix .desktop files appear in desktops/menus
  targets.genericLinux.enable = true;
  xdg.mime.enable = true;
  xdg.systemDirs.data =
    [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];

  gtk = {
    enable = true;

    #font = hm.types.fontType;

    #cursorTheme =  cursorThemeType;

    iconTheme = {
      name = buuf.name;
      package = buuf;
    };

    theme = {
      package = pkgs.theme-vertex; # pkgs.skeu
      name = "Vertex";
    };

    gtk2.extraConfig = ''
      gtk-enable-animations=0
      gtk-primary-button-warps-slider=0
      gtk-toolbar-style=3
      gtk-menu-images=1
      gtk-button-images=1
      gtk-cursor-theme-size=24
      gtk-cursor-theme-name="Adwaita"${
        "" # gtk-icon-theme-name="oxygen"
      }
      gtk-font-name="Droid Sans [1ASC],  8"${
        "" # gtk-theme-name="Adwaita-dark"
      }
    '';

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-button-images = true;
      gtk-cursor-theme-name = "Adwaita";
      gtk-cursor-theme-size = "24";
      gtk-decoration-layout = "icon:minimize,maximize,close";
      gtk-enable-animations = false;
      gtk-font-name = "Droid Sans [1ASC],  8";
      #gtk-icon-theme-name = "oxygen";
      gtk-menu-images = true;
      gtk-modules = "window-decorations-gtk-module:colorreload-gtk-module";
      gtk-primary-button-warps-slider = false;
      #gtk-theme-name=Adwaita-dark;
      gtk-toolbar-style = "3";
      gtk-xft-dpi = "98304";
      gtk-overlay-scrolling = false;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-cursor-theme-name = "Adwaita";
      gtk-cursor-theme-size = "24";
      gtk-decoration-layout = "icon:minimize,maximize,close";
      gtk-enable-animations = false;
      gtk-overlay-scrolling = false;
      gtk-font-name = "Droid Sans [1ASC],  8";
      #gtk-icon-theme-name = "oxygen";
      gtk-modules = "window-decorations-gtk-module:colorreload-gtk-module";
      gtk-primary-button-warps-slider = false;
      #gtk-theme-name = Adwaita-dark;
      gtk-xft-dpi = "98304";
    };
  };

  # Let Home Manager install and manage itself.
  programs = {
    bash = {
      enable = true;
      bashrcExtra = builtins.readFile ../../bashrc;
      profileExtra = ''
        # Inherited from pre-Home-Manager config; not sure if needed
        [[ -f ~/.bashrc ]] && . ~/.bashrc
      '';
    };

    browserpass = {
      enable = true;
      browsers = [ "firefox" ];
    };

    direnv.enable = true;

    emacs = {
      enable = true;
      # "Pure GTK" version has crisper font rendering on Wayland
      package = pkgs.emacs-pgtk;
    };

    firefox = {
      enable = true;
      profiles.default = {
        settings = {
          "browser.aboutConfig.showWarning" = false;
          "extensions.pictureinpicture.enable_picture_in_picture_overrides" =
            true;

          # This is required to prevent menus flickering and becoming unusable
          # TODO: Find relevant bug report
          "widget.wayland.use-move-to-rect" = false;

          # This determines the size of both UI elements and page content. It
          # can be tweaked along with the monitor's scale factor, and the GTK
          # font scaling, to find a nice size for PinePhone screen & monitor.
          "layout.css.devPixelsPerPx" = "-1";

          # Various UI settings
          "browser.compactmode.show" = true;
          "browser.theme.content-theme" = 0;
          "browser.theme.toolbar-theme" = 0;
          "browser.uidensity" = 1;
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "font.internaluseonly.changed" = true;
          "font.name.serif.x-western" = "Liberation Sans";
          "font.size.variable.x-western" = 12;
          "general.smoothScroll" = false;
          "intl.regional_prefs.use_os_locales" = true;
          "widget.gtk.overlay-scrollbars.enabled" = false;

          # Privacy, anti-tracking, etc.
          "browser.contentblocking.category" = "strict";
          "general.useragent.override" =
            "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:98.0) Gecko/20100101 Firefox/98.0";
          "privacy.clearOnShutdown.cookies" = false;
          "privacy.clearOnShutdown.sessions" = false;
          "privacy.history.custom" = true;
          "privacy.query_stripping.enabled" = true;
          "privacy.query_stripping.enabled.pbmode" = true;
          "privacy.sanitize.sanitizeOnShutdown" = true;
          "privacy.trackingprotection.emailtracking.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;

          # Fuck ads
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.pinned" = "[]";

          # Use DuckDuckGo for search
          "browser.search.region" = "GB";
          "browser.search.separatePrivateDefault.urlbarResult.enabled" = false;
          "browser.urlbar.maxRichResults" = 5;
          "browser.urlbar.suggest.history" = false;
          "browser.urlbar.tipShownCount.tabToSearch" = 2;
        };
      };
    };

    git = {
      enable = true;
      userEmail = "chriswarbo@gmail.com";
      userName = "Chris Warburton";
    };

    home-manager = {
      enable = true;
      path = fetchTarball {
        sha256 = "sha256:16078fwcmqq41dqfnm124xxm8l6zykvqlj1kzgi0fvfil4y86slm";
        url = pkgs.lib.concatStringsSep "/" [
          "https://github.com"
          "nix-community"
          "home-manager"
          "archive"
          "release-23.11.tar.gz"
        ];
      };
    };

    htop.enable = true;
    jq.enable = true;
    jujutsu.enable = true;

    /* TODO: Add these:
       https://github.com/nix-community/home-manager/blob/master/modules/programs/mbsync.nix
       https://github.com/nix-community/home-manager/blob/master/modules/programs/msmtp.nix
       https://github.com/nix-community/home-manager/blob/master/modules/programs/mu.nix
    */

    password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
      settings.PASSWORD_STORE_DIR = "$HOME/.password-store";
    };

    #rtorrent.enable = true;

    ssh = {
      enable = true;
      matchBlocks = {
        chromebook = {
          hostname = "chromebook.local";
          user = "jo";
        };
        pi = {
          hostname = "dietpi.local";
          user = "pi";
        };
        laptop = {
          hostname = "nixos-amd64.local";
          user = "chris";
        };
      };
    };

    yt-dlp.enable = true;
  };

  services = {
    emacs = {
      enable = true;
      startWithUserSession = true;
      defaultEditor = true;
    };

    mpd = {
      enable = true;
      musicDirectory = "/home/manjaro/Shared/Music/Commercial";
      #playlistDirectory = "none";
      dbFile = null;
      network.listenAddress = "any";
      extraConfig = ''
        database {
          plugin "proxy"
          host "127.0.0.1"
          port "6666"
        }

        audio_output {
          type "pulse"
          name "pulse audio"
        }
      '';
    };
  };

  dconf.settings = with { inherit (lib.hm.gvariant) mkDouble mkUint32; }; {
    "org/gnome/desktop/interface" = {
      clock-show-date = true;
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      enable-animations = false;
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      font-name = "Droid Sans 11";
      monospace-font-name = "Iosevka 9";
      show-battery-percentage = true;
    };
    "org/gnome/desktop/session" = { idle-delay = mkUint32 300; };
    "org/gnome/desktop/wm/preferences".focus-mode = "sloppy";
    "org/gnome/desktop/screensaver" = {
      # Phosh screen lock can mess up when plugging in external monitors, so
      # disable it completely (the pin-entry doesn't appear on the monitor,
      # but is still focused and hence capturing keyboard entry)
      lock-enabled = false;
      lock-delay = mkUint32 3600;
      picture-options = "none";
    };
  };

  systemd.user = {
    services = {
      fix-monitor = {
        Unit.Description = "Re-jig external monitor";
        Service = {
          Type = "oneshot";
          RemainAfterExit = "no";
          ExecStart = "${commands.fix}/bin/fix";
          Environment = [
            # We want to use wlr-randr to alter the existing Wayland display;
            # this requires setting a few env vars (hardcoded, but doesn't seem
            # tooooo bad...).
            "XDG_RUNTIME_DIR=/run/user/1000/"
            "WAYLAND_DISPLAY=wayland-0"
            "DISPLAY=:0"
          ];
        };
      };

      mpd.Unit.After = [ "dietpi-smb.service" "mpd-forwarder.service" ];
      mpd.Unit.Requires = [ "dietpi-smb.service" "mpd-forwarder.service" ];
      mpd-forwarder = {
        Unit = {
          Description = "Proxy MPD on an IPv6 mDNS host, to a local port";
          After = [ "dietpi-accessible.target" ];
          PartOf = [ "dietpi-accessible.target" ];
          BindsTo = [ "dietpi-accessible.target" ];
          Requires = [ "dietpi-accessible.target" ];
        };
        Service = {
          ExecStart = "${pkgs.writeShellScript "mpd-forwarder" ''
            set -ex
            if ADDRS=$(getent ahosts dietpi.local)
            then
              ADDR=$(echo "$ADDRS" | head -n1 | awk '{print $1}')
              exec ${pkgs.socat}/bin/socat \
                TCP-LISTEN:6666,fork,reuseaddr \
                TCP:[$ADDR]:6600
            else
              echo "Couldn't resolve dietpi.local" 1>&2
              exit 1
            fi
          ''}";
        };
      };

      dietpi-smb = {
        Unit = {
          Description = "Mount DietPi's shared folder read-only via SMB";
          After = [ "dietpi-accessible.target" ];
          PartOf = [ "dietpi-accessible.target" ];
          BindsTo = [ "dietpi-accessible.target" ];
          Requires = [ "dietpi-accessible.target" ];
        };
        Service = {
          ExecStart = "${pkgs.writeShellScript "dietpi-smb.sh" ''
            set -ex
            ADDR=$(${commands.pi4}/bin/pi4)
            # NOTE: Remote control (rc) port is arbitrary, but must be unique
            exec ${pkgs.rclone}/bin/rclone mount \
              --rc --rc-no-auth --rc-addr=:11111 \
              --vfs-cache-mode=full \
              ':smb:shared' \
              --smb-host "$ADDR" \
              /home/manjaro/Shared
          ''}";
          ExecStop = "fusermount -u /home/manjaro/Shared";
          Restart = "on-failure";
        };
        Install = { };
      };
      dietpi-sftp = {
        Unit = {
          Description = "Mount DietPi's root folder read/write via SFTP";
          After = [ "dietpi-accessible.target" "keyring-unlocked.target" ];
          PartOf = [ "dietpi-accessible.target" "keyring-unlocked.target" ];
          BindsTo = [ "dietpi-accessible.target" "keyring-unlocked.target" ];
          Requires = [ "dietpi-accessible.target" "keyring-unlocked.target" ];
        };
        Service = {
          ExecStart = "${pkgs.writeShellScript "dietpi-sftp.sh" ''
            set -ex
            . /home/manjaro/.bashrc
            unlocked | grep -q '^ssh' || {
              echo "SSH key not unlocked, skipping" 1>&2
              sleep 10
              exit 1
            }
            ADDR=$(${commands.pi4}/bin/pi4)

            # NOTE: We avoid setting modtime, to avoid SSH_FX_OP_UNSUPPORTED
            # NOTE: Remote control (rc) port is arbitrary, but must be unique
            exec ${pkgs.rclone}/bin/rclone mount \
              --rc --rc-no-auth --rc-addr=:22222 \
              --vfs-cache-mode=full \
              --sftp-set-modtime=false --no-update-modtime \
              ":sftp,user=pi,host=$ADDR:/" \
              /home/manjaro/DietPi
          ''}";
          ExecStop = "fusermount -u /home/manjaro/DietPi";
          Restart = "on-failure";
        };
        Install = { };
      };

      s3-git = {
        Unit = {
          Description = "Mount chriswarbo.net/git via S3";
          After = [ "network-online.target" "keyring-unlocked.target" ];
          Wants = [ "network-online.target" "keyring-unlocked.target" ];
        };
        Service = {
          ExecStart = "${pkgs.writeShellScript "s3-git.sh" ''
            set -ex
            . /home/manjaro/.bashrc
            ping -c1 8.8.8.8 || {
              echo "Don't seem to be online, aborting mount" 1>&2
              exit 0
            }
            export RCLONE_S3_REGION=eu-west-1
            export RCLONE_S3_PROVIDER=AWS
            export RCLONE_S3_ENV_AUTH=true

            # NOTE: Remote control (rc) port is arbitrary, but must be unique
            exec with-aws-creds ${pkgs.rclone}/bin/rclone mount \
              --rc --rc-no-auth --rc-addr=:33333 \
              --vfs-cache-mode=full \
              --no-update-modtime --checksum --file-perms 0766 \
              ":s3:www.chriswarbo.net/git" \
              /home/manjaro/Drives/s3_repos
          ''}";
          ExecStop = "fusermount -u /home/manjaro/Drives/s3_repos";
          Restart = "on-failure";
        };
        Install = { };
      };
    };

    targets = {
      dietpi-accessible = {
        Unit = {
          Description = "Can access dietpi.local";
          Wants = [ "dietpi-smb.service" "dietpi-sftp.service" "mpd.service" ];
        };
      };

      home-wifi-connected = {
        Unit = {
          Description = "On home WiFi network";
          Wants = [ "dietpi-smb.service" "dietpi-sftp.service" ];
        };
      };

      keyring-unlocked = {
        Unit = {
          Description = "Indicates GNOME keyring and ssh-agent are unlocked";
          Wants = [ "dietpi-sftp.service" "s3-git" ];
        };
      };
    };
  };
}
