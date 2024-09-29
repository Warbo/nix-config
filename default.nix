with {
  inherit (builtins) getAttr listToAttrs map;
  pkgs = import ./nix;
};
listToAttrs (
  map (name: {
    inherit name;
    value = getAttr name pkgs;
  }) pkgs.nix-config-names
)
