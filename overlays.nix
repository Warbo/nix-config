# TODO: Make it easy to use these as overlays or via a NixOS module; whilst
# allowing individual picking-and-choosing.
with rec {
  inherit (builtins)
    attrNames
    attrValues
    concatLists
    filter
    foldl'
    getAttr
    map
    readDir
    ;
  inherit ((import nix-config-sources.nix-helpers { }).nixpkgs-lib)
    hasSuffix
    removeSuffix
    ;


  nix-config-sources = import ./nix/sources.nix;

  overlays = fromOverrides // {
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
            nix-helpers = super.nix-helpers or (overlays.repos self super).nix-helpers;
          };

      warbo-utilities =
        import (super.nix-config-sources or nix-config-sources).warbo-utilities
          {
            # Pick warbo-packages in the same way we chose a nix-helpers above.
            # The nix-helpers will get inherited, as will nixpkgs.
            warbo-packages =
              super.warbo-packages or (overlays.repos self super).warbo-packages;
          };
    };

  };

  fromOverrides =
    with rec {
      # Names of every ".nix" file in overrides/ (this must not depend on 'self')
      fileNames = map (removeSuffix ".nix") (
        filter (hasSuffix ".nix") (attrNames (readDir ./overrides))
      );

      mkDef =
        acc: f:
        with { this = import (./. + "/overrides/${f}.nix"); };
        acc
        // {
          "${f}" = self: super: (this self super).overrides;
          nix-config-checks = self: super: {
            nix-config-checks =
              (acc.nix-config-checks self super).nix-config-checks
              // ((this self super).checks or { });
          };
          nix-config-names = self: super: {
            nix-config-names =
              (acc.nix-config-names self super).nix-config-names
              ++ attrNames (this self super).overrides;
          };
          nix-config-tests = self: super: {
            nix-config-tests = (acc.nix-config-tests self super).nix-config-tests // {
              "${f}" = (this self super).tests or { };
            };
          };
        };
    };
    foldl' mkDef {
      nix-config-checks = self: super: { nix-config-checks = { }; };
      nix-config-names = self: super: {
        nix-config-names = [
          "nix-config-checks"
          "nix-config-tests"
        ];
      };
      nix-config-tests = self: super: { nix-config-tests = { }; };
      nix-config-check = self: super: {
        nix-config-check = foldl' (result: msg: trace msg false) true (
          concatLists (attrValues self.nix-config-checks)
        );
      };
    } fileNames;
};
overlays
