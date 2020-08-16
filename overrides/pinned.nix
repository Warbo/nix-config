self: super: {
  overrides = {
    #inherit (import self.sources.niv {}) niv;
    niv = builtins.trace "FIXME: Use pinned niv"
      (import (fetchTarball {
        url = "https://github.com/nixos/nixpkgs-channels/archive/3506bce.tar.gz";
      }) { config = {}; overlays = []; }).niv;
  };
}
