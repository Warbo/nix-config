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
  options.fetch-youtube = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable polling and fetching of youtube feeds.
      '';
    };

    user = mkOption {
      type = types.nullOr types.str;
      example = "alice";
      default = null;
      description = ''
        Username to run the youtube scripts as.
      '';
    };

    timer = mkOption {
      example = {
        OnUnitActiveSec = "1h";
      };
      description = ''
        Attrset to use for polling feeds, used as the 'Timer' attribute of a
        systemd.timer. Note that subsequent downloading, processing, etc.
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

    destination = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Directory to rsync completed results to. This can be on a different
        filesystem to the 'dir' option. Use null to leave in fetched dir.
      '';
    };

    command = mkOption {
      type = with types; either str (listOf str);
      default = [ cfg.executable ] ++ cfg.args;
      example = [
        "ytdl"
        "-f"
        "bestaudio"
      ];
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
      default = [ ];
      example = [
        "-f"
        "bestaudio"
      ];
      description = ''
        Initial arguments to give to the downloader (the video URL will be given
        as a subsequent argument). This is only used by the default value of the
        'command' option, so overriding that option will ignore this one.
      '';
    };
  };

  config =
    with {
      setUser = x: (if cfg.user == null then {} else { User = cfg.user; }) // x;
    };
    mkIf cfg.enable (mkMerge [
    {
      systemd = {
        paths = {
          fetch-youtube-files = {
            description = "Fetch files when new entries appear in todo";
            pathConfig.DirectoryNotEmpty = toString cfg.todo;
            wantedBy = [ "multi-user.target" ];
          };
        };
        timers = {
          fetch-youtube-feeds = {
            description = "Fetch Youtube feeds daily";
            timerConfig = cfg.timer;
            wantedBy = [ "multi-user.target" ];
          };
        };
        services = {
          fetch-youtube-feeds = {
            description = "Fetch Youtube feeds";
            environment = {
              TEMP = toString cfg.temp;
              FEEDS = toString cfg.feeds;
              TODO = toString cfg.todo;
              DONE = toString cfg.done;
            };
            serviceConfig = setUser {
              Type = "oneshot";
              RemainAfterExit = "no";
              ExecStart = "${pkgs.writeShellApplication {
                name = "fetch-youtube-feeds";
                text = builtins.readFile ./fetch-youtube-feeds.sh;
                runtimeInputs = with pkgs; [ bash curl coreutils gnugrep ];
              }}/bin/fetch-youtube-feeds";
            };
          };

          fetch-youtube-files = {
            description = "Fetch all Youtube videos identified in todo";
            environment = {
              FETCHED = toString cfg.fetched;
              TODO = toString cfg.todo;
              DONE_BASE = toString cfg.done;
              TEMP = toString cfg.temp;
              CMD = pkgs.writeShellScript "fetch-youtube-cmd" ''
                exec ${
                  if builtins.isList cfg.command then
                    lib.concatMapStringsSep " " lib.escapeShellArg cfg.command
                  else
                    cfg.command
                } "$@"
              '';
            };
            serviceConfig = setUser {
              Type = "oneshot";
              RemainAfterExit = "no";
              ExecStart = "${pkgs.writeShellApplication {
                name = "fetch-youtube-files";
                text = builtins.readFile ./fetch-youtube-files.sh;
                runtimeInputs = with pkgs; [ bash coreutils findutils gnugrep ];
              }}/bin/fetch-youtube-files";
            };
          };
        };
      };
    }
    (mkIf (cfg.destination != null) {
      systemd = {
        paths.fetch-youtube-move = {
          description = "Move completed downloads";
          pathConfig.DirectoryNotEmpty = toString cfg.fetched;
          wantedBy = [ "multi-user.target" ];
        };
        services.fetch-youtube-move = {
          description = "Move completed downloads";
          environment = {
            DEST = toString cfg.destination;
            FETCHED = toString cfg.fetched;
            RSYNC = "${pkgs.rsync}/bin/rsync";
          };
          serviceConfig = setUser {
            Type = "oneshot";
            RemainAfterExit = "no";
            ExecStart = "${pkgs.writeShellApplication {
              name = "fetch-youtube-move";
              text = builtins.readFile ./fetch-youtube-move.sh;
              runtimeInputs = with pkgs; [ bash coreutils ];
            }}/bin/fetch-youtube-move";
          };
        };
      };
    })
  ]);
}
