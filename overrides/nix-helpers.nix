with {
  # If we've not got nix-helpers already, we'll get it from warbo-packages
  warbo-packages = self: super:
    (import ./warbo-packages.nix self super).overrides.warbo-packages;
};
self: super:
with rec {
  inherit (builtins) mapAttrs;

  # These are the definitions we want to use since they take dependencies from
  # self and hence use any overlays that are in effect. However, we can't use
  # them to get our attribute names, since that can cause infinite recursion.
  recursive = (warbo-packages self super).nix-helpers;

  # This avoids infinite recursion and hence can be used to get attribute names.
  # However, their values should be discarded since they ignore any overlays.
  nonrecursive = warbo-packages nixpkgs nixpkgs;

  # Override the default pinned nixpkgs with ours (if we have one), but don't
  # load any overlays in order to avoid infinite recursion.
  nixpkgs =
    if super ? path
    then import super.path { config = {}; overlays = []; }
    else {};
};
{
  overrides = super.nix-helpers or
    super.warbo-utilities.nix-helpers or
    super.warbo-packages.nix-helpers or
    (mapAttrs (n: _: recursive.${n}) nonrecursive);
}
