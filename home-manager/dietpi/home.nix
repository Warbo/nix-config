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

  programs.git = {
    userName = "Chris Warburton";
    userEmail = "chriswarbo@gmail.com";
  };

  systemd.user = with { yt-dir = builtins.toString ~/youtube; }; {
    systemctlPath = "/bin/systemctl"; # Use native, since Nix one hangs
    services = {
      # TODO: Move this to a standalone module, to avoid clutter
      fetch-youtube-feeds = {
        Unit.Description = "Fetch Youtube feeds";
        Service = {
          Type = "oneshot";
          RemainAfterExit = "no";
          ExecStart = "${pkgs.writeShellScript "fetch-youtube-feeds" ''
            set -e
            mkdir -p ${yt-dir}/temp

            # Fetch feeds in random order, in case one causes breakage
            < ${yt-dir}/feeds.tsv shuf | while read -r LINE
            do
              FORMAT=$(echo "$LINE" | cut -f1)
              [[ "$FORMAT" = "youtube" ]] || continue
              NAME=$(echo "$LINE" | cut -f2)
              URL=$(echo "$LINE" | cut -f3)
              echo "Processing $LINE" 1>&2

              # Video IDs will go in here
              TODO=${yt-dir}/todo
              DONE=${yt-dir}/done
              mkdir -p "$TODO"
              mkdir -p "$DONE"

              # Extract URLs immediately; no point storing feed itself
              while read -u 3 -r VURL
              do
                VID=$(echo "$VURL" | cut -d= -f2)
                [[ -e "$DONE/$VID" ]] || {
                  # Write atomically to TODO
                  mkdir -p ${yt-dir}/temp/"$VID"
                  echo "$VURL" > ${yt-dir}/temp/"$VID"/"$NAME"
                  mv ${yt-dir}/temp/"$VID" "$TODO/"
                }
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
      fetch-youtube-files = {
        Unit.Description = "Fetch all Youtube videos identified in todo";
        Service = {
          Type = "oneshot";
          RemainAfterExit = "no";
          ExecStart = "${pkgs.writeShellScript "fetch-youtube-files" ''
            set -e
            mkdir -p ${yt-dir}/fetched

            while true
            do
              # Run find to completion before changing anything in todo
              FILES=$(find ${yt-dir}/todo -type f | shuf)

              # Stop if nothing more was found
              echo "$FILES" | grep -q '^.' || break

              while read -r F
              do
                # Extract details
                URL=$(cat "$F")
                NAME=$(basename "$F")
                VID=$(basename "$(dirname "$F")")

                # Set up a temp dir to work in. The name is based on the VID; so
                # we can tell if this entry has been attempted before.
                T=${yt-dir}/temp/fetch-"$VID"
                if [[ -e "$T" ]]
                then
                  echo "Skipping $VID as $T already exists (prev. failure?)" >&2
                  continue
                fi

                # If this hasn't been attempted yet, make a working dir inside
                # the temp dir, named after the destination directory (making it
                # easier to move atomically without overlaps). Metadata is kept
                # in the temp dir, so we can tell what happened.
                mkdir -p "$T/$NAME"
                pushd "$T/$NAME"
                  if ${pkgs.yt-dlp}/bin/yt-dlp -f 'b[height<600]' "$URL" \
                       1> >(tee ../stdout)
                       2> >(tee ../stderr 1>&2)
                  then
                    touch ../success
                  fi
                popd

                # If the fetch succeeded, move the result atomically to fetched
                # and move the VID from todo to done
                if [[ -e "$T/success" ]]
                then
                  mv "$T" ${yt-dir}/fetched/
                  mkdir -p ${yt-dir}/done/"$NAME"
                  mv "$F" ${yt-dir}/done/"$NAME"/"$VID"
                  rmdir "$(dirname "$F")"
                fi

                sleep 10 # Slight delay to cut down on spam
              done < <(echo "$FILES")

              sleep 10  # Slight delay to cut down on spam
            done
          ''}";
        };
      };
    };
    paths = {
      fetch-youtube-files = {
        Unit.Description = "Fetch files when new entries appear in todo";
        Path.DirectoryNotEmpty = "${yt-dir}/todo";
      };
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
