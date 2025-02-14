{ config, lib, pkgs, ... }:
with rec {
  inherit (builtins) attrValues mapAttrs toString;
  inherit (lib) mkIf mkOption types;

  cfg = config.services.talecast;

  configEntries = {
    inherit (cfg) download_path;
    partial_path = "${toString cfg.dir}/partial/{podname}";
  } // (if cfg ? download_hook then { inherit (cfg) download_hook; } else {}) //
  (cfg.extraConfig or {});

  configFile = (pkgs.formats.toml {}).generate "talecast" configEntries;
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

    download_path = mkOption {
      type = types.path;
      description = ''
        "Library" directory to download files into.
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

  config = mkIf cfg.enable {
    systemd = {
      timers =
        if (cfg.timer != null)
        then {
          talecast = {
            description = "Fetch podcast feeds";
            timerConfig = cfg.timer;
            wantedBy = [ "multi-user.target" ];
          };
        }
        else {};

      services.talecast = {
        description = "Fetch podcast feeds";
        serviceConfig = {
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
    };
  };
}

