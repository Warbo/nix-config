with builtins;
with rec {
  remotes       = import ./helpers.nix {};
  importOverlay = name: import "${getAttr name remotes}/overlay.nix";
};
map importOverlay [ "nix-helpers" "warbo-packages" "warbo-utilities" ] ++
    [ (import ./overlay.nix) ]
