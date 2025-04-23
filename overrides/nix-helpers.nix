self: super: {
  overrides.nix-helpers =
    (super.warbo-packages
      or ((import ./warbo-packages.nix self super).overrides.warbo-packages)
    ).nix-helpers;
}
