self: super: {
  overrides = {
    nix-helpers =
      super.nix-helpers or (import ./nix-helpers.nix self (
        super
        // (if self ? warbo-packages then { inherit (self) warbo-packages; } else { })
      )).overrides.nix-helpers;

    warbo-packages =
      super.warbo-packages or (import ./warbo-packages.nix self (
        super
        // (if self ? warbo-utilities then { inherit (self) warbo-utilities; } else { })
      )).overrides.warbo-packages;

    warbo-utilities =
      super.warbo-utilities or (import ./warbo-utilities.nix self super)
      .overrides.warbo-utilities;
  };
}
