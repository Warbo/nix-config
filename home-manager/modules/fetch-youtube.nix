{
  config,
  lib,
  pkgs,
  ...
}:
with {
  inherit (builtins) toString;
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.fetch-youtube;
};
{
  options = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable polling and fetching of youtube feeds.
      '';
    };

    timer = mkOption {
      example = { OnUnitActiveSec = "1h"; };
      description = ''
        Attrset to use for polling feeds, used as the 'Timer' attribute of a
        systemd.user.timer. Note that subsequent downloading, processing, etc.
        is event-based, so doesn't require further polling.
      '';
    };

    dir = mkOption {
      type = types.path;
      default = ~/youtube;
      description = ''
        Base directory for downloading files, etc. Used by default values of
        feeds, temp, done, fetched, todo, etc. Ignored if those aren't default.
        We default to putting all those directories inside this one "base", so
        they are on the same filesystem, and hence 'mv' will be atomic (avoiding
        file watchers seeing partial data).
      '';
    };

    feeds = mkOption {
      type = types.path;
      default = cfg.dir + "/feeds.tsv";
      description = ''
        Path to file specifying feeds. Tab-separated, with columns for type,
        name and URL; where type is currently just youtube, name will be used to
        name the sub-directory results go in, and URL is for the RSS/Atom feed.
      '';
    };

    temp = mkOption {
      type = types.path;
      default = cfg.dir + "/temp";
      description = ''
        Path to directory we'll use for intermediate data: successful results
        will be moved out of here atomically using mv, whilst failed or
        interrupted results will leave partial files, stdout/err contents, etc.
        for manual resumption or investigation.
      '';
    };

    todo = mkOption {
      type = types.path;
      default = cfg.dir + "/todo";
      description = ''
        The feed reader will put unseen video IDs and URLs into this directory,
        which will trigger the file fetcher to download them.
      '';
    };

    done = mkOption {
      type = types.path;
      default = cfg.dir + "/done";
      description = ''
        This directory will accumulate video IDs and URLs that have been
        successfully fetched before, so we avoid getting them again.
      '';
    };

    fetched = mkOption {
      type = types.path;
      default = cfg.dir + "/fetched";
      description = ''
        This directory will store fully downloaded videos.
      '';
    };

    command = mkOption {
      type = with types; either str (listOf str);
      default = [cfg.executable] ++ cfg.args;
      example = [ "ytdl" "-f" "bestaudio" ];
      description = ''
        Command to execute on a video's URL. Can either be a list of strings to
        represent an executable and its initial arguments, or a string of shell
        code. Defaults to the 'executable' option followed by the 'args' option.
      '';
    };

    executable = mkOption {
      type = types.path;
      default = pkgs.yt-dlp + "/bin/yt-dlp";
      description = ''
        Executable to invoke for downloading videos, used by the default value
        of the 'command' option (overriding that option will ignore this one).
        Note that this is the path of an executable, not just a derivation, e.g.
        use 'pkgs.ytdl + "/bin/ytdl"' rather than just 'pkgs.ytdl'.
      '';
    };

    args = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "-f" "bestaudio" ]
      description = ''
        Initial arguments to give to the downloader (the video URL will be given
        as a subsequent argument). This is only used by the default value of the
        'command' option, so overriding that option will ignore this one.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    systemd.user = {
      paths = {
        fetch-youtube-files = {
          Unit.Description = "Fetch files when new entries appear in todo";
          Path.DirectoryNotEmpty = toString cfg.todo;
        };
      };
      timers = {
        fetch-youtube-feeds = {
          Unit.Description = "Fetch Youtube feeds daily";
          Timer = cfg.timer;
        };
      };
      services = {
        fetch-youtube-feeds = {
          Unit.Description = "Fetch Youtube feeds";
          Service = {
            Type = "oneshot";
            RemainAfterExit = "no";
            ExecStart = "${pkgs.writeShellScript "fetch-youtube-feeds" ''
              set -e
              mkdir -p ${toString cfg.temp}

              # Read all feeds up-front to reduce chance of catching it mid-edit
              # We'll fetch them in a random order, in case one causes breakage.
              FEEDS=$(shuf < ${toString cfg.feeds})

              while read -r LINE
              do
                FORMAT=$(echo "$LINE" | cut -f1)

                # Only handle 'youtube' for now; allows new types to be added.
                [[ "$FORMAT" = "youtube" ]] || continue

                NAME=$(echo "$LINE" | cut -f2)
                URL=$(echo "$LINE" | cut -f3)
                echo "Processing $LINE" 1>&2

                # Video IDs will go in here
                TODO=${toString cfg.todo}
                DONE=${toString cfg.done}
                mkdir -p "$TODO"
                mkdir -p "$DONE"

                # Extract URLs immediately; no point storing feed itself
                while read -u 3 -r VURL
                do
                  VID=$(echo "$VURL" | cut -d= -f2)
                  [[ -e "$DONE/$VID" ]] || {
                    # Write atomically to TODO
                    T=${toString cfg.temp}/"$VID"
                    mkdir -p "$T"
                    echo "$VURL" > "$T/$NAME"
                    mv -v "$T" "$TODO/"
                  }
                done 3< <(curl "$URL" |
                  grep -o 'https://www.youtube.com/watch?v=[^<>" &]*')
              done < <(echo "$FEEDS")
            ''}";
          };
        };

        fetch-youtube-files = {
          Unit.Description = "Fetch all Youtube videos identified in todo";
          Service = {
            Type = "oneshot";
            RemainAfterExit = "no";
            ExecStart = "${pkgs.writeShellScript "fetch-youtube-files" ''
              set -e
              mkdir -p ${toString cfg.fetched}

              while true
              do
                # Run find to completion before changing anything in todo
                FILES=$(find ${toString cfg.todo} -type f | shuf)

                # Stop if nothing more was found
                echo "$FILES" | grep -q '^.' || break

                while read -r F
                do
                  # Extract details
                  URL=$(cat "$F")
                  VID=$(basename "$(dirname "$F")")
                  NAME=$(basename "$F")
                  DONE=${toString cfg.done}/"$NAME"

                  # Set up a temp dir to work in. The name is based on the VID; so
                  # we can tell if this entry has been attempted before.
                  T=${toString cfg.temp}/fetch-"$VID"
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
                    if ${if builtins.isList cfg.command
                         then lib.concatMapStringsSep
                           " "
                           lib.escapeShellArg
                           cfg.command
                        else cfg.command} "$URL" \
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
                    mv "$T" ${toString cfg.fetched}/
                    mkdir -p "$DONE"
                    mv "$F" "$DONE/$VID"
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
    };
  ]);
}
