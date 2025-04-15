self: super:
{
  overrides.warbo-packages =
    (
      super.warbo-utilities or
        ((import ./warbo-utilities.nix self super).overrides.warbo-utilities)
    ).warbo-packages;
}
