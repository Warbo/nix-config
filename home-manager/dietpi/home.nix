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
  programs = {
    home-manager.enable = true;
    home-manager.path = import ../nixos-import.nix;

    git.userName = "Chris Warburton";
    git.userEmail = "chriswarbo@gmail.com";
  };

  systemd.user = {
    systemctlPath = "/bin/systemctl"; # Use native, since Nix one hangs
    services = with { yt-dir = builtins.toString ~/youtube; }; {
      # TODO: Move this to a standalone module, to avoid clutter
      fetch-youtube-feeds = {
        Unit.Description = "Fetch Youtube feeds";
        Service = {
          Type = "oneshot";
          RemainAfterExit = "no";
          ExecStart = "${pkgs.writeShellScript "fetch-youtube-feeds" ''
            set -ex
            # Fetch feeds in random order, in case one causes breakage
            < ${yt-dir}/feeds.tsv shuf | while read -r LINE
            do
              FORMAT=$(echo "$LINE" | cut -f1)
              [[ "$FORMAT" = "youtube" ]] || continue
              NAME=$(echo "$LINE" | cut -f2)
              URL=$(echo "$LINE" | cut -f3)
              echo "Processing $LINE" 1>&2

              # Video IDs will go in here
              TODO=${yt-dir}/todo/"$NAME"
              DONE=${yt-dir}/done/"$NAME"
              mkdir -p "$TODO"
              mkdir -p "$DONE"

              # Extract URLs immediately; no point storing feed itself
              while read -u 3 -r VURL
              do
                VID=$(echo "$VURL" | cut -d= -f2)
                [[ -e "$DONE/$VID" ]] || echo "$VURL" > "$TODO/$VID"
              done 3< <(curl "$URL" |
                grep -o 'https://www.youtube.com/watch?v=[^<>" &]*')
            done
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
