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
    };
  ]);
}
