{ config, lib, pkgs, ... }:
with rec {
  inherit (builtins) attrValues mapAttrs toString;
  inherit (lib) mkIf mkMerge mkOption types;

  cfg = config.services.talecast;

  configEntries = {
    # These two paths must be on the same FS (see also: cfg.destination)
    partial_path = "${toString cfg.dir}/partial/{podname}";
    download_path = default_download_path;
  } // (if cfg ? download_hook then { inherit (cfg) download_hook; } else {}) //
  (cfg.extraConfig or {});

  configFile = (pkgs.formats.toml {}).generate "talecast" configEntries;

  setUser = x: (if cfg.user == null then {} else { User = cfg.user; }) // x;

  default_download_path = "${cfg.fetched_path}/{podname}";

  enableMoveService =
    # Only enable if we know downloads will be in cfg.fetched_path. We can't
    # support an arbitray configEntries.download_path since it allows variables
    # like '{podname}' which aren't worth attempting to interpret.
    configEntries.download_path == default_download_path &&
    cfg.destination != null;  # We also need somewhere to put them!
};
{
  options.services.talecast = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable fetching of podcasts from configured feeds.
      '';
    };

    user = mkOption {
      type = types.nullOr types.str;
      example = "alice";
      default = null;
      description = ''
        Username to run TaleCast as as.
      '';
    };

    timer = mkOption {
      default = null;
      example = {
        OnUnitActiveSec = "1h";
      };
      description = ''
        Attrset to use for polling feeds, used as the 'Timer' attribute of a
        systemd.timer.
      '';
    };

    podcasts = mkOption {
      type = types.path;
      description = ''
        Path to podcasts.toml file. Talecast will be pointed at a symlink to
        this path, which should allow updating it without a rebuild.
      '';
    };

    fetched_path = mkOption {
      type = types.path;
      default = "${toString cfg.dir}/fetched";
      description = ''
        Directory to move completed downloads into (in subdirectories). Must be
        on the same filesystem as partial_path. If destination is not null, this
        is the directory we will rsync files out of when they appear (so be
        careful if you override 'download_path' to not use this!).
      '';
    };

    destination = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Directory to rsync completed results to. This can be on a different
        filesystem to the TailCast's 'partial_path' and 'download_path'. Use
        null to leave thing in the download_path.
      '';
    };

    extraConfig = mkOption {
      example = {
        tracker_path = "${toString cfg.dir}/partial/{podname}/.downloaded";
      };
      default = {};
      description = ''
        Extra options to append to the global config file.
      '';
    };

    dir = mkOption {
      type = types.path;
      default = /var/run/talecast;
      description = ''
        TaleCast's working directory.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      systemd.services.talecast = {
        description = "Fetch podcast feeds";
        serviceConfig = setUser {
          Type = "oneshot";
          RemainAfterExit = "no";
          ExecStart = "${pkgs.writeShellApplication {
            name = "run-talecast";
            runtimeInputs = with pkgs; [ pkgs.talecast ];
            runtimeEnv.XDG_CONFIG_HOME =
              pkgs.linkFarm "talecast-config" [
                {
                  name = "talecast/podcasts.toml";
                  path = toString cfg.podcasts;
                }
              ];
            text = ''exec talecast --config ${configFile}'';
          }}/bin/run-talecast";
        };
      };
    }
    (mkIf (cfg.timer != null) {
      systemd.timers.talecast = {
        description = "Fetch podcast feeds";
        timerConfig = cfg.timer;
        wantedBy = [ "multi-user.target" ];
      };
    })


    (mkIf enableMoveService {
      systemd.paths.talecast-move = {
        description = "Move completed downloads";
        pathConfig.DirectoryNotEmpty = toString cfg.fetched_path;
      };

      systemd.services.talecast-move = {
        description = "Move completed downloads";
        serviceConfig = setUser {
          Type = "oneshot";
          RemainAfterExit = "no";
          ExecStart = "${pkgs.writeShellApplication {
            name = "talecast-move";
            text = builtins.readFile ./talecast-move.sh;
            runtimeInputs = with pkgs; [ bash coreutils rsync ];
            runtimeEnv = {
              DEST = toString cfg.destination;
              FETCHED = toString cfg.fetched_path;
            };
          }}/bin/talecast-move";
        };
      };
    })
  ]);
}

