self: super: {
  overrides = {
    #inherit (import self.sources.niv {}) niv;
    niv = builtins.trace "FIXME: Use pinned niv"
      (import (fetchTarball {
        url = "https://github.com/nixos/nixpkgs-channels/archive/3506bce.tar.gz";
      }) { config = {}; overlays = []; }).niv;
  };

  checks =
    with {
      latestRev = name:
        with rec {
          src  = builtins.getAttr name self.sources;
          got  = src.rev;
          want = self.gitHead { url = src.repo; };
        };
        self.lib.optional (got != want) (builtins.toJSON {
          inherit got name want;
          warning = "Pinned repo is out of date";
        });
    };
    {
      nix-helpers = latestRev "nix-helpers";
      warbo-packages = latestRev "warbo-packages";
      warbo-utilities = latestRev "warbo-utilities";
    };
}
