self: super:

with builtins;
with super.lib;
with rec {
  combinedOverlays = super:
    fix (self: fold (overlay: old: old // overlay self super)
                    {}
                    (import ../overlays.nix));

  argsFor = name: if compareVersions name "repo1703" == -1
                     then { config = { packageOverrides = combinedOverlays; }; }
                     else { overlays = import ../overlays.nix; };
};
{
  overrides = {
    customised = listToAttrs
      (map (n: {
             name  = "nixpkgs" + removePrefix "repo" n;
             value = import (getAttr n self.pinnedNixpkgs) (argsFor n);
           })
           (filter (hasPrefix "repo") (attrNames self.pinnedNixpkgs)));
  };
  tests = {};
}
