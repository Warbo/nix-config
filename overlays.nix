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
  inherit
    (
      with rec { inherit (import overrides/repos.nix overrides { }) overrides; };
      overrides.nix-helpers.nixpkgs-lib
    )
    hasSuffix
    removeSuffix
    ;

  overlays =
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
              "${f}" = ((this self super).tests or { }) // {
                recurseForDerivations = true;
              };
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
      nix-config-tests = self: super: {
        nix-config-tests = { recurseForDerivations = true; };
      };
      nix-config-check = self: super: {
        nix-config-check = foldl' (result: msg: trace msg false) true (
          concatLists (attrValues self.nix-config-checks)
        );
      };
    } fileNames;
};
overlays
