with builtins;
with rec {
  remotes       = import ./helpers.nix {};
  importOverlay = name: import "${getAttr name remotes}/overlay.nix";
};
map importOverlay [ "nix-helpers" "warbo-packages" "warbo-utilities" ] ++ [
  (self: _: { sources = import ./nix/sources.nix; })
  (import ./overlay.nix)
]
