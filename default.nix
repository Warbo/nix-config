with builtins;
with { pkgs = import <nixpkgs> { overlays = import ./overlays.nix; }; };
listToAttrs (map (name: { inherit name; value = getAttr name pkgs; })
                 pkgs.customNames)
