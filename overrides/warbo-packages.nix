self: super:
{
  overrides.warbo-packages =
    super.warbo-packages or
      (super.warbo-utilities.warbo-packages or
        ((import ./warbo-utilities.nix self super)
        .overrides.warbo-utilities.warbo-packages));
}
