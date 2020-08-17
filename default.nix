with builtins;
with { pkgs = import ./nix; };
listToAttrs (map (name: { inherit name; value = getAttr name pkgs; })
                 pkgs.nix-config-names)
