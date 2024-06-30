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
            ExecStart = "${./fetch-youtube-feeds.sh}";
            Environment = {
              TEMP = toString cfg.temp;
              FEEDS = toString cfg.feeds;
              TODO = toString cfg.todo;
              DONE =toString cfg.done;
            };
          };
        };

        fetch-youtube-files = {
          Unit.Description = "Fetch all Youtube videos identified in todo";
          Service = {
            Type = "oneshot";
            RemainAfterExit = "no";
            ExecStart = "${./fetch-youtube-files.sh}";
            Environment = {
              FETCHED = toString cfg.fetched;
              TODO = toString cdf.todo;
              DONE_BASE = toString cfg.done;
              TEMP = toString cfg.temp;
              CMD = pkgs.writeShellScript "fetch-youtube-cmd" ''
                exec ${
                  if builtins.isList cfg.command
                  then lib.concatMapStringsSep
                    " "
                    lib.escapeShellArg
                    cfg.command
                  else cfg.command
                } "$@"
              '';
            };
          };
        };
      };
    };
  ]);
}
