{ config, pkgs, lib, ... }:

with { fix = pkgs.writeShellScriptBin "fix" (builtins.readFile ./fix.sh); }; {
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
  home.packages = with rec {
      aws-login = pkgs.writeShellScriptBin "aws-login" ''
        set -e

        # Creates a temporary folder for AWS credentials, populates it using
        # secrets taken from the Pass database, and gets a temporary session
        # token from AWS. This way, the only permanent way our credentials are
        # stored is in Pass's encrypted database; and applications are only
        # exposed to temporary tokens, rather than the underlying secrets.

        PATH="${pkgs.coreutils}/bin:${pkgs.gnused}/bin:${pkgs.jq}/bin:$PATH"

        DIR=$(mktemp -d)
        cleanup() {
          rm -rf "$DIR"
        }
        trap cleanup EXIT

        export AWS_SHARED_CREDENTIALS_FILE="$DIR/creds"

        CREDS=$(${pkgs.pass}/bin/pass automation/aws_s3 | sed -e 's@//.*@@g')
        echo "$CREDS" | jq -r '[
          "[default]\naws_access_key_id=",
          .AccessKeyId,
          "\naws_secret_access_key=",
          .SecretAccessKey,
          "\n"
        ] | join("")' > "$AWS_SHARED_CREDENTIALS_FILE"

        ${pkgs.awscli}/bin/aws sts get-session-token --output json --query \
          'Credentials.[AccessKeyId,SecretAccessKey,SessionToken,Expiration]' |
          jq '{
            "Version": 1,
            "AccessKeyId": .[0],
            "SecretAccessKey": .[1],
            "SessionToken": .[2],
            "Expiration": .[3]
          }'
      '';

      with-aws-creds = pkgs.writeShellScriptBin "with-aws-creds" ''
        set -e

        # Runs a given command, using aws-login to obtain an AWS access token.
        # This avoids permanently storing credentials in plaintext.

        PATH="${pkgs.coreutils}/bin:$PATH"

        DIR=$(mktemp -d)
        cleanup() {
          rm -rf "$DIR"
        }
        trap cleanup EXIT

        export AWS_CONFIG_FILE="$DIR/config"
        printf '[default]\ncredential_process=%s' \
               "${aws-login}/bin/aws-login" > "$AWS_CONFIG_FILE"
        "$@"
      '';
  }; [
    fix

      pkgs.qtstyleplugin-kvantum-qt4
      pkgs.libsForQt5.qtstyleplugin-kvantum
      pkgs.qt6Packages.qtstyleplugin-kvantum

    pkgs.cmus
      pkgs.libreoffice
    #pkgs.nix-top
      pkgs.nixfmt
      pkgs.rsync
      pkgs.screen
      pkgs.taskspooler
      pkgs.vlc
      pkgs.w3m
      #pkgs.waypipe
      #pkgs.weston
      pkgs.wget
      pkgs.wlr-randr

      # Wrappers/helpers for AWS CLI, to avoid storing credentials in plaintext
    #aws-login
    #with-aws-creds
    #(pkgs.writeShellScriptBin "aws" ''
    #  ${with-aws-creds}/bin/with-aws-creds ${pkgs.awscli}/bin/aws "$@"
    #'')

      (pkgs.writeShellScriptBin "yt" ''
        set -e

        # Put YouTube video in a download queue
        cd ~/Downloads/VIDEOS || exit 1  # Save to Downloads/VIDEOS
        # Use best quality less than 600p (avoids massive filesize)
        ${pkgs.taskspooler}/bin/ts \
          ${pkgs.yt-dlp}/bin/yt-dlp -f 'b[height<600]' "$@"
      '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

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
    NIX_PATH = pkgs.lib.concatStringsSep ":"
      [ "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixpkgs" ];
    QT_STYLE_OVERRIDE = "kvantum";
  };

  # These three ensure our Nix .desktop files appear in desktops/menus
  targets.genericLinux.enable = true;
  xdg.mime.enable = true;
  xdg.systemDirs.data =
    [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];

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

    foot = {
      enable = true;
      settings = {
        colors = {
          background = "111111";
          foreground = "CCCCCC";
        };
        csd.hide-when-maximized = "yes";
        main.initial-window-mode = "maximized";
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
        sha256 = "sha256:0dfshsgj93ikfkcihf4c5z876h4dwjds998kvgv7sqbfv0z6a4bc";
        url = pkgs.lib.concatStringsSep "/" [
          "https://github.com"
          "nix-community"
          "home-manager"
          "archive"
          "release-23.05.tar.gz"
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
      matchBlocks."chriswarbo.net" = {
          #HostName 35.179.11.29
          #User admin
          #PubkeyAcceptedKeyTypes +ssh-rsa
          #IdentityFile ~/LightsailDefaultKey-eu-west-2.pem
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
  };

  dconf.settings = with { inherit (lib.hm.gvariant) mkDouble mkUint32; }; {
      "org/gnome/desktop/interface" = {
        clock-show-date = true;
        clock-show-weekday = true;
        color-scheme = "prefer-dark";
        enable-animations = false;
        font-antialiasing = "grayscale";
        font-hinting = "slight";
        font-name = "Droid Sans 9";
        gtk-key-theme = "Emacs";
        monospace-font-name = "Iosevka 9";
        show-battery-percentage = true;
        # Works with 1.25x on PinePhone screen and 0.75x on monitor (via R&R)
        text-scaling-factor = 1.33;
      };
      "org/gnome/desktop/session" = {
        idle-delay = mkUint32 300;
      };
      "org/gnome/desktop/wm/preferences".focus-mode = "sloppy";
      "org/gnome/desktop/screensaver" = {
        # Phosh screen lock can mess up when plugging in external monitors, so
        # disable it completely (the pin-entry doesn't appear on the monitor,
        # but is still focused and hence capturing keyboard entry)
        lock-enabled = false;
        lock-delay = mkUint32 3600;
        picture-options = "none";
      };
      # "org/gnome/desktop/applications/terminal" = {
      #   exec = "${pkgs.foot}/bin/foot";
      #   exec-arg = "";
      # };
    };
}
