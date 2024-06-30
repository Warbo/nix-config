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
  };

  config = mkIf cfg.enable (mkMerge [
  ]);
}
