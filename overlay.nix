self: super:

builtins.foldl' (acc: o: acc // o self super) { } (
  builtins.attrValues (import ./overlays.nix)
)
