self: super:
{
  overrides.nix-helpers = super.nix-helpers or
    (super.warbo-utilities.nix-helpers or
      (super.warbo-packages.nix-helpers or
        ((import ./warbo-packages.nix self super)
          .overrides.warbo-packages.nix-helpers)));
}
