with rec {
  inherit (builtins) concatLists getAttr map;
  getOverlay = name: self: super:
    import "${getAttr name super.nix-config-sources}/overlay.nix" self super;
};
concatLists [
  [ (self: _: { nix-config-sources = import ./nix/sources.nix; }) ]
  (map getOverlay [ "nix-helpers" "warbo-packages" "warbo-utilities" ])
  [ (import ./overlay.nix) ]
]
