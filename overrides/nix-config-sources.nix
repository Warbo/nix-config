self: super:
with {
  inherit (builtins) getAttr toJSON;
  inherit (self.nix-helpers) onlineCheck;
}; {
  overrides = { };
  checks =
    super.lib.genAttrs
      [
        "nix-helpers"
        "warbo-packages"
        "warbo-utilities"
      ]
      (
        name:
        with rec {
          src = getAttr name self.nix-config-sources;
          got = src.rev;
          want = self.nix-helpers.gitHead { url = src.repo; };
        };
        super.lib.optional (onlineCheck && (got != want)) (toJSON {
          inherit got name want;
          warning = "Pinned repo is out of date";
        })
      );
}
