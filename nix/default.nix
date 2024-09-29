with rec { inherit (import ../overrides/repos.nix overrides { }) overrides; };
overrides
// import overrides.nix-helpers.repoLatest {
  config = { };
  overlays = builtins.attrValues (import ../overlays.nix);
}
