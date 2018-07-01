self: super:

with builtins;
with super.lib;
{
  overrides = {
    customised = listToAttrs
      (map (n: {
             name  = "nixpkgs" + removePrefix "repo" n;
             value = import (getAttr n self.nixpkgs) {
               overlays = import ../overlays.nix;
             };
           })
           (filter (hasPrefix "repo") (attrNames self.nixpkgs)));
  };
  tests = {};
}
