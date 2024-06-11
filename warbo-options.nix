{ lib }:
with {
  inherit (lib) mkIf mkMerge mkOption types;
};
{
  enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
      Turn on custom "warbo" configuration.
    '';
  };

  professional = mkOption {
    type = types.bool;
    default = false;
    description = ''
      Stick to utilities (avoiding music players, torrent clients, etc.).
    '';
  };

  direnv = mkOption {
    type = types.bool;
    default = true;
    description = ''
      Enable direnv and nix-shell integration.
    '';
  };

  home-manager.stateVersion = mkOption {
    type = types.str;
    default = "24.05";  # Override as needed
    description = ''
      Passed along to user's Home Manager. Records the version of Home
      Manager that was originally installed, so future upgrades can apply
      any necessary fixes/workarounds to maintain compatibility.
    '';
  };
}
