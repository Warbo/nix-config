{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ (import ../modules/warbo.nix) ];
  home.username = "pi";
  home.homeDirectory = "/home/pi";
  warbo.enable = true;

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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.home-manager.path = import ../nixos-import.nix;

  systemd.user = {
    services = {
      fetch-youtube-feeds = {
        Unit.Description = "Fetch Youtube feeds";
        Service = {
          Type = "oneshot";
          RemainAfterExit = "no";
          ExecStart = "${pkgs.writeShellScript "fetch-youtube-feeds" ''
            set -ex
            true
            # TODO: Set location we're downloading feeds to and putting maildirs

            # TODO: Loop through feeds in random order, downloading them.
            # extracting the video URLs and mv'ing them into a pending dir
            #while read -r LINE
            #do
            #  NAME=$(echo "$LINE" | cut -f1)
            #  URL=$(echo "$LINE" | cut -f2)
            #  mkdir
            #done < <(shuf < "$HOME/yt")
          ''}";
        };
      };

      # TODO: Trigger on path, pointing at pending URL dir:
      #  - We only want one copy running; but triggered whenever new URLs appear
      #  - Loop through pending URLs in random order, one at a time
      #  - Try downloading with yt-dlp, into an unfinished downloads dir
      #  - Wait until finished, ignoring common failures (shorts, etc.)
      #  - Once finished, mv resulting file to sub-folder of TODO
      #  - If successful, or known failure, delete URL from pending dir
      #fetch-youtube-files = {};
    };
    timers = {
      fetch-youtube-feeds = {
        Unit.Description = "Fetch Youtube feeds daily";
        Timer = {
          OnBootSec = "15min";
          OnUnitActiveSec = "1d";
        };
      };
    };
  };
}
