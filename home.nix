{ config, pkgs, ... }:

{
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
  home.packages = [
    pkgs.awscli
    pkgs.cmus
    pkgs.gnome.gnome-tweaks
    pkgs.nix-top
    pkgs.screen
    pkgs.taskspooler
    pkgs.vlc
    pkgs.w3m
    pkgs.waypipe
    pkgs.weston
    pkgs.wlr-randr

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

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
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs = {
    direnv.enable = true;

    emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;
    };

    firefox = {
      enable = true;
      profiles.default = {
        search = {
          default = "DuckDuckGo";
          engines.Bing.metaData.hidden = true;
          engines.Google.metaData.hidden = true;
        };
        settings = {
          "browser.aboutConfig.showWarning" = false;
          "extensions.pictureinpicture.enable_picture_in_picture_overrides" = true;

          # This is required to prevent menus flickering and becoming unusable
          # TODO: Find relevant bug report
          "widget.wayland.use-move-to-rect" = false;

          # This determines the size of both UI elements and page content. It
          # can be tweaked along with the monitor's scale factor, and the GTK
          # font scaling, to find a nice size for PinePhone screen & monitor.
          "layout.css.devPixelsPerPx" = "-1";

          # Various UI settings
          "browser.theme.content-theme" = 0;
          "browser.theme.toolbar-theme" = 0;
          "browser.uidensity" = 1;
          "browser.compactmode.show" = true;
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "font.internaluseonly.changed" = true;
          "font.name.serif.x-western" = "Liberation Sans";
          "font.size.variable.x-western" = 12;
          "general.smoothScroll" = false;
          "intl.regional_prefs.use_os_locales" = true;
          "widget.gtk.overlay-scrollbars.enabled" = false;

          # Privacy, anti-tracking, etc.
          "general.useragent.override" = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:98.0) Gecko/20100101 Firefox/98.0";
          "browser.contentblocking.category" = "strict";
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
        main.initial-window-mode = "maximized";
        csd.hide-when-maximized = "yes";
      };
    };

    git = {
      enable = true;
      userName = "Chris Warburton";
      userEmail = "chriswarbo@gmail.com";
    };

    home-manager = {
      enable = true;
      path = fetchTarball {
        sha256 = "sha256:0dfshsgj93ikfkcihf4c5z876h4dwjds998kvgv7sqbfv0z6a4bc";
        url = "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
      };
    };

    htop.enable = true;
    jq.enable = true;

    /* TODO: Add these:
https://github.com/nix-community/home-manager/blob/master/modules/programs/mbsync.nix
https://github.com/nix-community/home-manager/blob/master/modules/programs/msmtp.nix
https://github.com/nix-community/home-manager/blob/master/modules/programs/mu.nix
*/
    rtorrent.enable = true;
    yt-dlp.enable = true;

  };

  services = {
    emacs = {
      enable = true;
      startWithUserSession = true;
      defaultEditor = true;

    };
  };
}
