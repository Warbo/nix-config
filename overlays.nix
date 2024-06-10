# TODO: Make it easy to use these as overlays or via a NixOS module; whilst
# allowing individual picking-and-choosing.
with rec {
  inherit (builtins) concatLists getAttr map;

  repo =
    name: self: super:
    removeAttrs (getAttr name (overlays.repos self super)) [
      "nixpkgs"
      "nix-helpers"
      "warbo-packages"
      "warbo-utilities"
      "super"
      "nix-config-sources"
    ];

  nix-config-sources = import ./nix/sources.nix;

  overlays = {
    # Provides our pinned sources
    sources = _: _: { inherit nix-config-sources; };

    # Imports some useful git repositories (overridable via nix-config-sources)
    repos = self: super: {
      nix-helpers =
        import (super.nix-config-sources or nix-config-sources).nix-helpers
          {
            # Use the nixpkgs set we're overlaying instead of its pinned default
            nixpkgs = super;
          };

      warbo-packages =
        import (super.nix-config-sources or nix-config-sources).warbo-packages
          {
            # Take nix-helpers from self, to allow subsequent overrides. If no
            # nix-helpers is being used, take the one from above.
            # Note that warbo-packages inherits nixpkgs from nix-helpers, so we
            # don't need to pass super along directly.
            nix-helpers =
              super.nix-helpers or (overlays.repos.nix-helpers self super).nix-helpers;
          };

      warbo-utilities =
        import (super.nix-config-sources or nix-config-sources).warbo-utilities
          {
            # Pick warbo-packages in the same way we chose a nix-helpers above.
            # The nix-helpers will get inherited, as will nixpkgs.
            warbo-packages =
              super.warbo-packages or (overlays.warbo-packages).warbo-packages;
          };
    };

    # These overlays merge those repo contents directly into pkgs. Avoid for now
    # since they can cause infinite recursion (since the attribute NAMES need to
    # be known up-front; e.g. if self.warbo-packages uses self.foo to generate
    # its attrset, Nix can't know whether that attrset will be overriding foo!)
    #nix-helpers = repo "nix-helpers";
    #warbo-packages = repo "warbo-packages";
    #warbo-utilities = repo "warbo-utilities";

    # Overlays defined in this repo
    # TODO: Avoid this indirection, so everything works the same
    rest = import ./overlay.nix;
  };
};
overlays
