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
  };

  config = mkIf cfg.enable (mkMerge [
    systemd.user = {
      timers = {
        fetch-youtube-feeds = {
          Unit.Description = "Fetch Youtube feeds daily";
          Timer = cfg.timer;
        };
      };
    };
  ]);
}
