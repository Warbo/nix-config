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

    todo = mkOption {
      type = types.path;
      default = cfg.dir + "/todo";
      description = ''
        The feed reader will put unseen video IDs and URLs into this directory,
        which will trigger the file fetcher to download them.
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
    };
  ]);
}
