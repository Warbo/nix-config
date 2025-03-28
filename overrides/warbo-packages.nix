with {
  # If we've not got warbo-packages already, we'll get it from warbo-utilities.
  warbo-utilities = self: super:
    (import ./warbo-utilities.nix self super).overrides.warbo-utilities;
};
self: super:
with rec {
  inherit (builtins) mapAttrs;

  # These are the packages we want to use since they take dependencies from self
  # and hence use any overlays that are in effect. However, we can't use them to
  # get our attribute names, since that can cause infinite recursion.
  recursive = (warbo-utilities self super).warbo-packages;

  # This avoids infinite recursion and hence can be used to get attribute names.
  # However, their values should be discarded since they ignore any overlays.
  nonrecursive = (warbo-utilities nixpkgs nixpkgs).warbo-packages;

  # Override the default pinned nixpkgs with ours (if we have one), but don't
  # load any overlays in order to avoid infinite recursion.
  nixpkgs =
    if super ? path
    then import super.path { config = {}; overlays = []; }
    else {};
};
{
  overrides = super.warbo-packages or
    super.warbo-utilities.warbo-packages or
    (mapAttrs (n: _: recursive.${n}) nonrecursive);
}
