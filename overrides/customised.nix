self: super:

with rec {
  inherit (builtins)
    attrNames
    attrValues
    compareVersions
    filter
    fold
    getAttr
    listToAttrs
    ;
  inherit (super.lib) fix hasPrefix removePrefix;

  nix-helpers =
    self.nix-helpers
      or (rec { inherit (import ./repos.nix overrides super) overrides; })
      .overrides.nix-helpers;

  pinnedNixpkgs = self.pinnedNixpkgs or nix-helpers.pinnedNixpkgs;

  combinedOverlays =
    super:
    fix (
      self:
      fold (overlay: old: old // overlay self super) { } (import ../overlays.nix)
    );

  argsFor =
    name:
    if compareVersions name "repo1703" == -1 then
      {
        config = {
          packageOverrides = combinedOverlays;
        };
      }
    else
      { overlays = attrValues (import ../overlays.nix); };
}; {
  overrides = {
    customised = listToAttrs (
      map (n: {
        name = "nixpkgs" + removePrefix "repo" n;
        value = import (getAttr n pinnedNixpkgs) (argsFor n);
      }) (filter (hasPrefix "repo") (attrNames pinnedNixpkgs))
    );
  };
}
