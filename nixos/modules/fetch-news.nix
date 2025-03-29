{ config, lib, pkgs, ... }:
with rec {
  inherit (builtins) toString readFile;
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
  ;

  cfg = config.services.fetch-news;

  OPML = toString cfg.opml;
  FETCHED = toString cfg.fetched;
  PROCESSED = toString cfg.processed;
  MAILDIR = toString cfg.maildir;
  TEMP = toString cfg.temp;
};
{
  options.services.fetch-news = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable polling and fetching of youtube feeds.
      '';
    };

    timer = mkOption {
      example = {
        OnUnitActiveSec = "1h";
      };
      description = ''
        Attrset to use for polling feeds, used as the 'Timer' attribute of a
        systemd.timer. Note that subsequent processing, etc. is event-based, so
        doesn't require further polling.
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

    opml = mkOption {
      type = types.path;
      example = /home/alice/feeds.opml;
      description = ''
        OPML file describing the feeds we want to fetch.
      '';
    };

    dir = mkOption {
      type = types.path;
      description = ''
        Base directory to keep files in.
      '';
    };

    temp = mkOption {
      type = types.path;
      default = cfg.dir + "/temp";
      description = ''
        The feed reader will write files here that it's working on, before
        atomically moving them to their destination when finished.
      '';
    };

    fetched = mkOption {
      type = types.path;
      default = cfg.dir + "/fetched";
      description = ''
        The feed reader will put raw downloads in here.
      '';
    };

    processed = mkOption {
      type = types.path;
      default = cfg.dir + "/processed";
      description = ''
        Feeds will be put here after processing, e.g. populating articles.
      '';
    };

    maildir = mkOption {
      type = types.path;
      description = ''
        Destination for maildir entries.
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
            process-news-feeds = {
              description = "Process news feeds after they've been downloaded";
              pathConfig.DirectoryNotEmpty = FETCHED;
            };
            convert-news-feeds = {
              description = "Convert feeds to Maildir after processing";
              pathConfig.DirectoryNotEmpty = PROCESSED;
            };
          };
          timers = {
            fetch-news-feeds = {
              description = "Fetch news feeds periodically";
              timerConfig = cfg.timer;
              wantedBy = [ "multi-user.target" ];
            };
          };
          services = {
            fetch-news-feeds = {
              description = "Fetch news feeds";
              environment = {
                inherit FETCHED OPML TEMP;
              };
              serviceConfig = setUser {
                Type = "oneshot";
                RemainAfterExit = "no";
                ExecStart = "${pkgs.writeShellApplication {
                  name = "fetch-news";
                  runtimeInputs = [ pkgs.curl pkgs.xmlstarlet ];
                  text = readFile ./fetch-news.sh;
                }}/bin/fetch-news";
              };
            };

            process-news-feeds = {
              description = "Process raw feeds to be more readable.";
              environment = {
                inherit FETCHED PROCESSED TEMP;
              };
              serviceConfig = setUser {
                Type = "oneshot";
                RemainAfterExit = "no";
                ExecStart = "${pkgs.writeShellApplication {
                  name = "process-news";
                  runtimeEnv.UNSUMMARISE = "${./unsummarise.py}";
                  runtimeInputs = [
                    (pkgs.python3.withPackages (python3Packages: [
                      (pkgs.warbo-packages.morss.override {
                        inherit python3Packages;
                      }).lib
                    ]))
                  ];
                  text = readFile ./process-news.sh;
                }}/bin/process-news";
              };
            };

            convert-news-feeds = {
              description = "Convert news feeds to Maildir for reading.";
              environment = { inherit PROCESSED MAILDIR; };
              serviceConfig = setUser {
                Type = "oneshot";
                RemainAfterExit = "no";
                ExecStart = "${pkgs.writeShellApplication {
                  name = "convert-news";
                  runtimeInputs = [ pkgs.warbo-packages.feed2maildirsimple ];
                  text = readFile ./convert-news.sh;
                }}/bin/convert-news";
              };
            };
          };
        };
      }
    ]);
}
